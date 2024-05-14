# PLOTTER GERAL

import seaborn as sns
import pandas as pd
from matplotlib import pyplot as plt


class HeatMap:
    def __init__(self, local: str, file_name: str, zones: list = 0):
        self.local = local
        self.file_name = file_name
        self.df = pd.read_csv(f'{self.local}{self.file_name}', sep=',', index_col=0)
        self.df['gains_losses'] = self.df['gains_losses'].apply(lambda name: name.replace("_", " ").title())
        self.df['gains_losses'] = self.df.apply(lambda row: f'{row["gains_losses"]} +' if row['heat_direction'] == 'gain' else f'{row["gains_losses"]} - ', axis=1)
        self.copy_df = self.df.copy()
        self.zones = zones

    def convection_annual(self, tight: bool = True, show: bool = False) -> sns.heatmap:
        match self.zones:
            case 0:
                self.copy_df = self.df.loc[self.df['zone'] != 'EXTERNAL']
                title = f'Heatmap total anual de convecção'
            case _:
                self.copy_df = self.df.loc[self.df['zone'].isin(self.zones)]    
                title = f'Heatmap para {", ".join(self.zones)} anual de convecção'
        self.copy_df = self.copy_df[['gains_losses', 'zone', 'HEI']].pivot_table(index='gains_losses', columns='zone', values='HEI').fillna(0)
        heatmap = sns.heatmap(data=self.copy_df, vmax=1, vmin=0, cmap='Spectral_r', linewidths=1)
        heatmap.set_xlabel('')
        heatmap.set_ylabel('Heat Exchanges')
        heatmap.set_title(title)
        heatmap.collections[0].colorbar.set_label('HEI')
        if tight:
            plt.tight_layout()
        if show:
            plt.show()
        return heatmap

if __name__ == "__main__":
    annual = HeatMap(local=r'plotting_space/anual_conv/', file_name='anual_conv.csv', zones=['DORM1', 'DORM2', 'BWC'])
    annual.convection_annual(show=True)
