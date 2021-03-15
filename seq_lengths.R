###SEQUENCE QUALITY METRICS
#This script analyzes the sequence lengths, features, and overall quality...
#...of the four datasets used in the meta analysis
#Data won't plot as boxplot because data isnt' raw.
#...the length of the dataset is 4, which isn't enough to plot a boxplot


##LOAD PACKAGES, DATA, AND DIRECTORY
#Set Directory and Load required Packages
setwd('~/Documents/amphibian_meta_project/meta_analysis/qiime_analyses/seq-metrics/')
pcks <- c('ggplot2', 'wesanderson')
sapply(pcks, require, character.only = T)

metrics <- read.csv(file = 'meta_bioinf_metrics.csv', header = TRUE, sep = ',',
                    quote = "")

##SEQ METRICS
ggplot(metrics, aes(x = Dataset, y = Mean_Seq_Lngth))+
    geom_boxplot()+
    xlab('Dataset')+
    ylab('Mean Sequence Length')+
    scale_x_discrete(breaks = c("Bird_et_al._2018", "Ellison_et_al._2018",
                                "Ellison_et_al._2019", "Prado-Irwin_et_al._2017"),
                     labels = c("Cal Salamanders Data", "Mexico-Guatemala Data",
                                "Sierra Frogs Data", "Ensatina Data"))+
    theme_bw()+
    theme(legend.position = 'none',
          axis.title = element_text(size = 16, family = "Georgia"),
          axis.text.x = element_text(size = 12, family = "Georgia"),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.border = element_blank(),
          axis.line = element_line(colour = 'black', size = 0.25))
