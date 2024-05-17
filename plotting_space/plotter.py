# PLOTTER GERAL

import seaborn as sns
import pandas as pd
import numpy as np
from matplotlib import pyplot as plt
from matplotlib.colors import LinearSegmentedColormap

num_to_month = {1: 'jan', 2: 'feb', 3: 'mar', 4: 'apr', 5: 'may', 6: 'jun', 7: 'jul', 8: 'aug', 9: 'sep', 10: 'oct', 11: 'nov', 12: 'dec'}

class HeatMap:
    def __init__(self, file_path: str, file_name: str, zones: list = 0, sizefont: float = 10, tight: bool = True, show: bool = False):
        self.file_path = file_path
        self.file_name = file_name
        self.df = pd.read_csv(f'{self.file_path}{self.file_name}', sep=',', index_col=0)
        self.df['gains_losses'] = self.df['gains_losses'].apply(lambda name: name.replace("_", " ").title())
        self.df['gains_losses'] = self.df.apply(lambda row: f'{row["gains_losses"]} +' if row['heat_direction'] == 'gain' else f'{row["gains_losses"]} -', axis=1)
        self.zones = zones
        self.sizefont = sizefont
        self.tight = tight
        self.show = show

    def plot_heatmap(self, title: str) -> sns.heatmap:
        spectral_r = plt.get_cmap('Spectral_r')
        colors = spectral_r(np.arange(spectral_r.N))
        colors[0] = np.array([1, 1, 1, 1])
        cmap = LinearSegmentedColormap.from_list('Custom_Spectral', colors, spectral_r.N)
        heatmap = sns.heatmap(data=self.df, vmax=1, vmin=0, cmap=cmap, linewidths=1, xticklabels=True, yticklabels=True)
        heatmap.set_xlabel('')
        heatmap.set_ylabel('Heat Exchanges')
        heatmap.set_title(title)
        heatmap.collections[0].colorbar.set_label('HEI')
        cbar = heatmap.collections[0].colorbar
        cbar.outline.set_edgecolor('black')
        cbar.outline.set_linewidth(1)
        heatmap.tick_params(left=False, bottom=False)
        plt.xticks(rotation=90, fontsize=self.sizefont)
        plt.yticks(fontsize=self.sizefont)
        if self.tight:
            plt.tight_layout()
        if self.show:
            plt.show()
        return heatmap
    
    def convection_annual(self) -> sns.heatmap:
        match self.zones:
            case 0:
                self.df = self.df.loc[self.df['zone'] != 'EXTERNAL']
                title = f'Heatmap total anual de convecção'
            case _:
                self.df = self.df.loc[self.df['zone'].isin(self.zones)]    
                title = f'Heatmap para {", ".join(self.zones)} anual de convecção'
        self.df = self.df[['gains_losses', 'zone', 'HEI']].pivot_table(index='gains_losses', columns='zone', values='HEI').fillna(0)
        map_obj = self.plot_heatmap(title = title)
        return map_obj
    
    def convection_monthly(self) -> sns.heatmap:
        match self.zones:
            case 0:
                self.df = self.df.loc[self.df['zone'] != 'EXTERNAL']
                title = f'Heatmap total mensal de convecção'
            case _:
                self.df = self.df.loc[self.df['zone'].isin(self.zones)]    
                title = f'Heatmap para {", ".join(self.zones)} mensal de convecção'
        self.df['zone'] = self.df.apply(lambda row: f'{row["month"]} {row["zone"]}', axis=1)
        self.df = self.df[['gains_losses', 'zone', 'HEI']].pivot_table(index='gains_losses', columns='zone', values='HEI').fillna(0)
        map_obj = self.plot_heatmap(title = title)
        return map_obj


if __name__ == "__main__":
    # annual_conv = HeatMap(file_path=r'plotting_space/anual_conv/', file_name='anual_conv.csv', show=True)
    # annual_conv.convection_annual()
    mensal_conv = HeatMap(file_path=r'plotting_space/mensal_conv/', file_name='mensal_conv.csv', show=True)
    mensal_conv.convection_monthly()
