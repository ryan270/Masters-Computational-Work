###SUBSET ANALYSIS SCRIPT -- SALAMANDERS
#This script will provid an indepth analysis
#...of the microbial diversity of just salamanders.
#This script is a modification of meta_analyze: the Meta Analysis Script
setwd('~/Documents/amphibian_meta_project/meta_analysis/qiime_analyses/')
project_packages <- c('phyloseq', 'qiime2R','DESeq2', 'phangorn', 'grid', 'ggplot2','DECIPHER',
                      'gridExtra', 'vegan', 'wesanderson', 'dplyr', 'ggmap')
sapply(project_packages, require, character.only = TRUE)

#Create Phyloseq Object / Load data / Filter Ambiguous Orders
amphib.obj <- subset_taxa(qza_to_phyloseq(features="meta_c2_phy_table.qza", taxonomy = "meta_taxonomy.qza",
                                          tree = "meta_rootd.qza", metadata="merged_metadata.txt"),
                          !is.na(Order) & !Order %in% c("", "uncharacterized"))

#Subset just salamanders
frgs <- subset_samples(amphib.obj, Order =="Anura")

#Very Important
the.royal <- c("#899DA4", "#9A8822", "#F5CDB4", "#F8AFA8", "#FDDDA0", "#EE6A50", "#74A089")

#----------------------------------------------------------------#
#----------------------------------------------------------------#
