###META ANALYSIS SCRIPT

#This script will provide an in depth analysis of microbial data previously
#...analyzed in QIIME2. This script will render multiple plots that will
#...elucidate the change in diversity on amphibians between regions along the
#...Pacific Coast.

##LOAD PACKAGES, DATA, AND DIRECTORY
#Set Directory and Load required Packages
setwd('~/Documents/amphibian_meta_project/meta_analysis/qiime_analyses/')
project_packages <- c('phyloseq', 'qiime2R','DESeq2', 'grid',
                      'gridExtra', 'vegan', 'ggmap', 'tidyverse')
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

#Order Region Levels
sample_data(amphib.obj)$State_Region <-
    factor(sample_data(amphib.obj)$State_Region,
              levels = c("Northern California", "Coastal California",
                         "Sierra Nevada", "Southern California",
                         "Central America"))

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
##TAXA BARPLOT: Displays only the top OTUS for Each Region
#Create Database of OTU's w/ 1% Category
txs <- amphib.obj %>%
    transform_sample_counts(function(x) x / sum(x)) %>%
    tax_glom(taxrank = 'Phylum') %>%
    psmelt()

txs$Phylum <- as.character(txs$Phylum)
txs$Phylum[txs$Abundance < 0.01] <- "<1% Abundance"

#Re-Order Levels
txs$Phylum <- factor(txs$Phylum,
                          levels = c("Acidobacteria", "Actinobacteria",
                                     "Armatimonadetes", "Bacteroidetes",
                                     "Chlamydiae", "Chloroflexi",
                                     "Cyanobacteria", "Deferribacteres",
                                     "Elusimicrobia", "Fibrobacteres",
                                     "Firmicutes", "Fusobacteria",
                                     "Gemmatimonadetes", "Lentisphaerae",
                                     "Nitrospirae","Planctomycetes",
                                     "Proteobacteria","TM7", "Verrucomicrobia",
                                     "WS3", "[Thermi]",
                                     "<1% Abundance"))

#Plot Relative Abundances
abs <- ggplot(txs, aes(x=Sample, y=Abundance, fill=Phylum))+
    facet_wrap(~State_Region, scales = "free_x", nrow = 3)+
    geom_bar(aes(), stat="identity", position="stack") +
    scale_fill_manual(values = c("#E1BD6D", "#74A089", "#EABE94", "#FDDDA0",
                                 "#78B7C5", "#FF0000", "#00A08A", "#F2AD00",
                                 "#F98400", "#46ACC8", "#ECCBAE", "#F5CDB4",
                                 "#D69C4E", "#ABDDDE", "#446455", "#FDD262",
                                 "#EE6A50", "#899DA4","#D3DDDC", "#9A8822",
                                 "#046C9A", "#000000"))+
    ylab('Relative Abunance')+
    theme(legend.justification = c(1,0), legend.position = c(1,0),
          legend.key.height = unit(0.75, 'cm'),
          legend.key.width = unit(1.3, 'cm'),
          axis.title = element_text(size = 16, family = "Georgia"),
          axis.text.x = element_blank(),
          axis.ticks.x = element_blank(), axis.title.x = element_blank(),
          legend.title = element_text(size = 14, family = "Georgia"),
          legend.text = element_text(size = 10, family = "Georgia"),
          strip.text = element_text(size = 14, family = "Georgia",
                                    face = "bold"),
          panel.background = element_rect(fill = "gray98"),
          panel.grid.major = element_blank())+
    guides(fill=guide_legend(nrow=6, title.position = 'top'),
       theme(element_text(family = "Georgia")))

#View Plot
abs

#Fill Label Matches the Region Color
g <- ggplot_gtable(ggplot_build(abs))
stripr <- which(grepl('strip-t', g$layout$name))
flls <- c("#F8AFA8", "#EE6A50", "#9A8822", "#899DA4", "#FDDDA0")
k <- 1
for(i in c(32,34,35,36,37)) {
    j <- which(grepl('rect', g$grobs[[i]]$grobs[[1]]$childrenOrder))
    g$grobs[[i]]$grobs[[1]]$children[[j]]$gp$fill <- flls[k]
    k <- k+1
}
grid.draw(g)

#----------------------------------------------------------------#
##ALPHA DIVERSITY: plot and compare species richness and evenness
#Calculate Evenness & Create DF with Evenness
alphas <- estimate_richness(amphib.obj,
                            measure = c("Chao1", "Shannon", "Simpson"))
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
#Not even: p = 0.001
adonis(Evenness ~ State_Region, data = asa, permutations = 999)

#Plot Facet-Wrapped Boxpolot of Richness and Evenness
alpha2 <- tidyr::gather(data.frame(alphas, sample_data(amphib.obj)),
                        key = "Measure",
                        value = "Value", Shannon, Chao1, Simpson, Evenness)

