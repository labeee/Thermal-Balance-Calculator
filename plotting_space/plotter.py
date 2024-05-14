# PLOTTER GERAL

import seaborn as sns
import pandas as pd
from matplotlib import pyplot as plt

num_to_month = {1: 'jan', 2: 'feb', 3: 'mar', 4: 'apr', 5: 'may', 6: 'jun', 7: 'jul', 8: 'aug', 9: 'sep', 10: 'oct', 11: 'nov', 12: 'dec'}
month_to_num = {'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6, 'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12}

class HeatMap:
    def __init__(self, file_path: str, file_name: str, zones: list = 0):
        self.file_path = file_path
        self.file_name = file_name
        self.df = pd.read_csv(f'{self.file_path}{self.file_name}', sep=',', index_col=0)
        self.df['gains_losses'] = self.df['gains_losses'].apply(lambda name: name.replace("_", " ").title())
        self.df['gains_losses'] = self.df.apply(lambda row: f'{row["gains_losses"]} +' if row['heat_direction'] == 'gain' else f'{row["gains_losses"]} - ', axis=1)
        self.zones = zones

    def convection_annual(self, tight: bool = True, show: bool = False) -> sns.heatmap:
        match self.zones:
            case 0:
                self.df = self.df.loc[self.df['zone'] != 'EXTERNAL']
                title = f'Heatmap total anual de convecção'
            case _:
                self.df = self.df.loc[self.df['zone'].isin(self.zones)]    
                title = f'Heatmap para {", ".join(self.zones)} anual de convecção'
        self.df = self.df[['gains_losses', 'zone', 'HEI']].pivot_table(index='gains_losses', columns='zone', values='HEI').fillna(0)
        heatmap = sns.heatmap(data=self.df, vmax=1, vmin=0, cmap='Spectral_r', linewidths=1)
        heatmap.set_xlabel('')
        heatmap.set_ylabel('Heat Exchanges')
        heatmap.set_title(title)
        heatmap.collections[0].colorbar.set_label('HEI')
        if tight:
            plt.tight_layout()
        if show:
            plt.show()
        return heatmap
    
    def convection_monthly(self, tight: bool = True, show: bool = False):
        match self.zones:
            case 0:
                self.df = self.df.loc[self.df['zone'] != 'EXTERNAL']
                title = f'Heatmap total mensal de convecção'
            case _:
                self.df = self.df.loc[self.df['zone'].isin(self.zones)]    
                title = f'Heatmap para {", ".join(self.zones)} mensal de convecção'
        self.df['zone'] = self.df.apply(lambda row: f'{row["zone"]} {num_to_month[row["month"]]}', axis=1)
        self.df = self.df[['gains_losses', 'zone', 'HEI']].pivot_table(index='gains_losses', columns='zone', values='HEI').fillna(0)
        heatmap = sns.heatmap(data=self.df, vmax=1, vmin=0, cmap='Spectral_r', linewidths=1)
        heatmap.set_xlabel('')
        heatmap.set_ylabel('Heat Exchanges')
        heatmap.set_title(title)
        heatmap.collections[0].colorbar.set_label('HEI')
        plt.xticks(rotation=90)
        if tight:
            plt.tight_layout()
        if show:
            plt.show()
        return heatmap


if __name__ == "__main__":
    annual_conv = HeatMap(file_path=r'plotting_space/anual_conv/', file_name='anual_conv.csv', zones=['DORM1', "BWC"])
    annual_conv.convection_annual(show=True)
    # mensal_conv = HeatMap(file_path=r'plotting_space/mensal_conv/', file_name='mensal_conv.csv', zones=['SALA'])
    # mensal_conv.convection_monthly(show=True)
