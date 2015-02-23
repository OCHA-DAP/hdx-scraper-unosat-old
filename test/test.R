library(jsonlite)

# Function to transform a UNOSAT data.frame
# into a CKAN / HDX dataset JSON object.
createJSON <- function(df = NULL) {
  cat('Creating CKAN JSON object ...')
out <- c(
  name = "This is a name",
  title = "Title",
  author = "luiscape",
  author_email = "capelo@un.org",
  maintainer = "luiscape",
  maintainer_email = "capelo@un.org",
  license_id = "odb",
  license_other = "",
  notes = "There are plenty of notes that can happen here.",
  dataset_source = "UNOSAT",
  package_creator = "UNOSAT",
  private = TRUE,
  url = "http://test.example.website",
  state = "active",
  resources = c(
    package_id = c("xxx", "yyy", "zzz"),
    url = c("foo_url", "bar_url", "zed_url"),
    name = c("Foo", "Bar", "Zed"),
    format = c("SHP", "ZIP", "CSV")
    ),
  tags = c(
    name = c("Thing", "Thing Two", "Thing Three", "Example Thing")
    ),
  groups = c(
    title = c("Guinea", "United States", "Spain"),
    id = c("gne", "usa", "esp"),
    name = c("Guinea", "United States", "Spain")
    ),
  owner_org = "UNOSAT"
  )

  # names(out) <- rep("dataset", length(out))
  cat('done.\n')
  return(out)
}

x <- createJSON()
sink("test.json")
cat(toJSON(x))
sink()