ggplot(data = alpha2, aes(x = State_Region, y = Value, color = State_Region))+
  labs(color = "State Region", x = "State Region")+
  facet_wrap(~Measure, scale = "free", nrow = 1)+
  geom_jitter(width = 0.2)+
  stat_summary(aes(y = Value),
               fun.data=mean_cl_normal, colour="#000000", geom="errorbar")+
  scale_color_manual(values = c("#899DA4", "#FDDDA0", "#EE6A50", "#9A8822",
                               "#F8AFA8"))+
  theme(axis.text.x = element_text(angle = 70, hjust = 1, size = 10,
                                   colour = 'black', family = "Georgia"),
        panel.border = element_blank(), axis.title.y = element_blank(),
        legend.title = element_text(size = 14, family = "Georgia"),
        legend.text = element_text(size = 12, family = "Georgia"),
        panel.grid.major = element_line(size = .3, linetype = 'solid',
                                        colour = 'gray80'),
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
adm <- plyr::ldply(pca.list, function(x) x$data)
names(adm)[1] <- "distance"
print(pca.list[['unifrac']])

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
ds <- phyloseq::distance(amphib.obj, method = "unifrac")
ord <- ordinate(amphib.obj, "MDS", distance = ds)

#Plot
plot_ordination(amphib.obj, ord, color = "State_Region", shape = "Order")+
  scale_color_manual(values = c("#899DA4", "#FDDDA0", "#EE6A50", "#9A8822",
                               "#F8AFA8"))+
  geom_point(size = 5)+
  #annotate(geom = 'text', x = 0, y = 0.25, label = 'R. sierrae', size = 6)+
  #stat_ellipse(type = "norm", level = 0.99)+
  labs(shape = "Host", color = "Region")+
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
#Map Mex/Gua Samples
mgm <- get_stamenmap(bbox = c(bottom = 14.418492, left = -92.8479,
                              top = 16.098598, right = -90.227808),
                     maptype = "toner-background", zoom = 9,
                     crop = TRUE, color = "bw")

ggmap(mgm)+
    geom_point(data = sample_data(amphib.obj), color = "#F8AFA8",
               aes(x = Longitude, y = Latitude, shape = Order),
               size = 8, alpha = 0.6)+
    theme_void()+
    theme(legend.position = c(0.8,0.14),
          legend.text = element_text(size = 14, family = "Georgia"),
          legend.title = element_text(size = 16, family = "Georgia"))+
    geom_text(label = "Mexico", nudge_x = 0.4, nudge_y = 1.3, size = 12,
              family = "Georgia")+
    geom_text(label = "Guatemala", nudge_x = 1.55, nudge_y = 1.4, size = 12,
              family = "Georgia")

#Map California Regions
#Load California Map Data
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
            cac$zone[i] <- "Sierras - Ellison et al., 2017"
        }else if (is.element(cac$subregion[i], ccm)){
            cac$zone[i] <- "Coastal California - Prado-Irwin et al. 2017"
        }else if (is.element(cac$subregion[i], scal)){
            cac$zone[i] <- "Southern California - Bird et al., 2018"
        }else if (is.element(cac$subregion[i], ncal)){
            cac$zone[i] <- "Northern California - Bird et a., 2018"
        }
}

#Plot Map of California
ggplot(data = cali, mapping = aes(x = long, y = lat, group = group)) +
    coord_fixed(1.3) +
    geom_polygon(color = "black", fill = "gray85") +
    geom_polygon(data = cac, aes(fill = zone), color = "gray90") +
    scale_fill_manual(values = c("gray85", "#FDDDA0", "#899DA4",
                                 "#EE6A50", "#9A8822"),
                      name = "State Regions",
                      breaks = c("Coastal California - Prado-Irwin et al. 2017",
                                 "Northern California - Bird et a., 2018",
                                 "Sierras - Ellison et al., 2017",
                                 "Southern California - Bird et al., 2018")) +
    theme_void() +
    theme(legend.position = c(0.8,0.85),
          legend.text = element_text(size = 12, family = "Georgia"),
          legend.title = element_text(size = 18, family = "Georgia",
                                      face = "bold"))


#Load Mexico/Guatemala Map Data
library(maps)

mgm <- subset(map_data("state"), region == "chiapas")

#----------------------------------------------------------------#
##CLUSTER ANALYSIS
#Computing the Gap Statistic: this tells the most likely number of clusters
#Ordinate Data
exord.amp = ordinate(amphib.obj, method="MDS", distance="bray")

#Compute Gap Statistic
library(cluster)
#creates f(x) topartitions data into 'k' clusters
pam1 = function(x, k){list(cluster = cluster::pam(x,k, cluster.only=TRUE))}
x = phyloseq:::scores.pcoa(exord.amp, display="sites")
gskmn = cluster::clusGap(x[, 1:2], FUN=pam1, K.max = 6, B = 50)
gskmn #shows that I have 6 clusters in dataset

