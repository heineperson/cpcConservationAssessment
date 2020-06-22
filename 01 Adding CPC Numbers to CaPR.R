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

# Evaluating jepson list
jep[!is.na(CPCNumber),.(name_minus_authors,JepID,CPCNumber)]
jep[is.na(CPCNumber) & (grepl("1B",CRPR)|NATURESERVE_ID!=""),.(name_minus_authors,JepID,CPCNumber,NATURESERVE_ID,CRPR)]

# Add a column marking which needs CPC Num
jep[,needsCPCNum:=ifelse(is.na(CPCNumber) & (grepl("1B",CRPR)|NATURESERVE_ID!=""),"Yes","No")]
jep[needsCPCNum=="Yes",.(name_minus_authors,JepID,CPCNumber,NATURESERVE_ID,CRPR)]
jepNeeds <- jep[needsCPCNum=="Yes"]

# Merge on CPC Numbers from NatureServeIDs
jepNeeds <- merge(jepNeeds,cpc[tblRareTaxonTable_NATURESERVE_ID!="",.(CPCNumber_fromNat = tblRareTaxonTable_CPCNumber, NATURESERVE_ID=tblRareTaxonTable_NATURESERVE_ID)],by="NATURESERVE_ID",all.x=T)

# Look at what remains
jepNeeds[needsCPCNum=="Yes" & is.na(CPCNumber_fromNat),.(name_minus_authors,JepID,CPCNumber,NATURESERVE_ID,CRPR)]

# Try direct name cross walk from CPC database
jepNeeds[,name_minus_authors:=gsub("subsp.","ssp.",name_minus_authors,fixed=T)]
jepNeeds <- merge(jepNeeds, cpc[,.(CPCNumber_fromCPC=tblRareTaxonTable_CPCNumber, name_minus_authors=tblRareTaxonTable_Taxon)],by="name_minus_authors",all.x=T)


# look at CPC New
jepNeeds[,CPCNew:=ifelse(needsCPCNum=="Yes" & !is.na(CPCNumber_fromNat), CPCNumber_fromNat,CPCNumber_fromCPC)]


# Merge on Ruby's notes
jepNeeds=merge(jepNeeds, rubyList[,.(JepID,in_cpc)],by="JepID",all.x=T)
jepNeeds[!is.na(in_cpc) & is.na(CPCNew) ,.(name_minus_authors,JepID,CPCNew, in_cpc)]

# Marking manual things
jepNeeds[name_minus_authors=="Draba incrassata",CPCNew:=1468]
jepNeeds[name_minus_authors=="Erigeron greenei",CPCNew:=46383]
jepNeeds[name_minus_authors=="Galium angustifolium ssp. onycense",CPCNew:=48105]
jepNeeds[name_minus_authors=="Bensoniella oregona",CPCNew:=548]
jepNeeds[name_minus_authors=="Boechera rigidissima",CPCNew:=13104]
jepNeeds[name_minus_authors=="Sabulina decumbens",CPCNew:=2863]
jepNeeds[name_minus_authors=="Sabulina howellii",CPCNew:=8466]
jepNeeds[name_minus_authors=="Sabulina stolonifera",CPCNew:=44516]
jepNeeds[name_minus_authors=="Erythranthe inflatula",CPCNew:=44579]
jepNeeds[name_minus_authors=="Greeneocharis circumscissa var. rosulata",CPCNew:=47024]
jepNeeds[name_minus_authors=="Lupinus albifrons var. medius",CPCNew:=2710]
jepNeeds[name_minus_authors=="Oreocarya roosiorum",CPCNew:=1135]
jepNeeds[name_minus_authors=="Boechera rigidissima var. demota",CPCNew:=8299]
jepNeeds[name_minus_authors=="Clarkia mildrediae ssp. mildrediae",CPCNew:=8821]
jepNeeds[name_minus_authors=="Lomatium ravenii var. ravenii",CPCNew:=2676]

jepNeeds[!is.na(in_cpc) & is.na(CPCNew) ,CPCNew1:=.I+48107]




# END GOAL - Creating a file that cleanly lists a CPCNumber for all JepIDs for species with rank 1B in CNPS rare plant inventory

