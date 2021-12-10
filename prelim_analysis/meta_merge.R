## META MERGE: Merge mapping files from each dataset
setwd("~/Documents/amphibian_meta_project/meta_analysis/qiime_analyses/")
library(tidyverse)
abmap <- read.table(file = "AB_mapping_file.txt", sep = "\t", header = TRUE)
mgmap <- read.table(file = "MG_Mapping_File_GUA_with_Bd.txt",
                    sep = "\t", header = TRUE)
spimap <- read.table(file = "SPI_mapping_file.txt", sep = "\t", header = TRUE)
semap <- read.table(file = "SE_mapping_file.txt", sep = "\t", header = TRUE)

## FORMAT COLUMNS ------
names(abmap)[names(abmap) == "Habitat_Type"] <- "Habitat"
abmap <- select(abmap, -c(Sample_Type, Higher_Clade))
mgmap <- select(mgmap, -c(LinkerPrimerSequence, ReversePrimer, BarcodeSequence,
                          Sex, Age_Class, Geology, Site, Mountain_range,
                          Collector_number, ZE, Log_ZE, Elevation, Description,
                          Date, Country))
spimap <- select(spimap, -c(LinkerPrimerSequence, ReversePrimer,
                            BarcodeSequence, project1, project2, type, age,
                            sex, cov.obj, soil.moist, soil.temp, cov.wd,
                            cov.lth, date, Description, svl, tot.lgth, wgt))
semap <- select(semap, -c(Sample_Name, month, frog_location, extraction_date,
                          BarcodeSequence, year, frog_id, survey_date,
                          frog_weight, Description, LinkerPrimerSequence,
                          lifestage, ZE, pit_tag_id, frog_svl, ReversePrimer,
                          gosner_stage, frog_sex, swabber_name, site_id))
names(mgmap)[names(mgmap) == "County_Municipio"] <- "Site"
names(spimap)[names(spimap) == "county"] <- "Site"
names(spimap)[names(spimap) == "lat"] <- "Latitude"
names(spimap)[names(spimap) == "long"] <- "Longitude"
names(abmap)[names(abmap) == "Lower_Clade"] <- "subspecies"
names(mgmap)[names(mgmap) == "Bd_Status"] <- "Bd_status"
mgmap$State_Region <- "Central America"
mgmap <- mgmap[-c(78:82), ]
mgmap$Latitude <- as.numeric(mgmap$Latitude)
mgmap$Longitude <- as.numeric(mgmap$Longitude)
abmap$Dataset <- as.character("Bird et al., 2018", quote = FALSE)
mgmap$Dataset <- as.character("Ellison et al., 2018", quote = FALSE)
semap$Dataset <- as.character("Ellison et al., 2019", quote = FALSE)
spimap$Dataset <- as.character("Prado-Irwin et al., 2017", quote = FALSE)

## TAXONOMY & BD ------
abmap$Family <- "Plethodontidae"
abmap$Order <- "Salamander"
spimap$Family <- "Plethodontidae"
spimap$Order <- "Salamander"
spimap$Genus <- "Ensatina"
spimap$Species <- "Ensatina_eschscholtzii"
semap$Species <- "Rana_sierrae"
semap$Genus <- "Rana"
semap$Family <- "Ranidae"
semap$Order <- "Frog"
for (i in seq_len(nrow(mgmap))) {
  if (mgmap$Order[i] == "Caudata") {
    mgmap$Order[i] <- "Salamander"
  } else if (mgmap$Order[i] == "Anura") {
      mgmap$Order[i] <- "Frog"
  }
}

# BD
abmap$Bd_status <- 0
for (i in seq_len(nrow(mgmap))) {
         if (mgmap$Bd_status[i] == "Negative") {
             mgmap$Bd_status[i] <- 0
         } else {
             mgmap$Bd_status[i] <- 1
         }
}
mgmap$Bd_status <- as.numeric(mgmap$Bd_status)
for (i in which(!is.na(semap$Bd_status) == TRUE)) {
         if (semap$Bd_status[i] == "Negative") {
             semap$Bd_status[i] <- 0
         } else if (semap$Bd_status[i] == "Positive") {
             semap$Bd_status[i] <- 1
         }
}
semap$Bd_status <- as.numeric(semap$Bd_status)

## DIVIDE CALIFORNIA INTO FOUR REGIONS ------
abmap$State_Region <- 0
for (i in seq_len(nrow(abmap))) {
  if (abmap$Site[i] == "Alameda" || abmap$Site[i] == "Monterey") {
    abmap$State_Region[i] <- "Coastal California"
  } else if (abmap$Site[i] == "Jackson_State_Forest" ||
             abmap$Site[i] == "Siskiyou" || abmap$Site == "Shasta" ||
             abmap$Site[i] == "Humboldt" ||
             abmap$Site[i] == "Leggett") {
    abmap$State_Region[i] <- "Northern California"
  } else if (abmap$Site[i] == "Sierra_National_Forest") {
    abmap$State_Region[i] <- "Sierra Nevada"
  } else {
    abmap$State_Region[i] <- "Southern California"
  }
}
spimap$State_Region <- 0
for (i in seq_len(nrow(spimap))) {
  if (spimap$Site[i] == "Alameda" || spimap$Site[i] ==
      "Santa.Cruz" || spimap$pop[i] == "north.bay") {
    spimap$State_Region[i] <- "Coastal California"
  } else if (spimap$Site[i] == "Madera") {
    spimap$State_Region[i] <- "Sierra Nevada"
  } else if (spimap$pop[i] == "annadel") {
    spimap$State_Region[i] <- "Northern California"
  } else {
    spimap$State_Region[i] <- "Southern California"
  }
}
semap$State_Region <- "Sierra Nevada"

## GPS & COUNTY DATA ------
for (i in seq_len(nrow(semap))) {
    if (i < 32) {
        semap$Latitude[i] <- 38.934
        semap$Longitude[i] <- -120.1475
    } else if (32 < i & i < 64) {
        semap$Latitude[i] <- 38.38841
        semap$Longitude[i] <- -120.1595
    } else if (64 < i & i < 96) {
        semap$Latitude[i] <- 38.402
        semap$Longitude[i] <- -120.1602
    } else {
        semap$Latitude[i] <- 39.008395
        semap$Longitude[i] <- -120.21257
    }
}

#County
library(maps)
semap$Site <- map.where(database = "county",
                    semap$Longitude, semap$Latitude)
abmap$Site <- map.where(database = "county",
                    abmap$Longitude, abmap$Latitude)
semap$Site <- sub("...........", "", semap$Site)
abmap$Site <- sub("...........", "", abmap$Site)

## JOIN & EXPORT TABLES ------
meta_1 <- full_join(semap, mgmap, by = c("SampleID", "Bd_status",
                                         "State_Region", "Site", "Dataset",
                                         "Longitude", "Latitude",
                                         "Family", "Genus", "Species",
                                         "Order"), copy = TRUE)
meta_2 <- full_join(abmap, spimap, by = c("SampleID", "Genus", "Species",
                                          "Family", "Order", "Site", "Dataset",
                                          "Latitude", "Longitude", "subspecies",
                                           "State_Region"), copy = TRUE)
meta_3 <- full_join(meta_1, meta_2, by = c("SampleID", "Genus", "Species",
                                           "Family", "Order", "subspecies",
                                           "Habitat", "State_Region", "Dataset",
                                           "Latitude",
                                           "Longitude", "Site", "Bd_status"),
                    copy = TRUE)
write.table(meta_3, file = "merged_metadata.txt", append = FALSE, sep = "\t",
            row.names = FALSE, quote = FALSE, col.names = TRUE)
