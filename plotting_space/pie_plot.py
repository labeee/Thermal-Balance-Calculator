from matplotlib import pyplot as plt
import pandas as pd
from glob import glob

# ['Solarize_Light2', '_classic_test_patch', '_mpl-gallery', '_mpl-gallery-nogrid', 'bmh', 'classic', 
# dark_background', 'fast', 'fivethirtyeight', 'ggplot', 'grayscale', 'seaborn-v0_8', 'seaborn-v0_8-bright', 
# 'seaborn-v0_8-colorblind', 'seaborn-v0_8-dark', 'seaborn-v0_8-dark-palette', 'seaborn-v0_8-darkgrid', 
# 'seaborn-v0_8-deep', 'seaborn-v0_8-muted', 'seaborn-v0_8-notebook', 'seaborn-v0_8-paper', 'seaborn-v0_8-pastel', 
# 'seaborn-v0_8-poster', 'seaborn-v0_8-talk', 'seaborn-v0_8-ticks', 'seaborn-v0_8-white', 'seaborn-v0_8-whitegrid', 'tableau-colorblind10']
plt.style.use("seaborn-v0_8-poster")

globed = glob('plotting_space/compara*.xlsx')[0]

df = pd.read_excel(globed)

df = df[df['HEI Zac'].astype(float) != 0]

fig, (ax1, ax2) = plt.subplots(ncols=2)

slices_zac = df['HEI Zac']
slices_real = df['HEI correto:']
labels = df['gains_losses']

ax1.pie(slices_zac, labels=labels, rotatelabels=True, wedgeprops={'edgecolor': 'black'})
ax2.pie(slices_real, labels=labels, rotatelabels=True, wedgeprops={'edgecolor': 'black'})

fig.suptitle("HEI das regiões", fontsize=30)
fig.tight_layout()
plt.show()
