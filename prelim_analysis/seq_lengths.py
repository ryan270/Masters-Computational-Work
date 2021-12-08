###SEQUENCE QUALITY METRICS
#This script confirms the similarity of sequence metrics between the four
# datasets.

##LOAD PACKAGES, DATA, AND DIRECTORY
#Set Directory and Load required Packages
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

metrics = pd.read_csv("~/Documents/amphibian_meta_project/meta_analysis/" +
        "qiime_analyses/seq-metrics/meta_bioinf_metrics.csv")

sns.plot(data=metrics, x=Dataset, y=Mean_Seq_Lngth)
