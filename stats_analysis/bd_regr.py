## BD LOGISTIC REGRESSION ANALYSIS: predicts the likelihood a fatal BD load
md = pd.read_table('~/Documents/amphibian_meta_project/meta_analysis/' +
        'qiime_analyses/merged_metadata.txt', delimiter= '\t')

## {{{ CLEAN & FORMAT DATA
import pandas as pd
import numpy as np
md = md[['Latitude', 'State_Region', 'Species', 'Bd_status']]
md = md.dropna(axis = 0)
rgs = pd.get_dummies(md['State_Region'], drop_first=True)
spp = pd.get_dummies(md['Species'], drop_first=True)
lat = md['Latitude']
x = pd.concat([rgs, spp, lat], axis=1)
y = md.Bd_status
md1 =  pd.concat([rgs, spp, lat, y], axis=1) # }}}

## {{{ BUILD REGRESSION MODEL
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression
import matplotlib.pyplot as plt
x_train, x_test, y_train, y_test = train_test_split(x, y, test_size = 0.3)
mdl = LogisticRegression()
mdl.fit(x_train, y_train)
predictions = mdl.predict(x_test)
plt.hist(y_test - predictions)
plt.show() # }}}
