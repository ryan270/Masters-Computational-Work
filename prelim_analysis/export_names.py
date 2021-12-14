## EXPORT NAMES: Create a summarized table of the metadata
import numpy as np
import pandas as pd
ampm = pd.read_table("~/Documents/amphibian_meta_project/meta_analysis/" +
        "qiime_analyses/merged_metadata.txt", sep="\t")


## {{{ STANDARDIZE DATA FOR EACH REGION
# Create vectors for Sample sizes & Species
se_d = pd.DataFrame({"Paper": ["Ellison et al., 2018"],
    "Species": ["Rana sierrae"],
    "Region": ["Sierra Nevada"],
    "N": 130})

# MG Dataset
mg = ampm.loc[ampm["Dataset"] == "Ellison et al., 2018"]
mg_spp = mg['Species'].unique()
mg_sam = []
for i in mg_spp:
    mg_sam.append(len(mg.loc[mg['Species'] == i]))
mg_d = pd.DataFrame({'Paper': 'Ellison et al., 2018',
    'Species': mg_spp,
    'Region': 'Central America',
    'N': mg_sam})

# SPI Dataset
spi = ampm.loc[ampm['Dataset'] == 'Prado-Irwin et al., 2017']
spi_sam = []
for reg in spi['State_Region'].unique():
    spi_sam.append(len(spi.loc[spi['State_Region'] == reg]))
spi_d = pd.DataFrame({'Paper': 'Prado-Irwin et al., 2017',
    'Species': "Ensatina eschscholtzii",
    'Region': spi['State_Region'].unique(),
    'N': spi_sam})

# AB Dataset
