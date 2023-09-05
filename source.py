from glob import glob
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
    "DORM1_PISO": 'none_floor',
    "DORM1_COB": 'none_roof',
    "DORM1_JAN_0_00I": 'south_windows',
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
    'Environment': 'outdoor_air_drybulb_temperature'
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

convection = 'convection'
surface = 'conduction'

# Paths
surface_output_path = 'output/surface/'
convection_output_path = 'output/convection/'
surface_input_path = 'input/surface/'
convection_input_path = 'input/convection/'
full_output_path = 'output/full/'

# Style
interface_separators = '- '*45
screen_clean = '\n'*150

# Functions
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
