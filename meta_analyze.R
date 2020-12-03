###META ANALYSIS SCRIPT

#This script will provide an in depth analysis of microbial data previously analyzed in
#...QIIME2. This script will render multiple plots that will elucidate the change in
#...diversity on amphibians between regions along the Pacific Coast

##LOAD PACKAGES, DATA, AND DIRECTORY
#Set Directory and Load required Packages
setwd('~/Documents/amphibian_meta_project/meta_analysis/qiime_analyses/')
project_packages <- c('phyloseq', 'qiime2R','DESeq2', 'phangorn', 'grid', 'ggplot2','DECIPHER',
                      'gridExtra', 'vegan', 'wesanderson', 'dplyr', 'ggmap')
sapply(project_packages, require, character.only = TRUE)

#Create Phyloseq Object / Load data / Filter Ambiguous Orders
amphib.obj <- subset_taxa(qza_to_phyloseq(features="meta_c2_phy_table.qza", taxonomy = "meta_taxonomy.qza",
                                          tree = "meta_rootd.qza", metadata="merged_metadata.txt"),
                          !is.na(Order) & !Order %in% c("", "uncharacterized"))

#Very Important
the.royal <- c("#899DA4", "#9A8822", "#F5CDB4", "#F8AFA8", "#FDDDA0", "#EE6A50", "#74A089")

#----------------------------------------------------------------#
#----------------------------------------------------------------#

##TAXA BARPLOT: Displays only the top OTUS for Each Region
#Create Database of OTU's w/ 1% Category
txs <- psmelt(tax_glom(transform_sample_counts(amphib.obj, function(x) x / sum(x) ), taxrank = 'Phylum'))
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
  theme(legend.position= c(0.67, 0.17), legend.key.height = unit(0.7, 'cm'), legend.key.width = unit(1.7, 'cm'),
        axis.title = element_text(size = 16, family = "Georgia"), axis.text.x = element_blank(),
        axis.ticks.x = element_blank(), axis.title.x = element_blank(),
        legend.title = element_text(size = 14, family = "Georgia"),
        legend.text = element_text(size = 11, family = "Georgia"),
        panel.background = element_rect(fill = "gray98"), panel.grid.major = element_blank())+
  guides(fill=guide_legend(nrow=6, title.position = 'top'),
    theme(element_text(family = "Georgia")))

#----------------------------------------------------------------#
##ALPHA DIVERSITY: plot and compare species richness and evenness
#Calculate Evenness & Create DF with Evenness
alphas <- estimate_richness(amphib.obj, measure = c("Chao1", "Shannon", "Simpson"))
alphas$Evenness <- 0
for(i in 1:nrow(alphas)){
  H <- alphas$Shannon
  S1 <- alphas$Chao1
  S <- log(S1)
  alphas$Evenness[i] = H[i]/S[i]
}

#ANOVA Assumption Tests
asa = merge(alphas, sample_data(amphib.obj), by = 0, all = TRUE)
shapiro.test(alphas$Shannon) #FAILED: p = 0.02106
bartlett.test(Evenness ~ State_Region, data = asa) #FAILED: p = 0.0049

#PERMANOVA Richness Comparison
adonis(Evenness ~ State_Region, data = asa, permutations = 999) #Not even: p = 0.001

#Plot Facet-Wrapped Boxpolot of Richness and Evenness
alpha2 <- tidyr::gather(data.frame(alphas, sample_data(amphib.obj)),
                        key = "Measure", value = "Value", Shannon, Chao1, Simpson, Evenness)
ggplot(data = alpha2, aes(x = State_Region, y = Value, color = Order))+
  labs(color = "Host", x = "State Region")+
  facet_wrap(~Measure, scale = "free", nrow = 1)+
  geom_jitter(width = 0.2)+
  stat_summary(aes(y = Value,group=1), fun=mean, colour="#899DA4", geom="line",group=1)+
  scale_color_manual(values= c('#EE6A50', '#F5CDB4', '#9A8822'))+
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
  iDist <- phyloseq::distance(amphib.obj, method=i)
  iMDS  <- ordinate(amphib.obj, "MDS", distance = iDist)
  #Make plot
  p <- NULL
  p <- plot_ordination(amphib.obj, iMDS, color="State_Region", shape="Order")+
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
ord <- ordinate(amphib.obj, "MDS", distance = (phyloseq::distance(amphib.obj, method = "unifrac"))) #change model here
plot_ordination(amphib.obj, ord, color = "State_Region", shape = "Order")+
  scale_color_manual(values = the.royal)+
  scale_fill_manual(values = the.royal)+
  geom_point(size = 5)+
  annotate(geom = 'text', x = 0, y = 0.25, label = 'R. sierrae', size = 6)+
  stat_ellipse(type = "norm", level = 0.99)+
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

#----------------------------------------------------------------#
##MAP THE SAMPLES
#Map All Samples on International Map
rng <- get_stamenmap(bbox = c(left = -130.32, bottom = 11.45, right = -84.9, top = 42.99),
                     maptype = "terrain-background", zoom = 6, crop = TRUE, color = "bw")

