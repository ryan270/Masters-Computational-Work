# Master's Project: NGS Analysis & Microbiome Classification

<p align="center">
  <img src="https://vectorified.com/images/dna-icon-png-17.png" />
</p>

This repository is a collection of scripts written to estimate microbial diversity on amphibian across three countries and measure the impact of microbial diversity on host health. These scripts include techniques like supervised machine learning, data visualization, and a multitude of statistical concepts employed to measure diversity.

## Project Overview
### Preliminary Analysis
The majority of the prelim analysis (cleaning, trimming, quality analysis, etc.) was run through QIIME2: a Linux suite for analyzing microbial diversity. **qiime_pipeline_script** details the commands input into QIIME organized in the general workflow of the pipeline. In addition to preliminary work, QIIME2 was also used to construct an alinment and a phylogenetic tree. The plot below is an interactive 3D Bray-Curtis PCA plot generated by Emporer using QIIME2. The colors represent the differences of microbial diversity by changes of latitude.
![Bray-Curtis-Latitude](https://user-images.githubusercontent.com/32527761/145268955-30d931cb-040a-4d12-ba40-a8b674431683.png)
_One particular population located at unique latitudes have distincly similar microbiomes._

**Meta_merge.R** merges and standardizes the metadata for each of the datasets. **Export_names.R** creates a table summarizing the metadata.

### NGS Analysis
**Meta_analyze.R** is the central script of this project. It contains the
majority of the diversity analysis on the microbiomes and nearly all of the
visualizations. Diversity analysis includes:
- 4 independent estimations of alpha diversity and 24 independent estimations of
  Beta diversity.
- ANOVA's, PERMANOVA's, and Principle Component Analysis to qualify and validate the differences in diversity.
- Comparison of the diversity across taxonomy, geography, microbiome profile,
  and infection status
- Visualizations representing the output of all analyses using a cohesive,
  color-blind-friendly color palette.
The plots below indicate the sampling range across all four datasets, and a PCA plot showing the diversity on amphibians across entire sampling range.
<p float="center">
  <img src="https://user-images.githubusercontent.com/32527761/145129143-aafa360b-ae36-4e0e-ac0f-2165511b6ca0.png" />
  <img src="https://user-images.githubusercontent.com/32527761/145129232-e9546a3f-df93-4303-954a-6898ed6c8edb.png" />
</p>

