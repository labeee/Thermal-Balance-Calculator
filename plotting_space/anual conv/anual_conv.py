# DESCOMENTE A PORÇÃO DO CÓDIGO QUE DESEJA UTILIZAR

import seaborn as sns
import pandas as pd
from matplotlib import pyplot as plt
import numpy as np

df = pd.read_csv("plotting_space/anual conv/anual_conv.csv", sep=',', index_col=0)


# # HEATMAP DE ZONA ÚNICA
# myzone = 'BWC'
# zoned = df.loc[df['zone'] == myzone]
# zoned.set_index('gains_losses', inplace=True)
# zoned = zoned[['HEI']]
# title = f'Heatmap para zona {myzone}'
# mapa = sns.heatmap(data=zoned, vmax=1, vmin=0, linewidths=1, cmap='Spectral_r')
# mapa.set_title(title)
# mapa.set_ylabel('Heat Exchanges')
# mapa.collections[0].colorbar.set_label('HEI')
# mapa.set_xticklabels(labels=[f'{myzone}'])
# plt.tight_layout()
# plt.show()


# HEATMAP COM TODAS AS ZONAS
df = df.loc[df['zone'] != 'EXTERNAL']
df = df[['gains_losses', 'zone', 'HEI']].pivot_table(index='gains_losses', columns='zone', values='HEI').fillna(0)
mapa = sns.heatmap(data=df, vmax=1, vmin=0, cmap='Spectral_r', linewidths=1)
mapa.set_ylabel('Heat Exchanges')
mapa.set_xlabel('')
mapa.collections[0].colorbar.set_label('HEI')
plt.tight_layout()
plt.show()
