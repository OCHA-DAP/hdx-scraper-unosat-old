#############################################
## Helper Functions for the UNOSAT scraper ##
#############################################

# Function to identify a file pattern
# selecting only those patterns of interest.
identifyDataFile <- function(data = NULL, pattern_vector = NULL, v = FALSE) {
  cat('Idenfying data files ...')
  
  # Creating the format variables.
  data$url_2_format <- NA
  data$url_3_format <- NA
  data$url_4_format <- NA
  data$url_5_format <- NA
  data$url_6_format <- NA
  
  findPattern <- function(df = NULL, pattern = NULL, verbose = v) {
    # Making sure it is a character.
    pattern <- as.character(pattern)
    m = paste("Searching for pattern", pattern, "\n")
    if (verbose) cat(m)

    # Finding matches.
    df$url_2_format <- ifelse(grepl(pattern, df$url_2, ignore.case = T), pattern, df$url_2_format)
    df$url_3_format <- ifelse(grepl(pattern, df$url_3, ignore.case = T), pattern, df$url_3_format)
    df$url_4_format <- ifelse(grepl(pattern, df$url_4, ignore.case = T), pattern, df$url_4_format)
    df$url_5_format <- ifelse(grepl(pattern, df$url_5, ignore.case = T), pattern, df$url_5_format)
    df$url_6_format <- ifelse(grepl(pattern, df$url_6, ignore.case = T), pattern, df$url_6_format)

    # Cleaning the periods.
    df$url_2_format <- as.character(gsub("\\.", "", df$url_2_format))
    df$url_3_format <- gsub("\\.", "", df$url_3_format)
    df$url_4_format <- gsub("\\.", "", df$url_4_format)
    df$url_5_format <- gsub("\\.", "", df$url_5_format)
    df$url_6_format <- gsub("\\.", "", df$url_6_format)

    return(df)
  }
  # Iterating over the file extensions
  # to identify any potential matches.
  for (i in 1:length(pattern_vector)) {
    data <- findPattern(df = data, pattern_vector[i])
  }
  cat('done.\n')
  return(data)
}

# Simple function to create a
# dataset name as per HDX.
createDatasetName <- function(vector = NULL) {
  cat('Creating the dataset id ...')
  dataset_name <- gsub(" ", "-", vector)
  dataset_name <- gsub("\\:", "", dataset_name)
  dataset_name <- gsub("\\,", "", dataset_name)
  dataset_name <- gsub("\\.", "", dataset_name)
  dataset_name <- gsub("\\(", "", dataset_name)
  dataset_name <- gsub("\\)", "", dataset_name)
  dataset_name <- tolower(dataset_name)
  dataset_name <- paste0("geodata-of-", dataset_name)
  cat('done.\n')
  return(dataset_name)
}

# Function to create a nice HDX title.
createTitleName <- function(vector = NULL) {
  cat('Creating the dataset name ...')
  title <- paste("Geodata of", vector)
  cat('done.\n')
  return(title)
}

# Algorithm to elimitate duplicates
# selecting the latest date only
cleanDuplicates <- function(df = NULL) {
  # Using dplyr to "chain" the transformation
  # of a data.frame.
  cat('Cleaning duplicates ...')
  df$dataset_date <- as.Date(df$dataset_date)
  df <- df %>%
    group_by(url_2) %>%
    filter(dataset_date == max(dataset_date)) %>%
    arrange(desc(dataset_date))
  df$dataset_date <- as.character(df$dataset_date)
  cat('done.\n')
  return(df)
}

# Extracting file names with regex
extractFileNames <- function(vector = NULL) {
  cat('Extracting file names ...')
  vector <- basename(as.character(vector))
  cat('done.\n')
  return(vector)
}

# Standardizing the glide number.
fixGlide <- function(vector = NULL) {
  cat('Fixing glide ...')
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
  cat('done.\n')
  return(vector)
}

# Function to add missing metadat on
# each of the dataset records.
addMetadata <- function(df = NULL) {
  cat('Adding metadata ...')

  # Adding schema elements.
  df$license_title = "hdx-other"
  df$author = "unosat"
  df$author_email = "emergencymapping@unosat.org"
  df$maintainer = "unosat"
  df$maintainer_email = "emergencymapping@unosat.org"
  df$package_creator = "unosat"
  df$private = TRUE
  df$methodology_other = NA
  df$caveats = NA
  df$license_other = NA
  df$methodology = "Other"
  df$dataset_source = "UNOSAT"
  df$license_id = "hdx-other"
  df$owner_org = "un-operational-satellite-appplications-programme-unosat"
  df$group_id <- countrycode(df$country_name, "country.name", "iso3c")
  df$group_id <- ifelse(df$country_name == 'Horn Of Africa', "SOM", df$group_id)  # This is wrong conceptually. Horn of Africa != SOM.
  df$group_id <- tolower(df$group_id)  # Country names have to be lower case.

  cat('done.\n')
  return(df)
}

