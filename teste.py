import pandas as pd

dado = {
    "Position": [
        "primeiro",
        "segundo",
        "terceiro",
        "quarto"
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

soma = df.loc[0:, ["A", "B", "C"]].sum()
print(soma)
print('\n'*5)

df.loc['total'] = soma
print(df)
print('\n'*5)
