#Projeto Meliponini

#Pacotes para baixar
# Codes for installing package from CRAN:
install.packages("devtools")
install.packages("tidyverse")
install.packages("readr")
install.packages("countrycode")
install.packages("rangeBuilder")
install.packages("sf")
install.packages("terra")
install.packages("rworldmap")
install.packages("maps")
install.packages("ridigbio")
install.packages("rgbif")
install.packages("BIEN")
install.packages("rinat")

# Codes for installing package from GitHub:
devtools::install_github("idiv-biodiversity/LCVP")
devtools::install_github("idiv-biodiversity/lcvplants")
install.packages("rnaturalearthhires", repos = "http://packages.ropensci.org", type = "source")
devtools::install_github("ropensci/rnaturalearthdata")
devtools::install_github("ropensci/rgnparser")
rgnparser::install_gnparser()
# In case of trouble you can install gnparser see the help at  https://github.com/gnames/gnparser#install-with-homebrew

devtools::install_github("brunobrr/bdc")
devtools::install_github("liibre/rocc")
devtools::install_github("sjevelazco/flexsdm")
devtools::install_github("andrefaa/ENMTML")

# pacots para usar
devtools::install_github("liibre/Rocc")
library(Rocc)
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





# Baixar diretamente do SpeciesLink (https://specieslink.net/)


# Global Biodiversity Information Facility (https://www.gbif.org/)


# iDigBio (https://www.idigbio.org/)


# iNaturalist (https://www.inaturalist.org/)


# SibBr (https://www.sibbr.gov.br/).


# Salvar em formato csv