# Adding tags based on glide numbers
addGlideTags <- function(vector = NULL) {
  cat('Adding tags based on Glide number ...')
  vector <- data.frame(code = substr(vector, 1, 2))
  glide_dictionary <- data.frame(code = c("FL","FR","VO","CE","TC","DR","EQ","AC","OT","RC"),
                                 name  = c('Flood', 'Fire', 'Vulcano', 'Complex Emergency', 'Tropical Storm', 'Drought', 'Earthquake', 'Munitions Depot Explosion', 'Refugee Camp', 'Complex Emergency'))
  glide_dictionary$name <- as.character(glide_dictionary$name)
  vector <- merge(vector, glide_dictionary, by.y="code", all.x = T)
  vector$code <- NULL
  cat('done.\n')
  return(vector$name)
}

addOtherTags <- function(df = NULL) {
  tags = c("geodata", "shapefile", "geodatabase")
  df$tag_1 = df$glide_id
  df$tag_2 = tags[1]
  df$tag_3 = tags[2]
  df$tag_4 = tags[3]
  return(df)
}



# Function to transform a UNOSAT data.frame
# into a CKAN / HDX dataset JSON object.
createDatasetsJson <- function(df = NULL) {
  cat('Creating CKAN JSON object ...')
  
  # Making all variables character -- and !factors.
  df <- data.frame(lapply(df, as.character), stringsAsFactors=FALSE)

  for (i in 1:nrow(df)) {
    with(df, 
         it <<- list(
            name = dataset_name[i],
            title = title[i],
            author = author[i],
            author_email = author_email[i],
            maintainer = maintainer[i],
            maintainer_email = maintainer_email[i],
            license_id = license_id[i],
            license_other = license_other[i],
            dataset_date = format(as.Date(dataset_date[i]), "%m/%d/%Y"),
            subnational = "1",
            notes = notes[i],
            dataset_source = dataset_source[i],
            package_creator = package_creator[i],
            private = TRUE,  # otherwise it will be public to the world
            url = NULL,
            state = "active",  # better don't touch this
            tags = list(
              list(name = tag[i]),
              list(name = tag_1[i]),
              list(name = tag_2[i]),
              list(name = tag_3[i]),
              list(name = tag_4[i])
              ),
            groups = list(
              list(
                # title = c(),
                # name = cd(),
                id = group_id[i]
                )
              ),
            owner_org = owner_org[i]
            )
    )
    if (i == 1) out <- it
    else out <- rbind(out, it)
  }
  # names(out) <- rep("dataset", length(out))
  cat('done.\n')
  return(out)
}



# Function to create resouces.
createResourcesJson <- function(df = NULL) {
  cat('Creating CKAN JSON object ...')
  
  # Making all variables character -- and !factors.
  df <- data.frame(lapply(df, as.character), stringsAsFactors=FALSE)
  
  for (i in 1:nrow(df)) {
      with(df, 
           it <<-
               list(
                package_id = dataset_name[i],
                url = url_2[i],
                name = file_name_2[i],
                format = url_2_format[i]
               ),
               list(
                package_id = dataset_name[i],
                url = url_3[i],
                name = file_name_3[i],
                format = url_3_format[i]
                ),
               list(
                 package_id = dataset_name[i],
                 url = url_4[i],
                 name = file_name_4[i],
                 format = url_4_format[i]
               ),
               list(
                 package_id = dataset_name[i],
                 url = url_5[i],
                 name = file_name_5[i],
                 format = url_5_format[i]
               ),
               list(
                 package_id = dataset_name[i],
                 url = url_6[i],
                 name = file_name_6[i],
                 format = url_6_format[i]
               )
      )
      
    if (i == 1) out <- it
    else out <- rbind(out, it)
  }
  # names(out) <- rep("dataset", length(out))
  cat('done.\n')
  return(out)
}


# Function to create gallery items.
createGalleryJson <- function(df = NULL) {
  cat('Creating CKAN JSON object ...')
  
  # Making all variables character -- and !factors.
  df <- data.frame(lapply(df, as.character), stringsAsFactors=FALSE)
  
  for (i in 1:nrow(df)) {
    with(df, 
         it <<- list(
             title = "Static PDF Map",
             type = "paper",
             description = "Static viewing map for printing.",
             url = url_1[i],
             image_url = img_url[i],
             dataset_id = dataset_name[i]
         )
    )
    if (i == 1) out <- it
    else out <- rbind(out, it)
  }
  # names(out) <- rep("dataset", length(out))
  cat('done.\n')
  return(out)
}



