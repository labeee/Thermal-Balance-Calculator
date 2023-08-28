import pandas as pd
from glob import glob

# Engloba arquivos dentro de input
print('\n'*150)
globed = glob('input/*.csv')
print(f'\nglobed --> {globed}\n\n')
output_path = 'output/'

# Loop que exclui linhas com NaN e soma todos os valores
for i in globed:
    print('- '*45)
    df = pd.read_csv(i, index_col='Date/Time')
    print(f'\n\n- Leu CSV {i}')
    df = df.dropna()
    print('- Excluiu os NaN')
    columns_list = list(df.columns)
    soma = df.iloc[:].sum()
    print('- Somou os valores')
    df_somado = pd.DataFrame(soma, columns=['value'])
    df_somado.loc[:, 'case'] = i.split('\\')[1]
    print(df_somado)
    df_somado.to_csv(output_path+'processed_'+i.split('\\')[1], sep=';', index_label='gains_losses')
    print('- Criou arquivo\n\n')
    print('- '*45)

# Criar um arquivo grandão com todos os dados concatenados
globed = glob(output_path+'*.csv')
big_df = pd.read_csv(globed[0], sep=';', index_col='gains_losses')
big_df.to_csv(output_path+'Full_DataFrame.csv', sep=';')
globed.pop(0)
for i in globed:
    new_df = pd.read_csv(i, sep=';', index_col='gains_losses')
    old_df = pd.read_csv(output_path+'Full_DataFrame.csv', sep=';', index_col='gains_losses')
    concated = pd.concat([old_df, new_df])
    concated.to_csv(output_path+'Full_DataFrame.csv', sep=';')

print('\n\nTerminou\n\n')