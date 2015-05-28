#
# Scraper for UNOSAT public datasets.
# 
# This script will visit UNOSAT's public
# website and collect the metadata available.
# It will later organize that metadata in
# a HDX-friendly metadata format, storing
# the output in a series of JSON files.
#
# Author: Luis Capelo | capelo@un.org
#
#
# There is a conceptual problem with 'Horn of Africa': 
# at the moment 'Horn of Africa' is being turned into
# Somalia (SOM).
#
# Author: Luis Capelo | capelo@un.org
#


library(XML)
library(dplyr)
library(RCurl)
library(RJSONIO)
library(countrycode)

#
# ScraperWiki path-helper function.
#
onSw <- function(p = NULL, l = 'tool/', d = TRUE) {
  if(d) return(paste0(l, p))
  else return(p)
}


#
# Configuration variables. 
#
JSON_PATH = onSw("http/data.json")
CSV_PATH = onSw("http/data.csv")
DB_TABLE_NAME_ALL = "unosat_datasets_all"
DB_TABLE_NAME_SUBSET = "unosat_datasets_subset"
DATA_EXTENSIONS = c('.ZIP', '.KML', '.SHP', '.GDB', '.KMZ')
GALLERY_EXTENSIONS = c('.JPG', '.JPEG', '.PNG', '.PDF')

#
# Helper scripts.
#
source(onSw("scripts/R/helper.R"))
source(onSw("scripts/R/sw_status.R"))
source(onSw("scripts/R/read_tables.R"))
source(onSw("scripts/R/write_tables.R"))

cat('-------------------------------------\n')

#
# Collect and organize page links.
#
grabPageLinks <- function() {

  cat('Collecting product page URLs...')

  #
  # List of country URLs from config.
  #
  country_list <- read.csv(paste0(onSw(),'config/country_urls.csv'))
  country_list$country <- paste0('http://www.unitar.org', country_list$country)

  #
  # Iterate over the country URL list.
  #
  total = nrow(country_list)
  pb <- txtProgressBar(min = 0, max = total, char = ".", style = 3)
  for (i in 1:total) {
    
    #
    # Download HTML document using wget.
    #
    setTxtProgressBar(pb, i)
    url = country_list$country[i]
    download.file(url, onSw('data/temp.html'), method = 'wget', quiet = T)

    #
    # Parse the HTML document.
    #
    doc <- htmlParse(onSw('data/temp.html'))
    crisis_ids = xpathSApply(doc, '//*[@id="block-system-main"]/div/div/div/h3', xmlValue)
    country_name = gsub("Maps: ", "", xpathSApply(doc, '//*[@id="title-container"]/h1', xmlValue))
    for (j in 1:length(crisis_ids)) {

      #
      # Organize records based on crisis id.
      #
      crisis_it <- data.frame(
        country_name = country_name,
        crisis_id = xpathSApply(doc, paste0('//*[@id="block-system-main"]/div/div/div[',j,']/h3'), xmlValue),
        dataset_date = xpathSApply(doc, paste0('//*[@id="block-system-main"]/div/div/div[',j,']/ul/li/span[1]/span'), xmlValue),
        page_name = xpathSApply(doc, paste0('//*[@id="block-system-main"]/div/div/div[',j,']/ul/li/span[2]/span/a'), xmlValue),
        page_url = xpathSApply(doc, paste0('//*[@id="block-system-main"]/div/div/div[',j,']/ul/li/span[2]/span/a'), xmlGetAttr, 'href')
        )

        if (j == 1) crisis_out <- crisis_it
        else crisis_out <- rbind(crisis_out, crisis_it)
    }

    #
    # Assemble data.frame.
    #
    if (i == 1) out <- crisis_out
    else out <- rbind(out, crisis_out)
  }

  #
  # Format dates into ISO.
  #
  out$dataset_date <- as.character(as.Date(out$dataset_date, format="%d-%b-%Y"))
  cat('\nDone.\n')

  #
  # Done.
  #
  return(out)
}


