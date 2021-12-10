## PCA PLOT SCRIPTS: A script just for PCA plots
setwd("~/Documents/amphibian_meta_project/meta_analysis/qiime_analyses/
      meta-metrics/")
pcks <- c("ggplot2", "qiime2R", "dplyr", "vegan")
sapply(pcks, require, character.only = TRUE)
require(data.table)
meta_map <- read.table("../merged_metadata.txt", sep = "\t", header = TRUE)
meta_tree <- read_qza("AB_rootd.qza")
shannon <- read_qza("shannon_vector.qza")
unweighted_pco <- read_qza("unweighted_unifrac_pcoa_results.qza")
weighted_pco <- read_qza("weighted_unifrac_pcoa_results.qza")

## ALPHA DIVERSITY -------
alpha_frame <- shannon$data %>% as.data.frame() %>% rownames_to_column()
colnames(alpha_frame)[1] <- "SampleID"
alpha_meta <- left_join(alpha_frame, meta_map, by = "SampleID")

#Alpha Diversity Plot
ggplot(alpha_meta, aes(x = State_Region, y = shannon)) +
  geom_jitter(width = .15, alpha = .8, size = 4, aes(color = Order)) +
  xlab("Field Site") +
  ylab("Shannon Diversity") +
  labs(title = "Meta Shannon",
       subtitle = "Colored by Species",
       color = "Species") +
  theme(plot.title = element_text(size = 28, face = "bold"),
        plot.subtitle = element_text(size = 22, face = "italic"),
        axis.title = element_text(size = 16))

## BETA DIVERSITY -------
beta_frame <- as.data.frame(unweighted_pco$data$Vectors) %>%
 left_join(meta_map, by = "SampleID") #combine metadata
beta2_frame <- as.data.frame(weighted_pco$data$Vectors) %>% #weighted
  left_join(meta_map, by = "SampleID", copy = TRUE)
royal <- c("#899DA4", "#9A8822", "#F5CDB4", "#F8AFA8", "#FDDDA0", "#EE6A50",
           "#74A089")

#Beta Diversity Plot
ggplot(beta_frame, aes(x = PC2, y = PC1, color = State_Region)) +
  geom_point(aes(shape = Order), size = 4) +
  xlab(paste("PC1: ",
             round(100 * weighted_pco$data$ProportionExplained[1]), "%")) +
  ylab(paste("PC2: ",
             round(100 * weighted_pco$data$ProportionExplained[2]), "%")) +
  scale_color_manual(values = royal) +
  labs(shape = "Host", color = "Region") +
  theme(panel.border = element_blank(),
        legend.title = element_text(size = 16, family = "Georgia"),
        legend.text = element_text(size = 11, family = "Georgia"),
        axis.title.x = element_text(size = 16, family = "Georgia"),
        axis.title.y = element_text(size = 16, family = "Georgia"),
        panel.grid.major = element_line(size = .45, linetype = "solid",
                                        colour = "gray75"),
        axis.line = element_line(colour = "black", size = 0.2),
        panel.background = element_rect(fill = "gray98"))
