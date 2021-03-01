###SUBSET ANALYSIS SCRIPT -- SALAMANDERS
#This script will provid an indepth analysis
#...of the microbial diversity of just salamanders.
#This script is a modification of meta_analyze: the Meta Analysis Script
setwd('~/Documents/amphibian_meta_project/meta_analysis/qiime_analyses/')
project_packages <- c('phyloseq', 'qiime2R','DESeq2', 'phangorn', 'grid',
                      'ggplot2','DECIPHER', 'gridExtra', 'vegan', 'wesanderson',
                      'dplyr', 'ggmap')
sapply(project_packages, require, character.only = TRUE)

#Create Phyloseq Object / Load data / Filter Ambiguous Orders
amphib.obj <- subset_taxa(qza_to_phyloseq(features="meta_c2_phy_table.qza",
                                          taxonomy = "meta_taxonomy.qza",
                                          tree = "meta_rootd.qza",
                                          metadata="merged_metadata.txt"),
                          !is.na(Order) & !Order %in% c("", "uncharacterized"))

#Subset just salamanders
sals <- subset_samples(amphib.obj, Order !="Anura")

#Very Important
the.royal <- c("#899DA4", "#9A8822", "#F5CDB4", "#F8AFA8", "#FDDDA0",
               "#EE6A50", "#74A089")

#----------------------------------------------------------------#
#----------------------------------------------------------------#
##ALPHA DIVERSITY: plot and compare species richness and evenness
#Calculate Evenness & Create DF with Evenness
alphas <- estimate_richness(sals, measure = c("Chao1", "Shannon", "Simpson"))
alphas$Evenness <- 0
for(i in 1:nrow(alphas)){
  H <- alphas$Shannon
  S1 <- alphas$Chao1
  S <- log(S1)
  alphas$Evenness[i] = H[i]/S[i]
}

#ANOVA Assumption Tests
asa = merge(alphas, sample_data(sals), by = 0, all = TRUE)
shapiro.test(alphas$Shannon) #FAILED: p = 0.02106
bartlett.test(Evenness ~ State_Region, data = asa) #FAILED: p = 0.0049

#PERMANOVA Richness Comparison
adonis(Shannon ~ State_Region, data = asa, permutations = 999, pairwise = TRUE) #Not even: p = 0.001

#----------------------------------------------------------------#
##BETA DIVERSITY AND DISTANCE: calculate PCA's with multiple models
#Includes -- The Plot --
#Omit user-defined distance methods and unapplicable methods
dist_models <- unlist(distanceMethodList)[-c(2,3,9,12,16,20,27,29,35,42,43,47)]

#Vectorize Distance models list
pca.list <- vector("list", length(dist_models))
names(pca.list) = dist_models

#For loop that loops through all of the distance models and calculates them
for (i in dist_models) {
  iDist <- phyloseq::distance(sals, method=i)
  iMDS  <- ordinate(sals, "MDS", distance = iDist)
  #Make plot
  p <- NULL
  p <- plot_ordination(sals, iMDS, color="State_Region", shape="Order")+
    ggtitle(paste("Distance Method ", i, sep=""))+
    geom_point(size = 4)+
    theme(plot.title = element_text(size = 12, family = "Georgia"))
  #Save the graphic to file.
  pca.list[[i]] = p
}

#Merges all of the distances from all methods into a dataframe
adm <- ldply(pca.list, function(x) x$data)
names(adm)[1] <- "distance"
print(pca.list[['bray']])

#Plots Methods Confirming Distinctions
ggplot(adm, aes(Axis.1, Axis.2, color = State_Region, shape = Order))+
  geom_point(size=1.5, alpha = 0.8)+
  scale_color_manual(values = the.royal)+
  facet_wrap(~distance, scales="free")+
  labs(color = "State Region", x = "Axis 1", y = "Axis 2",
       shape = "Taxonomic Order")+
  theme(axis.title.x = element_text(size = 16, family = "Georgia"),
        axis.title.y = element_text(size = 16, family = "Georgia"),
        legend.title = element_text(size = 14, family = "Georgia"),
        panel.border = element_blank(),
        panel.grid.major = element_line(size = .45, linetype = 'solid',
                                        colour = 'gray75'),
        axis.line = element_line(colour = 'black', size = 0.2),
        panel.background = element_rect(fill = "gray98"))

#Use to Calculate Distances without For Loop on the Fly
#Unweighted Unifrac -- The Plot
ord <- ordinate(sals, "MDS", distance = (phyloseq::distance(sals, method = "unifrac"))) #change model here
plot_ordination(sals, ord, color = "State_Region", shape = "Order")+
  scale_color_manual(values = the.royal)+
  scale_fill_manual(values = the.royal)+
  geom_point(size = 5)+
  labs(shape = "Host", color = "Region", x = "PC2", y = "PC1")+
  theme(panel.border = element_blank(),
        plot.title = element_text(size = 30, face = "bold"),
        plot.subtitle = element_text(size = 22, face = "italic"),
        legend.title = element_text(size = 16, family = "Georgia"),
        legend.text = element_text(size = 11, family = "Georgia"),
        axis.title.x = element_text(size = 16, family = "Georgia"),
        axis.title.y = element_text(size = 16, family = "Georgia"),
        panel.grid.major = element_line(size = .45, linetype = 'solid',
                                        colour = 'gray75'),
        axis.line = element_line(colour = 'black', size = 0.2),
        panel.background = element_rect(fill = "gray98"))