#
# Collect and organize metadata
# from UNOSAT product pages.
#
fetchContent <- function(list_of_pages = NULL, verbose = F) {
  cat('Fetching content from UNOSAT pages...')

  #
  # Iterate over each product page.
  #
  total = nrow(list_of_pages)
  pb <- txtProgressBar(min = 0, max = total,  char = ".", style = 3)
  for (i in 1:total) {
    setTxtProgressBar(pb, i)
    
    #
    # This method effectively downloads the HTML page
    # from WFP locally and then proceeds to processing the page.
    # This approach isn't efficient, but deals solves the issue
    # that XPath for particular pages wasn't being generated.
    #
    url = as.character(list_of_pages$page_url[i])
    download.file(url = url, destfile = onSw('data/temp.html'), method = 'wget', quiet = T)
    doc <- htmlParse(paste0(onSw(),'data/temp.html'))

    # Debugging
    if (verbose) print(url)

    #
    # Determining where to find the description row.
    # That row can be always found 2 rows before the end of
    # the page (those two last rows are reserved for satellite
    # metadata).
    #
    d_row <- length(xpathSApply(doc, '//*[@id="node-44"]/div/div/div/div/table//tr')) - 2

    #
    # Data.frame schema and XPath locations.
    #
    it <- data.frame(
      page_url = url,
      title = ifelse(is.na(xpathSApply(doc, '//*[@id="title-container"]/h1', xmlValue)), NA, xpathSApply(doc, '//*[@id="title-container"]/h1', xmlValue)),
      img_url = ifelse(
          length(xpathSApply(doc, '//*[@id="node-44"]/div/div/div/div/table/tr[1]/td[2]/img', xmlGetAttr, 'src')) == 0, 
          NA,
          xpathSApply(doc, '//*[@id="node-44"]/div/div/div/div/table/tr[1]/td[2]/img', xmlGetAttr, 'src')
        ),
      url_1 = ifelse(is.na(xpathSApply(doc, '//*[@id="node-44"]/div/div/div/div/table//a', xmlGetAttr, 'href')), NA, xpathSApply(doc, '//*[@id="node-44"]/div/div/div/div/table//a', xmlGetAttr, 'href'))[1],
      url_2 = ifelse(is.na(xpathSApply(doc, '//*[@id="node-44"]/div/div/div/div/table//a', xmlGetAttr, 'href')), NA, xpathSApply(doc, '//*[@id="node-44"]/div/div/div/div/table//a', xmlGetAttr, 'href'))[2],
      url_3 = ifelse(is.na(xpathSApply(doc, '//*[@id="node-44"]/div/div/div/div/table//a', xmlGetAttr, 'href')), NA, xpathSApply(doc, '//*[@id="node-44"]/div/div/div/div/table//a', xmlGetAttr, 'href'))[3],
      url_4 = ifelse(is.na(xpathSApply(doc, '//*[@id="node-44"]/div/div/div/div/table//a', xmlGetAttr, 'href')), NA, xpathSApply(doc, '//*[@id="node-44"]/div/div/div/div/table//a', xmlGetAttr, 'href'))[4],
      url_5 = ifelse(is.na(xpathSApply(doc, '//*[@id="node-44"]/div/div/div/div/table//a', xmlGetAttr, 'href')), NA, xpathSApply(doc, '//*[@id="node-44"]/div/div/div/div/table//a', xmlGetAttr, 'href'))[5],
      url_6 = ifelse(is.na(xpathSApply(doc, '//*[@id="node-44"]/div/div/div/div/table//a', xmlGetAttr, 'href')), NA, xpathSApply(doc, '//*[@id="node-44"]/div/div/div/div/table//a', xmlGetAttr, 'href'))[6],
      n_product_links = as.numeric(length(xpathSApply(doc, '//*[@id="node-44"]/div/div/div/div/table//a', xmlGetAttr, 'href'))),
      notes = ifelse(
        is.na(
          xpathSApply(doc, paste0('//*[@id=\"node-44\"]/div/div/div/div/table/tr[', d_row, ']'), xmlValue)), 
          NA,
          xpathSApply(doc, paste0('//*[@id=\"node-44\"]/div/div/div/div/table/tr[', d_row, ']'), xmlValue)
        )
      )

    #
    # Merge every extraction into a data.frame.
    #
    if (i == 1) out <- it
    else out <- rbind(out, it)
  }

  #
  # Adding other previously collected attributes.
  #
  out <- merge(list_of_pages, out, by="page_url")
  return(out)
}

