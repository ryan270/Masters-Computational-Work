## {{{ META MERGE: Merge mapping files from each dataset
import pandas as pd
import numpy as np
abmap = pd.read_table("~/Documents/amphibian_meta_project/meta_analysis/" +
        "qiime_analyses/AB_mapping_file.txt", sep='\t')
mgmap = pd.read_table('~/Documents/amphibian_meta_project/meta_analysis/' +
        'qiime_analyses/MG_Mapping_File_GUA_with_Bd.txt', sep='\t')
spimap = pd.read_table('~/Documents/amphibian_meta_project/meta_analysis/' +
        'qiime_analyses/SPI_mapping_file.txt', sep='\t')
semap = pd.read_table('~/Documents/amphibian_meta_project/meta_analysis/' +
        'qiime_analyses/SE_mapping_file.txt', sep='\t') # }}}

## {{{ DIVIDE CALIFORNIA INTO REGIONS
abmap['State_Region'] = np.nan
abmap.loc[(abmap['Site']=='Alameda') | (abmap['Site']=='Monterey'),
    'State_Region'] = 'Coastal California'
abmap.loc[(abmap['Site']=='Jackson_State_Forest') |
        (abmap['Site']=='Siskiyou') | (abmap['Site']=='Shasta') |
        (abmap['Site']=='Humboldt') | (abmap['Site']=='Leggett'),
        'State_Region'] = 'Northern California'
abmap.loc[(abmap['Site']=='Sierra_National_Forest'),
        'State_Region'] = 'Sierra Lowland'
abmap['State_Region'] = abmap['State_Region'].replace(
        np.nan, 'Southern California')

spimap['State_Region'] = np.nan
spimap.loc[(spimap['Site']=='Alameda') | (spimap['Site']=='Santa.Cruz') |
        (spimap['pop']=='north.bay'), 'State_Region'] = 'Coastal California'
spimap.loc[(spimap['Site']=='Madera'), 'State_Region'] = 'Sierra Lowland'
spimap.loc[(spimap['pop']=='annadel'), 'State_Region'] = 'Northern California'
spimap['State_Region'] = spimap['State_Region'].replace(np.nan,
        'Southern California')
spimap['State_Region'].value_counts()

semap['State_Region'] = 'Sierra Highland'
semap['Latitude'] = np.nan
semap['Longitude'] = np.nan
semap.loc[(semap['site_id']=='Pyramid_Valley'), 'Latitude'] = 38.825959
semap.loc[(semap['site_id']=='Rivendell'), 'Latitude'] = 38.848118
semap.loc[(semap['site_id']=='Pyramid_Valley'), 'Longitude'] = -120.142295
semap.loc[(semap['site_id']=='Rivendell'), 'Longitude'] = -120.163238 # }}}

## {{{ FORMAT COLUMNS
abmap = abmap.drop(['Higher_Clade', 'Lower_Clade', 'Habitat_Type',
    'Bd_status'], axis=1)
mgmap = mgmap.drop(['BarcodeSequence', 'LinkerPrimerSequence', 'ReversePrimer',
    'Collector_number', 'subspecies', 'Country', 'County_Municipio', 'Site',
    'Date', 'Sex', 'Age_Class', 'ZE', 'Log_ZE', 'Elevation', 'Mountain_range',
    'Geology', 'Habitat', 'Description', 'Bd_Status'], axis=1)
spimap = spimap.drop(['BarcodeSequence', 'LinkerPrimerSequence',
    'ReversePrimer', 'type', 'project1', 'project2', 'subspecies', 'pop', 'age',
    'sex', 'cov.obj', 'svl', 'tot.lgth', 'wgt', 'soil.moist', 'soil.temp',
    'cov.wd', 'cov.lth', 'date', 'Description'], axis=1)
semap = semap.drop(['BarcodeSequence', 'LinkerPrimerSequence', 'ReversePrimer',
    'Sample_Name', 'frog_id', 'lifestage', 'gosner_stage', 'month', 'year',
    'ZE', 'survey_date', 'pit_tag_id', 'frog_sex', 'extraction_date',
    'frog_location', 'frog_weight', 'frog_svl', 'swabber_name', 'Description',
    'Bd_status'],
    axis=1)

abmap = abmap.rename(columns={'Sample_Type':'Order'})
semap = semap.rename(columns={'site_id':'Site'})
mgmap = mgmap.rename(columns={'State_Province': 'Site'})
spimap = spimap.rename(columns={'county': 'Site',
    'lat':'Latitude', 'long':'Longitude'})
mgmap = mgmap.drop([0, 78, 79, 80, 81, 82])
mgmap['Latitude'] = mgmap['Latitude'].astype('float')
mgmap['Longitude'] = mgmap['Longitude'].astype('float')
mgmap['State_Region'] = "Central America"
abmap['Dataset'] = "Bird et al., 2018"
mgmap['Dataset'] = "Ellison et al., 2018"
semap['Dataset'] = "Ellison et al., 2019"
spimap['Dataset'] = "Prado-Irwin et al., 2017" # }}}

## {{{ TAXONOMY & BD
abmap['Family'] = "Plethodontidae"
abmap['Order'] = "Salamander"
spimap['Family'] = "Plethodontidae"
spimap['Order'] = "Salamander"
spimap['Genus'] = "Ensatina"
spimap['Species'] = "Ensatina_eschscholtzii"
semap['Species'] = "Rana_sierrae"
semap['Genus'] = "Rana"
semap['Family'] = "Ranidae"
semap['Order'] = "Frog"
mgmap['Order'] = mgmap['Order'].apply(lambda x: 'Salamander' if x=='Caudata'
        else 'Frog') # }}}

## {{{ JOIN & EXPORT TABLES ------
dfs = [abmap, spimap, mgmap, semap]

from functools import reduce
mm = reduce(lambda left,right: pd.merge(left,right, on=["SampleID",
    "State_Region", "Dataset", "Longitude", "Latitude", "Family", "Genus",
    "Species", "Order", "Site"], how='outer'), dfs)

mm.to_csv('~/Documents/amphibian_meta_project/meta_analysis/' +
        'qiime_analyses/merged_metadata.txt', sep="\t", header=True,
        index=False)
# }}}
