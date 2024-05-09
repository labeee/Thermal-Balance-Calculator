import seaborn as sns
import pandas as pd

myzone = 'DORM1'

df = pd.read_csv("plotting_space/anual_conv.csv", sep=',', index_col=0)

zoned = df.loc[df['zone'] == myzone]
title = f'Heatmap para zona {myzone}'

mapa = sns.heatmap(data=zoned)
mapa.figure.set_title(title)
sns.plt.show()
