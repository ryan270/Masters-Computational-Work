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

## {{{ FORMAT COLUMNS
abmap = abmap.drop(['Sample_Type', 'Higher_Clade'], axis=1)
mgmap = mgmap.drop(['LinkerPrimerSequence', 'ReversePrimer', 'BarcodeSequence',
    'Sex', 'Age_Class', 'Geology', 'Site', 'Mountain_range', 'Collector_number',
    'ZE', 'Log_ZE', 'Elevation', 'Description', 'Date', 'Country'], axis=1)
spimap = spimap.drop(['LinkerPrimerSequence', 'ReversePrimer', 'BarcodeSequence',
    'project1', 'project2', 'type', 'age', 'sex', 'cov.obj', 'soil.moist',
    'soil.temp', 'cov.wd', 'cov.lth', 'date', 'Description', 'svl',
    'tot.lgth', 'wgt'], axis=1)
semap = semap.drop(['Sample_Name', 'month', 'frog_location', 'extraction_date',
    'BarcodeSequence', 'year', 'frog_id', 'survey_date', 'frog_weight',
    'Description', 'LinkerPrimerSequence', 'lifestage', 'ZE', 'pit_tag_id',
    'frog_svl', 'ReversePrimer', 'gosner_stage', 'frog_sex',
    'swabber_name', 'site_id'], axis=1)
abmap = abmap.rename(columns={'Habitat_Type':'Habitat',
    'Lower_Clade':'subspecies'})
mgmap = mgmap.rename(columns={'County_Municipio': 'Site',
    'Bd_Status':'Bd_status'})
spimap = spimap.rename(columns={'county': 'Site',
    'lat':'Latitude', 'long':'Longitude'})
mgmap=mgmap.drop(mgmap.index[78:])
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
        else 'Frog')
abmap['Bd_status'] = abmap['Bd_status'].apply(lambda x: 0 if x=='Negative'
        else 1)
semap['Bd_status'] = semap['Bd_status'].apply(lambda x: 0 if x=='Negative'
        else 1) # }}}

## {{{ DIVIDE CALIFORNIA INTO FOUR REGIONS
abmap['State_Region'] = np.nan
abmap.loc[(abmap['Site']=='Alameda') | (abmap['Site']=='Monterey'),
    'State_Region'] = 'Coastal California'
abmap.loc[(abmap['Site']=='Jackson_State_Forest') |
        (abmap['Site']=='Siskiyou') | (abmap['Site']=='Shasta') |
        (abmap['Site']=='Humboldt') | (abmap['Site']=='Leggett'),
        'State_Region'] = 'Northern California'
abmap.loc[(abmap['Site']=='Sierra_National_Forest'),
        'State_Region'] = 'Sierra Nevada'
abmap['State_Region'] = abmap['State_Region'].replace(
        np.nan, 'Southern California')

spimap['State_Region'] = np.nan
spimap.loc[(spimap['county']=='Alameda') | (spimap['county']=='Santa.Cruz') |
        (spimap['pop']=='north.bay'), 'State_Region'] = 'Coastal California'
spimap.loc[(spimap['county']=='Madera'), 'State_Region'] = 'Sierra Nevada'
spimap.loc[(spimap['pop']=='annadel'), 'State_Region'] = 'Northern California'
spimap['State_Region'] = spimap['State_Region'].replace(
        np.nan, 'Southern California')
spimap['State_Region'].value_counts()

semap['State_Region'] = 'Sierra Nevada' # }}}
