# Master's Project: NGS Analysis & Microbiome Classification
![](https://vectorified.com/images/dna-icon-png-17.png)

## Summary
This repository is a collection of R, Python, and Linux scripts detailing microbial diversity on amphibian across three countries. These scripts include techniques like supervised machine learning, extensive visualization, and a multitude of statistical principles employed to measure diversity. Each script is highly commented for educational & collaborative purposes.In my opinion, the narrative is just as important as the code.

## Project Overview
### Preliminary Analysis
The majority of the prelim analysis (cleaning, trimming, quality analysis, etc.) was run through QIIME2: a Linux suite for analyzing microbial diversity. **qiime_pipeline_script** details the commands input into the suite organized in the general workflow of the pipeline. **export_names.R** and **meta_merge.R** standardizes the metadata, while the plot below confirms standardization of seq lengths.

### NGS Analysis
