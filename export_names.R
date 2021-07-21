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
se_d <- data.frame(Paper = 'Ellison et al., 2018',
                   Species = 'Rana Sierrae',
                   Region = 'Sierra Nevada',
                   N = 130)

# MG Dataset
mg_spp <- unique(ampm$Species[which(ampm$Dataset == 'Ellison et al., 2017')])
mg_sam <- NULL
for(i in mg_spp){
    ph <- length(which(ampm$Species == i))
    mg_sam <- c(mg_sam, ph)
}
mg_d <- data.frame(Paper = 'Ellison et al., 2017',
                   Species = mg_spp,
                   Region = 'Central America',
                   N = mg_sam)

# SPI Dataset
spi_reg <- unique(ampm$State_Region[which(ampm$Dataset ==
                                          'Prado-Irwin et al., 2017')])

# Get samples sizes of ab dataset for each region
spi_sam <- numeric()
for(i in 1:4){
    ph <- length(which(ampm$Species == 'Ensatina_eschscholtzii' &
                       ampm$State_Region == spi_reg[i] &
                       ampm$Dataset == 'Prado-Irwin et al., 2017'))
    spi_sam <- c(spi_sam, ph)
}

spi_d <- data.frame(Paper = 'Prado-Irwin et al., 2017',
                    Species = 'Ensatina eschscholtzii',
                    Region = spi_reg,
                    N = spi_sam)


# AB Dataset
ab_spp <- unique(ampm$Species[which(ampm$Dataset ==
                                    'Bird et al., 2018')])
ab_reg <- unique(ampm$State_Region[which(ampm$Dataset == 'Bird et al., 2018')])

# Get samples sizes of ab dataset for each region
# Change this line to get samples per region for dataset
length(which(ampm$Species == ab_spp[4] & ampm$State_Region == ab_reg[2] &
             ampm$Dataset == 'Bird et al., 2018'))

# Write to dataframe
ab_d <-data.frame(Species = c(ab_spp[1], ab_spp[1], ab_spp[2], ab_spp[3],
                                ab_spp[4], ab_spp[4], ab_spp[4], ab_spp[4]),
                    Region = c(ab_reg[1], ab_reg[2], ab_reg[3], ab_reg[1],
                               ab_reg[1], ab_reg[2], ab_reg[3], ab_reg[4]),
                    N = c(5, 15, 4, 8, 10, 39, 2, 13),
                    Paper = 'Bird et al., 2018')

# Remove Unnecessary Variables
rm(ab_spp, ab_reg, spi_sam, spi_reg,mg_sam, mg_spp, ph, se_reg)

#-------------------------------------#
## MERGE & FORMAT TABLE
# Bind other Dataframes
Info_Table <- rbind(ab_d, mg_d, se_d, spi_d)

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
                  "Franklin's Climbing Salamander", 'Spikethumb Frogs',
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
