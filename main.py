from source import *

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
                    df.rename(columns={item: sala[new_name]+surface}, inplace=True)
        for item in columns_list:
            for new_name in dorm1:
                if item.startswith(new_name):
                    df.rename(columns={item: dorm1[new_name]+surface}, inplace=True)
        for item in columns_list:
            for new_name in dorm2:
                if item.startswith(new_name):
                    df.rename(columns={item: dorm2[new_name]+surface}, inplace=True)    
        for item in columns_list:
            for new_name in extras:
                if item.startswith(new_name):
                    df.rename(columns={item: extras[new_name]}, inplace=True)

        columns_list = df.columns
        unwanted_list = []
        for item in columns_list:
            if item not in wanted_list:
                unwanted_list.append(item)
        df.drop(columns=unwanted_list, axis=1, inplace=True)     

        df = df.groupby(df.columns, axis=1).sum()

        soma = df.apply(sum_separated)
        soma = divide(soma)
        print('- Somou gains e losses')
        
        soma.loc[:, 'case'] = i.split('\\')[1]
        print('- Adicionou case')

        soma.to_csv(surface_output_path+'annual_surface_'+i.split('\\')[1], sep=';')
        print('- Criou arquivo\n\n')

        print(interface_separators)


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
                    df.rename(columns={item: sala[new_name]+convection}, inplace=True)
        for item in columns_list:
            for new_name in dorm1:
                if item.startswith(new_name):
                    df.rename(columns={item: dorm1[new_name]+convection}, inplace=True)
        for item in columns_list:
            for new_name in dorm2:
                if item.startswith(new_name):
                    df.rename(columns={item: dorm2[new_name]+convection}, inplace=True)
        for item in columns_list:
            for new_name in extras:
                if item.startswith(new_name):
                    df.rename(columns={item: extras[new_name]+convection}, inplace=True)
        
        columns_list = df.columns
        unwanted_list = []
        for item in columns_list:
            if item not in wanted_list:
                unwanted_list.append(item)
        df.drop(columns=unwanted_list, axis=1, inplace=True) 
        
        df = df.groupby(df.columns, axis=1).sum()

        soma = df.apply(sum_separated)
        soma = divide(soma)
        print('- Somou gains e losses')
        print(type(soma))
        print(soma)
             
        soma.loc[:, 'case'] = i.split('\\')[1]
        print('- Adicionou case')

        soma.to_csv(convection_output_path+'annual_surface_'+i.split('\\')[1], sep=';')
        print('- Criou arquivo\n\n')

        print(interface_separators)


# Criar um arquivo grandão com todos os dados concatenados
globed = glob(convection_output_path+'*.csv')
globed2 = glob(surface_output_path+'*.csv')
for each in globed2:
    globed.append(each)
big_df = pd.read_csv(globed[0], sep=';', index_col='type')
big_df.to_csv(full_output_path+'annual_Full_DataFrame.csv', sep=';')
globed.pop(0)
for i in globed:
    new_df = pd.read_csv(i, sep=';', index_col='type')
    old_df = pd.read_csv(full_output_path+'annual_Full_DataFrame.csv', sep=';', index_col='type')
    concated = pd.concat([old_df, new_df])
    concated.to_csv(full_output_path+'annual_Full_DataFrame.csv', sep=';')
edit_df = pd.read_csv(full_output_path+'annual_Full_DataFrame.csv', sep=';', index_col='type')
edit_df.drop(columns='Unnamed: 0', axis=1,inplace=True)
edit_df.to_csv(full_output_path+'annual_Full_DataFrame.csv', sep=';')

print('\n\nTerminou\n\n')
