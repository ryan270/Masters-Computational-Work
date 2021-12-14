# SEQ METRICS: Confirms/denies the uniformity of seq lengths across datasets
from pandas import read_csv as pdr
import seaborn as sns
from math import sqrt
from matplotlib import pyplot as plt
metrics = pdr("~/Documents/amphibian_meta_project/meta_analysis/" +
        "qiime_analyses/seq-metrics/meta_bioinf_metrics.csv")
metrics['Seq_SE'] = metrics['Seq_SD']/sqrt(len(metrics['Seq_SD']))

# Plot
g = sns.FacetGrid(metrics, size=5)
g.map(plt.errorbar, 'Dataset', 'Mean_Seq_Lngth', 'Seq_SE',
        marker='o')
g.set_xticklabels(["Ellison et al., 2019",
        "Prado-Irwin et al., 2017",
        "Ellison et al., 2018",
        "Bird et al., 2018"])
g.ylabel('Mean Sequence Length')
plt.rcParams["axes.labelsize"] = 15
plt.title('Similarity of Sequence Lenths', fontsize = 20)
plt.show()
