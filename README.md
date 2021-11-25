# Master's Project: NGS Analysis & Microbiome Classification

## Summary
This repository is a collection of R, python, and linux scripts detailing microbial diversity across three countries. Each script is highly commented, so observe the first few lines of each script for a detailed description of what it accomplishes.

## Project Overview
### Preliminary Analysis
The majority of the prelim analysis was run through QIIME2: a Linux suite for analyzing microbial diversity. While QIIME2 does offer robust analytical tools for measuring microbial diversity, it's primary use for this project was to clean, trim, and organize raw NGS sequences. **qiime_pipeline_script** details the commands input into the suite organized in the general workflow of the pipeline. **taxon_pie** confirms array of microbial diversity, while **export_names.R** and **meta_merge.R** standardizes the metadata.

![](~/Documents/amphibian_meta_project/meta_analysis/plots

### NGS Analysis
### Statistical Analysis
These scripts use a combination of machine learning, and bioinformatics techniques including Principal Components Analysis, K-means, logisitic regression, PERMANOVA, and extensive visualizations to describe the genetic diversity of microbes residing on amphibians' skin.
