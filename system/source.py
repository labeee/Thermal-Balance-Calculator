import pandas as pd
import warnings
from glob import glob
import os
from datetime import datetime, timedelta
warnings.filterwarnings("ignore")

# Columns per zone
sala = {
    "ZONE": "SALA",
    "SALA_PARIN_01S": "none_intwalls",
    "SALA_PARIN_00E": "none_intwalls",
    "SALA_PORTAIN_0_00E": "none_intwalls",
    "SALA_PARIN_01D": "none_intwalls",
    "SALA_PORTAIN_0_01D": "none_intwalls",
    "SALA_PARIN_02D": "none_intwalls",
    "SALA_PORTAIN_0_02D": "none_intwalls",
    "SALA_PAREX_00I": 'south_extwalls',
    "SALA_PAREX_01E": 'west_extwalls',
    "SALA_PAREX_00S": 'north_extwalls',
    "SALA_PORTAEX_0_00S": 'north_extwalls',
    'SALA_JAN_0_01E:Surface Inside': 'west_windows',
    'SALA_JAN_0_00I:Surface Inside': 'south_windows',
    'SALA_JAN_0_00I:Surface Window': 'south_frame',
    'SALA_JAN_0_01E:Surface Window': 'west_frame',
    'SALA:Zone Total': 'internal_gains',
    'SALA:AFN Zone Ventilation Sensible Heat Gain': 'vn_window_gain',
    'SALA:AFN Zone Ventilation Sensible Heat Loss': 'vn_window_loss',
    'SALA:AFN Zone Mixing Sensible Heat Gain': 'vn_interzone_gain',
    'SALA:AFN Zone Mixing Sensible Heat Loss': 'vn_interzone_loss',
    'SALA:Zone Air System Sensible Heating': 'heating',
    'SALA:Zone Air System Sensible Cooling': 'cooling'
}
dorm1 = {
    "ZONE": "DORM1",
    "DORM1_PARIN_00E": 'none_intwalls',
    "DORM1_PARIN_00S": 'none_intwalls',
    "DORM1_PORTAIN_0_00E": 'none_intwalls',
    "DORM1_PAREX_00I": 'south_extwalls',
    "DORM1_PAREX_00D": 'east_extwalls',
    "DORM1_PISO": 'none_floor',
    'DORM1_COB': 'none_roof',
    'DORM1_JAN_0_00I:Surface Inside': 'south_windows',
    'DORM1_JAN_0_00I:Surface Window': 'south_frame',
    'DORM1:Zone Total Internal': 'internal_gains',
    'DORM1:AFN Zone Ventilation Sensible Heat Gain': 'vn_window_gain',
    'DORM1:AFN Zone Ventilation Sensible Heat Loss': 'vn_window_loss',
    'DORM1:AFN Zone Mixing Sensible Heat Gain': 'vn_interzone_gain',
    'DORM1:AFN Zone Mixing Sensible Heat Loss': 'vn_interzone_loss',
    'DORM1:Zone Air System Sensible Heating': 'heating',
    'DORM1:Zone Air System Sensible Cooling': 'cooling'
}
dorm2 = {
    "ZONE": "DORM2",
    "DORM2_PARIN_00I": 'none_intwalls',
    "DORM2_PARIN_01E": 'none_intwalls',
    "DORM2_PORTAIN_0_01E": 'none_intwalls',
    "DORM2_PAREX_00E": 'west_extwalls',
    "DORM2_PAREX_00D": 'east_extwalls',
    'DORM2_PAREX_00S': 'north_extwalls',
    'DORM2_PISO': 'none_floor',
    'DORM2_COB': 'none_roof',
    'DORM2_JAN_0_00D:Surface Inside': 'east_windows',
    'DORM2_JAN_0_00D:Surface Window': 'east_frame',
    'DORM2:Zone Total Internal': 'internal_gains',
    'DORM2:AFN Zone Ventilation Sensible Heat Gain': 'vn_window_gain',
    'DORM2:AFN Zone Ventilation Sensible Heat Loss': 'vn_window_loss',
    'DORM2:AFN Zone Mixing Sensible Heat Gain': 'vn_interzone_gain',
    'DORM2:AFN Zone Mixing Sensible Heat Loss': 'vn_interzone_loss',
    'DORM2:Zone Air System Sensible Heating': 'heating',
    'DORM2:Zone Air System Sensible Cooling': 'cooling'
}
all = {
    'ZONE': 'ALL ZONES',
    'Environment': 'temp_ext'
}

wanted_list = ['Date/Time', 'temp_ext']
for item in sala:
    wanted_list.append(f"{sala['ZONE']}_{sala[item]}")
for item in dorm1:
    wanted_list.append(f"{dorm1['ZONE']}_{dorm1[item]}")
for item in dorm2:
    wanted_list.append(f"{dorm2['ZONE']}_{dorm2[item]}")
wanted_list = list(set(wanted_list))

dont_change_list = ['temp_ext']
for item in wanted_list:
    if item.endswith('loss') or item.endswith('gains') or item.endswith('gain') or item.endswith('cooling') or item.endswith('heating'):
        dont_change_list.append(item)
dont_change_list = list(set(dont_change_list))

ref_multiply_list = ["none_intwalls", "south_extwalls", "north_extwalls", "west_extwalls", "east_extwalls", "none_floor", "none_roof", "south_windows", "west_windows", "east_windows", "east_windows", "vn_window_loss", "vn_interzone_loss", "cooling"]
multiply_list = []
for item in ref_multiply_list:
    for i in wanted_list:
        if item in i:
            multiply_list.append(i)
multiply_list = list(set(multiply_list))

convection = 'convection'
surface = 'conduction'

# Paths
surface_output_path = r'output/surface/'
convection_output_path = r'output/convection/'
surface_input_path = r'input/surface/'
convection_input_path = r'input/convection/'
full_output_path = r'output/full/'
organizer_path = r'system/organizer/'

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
warn = """█░█░█ ▄▀█ █▀█ █▄░█ █ █▄░█ █▀▀
▀▄▀▄▀ █▀█ █▀▄ █░▀█ █ █░▀█ █▄█"""
def clear_screen():
    """Limpa a tela"""
    print('\n'*150)
def separators():
    """Lê e printa os separadores da interface"""
    interface_separators = open('system/separators.txt', 'r').readlines()[0]
    print(interface_separators)
def clean_cache():
    glob_remove = glob(organizer_path+'*.csv')
    if glob_remove != []:
        for item in glob_remove:
            os.remove(item)
    