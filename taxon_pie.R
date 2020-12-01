###TAXON PIE CHARTS
#This script will make pie charts from the preliminary taxonomic counts from ensatina_data
#pie charts made from taxonomy before sampling was random
# sample list ~/Documents/ensatina_x/qiime_work_2/sample_list.txt

##SET DIRECTORY AND LOAD PACKAGES
setwd('/Users/ade/Documents/amphibian_meta_project/california_x/')
pcks <- c('ggplot2', 'ggthemes', 'stringr')
sapply(pcks, require, character.only = T)
require(data.table)

#Load .tsv files
tax.1 <- as.data.frame(fread('AB_taxonomy.tsv'))
summary(tax.1)

##FORMATTING
#remove first row
tax.1 <- tax.1[-c(1),]

#Rename default name to family name for the first pie chart
for (i in tax.1$Taxon) {
  if (str_detect(i, 'Proteobacteria') ==  TRUE) {
    gsub('Proteobacteria', tax.1$Taxon)
  }
}


tax.1$Taxon <- (gsub('k__Bacteria; p__Chlamydiae; c__Chlamydiia; o__Chlamydiales; f__Chlamydiaceae', 
                     'Chlamydiaceae', tax.1$Taxon))
tax.1$Taxon <- (gsub("k__Bacteria; p__Acidobacteria; c__Acidobacteriia; o__Acidobacteriales; f__Acidobacteriaceae; g__Granulicella; s__paludicola",
                     'Acidobacteriaceae', tax.1$Taxon))
tax.1$Taxon <- (gsub("k__Bacteria; p__Bacteroidetes; c__Sphingobacteriia; o__Sphingobacteriales; f__Sphingobacteriaceae; g__Mucilaginibacter; s__rigui",
                     'Sphingobacteriaceae', tax.1$Taxon))
tax.1$Taxon <- gsub("k__Bacteria; p__Proteobacteria; c__Gammaproteobacteria; o__Xanthomonadales; f__Xanthomonadaceae; g__Arenimonas; s__oryziterrae",
                    'Xanthomonadaceae', tax.1$Taxon)
tax.1$Taxon <- gsub("k__Bacteria; p__Actinobacteria; c__Actinobacteria; o__Actinomycetales; f__Nocardioidaceae; g__Nocardioides",
                    'Nocardioidaceae', tax.1$Taxon)
tax.1$Taxon <- gsub("k__Bacteria; p__Proteobacteria; c__Gammaproteobacteria; o__Enterobacteriales; f__Enterobacteriaceae; g__Pseudomonas; s__syringae",
                    'Enterobacteriaceae', tax.1$Taxon)
tax.1$Taxon <- gsub("k__Bacteria; p__Bacteroidetes; c__Sphingobacteriia; o__Sphingobacteriales; f__Sphingobacteriaceae; g__Cytophagales; s__MBIC4147",
                    'Sphingobacteriaceae', tax.1$Taxon)
tax.1$Taxon <- gsub("k__Bacteria; p__Actinobacteria; c__Actinobacteria; o__Actinomycetales; f__Micromonosporaceae",
                    'Micromonosporaceae', tax.1$Taxon)

#blank theme for pie_chart
blank_theme <- theme_minimal()+
  theme(
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    panel.border = element_blank(),
    panel.grid=element_blank(),
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    plot.title=element_text(size=14, face="bold")
  )

#TAXONOMY 1 PIE CHART!!
#can't store plot as variable
ggplot(tax.1, aes(x = factor(1), fill = Taxon))+
  geom_bar(width = 1)+
  coord_polar('y', start = 0)+
  blank_theme+
  labs(title = 'California Diversity',
       subtitle = 'Preliminary Results')+
  theme(plot.title = element_text(size = 32, face = "bold"))+
  theme(plot.subtitle = element_text(size = 22, face = "italic"))+
  theme(legend.position = 'none') #use in case you don't correct names

ggplot(data = tax.1, aes(x = Taxon))+
  geom_col(stat = 'count')


#repeat for tax.2
tax.2 <- tax.2[-c(1),]

tax.2$Taxon <- gsub("k__Bacteria; p__Chlamydiae; c__Chlamydiia; o__Chlamydiales; f__Parachlamydiaceae; g__; s__",
                    'Parachlamydiaceae', tax.2$Taxon)
tax.2$Taxon <- gsub("k__Bacteria; p__Bacteroidetes; c__Cytophagia; o__Cytophagales; f__Flammeovirgaceae; g__Flexithrix; s__",
                    'Flammeovirgaceae', tax.2$Taxon)
tax.2$Taxon <- gsub("k__Bacteria; p__Proteobacteria; c__Gammaproteobacteria; o__Xanthomonadales; f__Xanthomonadaceae; g__; s__",
                    'Xanthomonodaceae', tax.2$Taxon)
tax.2$Taxon <- gsub("k__Bacteria; p__Actinobacteria; c__Actinobacteria; o__Actinomycetales; f__Streptomycetaceae; g__Streptomyces; s__",
                    'Streptomycetaceae', tax.2$Taxon)
tax.2$Taxon <- gsub("k__Bacteria; p__Actinobacteria; c__Actinobacteria; o__Actinomycetales",
                    'Actinomycetales order', tax.2$Taxon)
tax.2$Taxon <- gsub("k__Bacteria; p__Proteobacteria; c__Gammaproteobacteria; o__Pseudomonadales; f__Pseudomonadaceae; g__Pseudomonas; s__veronii",
                    'Pseudomonadaceae', tax.2$Taxon)
tax.2$Taxon <- gsub("k__Bacteria; p__Proteobacteria; c__Gammaproteobacteria; o__Pseudomonadales; f__Pseudomonadaceae; g__Pseudomonas; s__",
                    'Pseudomonadaceae', tax.2$Taxon)
tax.2$Taxon <- gsub("k__Bacteria; p__Proteobacteria; c__Gammaproteobacteria; o__Pseudomonadales; f__Pseudomonadaceae; g__Pseudomonas",
                    'Pseudomonadaceae', tax.2$Taxon)
tax.2$Taxon <- gsub("k__Bacteria; p__Bacteroidetes", 'Bacteroidetes phylum', tax.2$Taxon)

##PLOT
#TAXONOMY 2 PIE CHART
ggplot(tax.2, aes(x = factor(1), fill = Taxon))+
  geom_bar(width = 1)+
  coord_polar('y', start = 0)+
  blank_theme+
  labs(title = 'Ensatina Microbial Diversity',
       subtitle = 'First 100 reads, first pass at QIIME pipeline,
       classifier re-trained')+
  theme(plot.title = element_text(size = 20, face = "bold"))+
  theme(plot.subtitle = element_text(size = 14, face = "italic"))
