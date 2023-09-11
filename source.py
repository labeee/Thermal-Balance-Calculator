import pandas as pd

# Columns per zone
sala = {
    "SALA_PARIN_01S": "none_intwalls",
    "SALA_PARIN_00E": "none_intwalls",
    "SALA_PORTAIN_0_00E": "none_intwalls",
    "SALA_PARIN_01D": "none_intwalls",
    "SALA_PORTAIN_0_01D": "none_intwalls",
    "SALA_PARIN_02D": "none_intwalls",
    "SALA_PORTAIN_0_02D": "none_intwalls",
    "SALA_PAREX_00I": 'south_extwalls',
    "SALA_PAREX_01E": 'west_extwalls',
    'SALA_JAN_0_01E': 'west_windows'
}
dorm1 = {
    "DORM1_PARIN_00E": 'none_intwalls',
    "DORM1_PARIN_00S": 'none_intwalls',
    "DORM1_PORTAIN_0_00E": 'none_intwalls',
    "DORM1_PAREX_00I": 'south_extwalls',
    "DORM1_PAREX_00D": 'east_extwalls',
    "DORM1_PISO": 'none_floor',
    'DORM1_COB': 'none_roof',
    'DORM1_JAN_0_00I': 'south_windows'
}
dorm2 = {
    "DORM2_PARIN_00I": 'none_intwalls',
    "DORM2_PARIN_01E": 'none_intwalls',
    "DORM2_PORTAIN_0_01E": 'none_intwalls',
    "DORM2_PAREX_00E": 'west_extwalls',
    "DORM2_PAREX_00D": 'east_extwalls',
    'DORM2_PAREX_00S': 'north_extwalls',
    'DORM2_PISO': 'none_floor',
    'DORM2_COB': 'none_roof',
    'DORM2_JAN_0_00D': 'east_windows'
}
extras = {
    'Environment': 'temp_ext'
}

wanted_list = []
for item in sala:
    wanted_list.append(sala[item])
for item in dorm1:
    wanted_list.append(dorm1[item])
for item in dorm2:
    wanted_list.append(dorm2[item])
for item in extras:
    wanted_list.append(extras[item])
wanted_list = list(set(wanted_list))

convection = '_convection'
surface = '_conduction'

# Paths
surface_output_path = 'output/surface/'
convection_output_path = 'output/convection/'
surface_input_path = 'input/surface/'
convection_input_path = 'input/convection/'
full_output_path = 'output/full/'

# Main Functions
def sum_separated(coluna):
    positivos = coluna[coluna > 0].sum()
    negativos = coluna[coluna < 0].sum()
    return pd.Series([positivos, negativos])

def divide(df):
    divided = pd.DataFrame()
    col = df.columns
    for column in col:
        if column == extras['Environment']:
            divided[column] = df[column]
        else:
            divided[f'{column}_gains'] = df[column].apply(lambda item: item if item>0 else 0)
            divided[f'{column}_losses'] = df[column].apply(lambda item: item if item<0 else 0)
    divided = divided.sum().reset_index()
    divided.columns = ['type', 'value']
    return divided


# Style
software_name = """▀█▀ █░█ █▀▀ █▀█ █▀▄▀█ ▄▀█ █░░   █▄▄ ▄▀█ █░░ ▄▀█ █▄░█ █▀▀ █▀▀   █▀▀ ▄▀█ █░░ █▀▀ █░█ █░░ ▄▀█ ▀█▀ █▀█ █▀█
░█░ █▀█ ██▄ █▀▄ █░▀░█ █▀█ █▄▄   █▄█ █▀█ █▄▄ █▀█ █░▀█ █▄▄ ██▄   █▄▄ █▀█ █▄▄ █▄▄ █▄█ █▄▄ █▀█ ░█░ █▄█ █▀▄"""
end_message = """▀█▀ █░█ ▄▀█ █▄░█ █▄▀   █▄█ █▀█ █░█
░█░ █▀█ █▀█ █░▀█ █░█   ░█░ █▄█ █▄█
----------------------------------
LabEEE - Thermal Balance Calculator

    Developed by Zac   -    https://www.linkedin.com/in/zac-milioli
                       -    zacmilioli@gmail.com

    Created and directed by Letícia  -  https://www.linkedin.com/in/letícia-gabriela-eli-347063b0


    Texts from https://fsymbols.com/generators/blocky/
    Free of copyright
"""
def clear_screen():
    print('\n'*150)
def separators():
    interface_separators = open('separators.txt', 'r').readlines()[0]
    interface_separators = interface_separators*(round(100/len(interface_separators)))
    print(interface_separators)
