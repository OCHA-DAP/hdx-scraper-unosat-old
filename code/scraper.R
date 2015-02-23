## Grab Links
#  Script to grab links from UNOSAT's publicly
#  available data.

# There is a conceptual problem with 'Horn of Africa': 
# at the moment 'Horn of Africa' is being turned into
# Somalia (SOM).

# Dependencies
library(RCurl)
library(XML)
library(countrycode)
library(dplyr)
library(RJSONIO)

# Scraperwiki helper function
onSw <- function(p = NULL, l = 'tool/', d = F) {
  if(d) return(paste0(l, p))
  else return(p)
}

#####################
### Configuration ###
#####################
JSON_PATH = onSw("http/data.json")
CSV_PATH = onSw("http/data.csv")
DB_TABLE_NAME_ALL = "unosat_datasets_all"
DB_TABLE_NAME_SUBSET = "unosat_datasets_subset"
DATA_EXTENSIONS = c('.ZIP', '.KML', '.SHP', '.GDB', '.KMZ')
GALLERY_EXTENSIONS = c('.JPG', '.JPEG', '.PNG', '.PDF')

# Loading helper functions
source(onSw("code/write_tables.R"))
source(onSw("code/sw_status.R"))
source(onSw("code/helper.R"))

cat('-------------------------------------\n')

# Grabbing links scraper
grabPageLinks <- function() {
  cat('Collecting product page URLs...')
  country_list <- read.csv(paste0(onSw(),'data/country_urls.csv'))
  country_list$country <- paste0('http://www.unitar.org', country_list$country)
  total = nrow(country_list)
  pb <- txtProgressBar(min = 0, max = total, char = ".", style = 3)
  for (i in 1:total) {
    # getting the html
    setTxtProgressBar(pb, i)
    url = country_list$country[i]
    download.file(url, 'data/temp.html', method = 'wget', quiet = T)
    doc <- htmlParse('data/temp.html')

    # query and parse
    # grab links and assemble data.frame
    glide_ids = xpathSApply(doc, '//*[@id="block-system-main"]/div/div/div/h3', xmlValue)
    country_name = gsub("Maps: ", "", xpathSApply(doc, '//*[@id="title-container"]/h1', xmlValue))
    for (j in 1:length(glide_ids)) {
      glide_it <- data.frame(
        country_name = country_name,
        glide_id = xpathSApply(doc, paste0('//*[@id="block-system-main"]/div/div/div[',j,']/h3'), xmlValue),
        dataset_date = xpathSApply(doc, paste0('//*[@id="block-system-main"]/div/div/div[',j,']/ul/li/span[1]/span'), xmlValue),
        page_name = xpathSApply(doc, paste0('//*[@id="block-system-main"]/div/div/div[',j,']/ul/li/span[2]/span/a'), xmlValue),
        page_url = xpathSApply(doc, paste0('//*[@id="block-system-main"]/div/div/div[',j,']/ul/li/span[2]/span/a'), xmlGetAttr, 'href')
        )

        if (j == 1) glide_out <- glide_it
        else glide_out <- rbind(glide_out, glide_it)
    }

    # assembling the overrall data.frame
    if (i == 1) out <- glide_out
    else out <- rbind(out, glide_out)
  }

  # Adjusting dates.
  out$dataset_date <- as.character(as.Date(out$dataset_date, format="%d-%b-%Y"))
  cat('\nDone.\n')

  # Returning
  return(out)
}

