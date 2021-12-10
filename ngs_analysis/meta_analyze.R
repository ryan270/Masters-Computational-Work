## META ANALYSIS SCRIPT: Conduct an in-depth analysis of microbial diversity
setwd("~/Documents/amphibian_meta_project/meta_analysis/qiime_analyses/")
project_packages <- c("phyloseq", "grid", "gridExtra", "vegan", "tidyverse")
sapply(project_packages, require, character.only = TRUE)

# Phyloseq object
amphib_obj <- subset_taxa(qiime2R::qza_to_phyloseq(features = "meta_c2_phy_table.qza",
                                          taxonomy = "meta_taxonomy.qza",
                                          tree = "meta_rootd.qza",
                                          metadata = "merged_metadata.txt"),
                          !is.na(Order) & !Order %in% c("", "uncharacterized"))
royal <- c("#899DA4", "#9A8822", "#F5CDB4", # Very Important
               "#F8AFA8", "#FDDDA0", "#EE6A50", "#74A089")
sample_data(amphib_obj)$State_Region <-
    factor(sample_data(amphib_obj)$State_Region,
              levels = c("Northern California", "Coastal California",
                         "Sierra Nevada", "Southern California",
                         "Central America"))

## REMOVE OUTLIERS (Optional) -------
acts <- transform_sample_counts(amphib_obj, function(x) x / sum(x)) %>%
    psmelt()
outs <- acts$Sample[which(acts$Abundance > .8)] %>%
    append(c("SE108", "SE107", "SE110", "SE37", "SE39", "SE44", "SE72"))
nsmps <- setdiff(sample_names(amphib_obj), outs)
amphib_obj <- prune_samples(nsmps, amphib_obj)

## TAXA BARPLOT -------
# Create Database of OTU"s w/ 1% Category
txs <- amphib_obj %>%
    transform_sample_counts(function(x) x / sum(x)) %>%
    tax_glom(taxrank = "Phylum") %>%
    psmelt() %>%
    mutate(Prbd = as.numemric(0))
txs$Phylum <- as.character(txs$Phylum)
txs$Phylum <- factor(txs$Phylum,
                          levels = c("Acidobacteria", "Actinobacteria",
                                     "Armatimonadetes", "Bacteroidetes",
                                     "Chlamydiae", "Chloroflexi",
                                     "Cyanobacteria", "Deferribacteres",
                                     "Elusimicrobia", "Fibrobacteres",
                                     "Firmicutes", "Fusobacteria",
                                     "Gemmatimonadetes", "Lentisphaerae",
                                     "Nitrospirae", "Planctomycetes",
                                     "Proteobacteria", "TM7", "Verrucomicrobia",
                                     "WS3", "[Thermi]",
                                     "<1% Abundance"))

# Plot: Taxa
abs <- ggplot(txs, aes(x = Sample, y = Abundance, fill = Phylum)) +
    facet_wrap(~State_Region, scales = "free_x", nrow = 3) +
    geom_bar(aes(), stat = "identity", position = "stack") +
    scale_fill_manual(values = c("#E1BD6D", "#74A089", "#EABE94", "#FDDDA0",
                                 "#78B7C5", "#FF0000", "#00A08A", "#F2AD00",
                                 "#F98400", "#46ACC8", "#ECCBAE", "#F5CDB4",
                                 "#D69C4E", "#ABDDDE", "#446455", "#FDD262",
                                 "#EE6A50", "#899DA4", "#D3DDDC", "#9A8822",
                                 "#046C9A", "#000000")) +
    ylab("Relative Abunance") +
    theme(legend.justification = c(1, 0), legend.position = c(1, 0),
          legend.key.height = unit(0.75, "cm"),
          legend.key.width = unit(1.3, "cm"),
          axis.title = element_text(size = 16, family = "Georgia"),
          axis.text.x = element_blank(),
          axis.ticks.x = element_blank(), axis.title.x = element_blank(),
          legend.title = element_text(size = 14, family = "Georgia"),
          legend.text = element_text(size = 10, family = "Georgia"),
          strip.text = element_text(size = 14, family = "Georgia",
                                    face = "bold"),
          panel.background = element_rect(fill = "gray98"),
          panel.grid.major = element_blank()) +
    guides(fill = guide_legend(nrow = 6, title.position = "top"),
       theme(element_text(family = "Georgia")))
abs

