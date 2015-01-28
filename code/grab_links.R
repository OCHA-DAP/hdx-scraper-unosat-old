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

# Scraperwiki helper function
onSw <- function(d = F, l = 'tool/') {
  if(d) return(l)
  else return("")
}

# Loading helper functions
# source(paste0(onSw(), "code/write_tables.R"))
# source(paste0(onSw(), "code/sw_status.R"))


# Grabbing links scraper
grabPageLinks <- function() {
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

  return(out)
}

# Grabbing content from each of the product pages.
fetchContent <- function(list_of_pages = NULL, verbose = F) {
  
  total = nrow(list_of_pages)
  pb <- txtProgressBar(min = 0, max = total,  char = ".", style = 3)
  for (i in 1:total) {
    setTxtProgressBar(pb, i)
    url = list_of_pages$page_url[i]
    download.file(url, 'data/temp.html', method = 'wget', quiet = T)
    doc <- htmlParse(paste0(onSw(),'data/temp.html'))
    if (verbose) print(url)
    
    # Determining where to find the description row.
    d_row <- length(xpathSApply(doc, '//*[@id="node-44"]/div/div/div/div/table//tr')) - 2
    
    # Data.frame schema and XPath commands.
    it <- data.frame(
      page_url = url,
      title = ifelse(is.na(xpathSApply(doc, '//*[@id="title-container"]/h1', xmlValue)), NA, xpathSApply(doc, '//*[@id="title-container"]/h1', xmlValue)),
      img_url = ifelse(
          length(xpathSApply(doc, '//*[@id="node-44"]/div/div/div/div/table/tr[1]/td[2]/img', xmlGetAttr, 'src')) == 0, 
          NA, 
          xpathSApply(doc, '//*[@id="node-44"]/div/div/div/div/table/tr[1]/td[2]/img', xmlGetAttr, 'src')
        ),
      url_1 = ifelse(is.na(xpathSApply(doc, '//*[@id="node-44"]/div/div/div/div/table//a', xmlGetAttr, 'href')), NA, xpathSApply(doc, '//*[@id="node-44"]/div/div/div/div/table//a', xmlGetAttr, 'href')[1]),
      url_2 = ifelse(is.na(xpathSApply(doc, '//*[@id="node-44"]/div/div/div/div/table//a', xmlGetAttr, 'href')), NA, xpathSApply(doc, '//*[@id="node-44"]/div/div/div/div/table//a', xmlGetAttr, 'href')[2]),
      url_3 = ifelse(is.na(xpathSApply(doc, '//*[@id="node-44"]/div/div/div/div/table//a', xmlGetAttr, 'href')), NA, xpathSApply(doc, '//*[@id="node-44"]/div/div/div/div/table//a', xmlGetAttr, 'href')[3]),
      url_4 = ifelse(is.na(xpathSApply(doc, '//*[@id="node-44"]/div/div/div/div/table//a', xmlGetAttr, 'href')), NA, xpathSApply(doc, '//*[@id="node-44"]/div/div/div/div/table//a', xmlGetAttr, 'href')[4]),
      url_5 = ifelse(is.na(xpathSApply(doc, '//*[@id="node-44"]/div/div/div/div/table//a', xmlGetAttr, 'href')), NA, xpathSApply(doc, '//*[@id="node-44"]/div/div/div/div/table//a', xmlGetAttr, 'href')[5]),
      url_6 = ifelse(is.na(xpathSApply(doc, '//*[@id="node-44"]/div/div/div/div/table//a', xmlGetAttr, 'href')), NA, xpathSApply(doc, '//*[@id="node-44"]/div/div/div/div/table//a', xmlGetAttr, 'href')[6]),
      n_product_links = length(xpathSApply(doc, '//*[@id="node-44"]/div/div/div/div/table//a', xmlGetAttr, 'href')),
      notes = ifelse(
        is.na(
          xpathSApply(doc, paste0('//*[@id=\"node-44\"]/div/div/div/div/table/tr[', d_row, ']'), xmlValue)), 
          NA, 
          xpathSApply(doc, paste0('//*[@id=\"node-44\"]/div/div/div/div/table/tr[', d_row, ']'), xmlValue)
        )
      )
    
    if (i == 1) out <- it
    else out <- rbind(out, it)
  }
  
  # precaution
  write.csv(out, 'test.csv', row.names = F)
  
  return(out)
}

