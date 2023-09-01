import pandas as pd
import re
import numpy
from variables import *

# dado = {
#     "Position": [
#         "primeiro",
#         "segundo",
#         "terceiro",
#         "quarto"
#     ],
#     "QUARTO1_trashtrash": [
#         1,
#         2,
#         3,
#         4
#     ],
#     "QUARTO1_trash2trash2": [
#         5,
#         6,
#         7,
#         8
#     ],
#     "BWC_trashtrash": [
#         9,
#         10,
#         11,
#         12
#     ]
# }

# df = pd.DataFrame(dado)
# busca = 'QUARTO1'
# print('\n'*5)
# print(f'Dataframe\n{df}\nTermo de busca: {busca}')
# print('\n'*5)

# colunas = df.columns

# for item in colunas:
#     reg = re.search(busca, df.iloc[item])
#     print('\n'*5)
#     if reg != None:
#         print(reg.group())
#         df[item].replace(item, busca, inplace=True)
#         print(f'Found {reg}')
#         print(df)
#     else:
#         df[item].replace(item, numpy.nan, inplace=True)
#         print(f'Did not found {reg}, found {item} instead. Col will be removed')

# print('\n'*5)
# df.dropna(inplace=True)

# print('\n'*5)
# print(f'Dataframe após filtragem e renomeação:\n{df}')
# print('\n'*5)

# soma = df.loc[0:, ["A", "B", "C"]].sum()
# print(soma)
# print('\n'*5)

# df.loc['total'] = soma
# print(df)
# print('\n'*5)


# for item in sala['none_intwalls']:
#     print(item)
