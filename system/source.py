import pandas as pd
import warnings
import sqlite3
from glob import glob
import os
from datetime import datetime, timedelta
warnings.filterwarnings("ignore")

zone_addons = {
    'Zone Total Internal Convective Heating Rate': 'convection?internal_gains',
    'AFN Zone Ventilation Sensible Heat Gain Rate': 'convection?vn_window_gain',
    'AFN Zone Ventilation Sensible Heat Loss Rate': 'convection?vn_window_loss',
    'AFN Zone Mixing Sensible Heat Gain Rate': 'convection?vn_interzone_gain',
    'AFN Zone Mixing Sensible Heat Loss Rate': 'convection?vn_interzone_loss',
    'Zone Air System Sensible Heating Rate': 'convection?heating',
    'Zone Air System Sensible Cooling Rate': 'convection?cooling'
}

convection_addons = {
    'default': 'Surface Inside Face Convection Heat Gain Rate',
    'frame': 'Surface Window Inside Face Frame and Divider Zone Heat Gain Rate'
}

surface_addons = {
    'Surface Inside Face Convection Heat Gain Rate': 'convection',
    'Surface Inside Face Conduction Heat Transfer Rate': 'conduction',
    'Surface Inside Face Solar Radiation Heat Gain Rate': 'solarrad',
    'Surface Inside Face Lights Radiation Heat Gain Rate': 'swlights',
    'Surface Inside Face Net Surface Thermal Radiation Heat Gain Rate': 'lwsurfaces',
    'Surface Inside Face Internal Gains Radiation Heat Gain Rate': 'lwinternal'
}

drybulb_rename = {'EXTERNAL': {'Environment': 'drybulb?temp_ext'}}

def read_db_and_build_dicts(selected_zones, way):
    englob = glob(r'input/*.sql')
    print('\nConnecting to database...')
    conn = sqlite3.connect(englob[0])

    cursor = conn.cursor()

    if selected_zones != 'All':
        selected_zones = ', '.join(f'"{zona}"' for zona in selected_zones)
        cursor.execute(f"SELECT ZoneIndex, ZoneName FROM Zones WHERE ZoneName IN ({selected_zones});")
    else:
        cursor.execute("SELECT ZoneIndex, ZoneName FROM Zones;")
    result = cursor.fetchall()
    zones_dict = {}
    for i in result:
        zones_dict[i[1]] = i[0]
    print(f'\nReturned {zones_dict}')
    surfaces_dict = {}
    for key, value in zones_dict.items():
        print(f'Building dataframe of information for {key} of value {value}')
        cursor.execute(f"SELECT ZoneIndex, SurfaceName, ClassName, Azimuth, ExtBoundCond FROM Surfaces WHERE ZoneIndex={value};")
        result = cursor.fetchall()
        surfaces_dict[key] = pd.DataFrame(result, columns=['ZoneIndex', 'SurfaceName', 'ClassName', 'Azimuth', 'ExtBoundCond'])
        for idx in surfaces_dict[key].index:

            if surfaces_dict[key].at[idx, 'ExtBoundCond'] == 0:
                surfaces_dict[key].at[idx, 'ExtBoundCond'] = 'ext'
            else:
                surfaces_dict[key].at[idx, 'ExtBoundCond'] = 'int'
                
            azimuth = surfaces_dict[key].at[idx, 'Azimuth']
            if azimuth < 22.5 or azimuth >= 337.5:
                surfaces_dict[key].at[idx, 'Azimuth'] = 'north'
            elif azimuth >= 22.5 and azimuth < 67.5:
                surfaces_dict[key].at[idx, 'Azimuth'] = 'northeast'
            elif azimuth >= 67.5 and azimuth < 112.5:
                surfaces_dict[key].at[idx, 'Azimuth'] = 'east'
            elif azimuth >= 112.5 and azimuth < 157.5:
                surfaces_dict[key].at[idx, 'Azimuth'] = 'southeast'
            elif azimuth >= 157.5 and azimuth < 202.5:
                surfaces_dict[key].at[idx, 'Azimuth'] = 'south'
            elif azimuth >= 202.5 and azimuth < 247.5:
                surfaces_dict[key].at[idx, 'Azimuth'] = 'southwest'
            elif azimuth >= 247.5 and azimuth < 292.5:
                surfaces_dict[key].at[idx, 'Azimuth'] = 'west'
            elif azimuth >= 292.5 and azimuth < 337.5:
                surfaces_dict[key].at[idx, 'Azimuth'] = 'northwest'

            match surfaces_dict[key].at[idx, 'ClassName']:
                case 'Door':
                    surfaces_dict[key].at[idx, 'ClassName'] = 'Wall'
                case 'Ceiling':
                    surfaces_dict[key].at[idx, 'ClassName'] = 'Roof'
    cursor.close()
    conn.close()
    print('\nBuilding dictionary of names to rename...')
    dicionario = {}
    for zone, dataframe in surfaces_dict.items():
        dicionario[zone] = {'convection': {}, 'surface': {}}
        print('\nCreating zones...')
        for zone_specific, zone_transform in zone_addons.items():
            dicionario[zone]['convection'][f'{zone}:{zone_specific}'] = zone_transform
        print('\nCreating surfaces...')
        for idx in dataframe.index:
            surf_name = dataframe.at[idx, 'SurfaceName']
            surf_type = dataframe.at[idx, 'ClassName']
            surf_bound = dataframe.at[idx, 'ExtBoundCond']
            surf_azimuth = dataframe.at[idx, 'Azimuth']
            match way:
                case 'convection':
                    #convection
                    if surf_type in ['Window', 'GlassDoor']:
                        dicionario[zone]['convection'][f'{surf_name}:{convection_addons["frame"]}'] = f'convection?{surf_azimuth}_frame'
                    dicionario[zone]['convection'][f'{surf_name}:{convection_addons["default"]}'] = f'convection?{surf_azimuth}_{surf_bound}{surf_type}'
                case 'surface':
                    #surface
                    for surface_specific, surf_transf in surface_addons.items():
                        dicionario[zone]['surface'][f'{surf_name}:{surface_specific}'] = f'{surf_transf}?{surf_azimuth}_{surf_bound}{surf_type}'
    print('\nFinished processing')
    return dicionario

# Paths
surface_output_path = r'output/surface/'
convection_output_path = r'output/convection/'
surface_input_path = r'input/'
convection_input_path = r'input/'
organizer_path = r'system/organizer/'

frames_and_windows = {
    'SALA_convection?south_frame': 'SALA_convection?south_windows',
    'SALA_convection?west_frame': 'SALA_convection?west_windows',
    'DORM1_convection?south_frame': 'DORM1_convection?south_windows',
    'DORM2_convection?east_frame': 'DORM2_convection?east_windows' 
}

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
    """Limpa o cache (arquivos temporários na pasta organizer)"""
    glob_remove = glob(organizer_path+'*.csv')
    if glob_remove != []:
        for item in glob_remove:
            os.remove(item)
    