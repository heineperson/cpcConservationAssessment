# Loading Packages
library(httr)
library(data.table)
library(stringr)

# Readinging Caspio Code for Contacting API
source("caspioFunctions.R")
source("Tokens/caspioSource.R")

## Reading in Datasets to Use
# Read in CPC Rare Taxon Table
cpc <- caspio_get_view_all("RareTaxonTblNoLists")
# Read in CaPR Accessions
capr <-  caspio_get_view_all("caprViewNoLists")
# Read in CaPR Spp
jep <- caspio_get_table_all("tblSpeciesJepCAPR")
# Read in the File that Ruby created that lists which CaPR species need CPC Numbers (or have other issues)
rubyList <- fread("Data/caprs_cpc_diff_1.csv")


# END GOAL - Creating a file that cleanly lists a CPCNumber for all JepIDs for species with rank 1B in CNPS rare plant inventory

