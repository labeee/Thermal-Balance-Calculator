from system.source import *
from glob import glob


def sum_separated(coluna):
    """
    Soma separadamente os positivos e os negativos, retornando um objeto 
    Series contendo em uma coluna os positivos e em outra os negativos de cada linha
    """
    positivos = coluna[coluna > 0].sum()
    negativos = coluna[coluna < 0].sum()
    return pd.Series([positivos, negativos])


def rename_sala(columns_list: list, df: pd.DataFrame):
    for item in columns_list:
        for new_name in sala:
            if new_name in item:
                df.rename(columns={item: f"{sala[new_name]}_{sala['ZONE']}"}, inplace=True)
    return df


def rename_dorm1(columns_list: list, df: pd.DataFrame):
    for item in columns_list:
        for new_name in dorm1:
            if new_name in item:
                df.rename(columns={item: f"{dorm1[new_name]}_{dorm1['ZONE']}"}, inplace=True)
    return df


def rename_dorm2(columns_list: list, df: pd.DataFrame):
    for item in columns_list:
        for new_name in dorm2:
            if new_name in item:
                df.rename(columns={item: f"{dorm2[new_name]}_{dorm2['ZONE']}"}, inplace=True)
    return df


def divide(df):
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


def generate_df(path: str, output: str, way: str, type: str, zone: list):
    """
    Irá gerar os dataframes, separando por zona.
    """
    # Engloba arquivos dentro de input
    globed = glob(f'{path}*.csv')
    print(f'Found inputs: {globed}\n\n')
    print(f'Choosen zones: {zone}\n\n')
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
            for item in columns_list:
                for new_name in extras:
                    if new_name in item:
                        df.rename(columns={item: extras[new_name]}, inplace=True)
            columns_list = df.columns
            unwanted_list = []
            for item in columns_list:
                if item not in wanted_list:
                    unwanted_list.append(item)
            df.drop(columns=unwanted_list, axis=1, inplace=True)     
            columns_list = df.columns
            df = df.groupby(df.columns, axis=1).sum()
            df.to_csv(output+'initial'+type+i.split('\\')[1], sep=';')
            print('- Created the hourly dataframe')
            df.drop(columns='Date/Time', axis=1, inplace=True)
            soma = df.apply(sum_separated)
            soma = divide(soma)
            print('- Gains and losses separated and added')
            soma.loc[:, 'case'] = i.split('\\')[1]
            soma.loc[:, 'type'] = way
            print('- Case and type added')
            soma.to_csv(output+'final'+type+i.split('\\')[1], sep=';')
            print('- Final dataframe created\n\n')

