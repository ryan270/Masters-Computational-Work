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
for reg in mg_spp:
    mg_sam.append(len(mg.loc[mg['Species'] == reg])
mg_d = pd.DataFrame({'Paper': 'Ellison et al., 2018',
    'Species': mg_spp,
    'Region': 'Central America',
    'N': mg_sam}

# SPI Dataset
spi = ampm.loc[ampm['Dataset'] == 'Prado-Irwin et al., 2017']
spi_sam = []
for reg in spi['State_Region'].unique():
    spi_sam.append(len(spi.loc[spi['State_Region'] == reg])
spi_d = pd.DataFrame({'Paper': 'Prado-Irwin et al., 2017',
    'Species': "Ensatina eschscholtzii",
    'Region': spi['State_Region'].unique(),
    'N': spi_sam})

# AB Dataset
ab = ampm.loc[ampm['Dataset'] == 'Bird et al., 2018']
ab_spp = ab['Species'].unique()
ab_reg = ab['State_Region'].unique()
ab_sam = []
for reg in ab_reg:
    k = ab.loc[ab['State_Region'] == reg]
    for j in ab_spp:
        ab_sam.append(len(k.loc[ab['Species'] == j]))
from itertools import repeat
ab_d = pd.DataFrame({'Paper': 'Bird et al., 2018',
    'Species': np.concatenate(list(repeat(ab_spp, 4))),
    'Region': np.concatenate(list(repeat(ab_reg, 4))),
    'N': ab_sam}).sort_values(by=['Region'], ascending=True) # }}}

## {{{ MERGE, FORMAT, WRITE TABLE
info_table = pd.DataFrame()
