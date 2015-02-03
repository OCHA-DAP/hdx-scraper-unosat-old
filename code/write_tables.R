## Write tables in a db. ##
library(sqldf)

writeTable <- function(df = NULL, 
                        table_name = NULL, 
                        db = NULL, 
                        testing = FALSE,
                        verbose = FALSE,
                        overwrite = FALSE) {
  # sanity check
  if (is.null(df) == TRUE) stop("Don't forget to provide a data.frame.")
  if(is.null(table_name) == TRUE) stop("Don't forget to provide a table name.")
  if(is.null(db) == TRUE) stop("Don't forget to provide a data base name.")
  
  if (verbose) message('Storing data in a database.')
  
  # creating db
  db_name <- paste0(db, ".sqlite")
  db <- dbConnect(SQLite(), dbname = db_name)
  
  # force overwrite
  if (overwrite == T) {
    dbWriteTable(db,
                 table_name,
                 df,
                 row.names = FALSE,
                 overwrite = TRUE)
  }
  
  else {
    # To insert new values
    dbWriteTable(db,
                 table_name,
                 df,
                 row.names = FALSE,
                 append = TRUE)
  }
  
  # testing mode
  if(testing == TRUE) {
    # testing for the correct table name
    if (table_name %in% dbListTables(db)) {
      message(paste('The table', table_name, 'is in the db.'))
    }
    
    # testing for the table with data
    # and sample data
    x <- dbReadTable(db, table_name)
    if (is.data.frame(x) == TRUE) { 
      message(paste('There is a table with', nrow(x), 'records. The head is:'))
      print(head(x, 5))
    }
  } 

  dbDisconnect(db)
  if (verbose) message('Done!')
}