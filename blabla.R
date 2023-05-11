## %######################################################%##
#                                                          #
####            Downloading, integrating, and           ####
####           cleaning occurrence databases            ####
#                                                          #
## %######################################################%##

# Codes for installing package from GitHub:
# install.packages("devtools")
# devtools::install_github("idiv-biodiversity/LCVP")
# install.packages("rnaturalearthhires", repos = "http://packages.ropensci.org", type = "source")
# devtools::install_github("ropensci/rnaturalearthdata")
# devtools::install_github("ropensci/rgnparser")
# rgnparser::install_gnparser()
# In case of trouble you can install gnparser see the help at  https://github.com/gnames/gnparser#install-with-homebrew
# devtools::install_github("brunobrr/bdc")
# devtools::install_github("liibre/Rocc")
# devtools::install_github("sjevelazco/flexsdm")

# install.packages("rworldmap")
# install.packages("countrycode")
# install.packages("rangeBuilder")

###### Packages
require(sdm)
require(tidyr)
require(dplyr) # Manipulate data
require(readr) # Read and write data
require(ridigbio) # Download data from iDigBio
require(rgbif) # Download data from GBIF
require(rinat) # Download data from inaturaList
require(Rocc) # Download data from speciesLink


# Despite bdc is available on CRAN for this class we advice to install the development version
# available on GitHub (installed above)
require(bdc) # Biodiversity data cleaning https://brunobrr.github.io/bdc/index.html
require(ggplot2) # Plot data
require(sf) # For handling spatial data
require(maps) # A spatial database of country boundaries



## %######################################################%##
#                                                          #
####                    Species list                    ####
#                                                          #
## %######################################################%##

spp <- readxl::read_xlsx("EspeciesScanBug.xlsx", sheet = 1)
spp %>% dplyr::pull(1)
spp <- spp %>% dplyr::pull(1)

getwd()
dirs <- file.path(getwd(), "raw_data")
dirs
dir.create(dirs) # Function for creating the directory where each dataset will be saved



## %######################################################%##
#                                                          #
####            Downloading occurrences data            ####
####               from different sources               ####
#                                                          #
## %######################################################%##

## %######################################################%##
#                                                          #
####                       GBIF                         ####
#                                                          #
## %######################################################%##
# https://www.gbif.org
# https://docs.ropensci.org/rgbif/index.html
# https://vimeo.com/127119010
# rgbif::gbif_issues() %>% tibble() %>% View()
# Read more about GBIF issues and gbif_issues() function for performing some extra data.cleaning


occ_list <- list() # an empty list
for (i in seq_along(spp)) {
  message(paste(i, Sys.time()))
  occ_list[[i]] <-
    rgbif::occ_data(
      scientificName = spp[i],
      hasCoordinate = TRUE,
      hasGeospatialIssue = FALSE, # Without spatial issues
      limit = 20000
    )
  names(occ_list)[i] <- spp[i]
}
class(occ_list[[1]]) # it's a gbif_data not a data.frame or tibble

# Let's extract the tibble (a kind of data.frame) object for each species
for (i in seq_along(occ_list)) {
  occ_list[[i]] <- occ_list[[i]]$data
}


# let's merge these tibbles
occ_list <- dplyr::bind_rows(occ_list, .id = "search_name")
names(occ_list)

occ_list <- occ_list %>% dplyr::select(-networkKeys)

readr::write_csv(occ_list, file.path(dirs, "GBIF.csv")) # save as csv



## %######################################################%##
#                                                          #
####                      iDigBio                       ####
#                                                          #
## %######################################################%##
# https://www.idigbio.org/portal/search

occ_list <- list()
for (i in seq_along(spp)) {
  message(paste(i, Sys.time()))
  occ_list[[i]] <-
    ridigbio::idig_search_records(rq = list(scientificname = spp[i]), limit = 100000) %>%
      tibble()
  names(occ_list)[i] <- spp[i]
}

occ_list <- occ_list[sapply(occ_list, function(x) nrow((x))) > 0] # this line is only for removing
occ_list <- dplyr::bind_rows(occ_list, .id = "search_name")


# Extract year from date collected
occ_list$datecollected <- lubridate::ymd(occ_list$datecollected) # 57 failed to parse
occ_list$year <- lubridate::year(occ_list$datecollected)

readr::write_csv(occ_list, file.path(dirs, "IDIGBIO.csv")) # save as csv



## %######################################################%##
#                                                          #
####                    iNaturalist                     ####
#                                                          #
## %######################################################%##
# https://www.inaturalist.org

