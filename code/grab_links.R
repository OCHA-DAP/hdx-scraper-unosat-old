## Grab Links
#  Script to grab links from UNOSAT's publicly
#  available data.

# Dependencies
library(RCurl)
library(XML)

# Scraperwiki helper function
onSw <- function(d = F, l = 'tool/') {
  if(d) return(l)
  else return("")
}

# Loading helper functions
source(paste0(onSe(), "code/write_tables.R"))
source(paste0(onSe(), "code/sw_status.R"))


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
    download.file(url, 'data/temp.html', method = 'wget', quite = T)
    doc <- htmlParse('data/temp.html')
    
    # query and parse
    # grab links and assemble data.frame
    glide_ids = xpathSApply(doc, '//*[@id="block-system-main"]/div/div/div/h3', xmlValue)
    country_name = gsub("Maps: ", "", xpathSApply(doc, '//*[@id="title-container"]/h1', xmlValue))
    for (j in 1:length(glide_ids)) {
      glide_it <- data.frame(
        country_name = country_name,
        glide_id = xpathSApply(doc, paste0('//*[@id="block-system-main"]/div/div/div[',j,']/h3'), xmlValue),
        map_date = xpathSApply(doc, paste0('//*[@id="block-system-main"]/div/div/div[',j,']/ul/li/span[1]/span'), xmlValue),
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

page_list <- grabPageLinks()
write.csv(x, 'data/page_list.csv', row.names = F)
