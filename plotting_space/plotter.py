# PLOTTER GERAL

import seaborn as sns
import pandas as pd
import numpy as np
from matplotlib import pyplot as plt
from matplotlib.colors import LinearSegmentedColormap

num_to_month = {1: 'Jan', 2: 'Feb', 3: 'Mar', 4: 'Apr', 5: 'May', 6: 'Jun', 7: 'Jul', 8: 'Aug', 9: 'Sep', 10: 'Oct', 11: 'Nov', 12: 'Dec'}

class HeatMap:
    def __init__(self, file_path: str, file_name: str, zones: list = 0, sizefont: float = 10, tight: bool = False, show: bool = False, cbar_orientation: str = 'right', months: list = 0):
        self.file_path = file_path
        self.file_name = file_name
        self.df = pd.read_csv(f'{self.file_path}{self.file_name}', sep=',', index_col=0)
        self.df['gains_losses'] = self.df['gains_losses'].apply(lambda name: name.replace("_", " ").title())
        self.df['gains_losses'] = self.df.apply(lambda row: f'{row["gains_losses"]} +' if row['heat_direction'] == 'gain' else f'{row["gains_losses"]} -', axis=1)
        self.zones = zones
        self.sizefont = sizefont
        self.tight = tight
        self.show = show
        self.cbar_orientation = cbar_orientation
        self.months = months

    def plot_heatmap(self, title: str, month_plot: bool = False) -> sns.heatmap:
        spectral_r = plt.get_cmap('Spectral_r')
        colors = spectral_r(np.arange(spectral_r.N))
        colors[0] = np.array([1, 1, 1, 1])
        cmap = LinearSegmentedColormap.from_list('Custom_Spectral', colors, spectral_r.N)
        heatmap = sns.heatmap(data=self.df, vmax=1, vmin=0, cmap=cmap, linewidths=1, xticklabels=True, yticklabels=True, cbar_kws = {"location": self.cbar_orientation})
        heatmap.set_xlabel('')
        heatmap.set_ylabel('Heat Exchanges')
        heatmap.set_title(title)
        heatmap.collections[0].colorbar.set_label('HEI')
        cbar = heatmap.collections[0].colorbar
        cbar.outline.set_edgecolor('black')
        cbar.outline.set_linewidth(1)
        heatmap.tick_params(left=False, bottom=True)
        plt.xticks(rotation=90, fontsize=self.sizefont)
        plt.yticks(fontsize=self.sizefont)
        if month_plot:
            ax = plt.gca()
            labels = ax.get_xticklabels()
            splited = [label.get_text().split(' ') for label in labels]
            new_labels = [name[0] for name in splited]
            heatmap.set_xticklabels(new_labels, rotation=90, fontsize=self.sizefont)

            ax2 = ax.twiny()
            ax2.set_xticks(ax.get_xticks())
            new_labels2 = [name[1] for name in splited]
            ax2.set_xticklabels(new_labels2, rotation=60, fontsize=self.sizefont)

            ax.xaxis.tick_bottom()
            ax2.xaxis.tick_top()
            ax.tick_params(bottom=False)
        if self.tight and (self.cbar_orientation not in ['bottom', 'top']):
            plt.tight_layout()
        if self.show:
            plt.show()
        return heatmap

    def month_number(self, column_name):
        month_num = int(column_name.split(' ')[1])
        return month_num

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
        match self.months:
            case 0:
                pass
            case _:
                self.df = self.df.loc[self.df['month'].isin(self.months)] 
        self.df['zone'] = self.df.apply(lambda row: f'{row["zone"]} {row["month"]}', axis=1)
        self.df = self.df[['gains_losses', 'zone', 'HEI']].pivot_table(index='gains_losses', columns='zone', values='HEI').fillna(0)
        self.df = self.df[sorted(self.df.columns, key=self.month_number)]
        self.df.columns = [f'{column.split(" ")[0]} {column.split(" ")[1].replace(column.split(" ")[1], num_to_month[int(column.split(" ")[1])])}' for column in self.df.columns]
        map_obj = self.plot_heatmap(title = title, month_plot=True)
        return map_obj


if __name__ == "__main__":
    # annual_conv = HeatMap(file_path=r'plotting_space/anual_conv/', file_name='anual_conv.csv', show=True, zones=["DORM1", "DORM2", "BWC"], tight=True)
    # annual_conv.convection_annual()
    mensal_conv = HeatMap(file_path=r'plotting_space/mensal_conv/', file_name='mensal_conv.csv', show=True, months=[11,12,1,2,4,5,6,7], zones=["DORM1", "DORM2", "BWC"], tight=True)
    mensal_conv.convection_monthly()
