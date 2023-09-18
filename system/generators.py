from system.source import *
from glob import glob
import os


def rename_sala(columns_list: list, df: pd.DataFrame):
    for item in columns_list:
        for new_name in sala:
            if new_name in item:
                df.rename(columns={item: f"{sala['ZONE']}_{sala[new_name]}"}, inplace=True)
    return df


def rename_dorm1(columns_list: list, df: pd.DataFrame):
    for item in columns_list:
        for new_name in dorm1:
            if new_name in item:
                df.rename(columns={item: f"{dorm1['ZONE']}_{dorm1[new_name]}"}, inplace=True)
    return df


def rename_dorm2(columns_list: list, df: pd.DataFrame):
    for item in columns_list:
        for new_name in dorm2:
            if new_name in item:
                df.rename(columns={item: f"{dorm2['ZONE']}_{dorm2[new_name]}"}, inplace=True)
    return df


def sum_separated(coluna):
    """
    Soma separadamente os positivos e os negativos, retornando um objeto 
    Series contendo em uma coluna os positivos e em outra os negativos de cada linha
    """
    positivos = coluna[coluna > 0].sum()
    negativos = coluna[coluna < 0].sum()
    return pd.Series([positivos, negativos])


def divide(df: pd.DataFrame):
    """
    Divide algumas colunas em gain e loss. Ao fim, adiciona às colunas os nomes de 
    index e value, além de excluir os valores iguais a zero
    """
    divided = pd.DataFrame()
    col = df.columns
    for column in col:
        if column in dont_change_list:
            divided[column] = df[column]
        else:
            divided[f'{column}_gain'] = df[column].apply(lambda item: item if item>0 else 0)
            divided[f'{column}_loss'] = df[column].apply(lambda item: item if item<0 else 0)
    divided = divided.sum().reset_index()
    divided.columns = ['index', 'value']
    divided = divided[divided['value'] != 0]
    return divided

def invert_values(dataframe: pd.DataFrame):
    """
    Multiplica as colunas específicas por -1.
    """
    df_copy = dataframe.copy()
    valid_cols = [col for col in df_copy.columns if col in multiply_list]
    if not valid_cols:
        return df_copy
    df_copy[valid_cols] = df_copy[valid_cols].multiply(-1)
    return df_copy