# Function that collects relevant metadata from
# UNOSAT's drupal-based website.
fetchContent <- function(list_of_pages = NULL, verbose = F) {
  cat('Fetching content from UNOSAT pages...')
  total = nrow(list_of_pages)
  pb <- txtProgressBar(min = 0, max = total,  char = ".", style = 3)
  for (i in 1:total) {
    setTxtProgressBar(pb, i)

    # This method effectively downloads the HTML page
    # from WFP locally and then proceeds to processing the page.
    # This approach isn't efficient, but deals solves the issue
    # that XPath for particular pages wasn't being generated.
    url = list_of_pages$page_url[i]
    download.file(url, 'data/temp.html', method = 'wget', quiet = T)
    doc <- htmlParse(paste0(onSw(),'data/temp.html'))

    # Debugging
    if (verbose) print(url)

    # Determining where to find the description row.
    # That row can be always found 2 rows before the end of
    # the page (those two last rows are reserved for satellite
    # metadata).
    d_row <- length(xpathSApply(doc, '//*[@id="node-44"]/div/div/div/div/table//tr')) - 2

    # Data.frame schema and XPath locations.
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

    # Merging every extraction
    # into a data.frame.
    if (i == 1) out <- it
    else out <- rbind(out, it)
  }

  # Adding other previously collected attributes.
  out <- merge(list_of_pages, out, by="page_url")
  return(out)
}

# Once we collect all the attributes
subsetAndClean <- function(df = NULL, verbose = FALSE) {

  # Identifying the patterns.
  df <- identifyDataFile(df, DATA_EXTENSIONS)

  # Selecting only the datasets that have files
  # that matched the file extension. If any of the
  # attached files contains data it will be
  # considered a dataset.
  df <- df[!is.na(df$url_2_format) | 
           !is.na(df$url_3_format) |
           !is.na(df$url_4_format) |
           !is.na(df$url_5_format) |
           !is.na(df$url_6_format) ,]
  
  if (verbose) print(paste("There are: ", nrow(df), "rows in the dataset this after selecting data only."))

  # Creating the dataset name as per HDX.
  df$dataset_name <- createDatasetName(df$title)

  # Fixing all the glide numbers
  df$glide_id <- fixGlide(df$glide_id)

  # Adding missing HDX metadata fields.
  df <- addMetadata(df)

  # Adding tags.
  df$tag <- addGlideTags(df$glide_id)
  df <- addOtherTags(df)
  
  # Creating file names
  df$file_name_1 <- extractFileNames(df$url_1)
  df$file_name_2 <- extractFileNames(df$url_2)
  df$file_name_3 <- extractFileNames(df$url_3)
  df$file_name_4 <- extractFileNames(df$url_4)
  df$file_name_5 <- extractFileNames(df$url_5)
  df$file_name_6 <- extractFileNames(df$url_6)
  
  # Improving title
  df$title <- createTitleName(df$title)
  
  # Chosing the latest duplicate file (based on date).
  df <- cleanDuplicates(df)

  # Output
  return(df)
}


############################################
############################################
########### ScraperWiki Logic ##############
############################################
############################################

# Scraper wrapper.
runScraper <- function(p = NULL, table = NULL, key = NULL, c = NULL, csv = TRUE, json = TRUE, db = TRUE) {
  page_list <- grabPageLinks()
  system.time(page_content <- fetchContent(page_list))
  subset_of_interest <- subsetAndClean(page_content)

   # Storing results in a CSV file.
  if (csv) write.csv(subset_of_interest, onSw(c), row.names = F)

  # Storing results in a JSON file.
  if (json) {
    json_data <- createJSON(subset_of_interest)
    sink(onSw(p))
    cat(toJSON(json_data))
    sink()
  }

  # Storing results in a SQLite database.
  if (db) {
    writeTable(subset_of_interest, table, "scraperwiki")
  }
}

# Changing the status of SW.
tryCatch(runScraper(p = JSON_PATH, table = DB_TABLE_NAME_SUBSET, key = apikey, c = CSV_PATH),
         error = function(e) {
           cat('Error detected ... sending notification.')
           system('mail -s "CKAN Statistics: Organization list failed." luiscape@gmail.com')
           changeSwStatus(type = "error", message = "Scraper failed.")
           { stop("!!") }
         }
)

# If success:
changeSwStatus(type = 'ok')

cat('-------------------------------------\n')