#
# Subset the product list with only the ones
# we are interested in registering on HDX.
#
subsetAndClean <- function(df=NULL,
                           add_tags=TRUE,
                           fix_crisis_id=FALSE,
                           improve_title=TRUE,
                           clean_duplicates=FALSE,
                           remove_keys=TRUE,
                           verbose=FALSE) {

  #
  # Identify data files.
  #
  df <- identifyDataFile(df, DATA_EXTENSIONS)

  #
  # Selecting only the datasets that have files
  # that matched the file extension. If any of the
  # attached files contains data it will be
  # considered a dataset.
  #
  df <- df[!is.na(df$url_2_format) | 
           !is.na(df$url_3_format) |
           !is.na(df$url_4_format) |
           !is.na(df$url_5_format) |
           !is.na(df$url_6_format) ,]
  
  if (verbose) print(paste("There are: ", nrow(df), "rows in the dataset this after selecting data only."))

  #
  # Creating the dataset name as per HDX.
  #
  df$dataset_name <- createDatasetName(df$title)

  #
  # Fixing all the glide numbers
  #
  if (fix_crisis_id) df$crisis_id <- fixCrisisId(df$crisis_id)
  
  #
  # Adding missing HDX metadata fields.
  #
  df <- addMetadata(df)

  #
  # Adding tags.
  #
  if (add_tags) {
    df$tag <- addCrisisTag(df$crisis_id)
    df <- addOtherTags(df, tags=c("geodata", "shapefile", "geodatabase"))
  }
  
  #
  # Creating file names.
  #
  df$file_name_1 <- extractFileNames(df$url_1)
  df$file_name_2 <- extractFileNames(df$url_2)
  df$file_name_3 <- extractFileNames(df$url_3)
  df$file_name_4 <- extractFileNames(df$url_4)
  df$file_name_5 <- extractFileNames(df$url_5)
  df$file_name_6 <- extractFileNames(df$url_6)
  
  #
  # Improving title.
  #
  if (improve_title) {
    df$title <- createTitleName(df$title)
  }
  
  #
  # Chosing the latest duplicate file (based on date).
  #
  if (clean_duplicates) {
    df <- cleanDuplicates(df)
  }
  
  #
  # Remove datasets by key.
  #
  if (remove_keys) {
    df <- findAndRemoveKey(df=df, keys=c('poster'))
  }
  
  #
  # Arrange dates.
  #
  df <- arrange(df, dataset_date)

  #
  # Output.
  #
  return(df)
}


#
# Wrapper.
#
runScraper <- function(p = NULL,
                       backup = FALSE,
                       table = NULL,
                       c = NULL,
                       csv = FALSE,
                       json = TRUE,
                       db = TRUE
                       ) {
  
  #
  # Download the page lists
  # and store in database.
  #
  page_list <- grabPageLinks()
  writeTable(page_list, 'page_list', overwrite=TRUE)
  
  #
  # Collect detailed metadata.
  #
  if (backup) {
    page_content <- readTable('page_content')
  }
  else {
    system.time(page_content <- fetchContent(page_list))
    writeTable(page_content, 'page_content')
  }
  
  #
  # Process data.
  #
  subset_of_interest <- subsetAndClean(page_content)
  
  #
  # Write CSV.
  #
  if (csv) write.csv(subset_of_interest, c, row.names = F)
  
  #
  # Write results in database.
  #
  if (db) {
    writeTable(subset_of_interest, table)
  }

  #
  # Create JSON files.
  #
  if (json) {
    
    #
    # Creating JSON in memory.
    #
    datasets_json <- createDatasetsJson(subset_of_interest)
    resources_json <- createResourcesJson(subset_of_interest)
    gallery_json <- createGalleryJson(subset_of_interest)
    
    #
    # Writing JSON files to disk.
    #
    jsons <- list(datasets_json, resources_json, gallery_json)
    for (i in 1:length(jsons)) {
      p = c("data/datasets.json", "data/resources.json", "data/gallery.json")
      sink(onSw(p[i]))
        cat(toJSON(jsons[i]))
      sink()
    }
  }
}


#
# ScraperWiki error handler.
#
tryCatch(runScraper(p = JSON_PATH, table = DB_TABLE_NAME_SUBSET, c = CSV_PATH),
         error = function(e) {
           cat('Error detected ... sending notification.')
           system('mail -s "UNOSAT Scraper: Data collection failed." luiscape@gmail.com')
           changeSwStatus(type = "error", message = "Scraper failed.")
           { stop("!!") }
         }
)

#
# Success.
#
changeSwStatus(type = 'ok')

cat('-------------------------------------\n')