###SUBSET ANALYSIS SCRIPT -- SALAMANDERS
#This script will provid an indepth analysis
#...of the microbial diversity of just salamanders.
#This script is a modification of meta_analyze: the Meta Analysis Script
setwd('~/Documents/amphibian_meta_project/meta_analysis/qiime_analyses/')
project_packages <- c('phyloseq', 'qiime2R','phangorn', 'grid', 'ggplot2',
                      'gridExtra', 'vegan', 'wesanderson', 'dplyr')
sapply(project_packages, require, character.only = TRUE)

#Create Phyloseq Object / Load data / Filter Ambiguous Orders
amphib.obj <- subset_taxa(qza_to_phyloseq(features="meta_c2_phy_table.qza", taxonomy = "meta_taxonomy.qza",
                                          tree = "meta_rootd.qza", metadata="merged_metadata.txt"),
                          !is.na(Order) & !Order %in% c("", "uncharacterized"))

#Subset just frogs
frgs <- subset_samples(amphib.obj, Order =="Anura")

#Very Important
the.royal <- c("#899DA4", "#9A8822", "#F5CDB4", "#F8AFA8", "#FDDDA0", "#EE6A50", "#74A089")

#----------------------------------------------------------------#
#----------------------------------------------------------------#
##EXPLORATORY ANALYSIS: Explore ideas to parse frog data
#Remove Samples w/ more than 75% Proteobacteria
tfrg <- transform_sample_counts(frgs, function(x) x/ sum(x)) %>%
    psmelt()
nsmps <- setdiff(sample_names(frgs),
                 tfrg$Sample[which(tfrg$Abundance > .8)])

nopro <- prune_samples(nsmps, frgs)
ntst <- transform_sample_counts(nopro, function(x) x/ sum(x)) %>%
    psmelt()
mfrgs <- setdiff(nsmps,
                 c("SE108", "SE107", "SE110", "SE37", "SE39", "SE44", "SE72"))
npro2 <- prune_samples(mfrgs, nopro)
outs <- tfrg$Sample[which(tfrg$Abundance > .8)] %>%
    append(c("SE108", "SE107", "SE110", "SE37", "SE39", "SE44", "SE72"))

#----------------------------------------------------------------#
##TAXA BARPLOT: Displays only the top OTUS for Each Region
#Create Database of OTU's w/ 1% Category
txs <- psmelt(tax_glom(transform_sample_counts(npro2, function(x) x / sum(x) ), taxrank = 'Phylum'))
txs$Phylum <- as.character(txs$Phylum)
txs$Phylum[txs$Abundance < 0.01] <- "< 1% Abundance"

#Re-Order Levels
txs$Phylum <- factor(txs$Phylum,
                          levels = c("Acidobacteria", "Actinobacteria", "Armatimonadetes", "Bacteroidetes",
                                     "Chlamydiae", "Chloroflexi", "Cyanobacteria", "Deferribacteres",
                                     "Elusimicrobia", "Fibrobacteres", "Firmicutes", "Fusobacteria",
                                     "Gemmatimonadetes", "Lentisphaerae", "Nitrospirae","Planctomycetes",
                                     "Proteobacteria","TM7", "Verrucomicrobia", "WS3", "[Thermi]",
                                     "< 1% Abundance"))

#Plot Relative Abundances
ggplot(txs, aes(x=Sample, y=Abundance, fill=Phylum))+
  facet_wrap(~State_Region, scales = "free_x", nrow = 3)+
  geom_bar(aes(), stat="identity", position="stack") +
  scale_fill_manual(values = c("#E1BD6D", "#74A089", "#EABE94", "#FDDDA0", "#78B7C5", "#FF0000", "#00A08A",
                               "#F2AD00", "#F98400", "#46ACC8", "#ECCBAE", "#F5CDB4", "#D69C4E", "#ABDDDE",
                               "#446455", "#FDD262", "#EE6A50", "#899DA4","#D3DDDC", "#9A8822", "#046C9A",
                               "#000000"))+
  ylab('Relative Abunance')+
  theme(legend.position= c(0.67, 0.17), legend.key.height = unit(0.7, 'cm'),
        legend.key.width = unit(1.7, 'cm'),
        axis.text.x = element_blank(),
        axis.title = element_text(size = 16, family = "Georgia"),
        axis.ticks.x = element_blank(), axis.title.x = element_blank(),
        legend.title = element_text(size = 14, family = "Georgia"),
        legend.text = element_text(size = 11, family = "Georgia"),
        panel.background = element_rect(fill = "gray98"), panel.grid.major = element_blank())+
  guides(fill=guide_legend(nrow=6, title.position = 'top'),
    theme(element_text(family = "Georgia")))

