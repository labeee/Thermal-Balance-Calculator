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
            df = pd.read_csv(i, index_col='Date/Time')
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
            soma = df.apply(sum_separated)
            soma = divide(soma)
            print('- Somou gains e losses')
            soma.loc[:, 'case'] = i.split('\\')[1]
            soma.loc[:, 'type'] = way
            print('- Adicionou case')
            soma.to_csv(output+'annual'+type+i.split('\\')[1], sep=';')
            print('- Criou arquivo\n\n')


def generate_full_df():
    # Criar um arquivo grandão com todos os dados concatenados
    globed = glob(convection_output_path+'*.csv')
    globed2 = glob(surface_output_path+'*.csv')
    for each in globed2:
        globed.append(each)
    big_df = pd.read_csv(globed[0], sep=';', index_col='index')
    big_df.to_csv(full_output_path+'annual_Full_DataFrame.csv', sep=';')
    globed.pop(0)
    for i in globed:
        new_df = pd.read_csv(i, sep=';', index_col='index')
        old_df = pd.read_csv(full_output_path+'annual_Full_DataFrame.csv', sep=';', index_col='index')
        concated = pd.concat([old_df, new_df])
        concated.to_csv(full_output_path+'annual_Full_DataFrame.csv', sep=';')
    edit_df = pd.read_csv(full_output_path+'annual_Full_DataFrame.csv', sep=';', index_col='index')
    edit_df.drop(columns='Unnamed: 0', axis=1,inplace=True)
    edit_df.to_csv(full_output_path+'annual_Full_DataFrame.csv', sep=';')