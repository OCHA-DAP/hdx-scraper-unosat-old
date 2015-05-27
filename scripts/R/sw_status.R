#
# Manipulate the status
# of ScraperWiki boxes.
#
# Author: Luis Capelo | capelo@un.org

library(RCurl)

#
# Change status.
#
changeSwStatus <- function(type = NULL, message = NULL, verbose = F) {

  #
  # Handle messages.
  #
  if (!is.null(message)) { content = paste("type=", type, "&message=", message, sep="") }
  else content = paste("type=", type, sep="")
  curlPerform(postfields = content, url = 'https://scraperwiki.com/api/status', post = 1L)
  
  #
  # Print response from ScraperWiki.
  #
  if (verbose == T) {
    cat(content)
  }
}