occ_list <- list()
for (i in seq_along(spp)) {
  message(paste(i, Sys.time()))
  try(res <- rinat::get_inat_obs(query = spp[i], quality = "research", geo = TRUE, maxresults = 10000))
  try(res <- res %>% dplyr::filter(iconic_taxon_name == "Animalia") %>% as_tibble())
  try(occ_list[[i]] <- res)
  try(rm(res))
  names(occ_list)[i] <- spp[i]
} # Don't worry about these try() just catch the errors and continue the loop

occ_list <- occ_list[names(unlist(sapply(occ_list, nrow)))] # Checking rinat ouptut for valid species output and filtering out NA

occ_list <- dplyr::bind_rows(occ_list, .id = "search_name") %>% as_tibble()

# Extract year from date collected
# occ_list$year <- lubridate::year(occ_list$datetime)
readr::write_csv(occ_list, file.path(dirs, "INATURALIST.csv")) # save as csv


## %######################################################%##
#                                                          #
####                    SpeciesLink                     ####
#                                                          #
## %######################################################%##
# https://specieslink.net
# More interesting for Brazil and other countries of South America

occ_list <- list()
for (i in seq_along(spp)) {
  occ_list[[i]] <- rspeciesLink(
    species = spp[i],
    basisOfRecord = NULL,
    Scope = "Animals",
    save = FALSE,
    Coordinates = "Yes",
    CoordinatesQuality = "Good"
  ) %>%
    tibble()
  names(occ_list)[i] <- spp[i]
}
#IGNORE THIS MESSAGE: Output is empty. Check your request.

occ_list <- dplyr::bind_rows(occ_list, .id = "search_name")
occ_list$datecollected <- paste(occ_list$year, occ_list$month, occ_list$day, sep = "-")
occ_list$datecollected <- lubridate::ymd(occ_list$datecollected)

readr::write_csv(occ_list, file.path(dirs, "SPECIESLINK.csv")) # save as csv



## %######################################################%##
## %######################################################%##
## %######################################################%##
## %######################################################%##
## %######################################################%##
#                                                          #
####               Using bdc package for                ####
####   integrating and cleaning occurrences datasets    ####
#                                                          #
## %######################################################%##
## %######################################################%##
## %######################################################%##
## %######################################################%##
## %######################################################%##





##%######################################################%##
#                                                          #
####        bdc: Integrating different databases         ####
#                                                          #
##%######################################################%##
dirs <- file.path(getwd(), "raw_data_AparatrigonaImpuctata")
dirs

### First copy and paste the "DatabaseInfo.txt" our "configuration table" in the raw_data folder ###

# Read the configuration table
metadata <- readr::read_tsv(file.path(dirs, "DatabaseInfo.txt"), show_col_types = FALSE)

# Let's list different database
list_db <- list.files(dirs, pattern = ".csv", full.names = TRUE)
nms <- list_db %>%
  basename() %>%
  gsub(".csv", "", .)
names(list_db) <- nms
list_db <- dplyr::tibble(datasetName = names(list_db), fileName = list_db)
list_db



# Correct the fileName (path file)
metadata$fileName <- NULL

# Merge databases
metadata <- dplyr::left_join(list_db, metadata, by = "datasetName")

# Standarize datasets
database <-
  bdc::bdc_standardize_datasets(
    metadata = metadata,
    format = "csv",
    overwrite = TRUE,
    save_database = TRUE
  )


# bdc_standardize_datasets created a system of folders in "Documents"
# So, the merged database in is:
# C:/Users/santi/Documents/Output/Intermediate/00_merged_database.csv
# use this function: readr::write_csv(database, FILE PATH)




##%######################################################%##
#                                                          #
####     Some data exploration to convince you why      ####
####     it is important to clean up your database      ####
#                                                          #
##%######################################################%##

# Let's read this and explore this database
dirs <- file.path(getwd(), "raw_data_AparatrigonaImpuctata")
dir2 <- file.path(dirname(dirs), "Output/Intermediate/00_merged_database.csv")
database <- readr::read_csv(dir2, show_col_types = FALSE)
database

# Names used for searching occurrences
database$searchName %>% unique()

# Names returned by different databases
database$scientificName %>%
  unique() %>%
  sort()

# Names of the countries
database$country %>%
  unique() %>%
  sort()

# Years
ggplot(database, aes(year)) + geom_histogram() + theme_bw()
table(!is.na(database$year)) # many data not have year and other are very old

# Patterns of occurrences
w <- sf::st_as_sf(map("world", plot = FALSE, fill = TRUE))
ggplot(w) +
  geom_sf() +
  geom_hex(data = database, aes(decimalLongitude, decimalLatitude), binwidth = c(4, 4)) +
  scale_fill_viridis_c() +
  theme_bw() +
  theme(legend.position = "bottom")


# Keep 00_merged_database.csv file because it will be use in the 02_occ_data_cleaning.R
