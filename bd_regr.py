### BD LOGISTIC REGRESSION ANALYSIS
# This script assess the likelihood a sample will develop a high Bd load


#-------------------------#
## IMPORT DATA & LIBRAIES
# Import Libraries
import pandas as pd
import numpy as n
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.linear_model import LogisticRegression
from sklearn.compose import make_column_transformer
from sklearn.pipeline import make_pipeline
from sklearn import model_selection

# Import Data
md = pd.read_table('~/Documents/amphibian_meta_project/meta_analysis/' +
        'qiime_analyses/merged_metadata.txt', delimiter= '\t')


#-------------------------#
## EXPLORATORY DATA ANALYSIS
md.head()
md.shape
print(md.columns)

# Visualize Differences
pd.crosstab(md['Species'], md['Bd_status']).plot(kind = 'bar')
plt.show()
print(type(md))

#-------------------------#
## CLEAN & FORMAT DATA
# List only columns useful to study
['Latitude', 'State_Region', 'Species']

# Create Dummy Variables
rgs = pd.get_dummies(md['State_Region'], drop_first=True)
spp = pd.get_dummies(md['Species'], drop_first=True)
lat = md['Latitude']

# Create new Dataframe
x = pd.concat([rgs, spp, lat], axis=1)
y = md.Bd_status
md1 =  pd.concat([rgs, spp, lat, y], axis=1)
md1.columns



#-------------------------#
## BUILD REGRESSION MODEL
# Define Classificatioin Model
model = LogisticRegression(solver='liblinear', random_state=0)





