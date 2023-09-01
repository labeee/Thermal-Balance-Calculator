import pandas as pd
from glob import glob
from variables import *

print(screen_clean)

# Engloba arquivos dentro de input surface
globed = glob(f'{surface_input_path}*.csv')
print(f'\nglobed surface --> {globed}\n\n')

# Loop que exclui linhas com NaN e soma todos os valores
if globed != []:
    for i in globed:
        print(interface_separators)
        df = pd.read_csv(i, index_col='Date/Time')
        print(f'\n\n- Leu CSV {i}')
        df = df.dropna()
        print('- Excluiu os NaN')
        columns_list = df.columns
        for item in columns_list:
            for new_name in sala:
                if item.startswith(new_name):
                    df.rename(columns={item: sala[new_name]}, inplace=True)
        for item in columns_list:
            for new_name in dorm1:
                if item.startswith(new_name):
                    df.rename(columns={item: dorm1[new_name]}, inplace=True)
        for item in columns_list:
            for new_name in dorm2:
                if item.startswith(new_name):
                    df.rename(columns={item: dorm2[new_name]}, inplace=True)
        soma = df.iloc[:].sum()
        print('- Somou os valores')
        df_somado = pd.DataFrame(soma, columns=['value'])
        df_somado.loc[:, 'case'] = i.split('\\')[1]
        print(df_somado)
        df_somado.to_csv(surface_output_path+'annual_surface_'+i.split('\\')[1], sep=';', index_label='gains_losses')
        print('- Criou arquivo\n\n')
        print(interface_separators)

# Criar um arquivo grandão com todos os dados concatenados
    globed = glob(surface_output_path+'*.csv')
    big_df = pd.read_csv(globed[0], sep=';', index_col='gains_losses')
    big_df.to_csv(surface_output_path+'annual_surface_Full_DataFrame.csv', sep=';')
    globed.pop(0)
    for i in globed:
        new_df = pd.read_csv(i, sep=';', index_col='gains_losses')
        old_df = pd.read_csv(surface_output_path+'annual_surface_Full_DataFrame.csv', sep=';', index_col='gains_losses')
        concated = pd.concat([old_df, new_df])
        concated.to_csv(surface_output_path+'annual_surface_Full_DataFrame.csv', sep=';')

# Engloba arquivos dentro de input convection
globed = glob(f'{convection_input_path}*.csv')
print(f'\nglobed convection --> {globed}\n\n')

# Loop que exclui linhas com NaN e soma todos os valores
if globed != []:
    for i in globed:
        print(interface_separators)
        df = pd.read_csv(i, index_col='Date/Time')
        print(f'\n\n- Leu CSV {i}')
        df = df.dropna()
        print('- Excluiu os NaN')
        columns_list = df.columns
        for item in columns_list:
            for new_name in sala:
                if item.startswith(new_name):
                    df.rename(columns={item: sala[new_name]}, inplace=True)
        for item in columns_list:
            for new_name in dorm1:
                if item.startswith(new_name):
                    df.rename(columns={item: dorm1[new_name]}, inplace=True)
        for item in columns_list:
            for new_name in dorm2:
                if item.startswith(new_name):
                    df.rename(columns={item: dorm2[new_name]}, inplace=True)
        soma = df.iloc[:].sum()
        print('- Somou os valores')
        df_somado = pd.DataFrame(soma, columns=['value'])
        df_somado.loc[:, 'case'] = i.split('\\')[1]
        print(df_somado)
        df_somado.to_csv(convection_output_path+'annual_convection_'+i.split('\\')[1], sep=';', index_label='gains_losses')
        print('- Criou arquivo\n\n')
        print(interface_separators)

    # Criar um arquivo grandão com todos os dados concatenados
    globed = glob(convection_output_path+'*.csv')
    big_df = pd.read_csv(globed[0], sep=';', index_col='gains_losses')
    big_df.to_csv(convection_output_path+'annual_convection_Full_DataFrame.csv', sep=';')
    globed.pop(0)
    for i in globed:
        new_df = pd.read_csv(i, sep=';', index_col='gains_losses')
        old_df = pd.read_csv(convection_output_path+'annual_convection_Full_DataFrame.csv', sep=';', index_col='gains_losses')
        concated = pd.concat([old_df, new_df])
        concated.to_csv(convection_output_path+'annual_convection_Full_DataFrame.csv', sep=';')


print('\n\nTerminou\n\n')
