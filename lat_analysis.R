###LATITUDE ANALYSIS SCRIPT

#This script will provide an in depth analysis of the changes in microbial
#...diversity based on the proximity to the poles.

##LOAD PACKAGES, DATA, AND DIRECTORY
#Set Directory and Load required Packages
setwd('~/Documents/amphibian_meta_project/meta_analysis/qiime_analyses/')
project_packages <- c('phyloseq', 'qiime2R', 'ggplot2', 'gridExtra',
                      'vegan', 'wesanderson', 'dplyr', 'ggmap')
sapply(project_packages, require, character.only = TRUE)

#Create Phyloseq Object / Load data / Filter Ambiguous Orders
amphib.obj <- subset_taxa(qza_to_phyloseq(features="meta_c2_phy_table.qza",
                                          taxonomy = "meta_taxonomy.qza",
                                          tree = "meta_rootd.qza",
                                          metadata="merged_metadata.txt"),
                          !is.na(Order) & !Order %in% c("", "uncharacterized"))

#Very Important
the.royal <- c("#899DA4", "#9A8822", "#F5CDB4",
               "#F8AFA8", "#FDDDA0", "#EE6A50", "#74A089")

#----------------------------------------------------------------#
#----------------------------------------------------------------#

##REMOVE OUTLIERS: Remove Frogs with very high levels of Proteobacteria
acts <- transform_sample_counts(amphib.obj, function(x) x/sum(x)) %>%
    psmelt()

outs <- acts$Sample[which(acts$Abundance > .8)] %>%
    append(c("SE108", "SE107", "SE110", "SE37", "SE39", "SE44", "SE72"))

nsmps <- setdiff(sample_names(amphib.obj), outs)
amphib.obj <- prune_samples(nsmps, amphib.obj)

#----------------------------------------------------------------#
##TRANSFORM ABUNDANCE TABLE TO SUMMARY TABLE
sample_data(amphib.obj)$xantho <- 0
for(i in 1:nrow(sample_data(amphib.obj))){
        sample_data(amphib.obj)$xantho[i] <-
            subset_taxa(prune_samples(sample_names(amphib.obj)[i], amphib.obj),
                        Order=="Xanthomonadales") %>% sample_sums() /
            sample_sums(prune_samples(sample_names(amphib.obj)[i], amphib.obj))
}

#----------------------------------------------------------------#
##MAP THE SAMPLES
#Map All Samples on International Map
#Render Map of all Area
rng <- get_stamenmap(bbox = c(left = -130.32, bottom = 11.45,
                              right = -84.9, top = 42.99),
                     maptype = "terrain-background", zoom = 6,
                     crop = TRUE, color = "bw")

#Subplot of California
casm <- get_stamenmap(bbox = c(top = 42.0716, left = -125.62345,
                               bottom = 32.42387, right = -114.2196),
                      maptype = "toner-2011", zoom = 7,
                      color = "color", crop = TRUE)

#Subplot of Mexico
mgm <- get_stamenmap(bbox = c(top = 22.13214, left = -94.6965,
                               bottom = 12.86074, right = -89.24728),
                      maptype = "toner-background", zoom = 6,
                      color = "color", crop = TRUE)

#Plot Points to Map by % Xanthomonadales
ggmap(mgm)+
    geom_point(data = sample_data(amphib.obj),
               aes(x = Longitude, y = Latitude, col = xantho),
               size = 4, alpha = 0.8)+
    scale_colour_gradient(colours = the.royal,
                           low = "#FDDDA0", high = "#EE6A50")+
    theme_void()

#Map California Regions
#Load California datasets
cali <- subset(map_data("state"), region == "california")
cac <- subset(map_data("county"), region == "california")

#----------------------------------------------------------------#
#-----------------------END--------------------------------------#
