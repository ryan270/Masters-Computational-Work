# SEQ METRICS: Confirms/denies the uniformity of seq lengths across datasets
setwd("~/Documents/amphibian_meta_project/meta_analysis/qiime_analyses/seq-metrics")
pcks <- c("ggplot2", "wesanderson")
sapply(pcks, require, character.only = T)
metrics <- read.csv("meta_bioinf_metrics.csv")

# Plot
ggplot(metrics, aes(x = Dataset, y = Features)) +
    geom_boxplot() +
    xlab("Dataset") +
    ylab("Mean Sequence Length") +
    scale_x_discrete(breaks = c("Bird_et_al._2018",
                                "Ellison_et_al._2018",
                                "Ellison_et_al._2019",
                                "Prado-Irwin_et_al._2017"),
                     labels = c("Cal Salamanders Data",
                                "Mexico-Guatemala Data",
                                "Sierra Frogs Data",
                                "Ensatina Data")) +
    theme_bw() +
    theme(legend.position = "none",
          axis.title = element_text(size = 16, family = "Georgia"),
          axis.text.x = element_text(size = 12, family = "Georgia"),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.border = element_blank(),
          axis.line = element_line(colour = "black", size = 0.25))