def generate_df(path: str, output: str, way: str, type: str, zone: list, coverage: str):
    """
    Irá gerar os dataframes, separando por zona.
    path: path do input
    output: path do output
    way: convection/surface
    type: _convection_/_conduction_
    zone: lista de zonas (SALA, DORM1, DORM2)
    coverage: annual/monthly/daily
    """
    # Engloba arquivos dentro de input
    globed = glob(f'{path}*.csv')
    print(f'Found inputs: {globed}\n\n')
    print(f'Choosen zones: {zone}\n\n')
    print(f'Choosen type: {coverage}\n\n')
    # Loop que exclui linhas com NaN e soma todos os valores
    if globed != []:
        for i in globed:
            separators()
            df = pd.read_csv(i)
            print(f'\n\n- CSV read {i}')
            df = df.dropna()
            print('- NaN rows removed')
            columns_list = df.columns
            if sala['ZONE'] in zone:
                df = rename_sala(columns_list=columns_list, df=df)
            if dorm1['ZONE'] in zone:
                df = rename_dorm1(columns_list=columns_list, df=df)
            if dorm2['ZONE'] in zone:
                df = rename_dorm2(columns_list=columns_list, df=df)
            columns_list = df.columns
            unwanted_list = []
            for item in columns_list:
                if item not in wanted_list:
                    unwanted_list.append(item)
            df.drop(columns=unwanted_list, axis=1, inplace=True)
            columns_list = df.columns
            date_time = df['Date/Time']
            df = df.groupby(df.columns, axis=1).sum()
            df = pd.concat([date_time, df], axis=1)
            df.to_csv(output+'initial_'+'-'.join(zone)+type+i.split('\\')[1], sep=';')
            print('- Initial dataframe created')
            df = invert_values(df)
            print('- Inverted specified columns')
            df.to_csv(output+'intermediary_'+'-'.join(zone)+type+i.split('\\')[1], sep=';')
            print('- Intermediary dataframe created')
            match coverage:
                case 'annual':
                    df.drop(columns='Date/Time', axis=1, inplace=True)
                    soma = df.apply(sum_separated)
                    soma = divide(soma)
                    print('- Gains and losses separated and calculated')
                    soma.loc[:, 'case'] = i.split('\\')[1]
                    soma.loc[:, 'type'] = way
                    soma.loc[:, 'zone'] = 'no zone'
                    for j in soma.index:
                        zones = soma.at[j, 'index'].split('_')[0]
                        lenght = (len(zones)+1)
                        new_name = soma.at[j, 'index'][lenght:]
                        soma.at[j, 'zone'] = zones
                        soma.at[j, 'index'] = new_name
                    print('- Case, type and zone added')
                    soma.to_csv(output+'final_annual_'+'-'.join(zone)+type+i.split('\\')[1], sep=';')
                case 'monthly':
                    df.loc[:, 'month'] = 'no month'
                    for row in df.index:
                        month = str(df.at[row, 'Date/Time'])
                        df.at[row, 'month'] = month[14:16]
                    print('- Months column created')
                    df.drop(columns='Date/Time', axis=1, inplace=True)
                    months = df['month'].unique()
                    for unique_month in months:
                        df_monthly = df[df['month'] == unique_month]
                        df_monthly.drop(columns='month', axis=1, inplace=True)
                        soma = df_monthly.apply(sum_separated)
                        soma = divide(soma)
                        print(f'- Gains and losses separated and calculated for month {unique_month}')
                        soma.loc[:, 'case'] = i.split('\\')[1]
                        soma.loc[:, 'type'] = way
                        soma.loc[:, 'month'] = unique_month
                        soma.loc[:, 'zone'] = 'no zone'
                        for j in soma.index:
                            zones = soma.at[j, 'index'].split('_')[0]
                            lenght = (len(zones)+1)
                            new_name = soma.at[j, 'index'][lenght:]
                            soma.at[j, 'zone'] = zones
                            soma.at[j, 'index'] = new_name
                        print(f'- Case, type and zone added for month {unique_month}')
                        soma.to_csv(organizer_output_path+'_month'+unique_month+'.csv', sep=';')
                    glob_organizer = glob(organizer_output_path+'*.csv')
                    df_total = pd.read_csv(glob_organizer[0], sep=';')
                    glob_organizer.pop(0)
                    for item in glob_organizer:
                        each_df = pd.read_csv(item, sep=';')
                        df_total = pd.concat([df_total, each_df], axis=0, ignore_index=True)
                    df_total.drop(columns='Unnamed: 0', axis=1, inplace=True)
                    df_total.to_csv(output+'final_monthly_'+'-'.join(zone)+type+i.split('\\')[1], sep=';')
                case 'daily':
                    df.loc[:, 'day'] = 'no day'
                    for row in df.index:
                        day = str(df.at[row, 'Date/Time'])
                        df.at[row, 'day'] = day[17:19]
                    print('- Days column created')
                    df.drop(columns='Date/Time', axis=1, inplace=True)
                    days = df['day'].unique()
                    for unique_day in days:
                        df_daily = df[df['day'] == unique_day]
                        df_daily.drop(columns='day', axis=1, inplace=True)
                        soma = df_daily.apply(sum_separated)
                        soma = divide(soma)
                        print(f'- Gains and losses separated and calculated for day {unique_day}')
                        soma.loc[:, 'case'] = i.split('\\')[1]
                        soma.loc[:, 'type'] = way
                        soma.loc[:, 'day'] = unique_day
                        soma.loc[:, 'zone'] = 'no zone'
                        for j in soma.index:
                            zones = soma.at[j, 'index'].split('_')[0]
                            lenght = (len(zones)+1)
                            new_name = soma.at[j, 'index'][lenght:]
                            soma.at[j, 'zone'] = zones
                            soma.at[j, 'index'] = new_name
                        print(f'- Case, type and zone added for day {unique_day}')
                        soma.to_csv(organizer_output_path+'_day'+unique_day+'.csv', sep=';')
                    glob_organizer = glob(organizer_output_path+'*.csv')
                    df_total = pd.read_csv(glob_organizer[0], sep=';')
                    glob_organizer.pop(0)
                    for item in glob_organizer:
                        each_df = pd.read_csv(item, sep=';')
                        df_total = pd.concat([df_total, each_df], axis=0, ignore_index=True)
                    df_total.drop(columns='Unnamed: 0', axis=1, inplace=True)
                    df_total.to_csv(output+'final_daily_'+'-'.join(zone)+type+i.split('\\')[1], sep=';')
            glob_remove = glob(organizer_output_path+'*.csv')
            for item in glob_remove:
                os.remove(item)
            print('- Final dataframe created\n\n')

