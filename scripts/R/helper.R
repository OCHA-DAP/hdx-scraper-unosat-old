#
# Helper / patch functions for the
# UNOSAT scraper.
#
# Author: Luis Capelo | capelo@un.org
#

#
# Identify a file extension
# and filter non-matches.
#
identifyDataFile <- function(data = NULL, pattern_vector = NULL, v = FALSE) {
  cat('Idenfying data files ...')
  
  #
  # Creating file format dimensions.
  #
  data$url_2_format <- NA
  data$url_3_format <- NA
  data$url_4_format <- NA
  data$url_5_format <- NA
  data$url_6_format <- NA
  
  #
  # Find file extension by pattern.
  #
  findPattern <- function(df = NULL, pattern = NULL, verbose = v) {
    
    #
    # Changing type to character.
    #
    pattern <- as.character(pattern)
    m = paste("Searching for pattern", pattern, "\n")
    if (verbose) cat(m)

    #
    # Find matches using regex.
    #
    df$url_2_format <- ifelse(grepl(pattern, df$url_2, ignore.case = T), pattern, df$url_2_format)
    df$url_3_format <- ifelse(grepl(pattern, df$url_3, ignore.case = T), pattern, df$url_3_format)
    df$url_4_format <- ifelse(grepl(pattern, df$url_4, ignore.case = T), pattern, df$url_4_format)
    df$url_5_format <- ifelse(grepl(pattern, df$url_5, ignore.case = T), pattern, df$url_5_format)
    df$url_6_format <- ifelse(grepl(pattern, df$url_6, ignore.case = T), pattern, df$url_6_format)

    #
    # Cleaning periods.
    #
    df$url_2_format <- as.character(gsub("\\.", "", df$url_2_format))
    df$url_3_format <- gsub("\\.", "", df$url_3_format)
    df$url_4_format <- gsub("\\.", "", df$url_4_format)
    df$url_5_format <- gsub("\\.", "", df$url_5_format)
    df$url_6_format <- gsub("\\.", "", df$url_6_format)

    return(df)
  }
  
  #
  # Iterating over the file extensions
  # to identify any potential matches.
  #
  for (i in 1:length(pattern_vector)) {
    data <- findPattern(df = data, pattern_vector[i])
  }
  
  #
  # From "SHP" to "ZIPPED SHAPEFILE" to use the
  # new geo-preview feature.
  #
  data$url_2_format <- ifelse(data$url_2_format == "SHP", "ZIPPED SHAPEFILE", data$url_2_format)
  data$url_3_format <- ifelse(data$url_3_format == "SHP", "ZIPPED SHAPEFILE", data$url_2_format)
  data$url_4_format <- ifelse(data$url_4_format == "SHP", "ZIPPED SHAPEFILE", data$url_2_format)
  data$url_5_format <- ifelse(data$url_5_format == "SHP", "ZIPPED SHAPEFILE", data$url_2_format)
  data$url_6_format <- ifelse(data$url_6_format == "SHP", "ZIPPED SHAPEFILE", data$url_2_format)
  
  cat('done.\n')
  return(data)
}

#
# Create dataset ID based on page name.
#
createDatasetIDs <- function(vector = NULL, remove_update=TRUE, date_vector=NULL, add_geodata=TRUE) {
  cat('Creating dataset ids ...')

  #
  # Remove special characters using regex.
  #
  dataset_name <- gsub("[[:punct:]]", "", vector)  # punctuation
  dataset_name <- gsub("[^[:alnum:]]", "", dataset_name)  # non alpha-numeric
  # dataset_name <- gsub("[[:alnum:]]", "", dataset_name)  # non alpha-numeric
  
  #
  # Adjust blank spaces.
  #
  dataset_name <- gsub(" ", "-", vector)
  dataset_name <- gsub("\\:", "", dataset_name)
  dataset_name <- gsub("\\,", "", dataset_name)
  dataset_name <- gsub("\\.", "", dataset_name)
  dataset_name <- gsub("\\(", "", dataset_name)
  dataset_name <- gsub("\\)", "", dataset_name)
  dataset_name <- gsub("---", "-", dataset_name)
  dataset_name <- tolower(dataset_name)
  dataset_name <- gsub("--", "-", dataset_name)
  dataset_name <- gsub("&", "", dataset_name)
  dataset_name <- gsub("'", "", dataset_name)
  
  #
  # Removing "update" from title.
  #
  if (remove_update) {
    dataset_name <- gsub("update", "", dataset_name, ignore.case = TRUE)
    dataset_name <- gsub("update:", "", dataset_name, ignore.case = TRUE)
    dataset_name <- gsub("update: ", "", dataset_name, ignore.case = TRUE)
    dataset_name <- gsub("update ", "", dataset_name, ignore.case = TRUE)
  }
  
  #
  # Adding geodata to id.
  #
  if (add_geodata) {
    dataset_name <- paste0("geodata-of-", dataset_name)
  }
  
  #
  # Patch: Trimming names to 90 characters.
  #
  dataset_name <- strtrim(dataset_name, 77)
  
  #
  # Adding date to id.
  #
  if (!is.null(date_vector)) {
    dataset_name <- paste0(dataset_name, tolower(format(as.Date(date_vector), "-%B-%d-%Y")))
  }
  
  #
  # Trimming double dashes
  #
  dataset_name <- gsub("--", "-", dataset_name)
  
  cat('done.\n')
  return(dataset_name)
}

