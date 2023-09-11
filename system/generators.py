from system.source import *
from glob import glob

def sum_separated(coluna):
    positivos = coluna[coluna > 0].sum()
    negativos = coluna[coluna < 0].sum()
    return pd.Series([positivos, negativos])

def divide(df):
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

def generate_df(path, output, way, type):
    # Engloba arquivos dentro de input
    globed = glob(f'{path}*.csv')
    print(f'\nglobed --> {globed}\n\n')
    # Loop que exclui linhas com NaN e soma todos os valores
    if globed != []:
        for i in globed:
            separators()
            df = pd.read_csv(i)
            print(f'\n\n- Leu CSV {i}')
            df = df.dropna()
            print('- Excluiu os NaN')
            columns_list = df.columns
            for item in columns_list:
                for new_name in sala:
                    if new_name in item:
                        df.rename(columns={item: sala[new_name]}, inplace=True)
            for item in columns_list:
                for new_name in dorm1:
                    if new_name in item:
                        df.rename(columns={item: dorm1[new_name]}, inplace=True)
            for item in columns_list:
                for new_name in dorm2:
                    if new_name in item:
                        df.rename(columns={item: dorm2[new_name]}, inplace=True)    
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
            print('- Criou arquivo de hora em hora')
            df.drop(columns='Date/Time', axis=1, inplace=True)
            soma = df.apply(sum_separated)
            soma = divide(soma)
            print('- Somou gains e losses')
            soma.loc[:, 'case'] = i.split('\\')[1]
            soma.loc[:, 'type'] = way
            print('- Adicionou case')
            soma.to_csv(output+'final'+type+i.split('\\')[1], sep=';')
            print('- Criou arquivo\n\n')
