# Load Files & Library
library(tidyverse)
setwd('~/Documents/amphibian_meta_project/meta_analysis/qiime_analyses/')
abmap <- read.table(file = 'AB_mapping_file.txt', sep = "\t", header = TRUE)
mgmap <- read.table(file = 'MG_Mapping_File_GUA_with_Bd.txt',
                    sep = "\t", header = TRUE)
spimap <- read.table(file = 'SPI_mapping_file.txt', sep = "\t", header = TRUE)
semap <- read.table(file = 'SE_mapping_file.txt', sep = "\t", header = TRUE)

# Create a vector of Sample Sizes / species
ab_sam <- numeric()
for(i in 1:4){
    pa <- length(which(abmap$Species == unique(abmap$Species)[i]))
    ab_sam <- c(ab_sam, pa)
}

mg_sam <- numeric()
for(i in 1:17){
    pa <- length(which(mgmap$Species == unique(mgmap$Species)[i]))
    mg_sam <- c(mg_sam, pa)
}

# Create Table
Info_Table <- data.frame(Sample = c(unique(abmap$Species), unique(mgmap$Species),
                                    'Rana sierrae', 'Ensatina xanthoptica'),
                         Paper = c(rep('Bird et al (2018)', 4),
                                   rep('Ellison et al (2018)', 17), 'Ellison et al (2019)',
                                   'Prado-Irwin et al (2017)'),
                         Region = c(rep('California', 4), rep('Mexico/Guatemala', 17),
                                    'Coastal California', 'Sierra Nevada'),
                         N = c(ab_sam, mg_sam, nrow(abmap), nrow(mgmap)))

Info_Table <- Info_Table[-c(20,21),]

# Export Table
write.table(Info_Table, file = '~/Documents/amphibian_meta_project/Data_Info.csv',
          row.names = FALSE, col.names = TRUE, sep = ",", quote = FALSE)
