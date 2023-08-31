import pandas as pd
import re
import numpy
from variables import *

# dado = {
#     "Position": [
#         "QUARTO1_trashtrash",
#         "QUARTO1_trash2trash2",
#         "BWC_trashtrash",
#         "QUARTO2_trashtrash"
#     ],
#     "A": [
#         1,
#         2,
#         3,
#         4
#     ],
#     "B": [
#         5,
#         6,
#         7,
#         8
#     ],
#     "C": [
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

# for item in df.iloc[:, 0]:
    # reg = re.search(busca, item)
    # print('\n'*5)
    # if reg != None:
        # print(reg.group())
        # df.replace(item, busca, inplace=True)
        # print(f'Found {reg}')
        # print(df)
    # else:
    #     df.replace(item, numpy.nan, inplace=True)
        # print(f'Did not found {reg}, found {item} instead. Row will be removed')
        # print(df)

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

print(sala['zone'])

for item in sala:
    print(item)
