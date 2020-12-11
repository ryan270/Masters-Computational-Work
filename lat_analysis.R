###META ANALYSIS SCRIPT

#This script will provide an in depth analysis of microbial data previously
#...analyzed in QIIME2. This script will render multiple plots that will
#...elucidate the change in diversity on amphibians between regions along the
#...Pacific Coast.

##LOAD PACKAGES, DATA, AND DIRECTORY
#Set Directory and Load required Packages
setwd('~/Documents/amphibian_meta_project/meta_analysis/qiime_analyses/')
project_packages <- c('phyloseq', 'qiime2R','DESeq2', 'phangorn', 'grid',
                      'ggplot2','DECIPHER',
                      'gridExtra', 'vegan', 'wesanderson', 'dplyr', 'ggmap')
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
acts <- transform_sample_counts(amphib.obj, function(x) x/ sum(x)) %>%
    psmelt()

outs <- acts$Sample[which(acts$Abundance > .8)] %>%
    append(c("SE108", "SE107", "SE110", "SE37", "SE39", "SE44", "SE72"))

nsmps <- setdiff(sample_names(amphib.obj), outs)
amphib.obj <- prune_samples(nsmps, amphib.obj)

#----------------------------------------------------------------#
##MAP THE SAMPLES
#Map All Samples on International Map
rng <- get_stamenmap(bbox = c(left = -130.32, bottom = 11.45,
                              right = -84.9, top = 42.99),
                     maptype = "terrain-background", zoom = 6,
                     crop = TRUE, color = "bw")

ggmap(rng)+
    geom_point(data = sample_data(amphib.obj),
               aes(x = Longitude, y = Latitude, col = Dataset),
               size = 10, alpha = 0.05)+
    scale_color_manual(values = c("#74A089", "#F8AFA8", "#EE6A50", "#FDDDA0"))+
    guides(colour = guide_legend(override.aes = list(alpha = 1)))+
    theme_void()+
    theme(legend.position = c(0.25,0.25),
          legend.text = element_text(size = 14, family = "Georgia"),
          legend.title = element_text(size = 16, family = "Georgia"))

#Map California Regions
#Load California datasets
cali <- subset(map_data("state"), region == "california")
cac <- subset(map_data("county"), region == "california")

#For Loop that Divides California Counties into Regions
cac$zone <- as.character(0, quote = FALSE)

for(i in 1:nrow(cac)){
        srrs <- c("placer", "el dorado", "madera")
        ccm <- c("san francisco", "alameda", "santa cruz",
                 "monterey", "contra costa")
        scal <- c("san diego")
        ncal <- c("mendocino", "humboldt", "siskiyou", "shasta", "trinity",
                  "del norte", "sonoma", "trinity")
        if (is.element(cac$subregion[i], srrs)){
            cac$zone[i] <- "Sierras"
        }else if (is.element(cac$subregion[i], ccm)){
            cac$zone[i] <- "Coastal California"
        }else if (is.element(cac$subregion[i], scal)){
            cac$zone[i] <- "Southern California"
        }else if (is.element(cac$subregion[i], ncal)){
            cac$zone[i] <- "Northern California"
        }
}

#Plot Map of California
ggplot(data = cali, mapping = aes(x = long, y = lat, group = group)) +
    coord_fixed(1.3) +
    geom_polygon(color = "black", fill = "gray85") +
    geom_polygon(data = cac, aes(fill = zone), color = "gray90") +
    scale_fill_manual(values = c("gray85", "#FDDDA0", "#74A089",
                                 "#EE6A50", "#F8AFA8"),
                      name = "State Regions",
                      breaks = c("0", "Coastal California",
                                 "Northern California", "Sierras",
                                 "Southern California"),
                      labels = c("Unsampled", "Coastal California",
                                 "Northern California", "Sierras",
                                 "Southern California")) +
    theme_void() +
    theme(legend.position = c(0.75,0.75),
          legend.text = element_text(size = 14, family = "Georgia"),
          legend.title = element_text(size = 16, family = "Georgia"))

#----------------------------------------------------------------#
#-----------------------END--------------------------------------#
