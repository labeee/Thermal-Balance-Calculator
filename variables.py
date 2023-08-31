
# Zones and columns
sala = {
    'zone': 'SALA',
    'none_intwalls': ["SALA_PARIN_01S","SALA_PARIN_00E","SALA_PORTAIN_0_00E","SALA_PARIN_01D","SALA_PORTAIN_0_01D","SALA_PARIN_02D","SALA_PORTAIN_0_02D"],
    'south_extwalls': ["SALA_PAREX_00I"],
    'west_extwalls': ["SALA_PAREX_01E"],
    'none_floor': ["DORM1_PISO"],
    'none_roof': ["DORM1_COB"],
    'south_windows': ["DORM1_JAN_0_00I"],
    'west_windows': ['SALA_JAN_0_01E']
}
dorm1 = {
    'zone': 'DORM1',
    'none_intwalls': ["DORM1_PARIN_00E","DORM1_PARIN_00S","DORM1_PORTAIN_0_00E"],
    'south_extwalls': ["DORM1_PAREX_00I"],
    'east_extwalls': ["DORM1_PAREX_00D"],
    'none_floor': ["DORM1_PISO"],
    'none_roof': ['DORM1_COB'],
    'south_windows': ['DORM1_JAN_0_00I']
}
dorm2 = {
    'zone': 'DORM2',
    'none_intwalls': ["DORM2_PARIN_00I","DORM2_PARIN_01E","DORM2_PORTAIN_0_01E"],
    'west_extwalls': ["DORM2_PAREX_00E"],
    'east_extwalls': ["DORM2_PAREX_00D"],
    'north_extwalls': ['DORM2_PAREX_00S'],
    'none_floor': ['DORM2_PISO'],
    'none_roof': ['DORM2_COB'],
    'east_windows': ['DORM2_JAN_0_00D']
}

# Paths
surface_output_path = 'output/surface/'
convection_output_path = 'output/convection/'
surface_input_path = 'input/surface/'
convection_input_path = 'input/convection/'

# Style
interface_separators = '- '*45
screen_clean = '\n'*150