lookForData <- function(df = NULL, subset = TRUE) {
  # extensions of interest
  data_extensions <- c('.zip', '.kml', '.shp', '.gdp', '.kmz')
  gallery_extensions <- c('.jpg', '.jpeg', '.png', '.pdf')
  
  # creating the variable
  df$file_format <- NA
  
  # shp_url column
  lookForPattern <- function(data = NULL, pattern = NULL) {
    data$url_1 <- data
    data$file_format <- ifelse(grepl(pattern, data$gdp_url, ignore.case = T), pattern, data$file_format)
    data$file_format <- ifelse(grepl(pattern, data$shp_url, ignore.case = T), pattern, data$file_format)
    return(data)
  }
  
  # Iterating over the 
  for (i in 1:length(data_extensions)) {
    df <- lookForPattern(df, data_extensions[i])
  }
  
  # preparing output
  output <- df
  
  # subsetting only those of interest
  if (subset) output <- output[!is.na(output$file_format),]
  
  # Adding schema elements.
  output$license_title = "hdx-other"
  output$maintainer = "unosat"
  output$package_creator = "unosat"
  output$private = TRUE
  output$methodology_other = NA
  output$caveats = NA
  output$license_other = NA
  output$methodology = "Other"
  output$dataset_source = "UNOSAT"
  output$license_id = "hdx-other"
  output$owner_org = "un-operational-satellite-appplications-programme-unosat"
  output$file_format <- toupper(sub("\\.", "", output$file_format))
  output$group_id <- countrycode(output$country_name, "country.name", "iso3c")
  output$group_id <- ifelse(output$country_name == 'Horn Of Africa', "SOM", output$iso)  # this is wrong conceptually
  
  # dataset name
  # "name": "ebola-cases-2014"
  
  # standardizing the glide number
  fixGlide <- function(vector = NULL) {
    vector <- as.character(vector)
    s = '-'
    w = c(3, 8, 13)
    vector_subset = vector != 'Other' & !grepl("-", vector)
    for (i in 1:length(w)) {
      vector <- ifelse(
        vector_subset,
        paste0(substr(vector, 1, w[i]-1), s, substr(vector, w[i], nchar(vector))),
        vector
        )
    }
    return(vector)
  }
  
  # fixing all the glide numbers
  output$glide_id <- fixGlide(output$glide_id)

  # output
  return(output)
}

# adding tags based on glide numbers
addTags <- function(vector = NULL) {
  vector <- data.frame(code = substr(vector, 1, 2))
  glide_dictionary <- data.frame(code = c("FL","FR","VO","CE","TC","DR","EQ","AC","OT","RC"),
                                 name  = c('Flood', 'Fire', 'Vulcano', 'Complex Emergency', 'Tropical Storm', 'Drought', 'Earthquake', 'Munitions Depot Explosion', 'Refugee Camp', 'Complex Emergency'))
  vector <- merge(vector, glide_dictionary, by.y="code", all.x = T)
  return(vector$name)
}

runScraper <- function(csv = F) {
  page_list <- grabPageLinks()  # grabbing links from pages
  content <- fetchContent(page_list)  # fetching the content from pages
  subset_of_interest <- lookForData(content)  #
  subset_of_interest$tag <- addTags(subset_of_interest$glide_id)
  if (csv) write.csv(subset_of_interest, 'data/subset_of_interest.csv', row.names = F)
}

# runScraper(T)