#Fill Label Matches the Region Color
g <- ggplot_gtable(ggplot_build(abs))
stripr <- which(grepl("strip-t", g$layout$name))
flls <- c("#F8AFA8", "#EE6A50", "#9A8822", "#899DA4", "#FDDDA0")
k <- 1
for (i in c(32, 34, 35, 36, 37)) {
    j <- which(grepl("rect", g$grobs[[i]]$grobs[[1]]$childrenOrder))
    g$grobs[[i]]$grobs[[1]]$children[[j]]$gp$fill <- flls[k]
    k <- k + 1
}
grid.draw(g)

## ALPHA DIVERSITY -------
alphas <- estimate_richness(amphib_obj,
                            measure = c("Chao1", "Shannon", "Simpson"))
alphas$Evenness <- 0
for (i in seq_len(alphas)) {
  H <- alphas$Shannon
  S1 <- alphas$Chao1
  S <- log(S1)
  alphas$Evenness[i] <- H[i] / S[i]
}

# Stats: Alpha Diversity
asa <- merge(alphas, sample_data(amphib_obj), by = 0, all = TRUE)
shapiro.test(alphas$Shannon) #FAILED: p is 0.02106
bartlett.test(Evenness ~ State_Region, data = asa) #FAILED: p is 0.0049
# Reject Null: p = .0001
adonis(Evenness ~ State_Region, data = asa, permutations = 999)

# Plot: Alpha Diversity
alpha2 <- tidyr::gather(data.frame(alphas, sample_data(amphib_obj)),
                        key = "Measure",
                        value = "Value", Shannon, Chao1, Simpson, Evenness)
ggplot(data = alpha2, aes(x = State_Region, y = Value, color = State_Region)) +
  labs(color = "State Region", x = "State Region") +
  facet_wrap(~Measure, scale = "free", nrow = 1) +
  geom_jitter(width = 0.2) +
  stat_summary(aes(y = Value),
               fun.data = mean_cl_normal, colour = "#000000",
               geom = "errorbar") +
  scale_color_manual(values = c("#899DA4", "#FDDDA0", "#EE6A50", "#9A8822",
                               "#F8AFA8")) +
  theme(axis.text.x = element_text(angle = 70, hjust = 1, size = 10,
                                   colour = "black", family = "Georgia"),
        panel.border = element_blank(), axis.title.y = element_blank(),
        legend.title = element_text(size = 14, family = "Georgia"),
        legend.text = element_text(size = 12, family = "Georgia"),
        panel.grid.major = element_line(size = .3, linetype = "solid",
                                        colour = "gray80"),
        panel.background = element_rect(fill = "gray98"),
        axis.title = element_text(size = 16, family = "Georgia"))

## BETA DIVERSITY -------
# Stats: Beta Diversity
md <- data.frame(sample_data(amphib_obj))
perm <- adonis(phyloseq::distance(amphib_obj, method = "wunifrac") ~ Family,
       data = md, permutations = 999)
print(perm) # Reject Null
permutest(betadisper(phyloseq::distance(amphib_obj, method = "wunifrac"),
                     md$Order), pairwise = TRUE) # Sierras are different

# Prep for Plots
dist_models <- unlist(distanceMethodList)[-c(2, 3, 9, 12, 16, 20,
                                             27, 29, 35, 42, 43, 47)]
pca_list <- vector("list", length(dist_models))
names(pca_list) <- dist_models
for (i in dist_models) {
  iDist <- phyloseq::distance(amphib_obj, method = i)
  iMDS  <- ordinate(amphib_obj, "MDS", distance = iDist)
  # Make plot
  p <- NULL
  p <- plot_ordination(amphib_obj, iMDS, color = "State_Region",
                       shape = "Order") +
    ggtitle(paste("Distance Method ", i, sep = "")) +
    geom_point(size = 4) +
    theme(plot.title = element_text(size = 12, family = "Georgia"))
  # Save the graphic to file.
  pca_list[[i]] <- p
}
adm <- plyr::ldply(pca_list, function(x) x$data)
names(adm)[1] <- "distance"
# Print Individual plot: print(pca_list[["unifrac"]])
ds <- phyloseq::distance(amphib_obj, method = "unifrac")
ord <- ordinate(amphib_obj, "MDS", distance = ds)

# Plot: Grid of PCA's
ggplot(adm, aes(Axis.1, Axis.2, color = State_Region, shape = Order)) +
  geom_point(size = 1.5, alpha = 0.8) +
  scale_color_manual(values = royal) +
  facet_wrap(~distance, scales = "free") +
  labs(color = "State Region", x = "Axis 1", y = "Axis 2",
       shape = "Taxonomic Order") +
  theme(axis.title.x = element_text(size = 16, family = "Georgia"),
        axis.title.y = element_text(size = 16, family = "Georgia"),
        legend.title = element_text(size = 14, family = "Georgia"),
        panel.border = element_blank(),
        panel.grid.major = element_line(size = .45, linetype = "solid",
                                        colour = "gray75"),
        axis.line = element_line(colour = "black", size = 0.2),
        panel.background = element_rect(fill = "gray98"))

