import pandas as pd
import re
import numpy

dado = {
    "Position": [
        "QUARTO1_trashtrash",
        "QUARTO1_trash2trash2",
        "BWC_trashtrash",
        "QUARTO2_trashtrash"
    ],
    "A": [
        1,
        2,
        3,
        4
    ],
    "B": [
        5,
        6,
        7,
        8
    ],
    "C": [
        9,
        10,
        11,
        12
    ]
}

df = pd.DataFrame(dado)
print('\n'*5)
print(df)
print('\n'*5)

busca = 'QUARTO1'

# print('\n'*5)
# print(df.iloc[:, 0])

for item in df.iloc[:, 0]:
    reg = re.search(busca, item)
    print('\n'*5)
    if reg != None:
        print(reg.group())
        df.replace(item, busca, inplace=True)
        print(f'Found {reg}')
        print(df)
    else:
        df.replace(item, numpy.nan, inplace=True)
        print(f'Did not found {reg}, found {item} instead')
        print(df)

print('\n'*5)
df.dropna(inplace=True)

print('\n'*5)
print(df)
print('\n'*5)

# soma = df.loc[0:, ["A", "B", "C"]].sum()
# print(soma)
# print('\n'*5)

# df.loc['total'] = soma
# print(df)
# print('\n'*5)