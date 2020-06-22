library(natserv)
library(httr)
library(data.table)
library(stringr)

# Readinging Caspio Code for Contacting API
source("caspioFunctions.R")
source("Tokens/caspioSource.R")

## Reading in Datasets to Use
# Read in CPC Rare Taxon Table
cpc <- caspio_get_view_all("RareTaxonTblNoLists")


## Getting G2 Values
g2Can <- ns_search_comb(status="G2", location=list(nation="CA"),record_type="species",page=0,per_page=20)
pageNum <- g2Can$resultsSummary$value[[3]]
g2CanResults <- subset((g2Can$results),select=c(elementGlobalId,scientificName,primaryCommonName,roundedGRank,speciesGlobal))
g2CanResults$speciesGlobal <- g2CanResults$speciesGlobal$informalTaxonomy

for(i in 1:pageNum-1){
  g2temp <- ns_search_comb(status="G2", location=list(nation="CA"),record_type="species",page=0+i,per_page=20)
  g2tempResults<- subset((g2temp$results),select=c(elementGlobalId,scientificName,primaryCommonName,roundedGRank,speciesGlobal))
  g2tempResults$speciesGlobal <- g2tempResults$speciesGlobal$informalTaxonomy
  g2CanResults <- rbind(g2CanResults,g2tempResults)
}

## Getting G1 Values
g1Can <- ns_search_comb(status="G1", location=list(nation="CA"),record_type="species",page=0,per_page=20)
pageNum <- g1Can$resultsSummary$value[[3]]
g1CanResults <- subset((g1Can$results),select=c(elementGlobalId,scientificName,primaryCommonName,roundedGRank,speciesGlobal))
g1CanResults$speciesGlobal <- g1CanResults$speciesGlobal$informalTaxonomy

for(i in 1:pageNum-1){
  g1temp <- ns_search_comb(status="G1", location=list(nation="CA"),record_type="species",page=0+i,per_page=20)
  g1tempResults<- subset((g1temp$results),select=c(elementGlobalId,scientificName,primaryCommonName,roundedGRank,speciesGlobal))
  g1tempResults$speciesGlobal <- g1tempResults$speciesGlobal$informalTaxonomy
  g1CanResults <- rbind(g1CanResults,g1tempResults)
}

# Combining G2 & G2
globallyRareCan <- as.data.table(rbind(g1CanResults, g2CanResults))

# Filtering by just plants
globallyRarePlants <- subset(globallyRareCan,grepl("Vascular Plants",speciesGlobal))


# 

write.csv(globallyRarePlants,"Data/globallyRarePlants_NatureServec.csv")

