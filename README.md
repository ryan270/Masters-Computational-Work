# Master's Project: NGS Analysis & Microbiome Classification

<p align="center">
  <img src="https://vectorified.com/images/dna-icon-png-17.png" />
</p>

## Summary
This repository is a collection of R, Python, and Linux scripts detailing microbial diversity on amphibian across three countries. These scripts include techniques like supervised machine learning, extensive visualization, and a multitude of statistical principles employed to measure diversity. Each script is highly commented for educational & collaborative purposes.In my opinion, the narrative is just as important as the code.

## Project Overview
### Preliminary Analysis
The majority of the prelim analysis (cleaning, trimming, quality analysis, etc.) was run through QIIME2: a Linux suite for analyzing microbial diversity. **qiime_pipeline_script** details the commands input into QIIME organized in the general workflow of the pipeline. The table below shows a summary of all the sequences after denoising, trimming, and merging 4 datasets of NGS data. The features described are unclustered Amplicon Sequence Variants.
![table-metrics](https://user-images.githubusercontent.com/32527761/145107820-36a40813-9dff-4064-bc21-f61d06e76ab5.png)

**seq_lengths.R** confirms the similarity of feature lengths between the four
datasets prior to merging.
![Seq-Lengths](https://user-images.githubusercontent.com/32527761/145122142-ac7ed1ac-cdf9-438f-84a7-2a38f6367ebe.png)

**Meta_merge.R** merges and standardizes the metadata for each of the datasets. **Export_names.R** creates a table summarizing the metadata:
![Data-Info](https://user-images.githubusercontent.com/32527761/145119116-478a560b-6f39-46b7-9c47-d1b6c55e9f66.png)

### NGS Analysis
**Meta_analyze.R** is the central script of this project. It contains the
majority of the diversity analysis on the microbiomes and nearly all of the
visualizations.

Below shows California defined by county regions and PCA plot of the microbial
diversity on amphibians across entire sampling range.
<p align="left">
  <img src="https://github.com/ryan270/Masters-Computational-Work/files/7672428/cali_labels_2.pdf" />
</p>

<p align="right">
  <img src="https://github.com/ryan270/Masters-Computational-Work/files/7672437/the_plotv11.pdf" />
</p>

