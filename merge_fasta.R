###MERGE THE FASTA FILES OF ALL DATASETS

##LOAD LIBRARIES & DATASETS
setwd('~/Documents/amphibian_meta_project/meta_analysis/qiime_analyses/')
library(seqinr)
library(dplyr)

#Load Datasets
abseqs <- read.fasta(file = "AB_qiime_seqs.fasta", forceDNAtolower = FALSE)
mgseqs <- read.fasta(file = 'MG_qiime_seqs.fasta', forceDNAtolower = FALSE)
seseqs <- read.fasta(file = 'SE_qiime_seqs.fasta', forceDNAtolower = FALSE)
spiseqs <- read.fasta(file = 'SPI_qiime_seqs.fasta', forceDNAtolower = FALSE)

#Merge Lists
abmg.seqs <- (RCurl::merge.list(abseqs, mgseqs))
sdspi.seqs <- (RCurl::merge.list(seseqs, spiseqs))
meta.seqs <- (RCurl::merge.list(abmg.seqs, sdspi.seqs))

#Export & Write
write.fasta(meta.seqs, names = names(meta.seqs), file.out = "formatted_meta_seqs.fasta", open = "w", as.string = FALSE)

