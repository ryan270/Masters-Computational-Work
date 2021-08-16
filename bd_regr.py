### BD LOGISTIC REGRESSION ANALYSIS
# This script assess the likelihood a sample will develop a high Bd load


#-------------------------#
## IMPORT DATA & LIBRAIES
# Import Libraries
from numpy.lib.shape_base import column_stack
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.linear_model import LogisticRegression
from sklearn.compose import make_column_transformer
from sklearn.pipeline import make_pipeline
from sklearn import model_selection

# Import Data
md = pd.read_table('~/Documents/amphibian_meta_project/meta_analysis/' +
        'qiime_analyses/merged_metadata.txt')

#-------------------------#
## EXPLORATORY DATA ANALYSIS
np.shape(md)

# Visualize Differences
pd.crosstab(md.Dataset, md.Bd_status).plot(kind = 'bar')
plt.show()


# Drop Columns not Important to Study & NA's
md = md.drop(['State_Province', 'Habitat', 'pop', 'subspecies'], axis = 1)
md = md.dropna(axis = 0)