ggmap(rng)+
    geom_point(data = sample_data(amphib.obj), aes(x = Longitude, y = Latitude, col = Dataset),
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
        ccm <- c("san francisco", "alameda", "santa cruz", "monterey", "contra costa")
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
    scale_fill_manual(values = c("gray85", "#FDDDA0", "#74A089", "#EE6A50", "#F8AFA8"),
                      name = "State Regions",
                      breaks = c("0", "Coastal California", "Northern California",
                                 "Sierras", "Southern California"),
                      labels = c("Unsampled", "Coastal California", "Northern California",
                                 "Sierras", "Southern California")) +
    theme_void() +
    theme(legend.position = c(0.75,0.75),
          legend.text = element_text(size = 14, family = "Georgia"),
          legend.title = element_text(size = 16, family = "Georgia"))

#----------------------------------------------------------------#
##CLUSTER ANALYSIS
#Computing the Gap Statistic: this tells the most likely number of clusters
#Ordinate Data
exord.amp = ordinate(amphib.obj, method="MDS", distance="bray")

#Compute Gap Statistic
library(cluster)
pam1 = function(x, k){list(cluster = cluster::pam(x,k, cluster.only=TRUE))} #creates f(x) topartitions data into 'k' clusters
x = phyloseq:::scores.pcoa(exord.amp, display="sites")
gskmn = cluster::clusGap(x[, 1:2], FUN=pam1, K.max = 6, B = 50)
gskmn #shows that I have 6 clusters in dataset

#----------------------------------------------------------------#
##OTU ANALYSIS: Calculate the Difference in OTU Abundance Between Regions
#Convert physeq object to DESeq object
sample_data(amphib.obj)$State_Region <- as.factor(sample_data(amphib.obj)$State_Region)
da <- phyloseq_to_deseq2(amphib.obj, ~ State_Region)
gm_mean = function(x, na.rm=TRUE){
  exp(sum(log(x[x > 0]), na.rm=na.rm) / length(x))
}
geoMeans = apply(counts(da), 1, gm_mean)
da <- estimateSizeFactors(da, geoMeans = geoMeans)
da <- DESeq(da, fitType="local")

#For loop that Compares the significant OTU abundance differences by Region
otu.list <- vector("list", length = 6)
regs <- c(1,2,3,4,5,7)
for (i in regs){
  al = 0.01
  altrg = levels(sample_data(amphib.obj)$State_Region)[i]
  res = results(da, contrast = c("State_Region", "Sierra_Nevada", altrg), alpha = al)
  res = res[order(res$padj, na.last=NA), ]
  res_sig = res[(res$padj < al), ]
  res_sig = cbind(as(res_sig, "data.frame"), as(tax_table(amphib.obj)[rownames(res_sig), ], "matrix"))
  #plot
  o = NULL
  o = ggplot(res_sig, aes(x = Order, y = log2FoldChange))+
    geom_col(aes(fill = Phylum), width = 1)+
    scale_fill_manual(values = wes_palette("Royal2", 12, type = "continuous"))+
    ggtitle(paste("Sierra Nevada vs ", altrg, sep = ""))+
    theme(plot.title = element_text(family = "Georgia"),
          axis.text.x = element_blank(),
          axis.ticks.x = element_blank(),
          axis.title.x = element_blank(), axis.title.y = element_blank(),
          panel.background = element_rect(fill = "gray98"),
          legend.position = c(0.65,0.85), legend.title = element_blank(),
          legend.text = element_text(size = 9), legend.key.size = unit(0.3, 'cm'))+
    guides(fill=guide_legend(nrow=6))

  otu.list[[i]] <- o
}

#Plot the OTU abundances
grid.arrange(grobs = list(otu.list[[1]], otu.list[[2]],
                          otu.list[[3]], otu.list[[4]], otu.list[[5]], otu.list [[7]]), ncol = 3,
             bottom =textGrob("Order", gp=gpar(fontsize=22, fontfamily = "Georgia")),
             left = textGrob("log2FoldChange", rot = 90, vjust = 1, gp=gpar(fontsize = 22,
                                                                            fontfamily = "Georgia")))

#show's the orders of significant bacteria
#axis.text.x = element_text(angle = -90, hjust = 0, vjust = 0.5, size = 8)


#----------------------------------------------------------------#
##PERMANOVA: Confirms there are Diversity differences between the Groups
md = data.frame(sample_data(amphib.obj))
perm <- adonis(phyloseq::distance(amphib.obj, method="wunifrac") ~ Family,
       data = md, permutations = 999)
print(perm)

#Pairwise PERMANOVA: Pairwise analysis of Diversity Differences
permutest(betadisper(phyloseq::distance(amphib.obj, method = "wunifrac"),
                     md$Order),pairwise = TRUE)

#----------------------------------------------------------------#
#-----------------------END--------------------------------------#