#----------------------------------------------------------------#
##ALPHA DIVERSITY: plot and compare species richness and evenness
#Calculate Evenness & Create DF with Evenness
alphas <- estimate_richness(npro2, measure = c("Chao1", "Shannon", "Simpson"))
alphas$Evenness <- 0
for(i in 1:nrow(alphas)){
  H <- alphas$Shannon
  S1 <- alphas$Chao1
  S <- log(S1)
  alphas$Evenness[i] = H[i]/S[i]
}

#ANOVA Assumption Tests
asa = merge(alphas, sample_data(npro2), by = 0, all = TRUE)
shapiro.test(alphas$Shannon) #FAILED: p = 0.02106
bartlett.test(Evenness ~ State_Region, data = asa) #FAILED: p = 0.0049

#PERMANOVA Richness Comparison
#No Difference in Alpha Diversity: Shannon & Simpson,
#Differences in Alpha Diversity: Chao1 & Evenness
adonis(Simpson ~ State_Region, data = asa, permutations = 999, pairwise = TRUE) #Not even: p = 0.001

#Plot Facet-Wrapped Boxpolot of Richness and Evenness
alpha2 <- tidyr::gather(data.frame(alphas, sample_data(npro2)),
                        key = "Measure", value = "Value", Shannon, Chao1, Simpson, Evenness)
ggplot(data = alpha2, aes(x = State_Region, y = Value, color = Family))+
  labs(color = "Host", x = "State Region")+
  facet_wrap(~Measure, scale = "free", nrow = 1)+
  geom_jitter(width = 0.2)+
  stat_summary(aes(y = Value,group=1), fun=mean, colour="#899DA4", geom="line",group=1)+
  scale_color_manual(values= the.royal)+
  theme(axis.text.x = element_text(angle = 70, hjust = 1, size = 10,
                                   colour = 'black', family = "Georgia"),
        panel.border = element_blank(), axis.title.y = element_blank(),
        legend.title = element_text(size = 14, family = "Georgia"),
        legend.text = element_text(size = 12, family = "Georgia"),
        panel.grid.major = element_line(size = .3, linetype = 'solid', colour = 'gray80'),
        panel.background = element_rect(fill = "gray98"),
        axis.title = element_text(size = 16, family = "Georgia"))

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
  iDist <- phyloseq::distance(npro2, method=i)
  iMDS  <- ordinate(npro2, "MDS", distance = iDist)
  #Make plot
  p <- NULL
  p <- plot_ordination(npro2, iMDS, color="State_Region", shape="Order")+
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
ord <- ordinate(npro2, "MDS", distance = (phyloseq::distance(npro2, method = "wunifrac"))) #change model here
plot_ordination(npro2, ord, color = "State_Region")+
  scale_color_manual(values = the.royal)+
  scale_fill_manual(values = the.royal)+
  geom_point(size = 5)+
  labs(shape = "Host", color = "Region", x = "PC2", y = "PC1",
       title  = "Beta Diversity of Frogs",
       subtitle = "Weighted PCA")+
  theme(panel.border = element_blank(),
        plot.title = element_text(size = 24, face = "bold"),
        plot.subtitle = element_text(size = 20, face = "italic"),
        legend.title = element_text(size = 16, family = "Georgia"),
        legend.text = element_text(size = 11, family = "Georgia"),
        axis.title.x = element_text(size = 16, family = "Georgia"),
        axis.title.y = element_text(size = 16, family = "Georgia"),
        panel.grid.major = element_line(size = .45, linetype = 'solid',
                                        colour = 'gray75'),
        axis.line = element_line(colour = 'black', size = 0.2),
        panel.background = element_rect(fill = "gray98"))

#----------------------------------------------------------------#
##PERMANOVA: Confirms there are Diversity differences between the Groups
#Significant differences in weighted and unweighted
md = data.frame(sample_data(npro2))
perm <- adonis(phyloseq::distance(npro2, method="wunifrac") ~ State_Region,
       data = md, permutations = 999)
print(perm)

#----------------------------------------------------------------#
#-----------------------END--------------------------------------#
