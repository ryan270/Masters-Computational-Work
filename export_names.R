###CREATE TABLE FOR ALL DATA INFORMATION


#-------------------------------------#
##LOAD DATA & LIBRAIRES
# Load Files & Library
library(tidyverse)
setwd('~/Documents/amphibian_meta_project/meta_analysis/qiime_analyses/')
ampm <- read.table(file = 'merged_metadata.txt', sep = "\t", header = TRUE)


#-------------------------------------#
##PREP DATA FOR EACH REGION
# Create vectors for Sample sizes & Species
# SE Dataset
se <- unique(ampm$Dataset)[1]
se_spp <- 'Rana_sierrae'
se_reg <- unique(ampm$State_Region)[1]
se_sam <- length(which(ampm$Dataset == se))

# MG Dataset
mg <- unique(ampm$Dataset)[2]
mg_spp <- unique(ampm$Species[which(ampm$Dataset == mg)])
mg_reg <- unique(ampm$State_Region)[2]
mg_sam <- NULL
for(i in mg_spp){
    ph <- length(which(ampm$Species == i))
    mg_sam <- c(mg_sam, ph)
}

# SPI Dataset
spi <- unique(ampm$Dataset)[4]
spi_spp <- unique(ampm$Species[which(ampm$Dataset == spi)])
spi_reg <- unique(ampm$State_Region[which(ampm$Dataset == spi)])

# Get samples sizes of ab dataset for each region
spi_sam <- numeric()
for(i in 1:4){
    ph <- length(which(ampm$Species == spi_spp &
                       ampm$State_Region == spi_reg[i]))
    spi_sam <- c(spi_sam, ph)
}

# AB Dataset
ab <- unique(ampm$Dataset)[3]
ab_spp <- unique(ampm$Species[which(ampm$Dataset == ab)])
ab_reg <- unique(ampm$State_Region[which(ampm$Dataset == ab)])

# Get samples sizes of ab dataset for each region
# Change this line to get samples per region for dataset
length(which(ampm$Species == ab_spp[4] & ampm$State_Region == ab_reg[4]))

# Write to dataframe
ab_sam <-data.frame(Species = c(ab_spp[1], ab_spp[1], ab_spp[2], ab_spp[3],
                                ab_spp[4], ab_spp[4], ab_spp[4], ab_spp[4]),
                    Region = c(ab_reg[1], ab_reg[2], ab_reg[3], ab_reg[1],
                               ab_reg[1], ab_reg[2], ab_reg[3], ab_reg[4]),
                    N = c(5, 15, 4, 8, 42, 61, 13, 51),
                    Paper = ab)


#-------------------------------------#
## WRITE & FORMAT TABLE
# Create Table SE & MG Table
Info_Table <- data.frame(Species = c(se_spp, mg_spp, rep(spi_spp, 4)),
                         Paper = c(se, rep(mg, 15), rep(spi, 4)),
                         Region = c(se_reg, rep(mg_reg, 15), spi_reg),
                         N = c(se_sam, mg_sam, spi_sam))

# Bind other Dataframes
Info_Table <- rbind(Info_Table, ab_sam)

# Remove Extra Variables
rm(ab, ab_reg, ab_sam, ab_spp, mg, mg_reg, mg_sam, mg_spp, ph, se, se_reg,
   se_sam, se_spp, spi, spi_reg, spi_sam, spi_spp)

# Remove Underscore from species
for(i in 1:nrow(Info_Table)){
    Info_Table$Species[i] <- gsub('_', ' ', Info_Table$Species[i])
}

# Order by Dataset
Info_Table <- Info_Table[order(Info_Table$Paper),]

# Add Common Names
common_names <- c('California Slender Salamander',
                  'California Slender Salamander',
                  'Gregarious Slender Salamander',
                  'Santa Lucia Mountains Slender Salamander',
                  'Ensatina Salamanders', 'Ensatina Salamanders',
                  'Ensatina Salamanders', 'Ensatina Salamanders',
                  'Tropical Lungless Salamanders',
                  'Royal False Brook Salamander', 'Neotropical Salamanders',
                  'Spikethumb Frogs', 'Spikethumb Frogs',
                  'Guatemalan Bromeliad Salamander',
                  'Climbing Salamander Hybrid', 'Volcan Tacana Toad',
                  'Sierra Nevada Yellow-Legged Frog',
                  'Tropical Lungless Salamanders',
                  "Franklin's Climbin Salamander", 'Spikethumb Frogs',
                  'Brittle-belly Frogs',  'Spikethumb Frogs',
                  'Neotropical Salamander', 'Brittle-belly Frogs',
                  'Ensatina Salamanders', 'Ensatina Salamanders',
                  'Ensatina Salamanders', 'Ensatina Salamanders')

Info_Table$Common_Names <- common_names

# Reorder columns
Info_Table <- Info_Table[,c('Species', 'Common_Names', 'Paper', 'Region', 'N')]
Info_Table <- Info_Table[order(Info_Table$Region),]


#-------------------------------------#
## EXPORT
write.table(Info_Table, file = '~/Documents/amphibian_meta_project/Data_Info.txt',
          row.names = FALSE, col.names = TRUE, sep = "\t", quote = FALSE)