#----------------------------------------------------------------#
##OTU ANALYSIS: Calculate the Difference in OTU Abundance Between Regions
#Convert physeq object to DESeq object
da <- phyloseq_to_deseq2(amphib.obj, ~ State_Region)
gm_mean = function(x, na.rm=TRUE){
  exp(sum(log(x[x > 0]), na.rm=na.rm) / length(x))
}

geoMeans = apply(counts(da), 1, gm_mean)
da <- estimateSizeFactors(da, geoMeans = geoMeans)
da <- DESeq(da, fitType="local")

#For loop that Compares the significant OTU abundance of each Region
#with Sierra Nevada
# Need to break down for loop to individual comparisons


#Sierra vs Northern California
res.1 = results(da, contrast =
              c("State_Region", "Sierra Nevada", "Northern California"), alpha = 0.01)
res.1 = res.1[order(res.1$padj, na.last=NA), ]
res.1_sig = res.1[(res.1$padj < 0.01), ]
res.1_sig = cbind(as(res.1_sig, "data.frame"),
                as(tax_table(amphib.obj)[rownames(res.1_sig), ], "matrix"))

#Sierra vs Coastal California
res.2 = results(da, contrast =
              c("State_Region", "Sierra Nevada", "Coastal California"), alpha = 0.01)
res.2 = res.2[order(res.2$padj, na.last=NA), ]
res.2_sig = res.2[(res.2$padj < 0.01), ]
res.2_sig = cbind(as(res.2_sig, "data.frame"),
                as(tax_table(amphib.obj)[rownames(res.2_sig), ], "matrix"))


#Sierra vs Southern California
res.3 = results(da, contrast =
              c("State_Region", "Sierra Nevada", "Southern California"), alpha = 0.01)
res.3 = res.3[order(res.3$padj, na.last=NA), ]
res.3_sig = res.3[(res.3$padj < 0.01), ]
res.3_sig = cbind(as(res.3_sig, "data.frame"),
                as(tax_table(amphib.obj)[rownames(res.3_sig), ], "matrix"))

#Sierra vs Central America
res.4 = results(da, contrast =
              c("State_Region", "Sierra Nevada", "Central America"), alpha = 0.01)
res.4 = res.4[order(res.4$padj, na.last=NA), ]
res.4_sig = res.4[(res.4$padj < 0.01), ]
res.4_sig = cbind(as(res.4_sig, "data.frame"),
                as(tax_table(amphib.obj)[rownames(res.4_sig), ], "matrix"))

#Modified For Loop
for (i in c(1,2,4,5)){
  altrg = levels(sample_data(amphib.obj)$State_Region)[i]
  res = results(da, contrast =
                c("State_Region", "Sierra Nevada", altrg), alpha = 0.01)
  res = res[order(res$padj, na.last=NA), ]
  res_sig = res[(res$padj < 0.01), ]
  res_sig$Comparison <- as.factor(paste0("Sierra Nevada vs ", altrg))
  assign(paste0("res_sig", i), cbind(as(res_sig, "data.frame"),
        as(tax_table(amphib.obj)[rownames(res_sig), ], "matrix")))
  #Merge & Delete Tables
  while(i == 5){
      otu_res <- Reduce(function(x,y) merge(x,y, all = TRUE),
                        list(res_sig1, res_sig2, res_sig4, res_sig5))
      rm(altrg, res, res_sig, res_sig1, res_sig2, res_sig4, res_sig5)
      i = i+1
  }
}


#Plot Whole Dataset
ggplot(res_sig, aes(x = Order, y = log2FoldChange))+
    geom_col(aes(fill = Phylum), width = 1)+
    scale_fill_manual(values = c("#E1BD6D", "#74A089", "#EABE94", "#FDDDA0",
                                 "#78B7C5", "#CC99CC", "#00A08A","#FFC307",
                                 "#D69C4E", "#FDD262", "#EE6A50", "#D3DDDC",
                                 "#97D992"))+
ggtitle(paste("Sierra Nevada vs ", altrg, sep = ""))+
theme(plot.title = element_text(family = "Georgia"),
      axis.text.x = element_blank(),
      axis.ticks.x = element_blank(),
      axis.title.x = element_blank(), axis.title.y = element_blank(),
      panel.background = element_rect(fill = "gray98"),
      legend.position = c(0.65,0.85), legend.title = element_blank(),
      legend.text = element_text(size = 9),
      legend.key.size = unit(0.3, 'cm'))+
guides(fill=guide_legend(nrow=6))

#Plot the OTU abundances
grid.arrange(grobs = list(otu.list[[1]], otu.list[[2]], otu.list[[4]],
                          otu.list[[5]]), ncol = 3,
             bottom =textGrob("Order",
                              gp=gpar(fontsize=22, fontfamily = "Georgia")),
             left = textGrob("log2FoldChange", rot = 90,
                             vjust = 1,
                             gp=gpar(fontsize = 22, fontfamily = "Georgia")))

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
