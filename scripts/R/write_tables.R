#
# Write talbes in a SQLite database.
# Designed to work with ScraperWiki environments.
#
# Author: Luis Capelo | capelo@un.org
#

library(sqldf)


#
# Writes a data.frame to an SQLite databse.
# By default, it will write a scraperwiki.sqlite
# database in the root folder where the
# script was called.
#
writeTable <- function(df = NULL,
                       table_name = NULL,
                       db = 'scraperwiki',
                       testing = FALSE,
                       verbose = FALSE,
                       overwrite = FALSE) {
  
  #
  # Sanity check.
  #
  if(is.null(df) == TRUE) stop("Don't forget to provide a data.frame.")
  if(is.null(table_name) == TRUE) stop("Don't forget to provide a table name.")
  if(is.null(db) == TRUE) stop("Don't forget to provide a data base name.")

  if (verbose) message('Storing data in a database.')

  #
  # Create database and establish connection.
  #
  db_name <- paste0(db, ".sqlite")
  db <- dbConnect(SQLite(), dbname = db_name)

  #
  # Force overwrite.
  #
  if (overwrite == T) {
    dbWriteTable(db,
                 table_name,
                 df,
                 row.names = FALSE,
                 overwrite = TRUE)
  }
  
  #
  # Inserts new values.
  #
  else {
    dbWriteTable(db,
                 table_name,
                 df,
                 row.names = FALSE,
                 append = TRUE)
  }

  #
  # Perform tests at the time of usage.
  #
  if(testing == TRUE) {
    
    #
    # Test if table name is same
    # as provided.
    #
    if (table_name %in% dbListTables(db)) {
      message(paste('The table', table_name, 'is in the db.'))
    }

    #
    # Test if tables contain data.
    #
    loaded_data <- dbReadTable(db, table_name)
    if (is.data.frame(loaded_data) == TRUE) {
      message(paste('There is a table with', nrow(loaded_data), 'records. The head is:'))
      print(head(loaded_data, 5))
    }
  }
   
  #
  # Disconnect.
  #
  dbDisconnect(db)
  if (verbose) message('Done!')
}