#
# Function to create a nice HDX title.
#
createTitleName <- function(vector = NULL) {
  cat('Creating the dataset name ...')
  title <- paste("Geodata of", vector)
  cat('done.\n')
  return(title)
}

#
# Select only the latest entry for duplicates.
#
cleanDuplicates <- function(df = NULL) {
  
  #
  # Using dplyr to "chain" the transformation
  # of a data.frame.
  #
  cat('Cleaning duplicates ...')
  df$dataset_date <- as.Date(df$dataset_date)
  df <- df %>%
    group_by(dataset_name) %>%
    filter(dataset_date == max(dataset_date)) %>%
    arrange(desc(dataset_date))
  df$dataset_date <- as.character(df$dataset_date)
  cat('done.\n')
  return(df)
}

#
# Extracting file names with regex.
#
extractFileNames <- function(vector = NULL) {
  cat('Extracting file names ...')
  vector <- basename(as.character(vector))
  cat('done.\n')
  return(vector)
}

#
# Formatting the crisis id.
#
fixCrisisId <- function(vector = NULL) {
  cat('Fixing crisis id ...')
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

#
# Add default missing metadata to
# each dataset.
#
addMetadata <- function(df=NULL, is_private=TRUE) {
  cat('Adding metadata ...')

  #  
  # License
  #
  df$license_id = "hdx-other"
  df$license_title = "hdx-other"
  df$license_other = "Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License"

  #
  # Author and maintainer.
  #
  df$author = "unosat"
  df$author_email = "emergencymapping@unosat.org"
  df$maintainer = "unosat"
  df$maintainer_email = "emergencymapping@unosat.org"
  df$dataset_source = "UNOSAT"
  df$owner_org = "un-operational-satellite-appplications-programme-unosat"

  #
  # Organization id that created dataset.
  #
  df$package_creator = "unosat"

  #
  # Private attribute.
  #
  df$private = is_private

  #
  # Methodology and caveats.
  #
  df$methodology = "Other"
  df$methodology_other = "UNOSAT datasets and maps are produced using a variety of methods. In general, analysts closely review satellite imagery, often comparing two or more images together, and determine notable changes between the images. For damage assessments, refugee or IDP assessments, and similar analyses, these changes are then manually documented in the vector data by the analyst. For flood extractions, landcover mapping and similar analyses, a variety of automated remote sensing techniques are used to extract the relevant information which is then reviewed and revised as necessary by the analyst. In all cases, resulting data is then loaded into a standardized UNOSAT geodatabase and exported asshapefiles for dissemination."
  df$caveats = "This is a preliminary assessment and has not yet been validated in the field. It is important to consider the characteristics of the source imagery used in the analyses when interpreting results. For damage assessments it should be noted that only significant damage to the structural integrity of the buildings analyzed can be seen in imagery, while minor damage such as cracks or holes may not be visible at all. For flood extractions using radar data it is important to note that urban areas and highly vegetated areas may mask the flood signature and result in underestimation of flood waters. Users with specific questions or concerns should contact unosat@unitar.org to seek clarification."

  #
  # Countries.
  #
  df$group_id <- countrycode(df$country_name, "country.name", "iso3c")
  df$group_id <- ifelse(df$country_name == 'Horn Of Africa', "SOM", df$group_id)  # This is wrong conceptually. Horn of Africa != SOM.
  df$group_id <- tolower(df$group_id)  # Country names have to be lower case.

  cat('done.\n')
  return(df)
}


#
# Adding tags based on crisis ids.
#
addCrisisTag <- function(vector = NULL) {
  cat('Adding tags based on crisis id ...')

  #
  # Crisis code and description.
  #
  crisis_dictionary <- data.frame(
    code = c("FL","FR","VO","CE","TC","DR","EQ","AC","OT","RC","ST"),
    name = c('Flood', 'Fire', 'Vulcano', 'Complex Emergency', 'Tropical Storm', 'Drought', 'Earthquake', 'Munitions Depot Explosion', 'Other', 'Refugee Camp', 'Storm')
    )

  #
  # Make sure they are characters.
  #
  crisis_dictionary$code <- as.character(crisis_dictionary$code)
  crisis_dictionary$name <- as.character(crisis_dictionary$name)
  
  #
  # Split 2 first characeters of vector
  # and merge with dictionary.
  #
  vector <- data.frame(code = toupper(substr(vector, 1, 2)), id = 1:length(vector))
  vector <- merge(vector, crisis_dictionary, by="code", all.x=TRUE)
  vector <- arrange(vector, id)

  #
  # Done.
  #
  cat('done.\n')
  return(vector$name)
}

#
# Add ad-hoc tags.
#
addOtherTags <- function(df=NULL, tags=NULL) {
  cat('Adding extra tags ...')

  #
  # Sanity check.
  #
  if (is.null(tags)) {
    warn('No tags provided...')
    return(FALSE)
  }

  #
  # Iterating over tags.
  #
  df$tag_1 = df$crisis_id
  df$tag_2 = tags[1]
  df$tag_3 = tags[2]
  df$tag_4 = tags[3]
  
  #
  # Done.
  #
  cat('done.\n')
  return(df)
}

#
# Find and remove based on key.
#
findAndRemoveKey <- function(df=NULL, keys=NULL) {
  cat('Filtering keys ...')

  #
  # Sanity check.
  #
  if (is.null(keys)) {
    warn('No keys provided...')
    return(FALSE)
  }

  #
  # Iterating over every key.
  #
  for (i in 1:length(keys)) {
    found = grep(keys[i], df$title, ignore.case=TRUE)
    if (length(found) > 0) {
      df <- df[-found,] 
    }
  }
  
  #
  # Done.
  #
  cat('done.\n')
  return(df)
}

#
# Filter datasets from a certain date.
#
filterDatasetsByDate <- function(df=NULL, date='2014-01-01') {
  cat('Filtering dataset by date ...')
  df <- filter(df, as.Date(dataset_date) > as.Date(date))
  
  cat('done.\n')
  return(df)
}

#### JSON SERIALIZATION ####

#
# Function to transform a UNOSAT data.frame
# into a CKAN / HDX dataset JSON object.
#
createDatasetsJson <- function(df = NULL) {
  cat('Creating CKAN JSON object ...')
  
  #
  # Making all variables character -- and !factors.
  #
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
            dataset_date = format(as.Date(dataset_date[i]), "%m/%d/%Y"),  # HDX doesn't use ISO here.
            subnational = "1",
            notes = notes[i],
            caveats = caveats[i],
            dataset_source = dataset_source[i],
            package_creator = package_creator[i],
            private = FALSE,  # Public to the world?
            url = NULL,
            state = "active",  # Better don't touch this.
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



#
# Serializing resources.
#
createResourcesJson <- function(df = NULL) {
  cat('Creating CKAN JSON object ...')
  
  # Making all variables character -- and !factors.
  df <- data.frame(lapply(df, as.character), stringsAsFactors=FALSE)
  
  for (i in 1:nrow(df)) {
      with(df, 
           resource_1 <<-
             list(
               package_id = dataset_name[i],
               url = url_2[i],
               name = file_name_2[i],
               format = url_2_format[i]
             )
      )
      with(df, 
           resource_2 <<-
             list(
               package_id = dataset_name[i],
               url = url_3[i],
               name = file_name_3[i],
               format = url_3_format[i]
             )
      )
      with(df, 
           resource_3 <<-
             list(
               package_id = dataset_name[i],
               url = url_4[i],
               name = file_name_4[i],
               format = url_4_format[i]
             )
      )
      with(df, 
           resource_4 <<-
             list(
               package_id = dataset_name[i],
               url = url_5[i],
               name = file_name_5[i],
               format = url_5_format[i]
             )
      )
      
      it <- c(
        list(resource_1), 
        list(resource_2), 
        list(resource_3), 
        list(resource_4)
      )
      
      #
      # Filter resources without URL
      #
      # it <- filter(it, is.na(url) != TRUE)
      if (i == 1) out <- it
      else out <- c(out, it)
    }
  
  # names(out) <- rep("dataset", length(out))
  cat('done.\n')
  return(out)
}


#
# Serializing gallery items.
#
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