# Plot: PCA Plot of the Amphibian Beta Diversty (Main Plot)
plot_ordination(amphib_obj, ord, color = "State_Region", shape = "Order") +
  scale_color_manual(values = c("#899DA4", "#FDDDA0", "#EE6A50", "#9A8822",
                               "#F8AFA8")) +
  geom_point(size = 5) +
  annotate(geom = "text", x = 0, y = 0.25, label = "R. sierrae", size = 6)+
  stat_ellipse(type = "norm", level = 0.99)+
  labs(shape = "Host", color = "Region") +
  theme(panel.border = element_blank(),
        plot.title = element_text(size = 30, face = "bold"),
        plot.subtitle = element_text(size = 22, face = "italic"),
        legend.title = element_text(size = 16, family = "Georgia"),
        legend.text = element_text(size = 11, family = "Georgia"),
        axis.title.x = element_text(size = 16, family = "Georgia"),
        axis.title.y = element_text(size = 16, family = "Georgia"),
        panel.grid.major = element_line(size = .45, linetype = "solid",
                                        colour = "gray75"),
        axis.line = element_line(colour = "black", size = 0.2),
        panel.background = element_rect(fill = "gray98"))

## MAP THE SAMPLES -------
library("ggmap")
mgm <- get_stamenmap(bbox = c(bottom = 14.418492, left = -92.8479,
                              top = 16.098598, right = -90.227808),
                     maptype = "toner-background", zoom = 9,
                     crop = TRUE, color = "bw")

# Plot: Mexico/Guatemala Border
ggmap(mgm) +
    geom_point(data = sample_data(amphib_obj), color = "#F8AFA8",
               aes(x = Longitude, y = Latitude, shape = Order),
               size = 8, alpha = 0.6) +
    theme_void() +
    theme(legend.position = c(0.8, 0.14),
          legend.text = element_text(size = 14, family = "Georgia"),
          legend.title = element_text(size = 16, family = "Georgia")) +
    geom_text(label = "Mexico", nudge_x = 0.4, nudge_y = 1.3, size = 12,
              family = "Georgia") +
    geom_text(label = "Guatemala", nudge_x = 1.55, nudge_y = 1.4, size = 12,
              family = "Georgia")

# Map California Regions
cali <- subset(map_data("state"), region == "california")
cac <- subset(map_data("county"), region == "california")
cac$zone <- NA
for (i in seq_len(cac)) {
        srrs <- c("placer", "el dorado", "madera")
        ccm <- c("san francisco", "alameda", "santa cruz",
                 "monterey", "contra costa")
        scal <- c("san diego")
        ncal <- c("mendocino", "humboldt", "siskiyou", "shasta", "trinity",
                  "del norte", "sonoma", "trinity")
        if (is.element(cac$subregion[i], srrs)) {
            cac$zone[i] <- "Sierras"
        } else if (is.element(cac$subregion[i], ccm)) {
            cac$zone[i] <- "Coastal California"
        } else if (is.element(cac$subregion[i], scal)) {
            cac$zone[i] <- "Southern California"
        } else if (is.element(cac$subregion[i], ncal)) {
            cac$zone[i] <- "Northern California"
        }
}
detach("package:ggmap")

