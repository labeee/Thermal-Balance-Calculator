# AINDA NÃO FUNCIONA

import seaborn as sns
import pandas as pd
from matplotlib import pyplot as plt

df = pd.read_csv("plotting_space/mensal conv/mensal_conv.csv", sep=',', index_col=0)
months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
df = df.loc[df['zone'] != 'EXTERNAL']
df = df[['gains_losses', 'zone', 'HEI', 'month']]

fig, axs = plt.subplots(nrows=1, ncols=12, sharex=True)

for i in range(12):
    month_df = df[df['month'] == i+1]
    month_df = month_df.pivot_table(index='gains_losses', columns='zone', values='HEI').fillna(0)
    if i < 11:
        mapa = sns.heatmap(data=month_df, vmax=1, vmin=0, cmap='Spectral_r', linewidths=1, ax=axs[i], cbar=False)
        mapa.set_yticks([])
    else:
        mapa = sns.heatmap(data=month_df, vmax=1, vmin=0, cmap='Spectral_r', linewidths=1, ax=axs[i])
        mapa.collections[0].colorbar.set_label('HEI')
    mapa.set_ylabel('') if i > 0 else mapa.set_ylabel('Heat Exchanges')
    mapa.set_yticklabels([])# if i > 0 else mapa.set_yticklabels()
    mapa.set_xlabel(months[i])

plt.show()