# Plot: Map of California
library("ggbrace")
ggplot(data = cali, mapping = aes(x = long, y = lat, group = group,
                                  fill = "white")) +
    coord_fixed(1.3) +
    geom_polygon(data = cac,  aes(fill = zone),  colour = "white", size = 0.1) +
    scale_fill_manual(values = c("#FDDDA0", "#899DA4", "#EE6A50", "#9A8822"),
                      name = "State Regions",
                      breaks = c("Coastal California",
                                 "Northern California",
                                 "Sierras",
                                 "Southern California"),
                      na.value = "lightgray") +
    geom_brace(aes(c(-125, -124.6), c(38.1, 42), label = "Bird et al"),
               color = "#899DA4", labelsize = 4, rotate = 270,
               inherit.data = F) +
    geom_brace(aes(c(-123, -122.7), c(38.1, 35.7),
                   label = "Prado-Irwin et al.
                   Bird et al."),
               rotate = 270, labelsize = 4, color = "goldenrod1",
               inherit.data = F) +
    geom_brace(aes(c(-118.2, -117.8), c(33.5, 32.5), label = "Prado-Irwin et al.
                   Bird et al."),
                   rotate = 270, labelsize = 4, color = "#9a8822",
               inherit.data = F) +
    geom_brace(aes(c(-118.9, -118.4), c(39.4, 36.8),
                   label = "Prado-Irwin et al.
Bird et al.
Ellison et al., 2018"),
                   rotate = 90, labelsize = 4, color = "#EE6A50",
               inherit.data = F) +
    xlim(-126.1, -113.75) +
    theme_void() +
    theme(legend.position = c(0.8, 0.85),
          legend.text = element_text(size = 12, family = "Georgia"),
          legend.title = element_text(size = 18, family = "Georgia",
                                      face = "bold"))
detach("package:ggbrace")

## CLUSTER ANALYSIS -------
exord_amp <- ordinate(amphib_obj, method = "MDS", distance = "bray")
# Gap Statistic
library(cluster)
pam1 <- function(x, k) {
    list(cluster = cluster::pam(x, k, cluster.only = TRUE))
}
x <- phyloseq:::scores.pcoa(exord_amp, display = "sites")
gskmn <- cluster::clusGap(x[, 1:2], FUN = pam1, K.max = 6, B = 50)
gskmn # shows 6 clusters
detach("package:cluster")

## OTU ANALYSIS -------
# Need to reinstall Deseq
# library("DESeq")
da <- phyloseq_to_deseq2(amphib_obj, ~ State_Region)
gm_mean <- function(x, na.rm = TRUE) {
  exp(sum(log(x[x > 0]), na.rm = na.rm) / length(x))
}
geo_means <- apply(counts(da), 1, gm_mean)
da <- estimateSizeFactors(da, geo_means = geo_means)
da <- DESeq(da, fitType = "local")
# detach("package:DESeq")
for (i in c(1, 2, 4, 5)) {
  altrg <- levels(sample_data(amphib_obj)$State_Region)[i]
  res <- results(da, contrast =
                c("State_Region", "Sierra Nevada", altrg), alpha = 0.01)
  res <- res[order(res$padj, na.last = NA), ]
  res_sig <- res[(res$padj < 0.01), ]
  res_sig$Comparison <- as.factor(paste0("Sierra Nevada vs ", altrg))
  assign(paste0("res_sig", i), cbind(as(res_sig, "data.frame"),
        as(tax_table(amphib_obj)[rownames(res_sig), ], "matrix")))
  while (i == 5) {
      otu_res <- Reduce(function(x, y) merge(x, y, all = TRUE),
                        list(res_sig1, res_sig2, res_sig4, res_sig5))
      rm(altrg, res, res_sig, res_sig1, res_sig2, res_sig4, res_sig5)
      i <- i + 1
  }
}

#Plot: OTU Abundances
otup <- ggplot(otu_res, aes(x = Order, y = log2FoldChange)) +
    geom_col(aes(fill = Phylum), width = 1) +
    scale_fill_manual(values = c("#E1BD6D", "#74A089", "#EABE94", "#FFC307",
                                 "#78B7C5", "#CC99CC", "#00A08A", "#FDDDA0",
                                 "#D69C4E", "#FDD262", "#D3DDDC", "#EE6A50",
                                 "#97D992")) +
facet_wrap(~Comparison) +
theme(plot.title = element_text(family = "Georgia"),
      axis.text.x = element_blank(),
      axis.ticks.x = element_blank(),
      axis.title.x = element_blank(), axis.title.y = element_blank(),
      strip.text = element_text(size = 14, family = "Georgia",
                                face = "bold"),
      panel.background = element_rect(fill = "gray98"),
      legend.position = c(0.82, 0.35), legend.title = element_blank(),
      legend.text = element_text(size = 9),
      legend.key.size = unit(0.3, "cm")) +
guides(fill = guide_legend(nrow = 6))
h <- ggplot_gtable(ggplot_build(otup))
stripr <- which(grepl("strip-t", h$layout$name))
flls <- c("#9A8822", "#F8AFA8",  "#899DA4", "#FDDDA0")
k <- 1
for (i in stripr) {
    j <- which(grepl("rect", h$grobs[[i]]$grobs[[1]]$childrenOrder))
    h$grobs[[i]]$grobs[[1]]$children[[j]]$gp$fill <- flls[k]
    k <- k + 1
}
grid.draw(h)
