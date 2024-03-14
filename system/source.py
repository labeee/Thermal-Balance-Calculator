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

def read_db(selected_zones: list = None):
    conn = sqlite3.connect(r'input/database.sql')

    cursor = conn.cursor()

    if selected_zones != None:
        selected_zones = ', '.join(f'"{zona}"' for zona in selected_zones)
        cursor.execute(f"SELECT ZoneIndex, ZoneName FROM Zones WHERE ZoneName IN ({selected_zones});")
    else:
        cursor.execute("SELECT ZoneIndex, ZoneName FROM Zones;")
    result = cursor.fetchall()
    zones_dict = {}
    for i in result:
        zones_dict[i[1]] = i[0]

    surfaces_dict = {}
    for key, value in zones_dict.items():
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

    dicionario = {'ALL ZONES': {'Environment': 'drybulb?temp_ext'}}
    for zone, dataframe in surfaces_dict.items():
        dicionario[zone] = {'convection': {}, 'surface': {}}
        for zone_specific, zone_transform in zone_addons.items():
            dicionario[zone]['convection'][f'{zone}:{zone_specific}'] = zone_transform
        for idx in dataframe.index():
            surf_name = dataframe.at[idx, 'SurfaceName']
            surf_type = dataframe.at[idx, 'ClassName']
            surf_bound = dataframe.at[idx, 'ExtBoundCond']
            surf_azimuth = dataframe.at[idx, 'Azimuth']
            #convection
            if surf_type in ['Window', 'GlassDoor']:
                dicionario[zone]['convection'][f'{surf_name}:{convection_addons["frame"]}'] = f'convection?{surf_azimuth}_frame'
            dicionario[zone]['convection'][f'{surf_name}:{convection_addons["default"]}'] = f'convection?{surf_azimuth}_{surf_bound}{surf_type}'
            #surface
            for surface_specific, surf_transf in surface_addons.items():
                dicionario[zone]['surface'][f'{surf_name}:{surface_specific}'] = f'{surf_transf}?{surf_azimuth}_{surf_bound}{surf_type}'
    return dicionario


# Columns per zone  
sala = {
    "ZONE": "SALA",
    "convection": {
        "SALA_PARIN_01S:Surface Inside Face Convection Heat Gain Rate": "convection?none_intwalls",
        "SALA_PARIN_00E:Surface Inside Face Convection Heat Gain Rate": "convection?none_intwalls",
        "SALA_PORTAIN_0_00E:Surface Inside Face Convection Heat Gain Rate": "convection?none_intwalls",
        "SALA_PARIN_01D:Surface Inside Face Convection Heat Gain Rate": "convection?none_intwalls",
        "SALA_PORTAIN_0_01D:Surface Inside Face Convection Heat Gain Rate": "convection?none_intwalls",
        "SALA_PARIN_02D:Surface Inside Face Convection Heat Gain Rate": "convection?none_intwalls",
        "SALA_PORTAIN_0_02D:Surface Inside Face Convection Heat Gain Rate": "convection?none_intwalls",
        "SALA_PAREX_00I:Surface Inside Face Convection Heat Gain Rate": "convection?south_extwalls",
        "SALA_PAREX_00S:Surface Inside Face Convection Heat Gain Rate": "convection?north_extwalls",
        "SALA_PORTAEX_0_00S:Surface Inside Face Convection Heat Gain Rate": "convection?north_extwalls",
        "SALA_PAREX_01E:Surface Inside Face Convection Heat Gain Rate": "convection?west_extwalls",
        "SALA_PAREX_00D:Surface Inside Face Convection Heat Gain Rate": "convection?east_extwalls",
        "SALA_PORTAEX_0_00D:Surface Inside Face Convection Heat Gain Rate": "convection?east_extwalls",
        "SALA_PISO:Surface Inside Face Convection Heat Gain Rate": "convection?none_floor",
        "SALA_COB_1:Surface Inside Face Convection Heat Gain Rate": "convection?none_roof",
        "SALA_COB_0:Surface Inside Face Convection Heat Gain Rate": "convection?none_roof",
        "SALA_JAN_0_00I:Surface Inside Face Convection Heat Gain Rate": "convection?south_windows",
        "SALA_JAN_0_01E:Surface Inside Face Convection Heat Gain Rate": "convection?west_windows",
        "SALA_JAN_0_00I:Surface Window Inside Face Frame and Divider Zone Heat Gain Rate": "convection?south_frame",
        "SALA_JAN_0_01E:Surface Window Inside Face Frame and Divider Zone Heat Gain Rate": "convection?west_frame",
        "SALA:Zone Total Internal Convective Heating Rate": "convection?internal_gains",
        "SALA:AFN Zone Ventilation Sensible Heat Gain Rate": "convection?vn_window_gain",
        "SALA:AFN Zone Ventilation Sensible Heat Loss Rate": "convection?vn_window_loss",
        "SALA:AFN Zone Mixing Sensible Heat Gain Rate": "convection?vn_interzone_gain",
        "SALA:AFN Zone Mixing Sensible Heat Loss Rate": "convection?vn_interzone_loss",
        "SALA:Zone Air System Sensible Heating Rate": "convection?heating",
        "SALA:Zone Air System Sensible Cooling Rate": "convection?cooling"
        },
    "surface": {
        'SALA_PARIN_01S:Surface Inside Face Convection Heat Gain Rate': 'convection?none_intwalls',
        'SALA_PARIN_00E:Surface Inside Face Convection Heat Gain Rate': 'convection?none_intwalls',
        'SALA_PORTAIN_0_00E:Surface Inside Face Convection Heat Gain Rate': 'convection?none_intwalls',
        'SALA_PARIN_01D:Surface Inside Face Convection Heat Gain Rate': 'convection?none_intwalls',
        'SALA_PORTAIN_0_01D:Surface Inside Face Convection Heat Gain Rate': 'convection?none_intwalls',
        'SALA_PARIN_02D:Surface Inside Face Convection Heat Gain Rate': 'convection?none_intwalls',
        'SALA_PORTAIN_0_02D:Surface Inside Face Convection Heat Gain Rate': 'convection?none_intwalls',
        'SALA_PAREX_00I:Surface Inside Face Convection Heat Gain Rate': 'convection?south_extwalls',
        'SALA_PAREX_00S:Surface Inside Face Convection Heat Gain Rate': 'convection?north_extwalls',
        'SALA_PORTAEX_0_00S:Surface Inside Face Convection Heat Gain Rate': 'convection?north_extwalls',
        'SALA_PAREX_01E:Surface Inside Face Convection Heat Gain Rate': 'convection?west_extwalls',
        'SALA_PAREX_00D:Surface Inside Face Convection Heat Gain Rate': 'convection?east_extwalls',
        'SALA_PORTAEX_0_00D:Surface Inside Face Convection Heat Gain Rate': 'convection?east_extwalls',
        'SALA_PISO:Surface Inside Face Convection Heat Gain Rate': 'convection?none_floor',
        'SALA_COB_1:Surface Inside Face Convection Heat Gain Rate': 'convection?none_roof',
        'SALA_COB_0:Surface Inside Face Convection Heat Gain Rate': 'convection?none_roof',
        'SALA_PARIN_01S:Surface Inside Face Conduction Heat Transfer Rate': 'conduction?none_intwalls',
        'SALA_PARIN_00E:Surface Inside Face Conduction Heat Transfer Rate': 'conduction?none_intwalls',
        'SALA_PORTAIN_0_00E:Surface Inside Face Conduction Heat Transfer Rate': 'conduction?none_intwalls',
        'SALA_PARIN_01D:Surface Inside Face Conduction Heat Transfer Rate': 'conduction?none_intwalls',
        'SALA_PORTAIN_0_01D:Surface Inside Face Conduction Heat Transfer Rate': 'conduction?none_intwalls',
        'SALA_PARIN_02D:Surface Inside Face Conduction Heat Transfer Rate': 'conduction?none_intwalls',
        'SALA_PORTAIN_0_02D:Surface Inside Face Conduction Heat Transfer Rate': 'conduction?none_intwalls',
        'SALA_PAREX_00I:Surface Inside Face Conduction Heat Transfer Rate': 'conduction?south_extwalls',
        'SALA_PAREX_00S:Surface Inside Face Conduction Heat Transfer Rate': 'conduction?north_extwalls',
        'SALA_PORTAEX_0_00S:Surface Inside Face Conduction Heat Transfer Rate': 'conduction?north_extwalls',
        'SALA_PAREX_01E:Surface Inside Face Conduction Heat Transfer Rate': 'conduction?west_extwalls',
        'SALA_PAREX_00D:Surface Inside Face Conduction Heat Transfer Rate': 'conduction?east_extwalls',
        'SALA_PORTAEX_0_00D:Surface Inside Face Conduction Heat Transfer Rate': 'conduction?east_extwalls',
        'SALA_PISO:Surface Inside Face Conduction Heat Transfer Rate': 'conduction?none_floor',
        'SALA_COB_1:Surface Inside Face Conduction Heat Transfer Rate': 'conduction?none_roof',
        'SALA_COB_0:Surface Inside Face Conduction Heat Transfer Rate': 'conduction?none_roof',
        'SALA_PARIN_01S:Surface Inside Face Solar Radiation Heat Gain Rate': 'solarrad?none_intwalls',
        'SALA_PARIN_00E:Surface Inside Face Solar Radiation Heat Gain Rate': 'solarrad?none_intwalls',
        'SALA_PORTAIN_0_00E:Surface Inside Face Solar Radiation Heat Gain Rate': 'solarrad?none_intwalls',
        'SALA_PARIN_01D:Surface Inside Face Solar Radiation Heat Gain Rate': 'solarrad?none_intwalls',
        'SALA_PORTAIN_0_01D:Surface Inside Face Solar Radiation Heat Gain Rate': 'solarrad?none_intwalls',
        'SALA_PARIN_02D:Surface Inside Face Solar Radiation Heat Gain Rate': 'solarrad?none_intwalls',
        'SALA_PORTAIN_0_02D:Surface Inside Face Solar Radiation Heat Gain Rate': 'solarrad?none_intwalls',
        'SALA_PAREX_00I:Surface Inside Face Solar Radiation Heat Gain Rate': 'solarrad?south_extwalls',
        'SALA_PAREX_00S:Surface Inside Face Solar Radiation Heat Gain Rate': 'solarrad?north_extwalls',
        'SALA_PORTAEX_0_00S:Surface Inside Face Solar Radiation Heat Gain Rate': 'solarrad?north_extwalls',
        'SALA_PAREX_01E:Surface Inside Face Solar Radiation Heat Gain Rate': 'solarrad?west_extwalls',
        'SALA_PAREX_00D:Surface Inside Face Solar Radiation Heat Gain Rate': 'solarrad?east_extwalls',
        'SALA_PORTAEX_0_00D:Surface Inside Face Solar Radiation Heat Gain Rate': 'solarrad?east_extwalls',
        'SALA_PISO:Surface Inside Face Solar Radiation Heat Gain Rate': 'solarrad?none_floor',
        'SALA_COB_1:Surface Inside Face Solar Radiation Heat Gain Rate': 'solarrad?none_roof',
        'SALA_COB_0:Surface Inside Face Solar Radiation Heat Gain Rate': 'solarrad?none_roof',
        'SALA_PARIN_01S:Surface Inside Face Lights Radiation Heat Gain Rate': 'swlights?none_intwalls',
        'SALA_PARIN_00E:Surface Inside Face Lights Radiation Heat Gain Rate': 'swlights?none_intwalls',
        'SALA_PORTAIN_0_00E:Surface Inside Face Lights Radiation Heat Gain Rate': 'swlights?none_intwalls',
        'SALA_PARIN_01D:Surface Inside Face Lights Radiation Heat Gain Rate': 'swlights?none_intwalls',
        'SALA_PORTAIN_0_01D:Surface Inside Face Lights Radiation Heat Gain Rate': 'swlights?none_intwalls',
        'SALA_PARIN_02D:Surface Inside Face Lights Radiation Heat Gain Rate': 'swlights?none_intwalls',
        'SALA_PORTAIN_0_02D:Surface Inside Face Lights Radiation Heat Gain Rate': 'swlights?none_intwalls',
        'SALA_PAREX_00I:Surface Inside Face Lights Radiation Heat Gain Rate': 'swlights?south_extwalls',
        'SALA_PAREX_00S:Surface Inside Face Lights Radiation Heat Gain Rate': 'swlights?north_extwalls',
        'SALA_PORTAEX_0_00S:Surface Inside Face Lights Radiation Heat Gain Rate': 'swlights?north_extwalls',
        'SALA_PAREX_01E:Surface Inside Face Lights Radiation Heat Gain Rate': 'swlights?west_extwalls',
        'SALA_PAREX_00D:Surface Inside Face Lights Radiation Heat Gain Rate': 'swlights?east_extwalls',
        'SALA_PORTAEX_0_00D:Surface Inside Face Lights Radiation Heat Gain Rate': 'swlights?east_extwalls',
        'SALA_PISO:Surface Inside Face Lights Radiation Heat Gain Rate': 'swlights?none_floor',
        'SALA_COB_1:Surface Inside Face Lights Radiation Heat Gain Rate': 'swlights?none_roof',
        'SALA_COB_0:Surface Inside Face Lights Radiation Heat Gain Rate': 'swlights?none_roof',
        'SALA_PARIN_01S:Surface Inside Face Net Surface Thermal Radiation Heat Gain Rate': 'lwsurfaces?none_intwalls',
        'SALA_PARIN_00E:Surface Inside Face Net Surface Thermal Radiation Heat Gain Rate': 'lwsurfaces?none_intwalls',
        'SALA_PORTAIN_0_00E:Surface Inside Face Net Surface Thermal Radiation Heat Gain Rate': 'lwsurfaces?none_intwalls',
        'SALA_PARIN_01D:Surface Inside Face Net Surface Thermal Radiation Heat Gain Rate': 'lwsurfaces?none_intwalls',
        'SALA_PORTAIN_0_01D:Surface Inside Face Net Surface Thermal Radiation Heat Gain Rate': 'lwsurfaces?none_intwalls',
        'SALA_PARIN_02D:Surface Inside Face Net Surface Thermal Radiation Heat Gain Rate': 'lwsurfaces?none_intwalls',
        'SALA_PORTAIN_0_02D:Surface Inside Face Net Surface Thermal Radiation Heat Gain Rate': 'lwsurfaces?none_intwalls',
        'SALA_PAREX_00I:Surface Inside Face Net Surface Thermal Radiation Heat Gain Rate': 'lwsurfaces?south_extwalls',
        'SALA_PAREX_00S:Surface Inside Face Net Surface Thermal Radiation Heat Gain Rate': 'lwsurfaces?north_extwalls',
        'SALA_PORTAEX_0_00S:Surface Inside Face Net Surface Thermal Radiation Heat Gain Rate': 'lwsurfaces?north_extwalls',
        'SALA_PAREX_01E:Surface Inside Face Net Surface Thermal Radiation Heat Gain Rate': 'lwsurfaces?west_extwalls',
        'SALA_PAREX_00D:Surface Inside Face Net Surface Thermal Radiation Heat Gain Rate': 'lwsurfaces?east_extwalls',
        'SALA_PORTAEX_0_00D:Surface Inside Face Net Surface Thermal Radiation Heat Gain Rate': 'lwsurfaces?east_extwalls',
        'SALA_PISO:Surface Inside Face Net Surface Thermal Radiation Heat Gain Rate': 'lwsurfaces?none_floor',
        'SALA_COB_1:Surface Inside Face Net Surface Thermal Radiation Heat Gain Rate': 'lwsurfaces?none_roof',
        'SALA_COB_0:Surface Inside Face Net Surface Thermal Radiation Heat Gain Rate': 'lwsurfaces?none_roof',
        'SALA_PARIN_01S:Surface Inside Face Internal Gains Radiation Heat Gain Rate': 'lwinternal?none_intwalls',
        'SALA_PARIN_00E:Surface Inside Face Internal Gains Radiation Heat Gain Rate': 'lwinternal?none_intwalls',
        'SALA_PORTAIN_0_00E:Surface Inside Face Internal Gains Radiation Heat Gain Rate': 'lwinternal?none_intwalls',
        'SALA_PARIN_01D:Surface Inside Face Internal Gains Radiation Heat Gain Rate': 'lwinternal?none_intwalls',
        'SALA_PORTAIN_0_01D:Surface Inside Face Internal Gains Radiation Heat Gain Rate': 'lwinternal?none_intwalls',
        'SALA_PARIN_02D:Surface Inside Face Internal Gains Radiation Heat Gain Rate': 'lwinternal?none_intwalls',
        'SALA_PORTAIN_0_02D:Surface Inside Face Internal Gains Radiation Heat Gain Rate': 'lwinternal?none_intwalls',
        'SALA_PAREX_00I:Surface Inside Face Internal Gains Radiation Heat Gain Rate': 'lwinternal?south_extwalls',
        'SALA_PAREX_00S:Surface Inside Face Internal Gains Radiation Heat Gain Rate': 'lwinternal?north_extwalls',
        'SALA_PORTAEX_0_00S:Surface Inside Face Internal Gains Radiation Heat Gain Rate': 'lwinternal?north_extwalls',
        'SALA_PAREX_01E:Surface Inside Face Internal Gains Radiation Heat Gain Rate': 'lwinternal?west_extwalls',
        'SALA_PAREX_00D:Surface Inside Face Internal Gains Radiation Heat Gain Rate': 'lwinternal?east_extwalls',
        'SALA_PORTAEX_0_00D:Surface Inside Face Internal Gains Radiation Heat Gain Rate': 'lwinternal?east_extwalls',
        'SALA_PISO:Surface Inside Face Internal Gains Radiation Heat Gain Rate': 'lwinternal?none_floor',
        'SALA_COB_1:Surface Inside Face Internal Gains Radiation Heat Gain Rate': 'lwinternal?none_roof',
        'SALA_COB_0:Surface Inside Face Internal Gains Radiation Heat Gain Rate': 'lwinternal?none_roof'
    }
}
dorm1 = {
    "ZONE": "DORM1",
    "convection": {
        "DORM1_PARIN_00E:Surface Inside Face Convection Heat Gain Rate": "convection?none_intwalls",
        "DORM1_PARIN_00S:Surface Inside Face Convection Heat Gain Rate": "convection?none_intwalls",
        "DORM1_PORTAIN_0_00E:Surface Inside Face Convection Heat Gain Rate": "convection?none_intwalls",
        "DORM1_PAREX_00I:Surface Inside Face Convection Heat Gain Rate": "convection?south_extwalls",
        "DORM1_PAREX_00D:Surface Inside Face Convection Heat Gain Rate": "convection?east_extwalls",
        "DORM1_PISO:Surface Inside Face Convection Heat Gain Rate": "convection?none_floor",
        "DORM1_COB:Surface Inside Face Convection Heat Gain Rate": "convection?none_roof",
        "DORM1_JAN_0_00I:Surface Inside Face Convection Heat Gain Rate": "convection?south_windows",
        "DORM1_JAN_0_00I:Surface Window Inside Face Frame and Divider Zone Heat Gain Rate": "convection?south_frame",
        "DORM1:Zone Total Internal Convective Heating Rate": "convection?internal_gains",
        "DORM1:AFN Zone Ventilation Sensible Heat Gain Rate": "convection?vn_window_gain",
        "DORM1:AFN Zone Ventilation Sensible Heat Loss Rate": "convection?vn_window_loss",
        "DORM1:AFN Zone Mixing Sensible Heat Gain Rate": "convection?vn_interzone_gain",
        "DORM1:AFN Zone Mixing Sensible Heat Loss Rate": "convection?vn_interzone_loss",
        "DORM1:Zone Air System Sensible Heating Rate": "convection?heating",
        "DORM1:Zone Air System Sensible Cooling Rate": "convection?cooling"
        },
    "surface": {
        'DORM1_PARIN_00E:Surface Inside Face Convection Heat Gain Rate': 'convection?none_intwalls',
        'DORM1_PARIN_00S:Surface Inside Face Convection Heat Gain Rate': 'convection?none_intwalls',
        'DORM1_PORTAIN_0_00E:Surface Inside Face Convection Heat Gain Rate': 'convection?none_intwalls',
        'DORM1_PAREX_00I:Surface Inside Face Convection Heat Gain Rate': 'convection?south_extwalls',
        'DORM1_PAREX_00D:Surface Inside Face Convection Heat Gain Rate': 'convection?east_extwalls',
        'DORM1_PISO:Surface Inside Face Convection Heat Gain Rate': 'convection?none_floor',
        'DORM1_COB:Surface Inside Face Convection Heat Gain Rate': 'convection?none_roof',
        'DORM1_PARIN_00E:Surface Inside Face Conduction Heat Transfer Rate': 'conduction?none_intwalls',
        'DORM1_PARIN_00S:Surface Inside Face Conduction Heat Transfer Rate': 'conduction?none_intwalls',
        'DORM1_PORTAIN_0_00E:Surface Inside Face Conduction Heat Transfer Rate': 'conduction?none_intwalls',
        'DORM1_PAREX_00I:Surface Inside Face Conduction Heat Transfer Rate': 'conduction?south_extwalls',
        'DORM1_PAREX_00D:Surface Inside Face Conduction Heat Transfer Rate': 'conduction?east_extwalls',
        'DORM1_PISO:Surface Inside Face Conduction Heat Transfer Rate': 'conduction?none_floor',
        'DORM1_COB:Surface Inside Face Conduction Heat Transfer Rate': 'conduction?none_roof',
        'DORM1_PARIN_00E:Surface Inside Face Solar Radiation Heat Gain Rate': 'solarrad?none_intwalls',
        'DORM1_PARIN_00S:Surface Inside Face Solar Radiation Heat Gain Rate': 'solarrad?none_intwalls',
        'DORM1_PORTAIN_0_00E:Surface Inside Face Solar Radiation Heat Gain Rate': 'solarrad?none_intwalls',
        'DORM1_PAREX_00I:Surface Inside Face Solar Radiation Heat Gain Rate': 'solarrad?south_extwalls',
        'DORM1_PAREX_00D:Surface Inside Face Solar Radiation Heat Gain Rate': 'solarrad?east_extwalls',
        'DORM1_PISO:Surface Inside Face Solar Radiation Heat Gain Rate': 'solarrad?none_floor',
        'DORM1_COB:Surface Inside Face Solar Radiation Heat Gain Rate': 'solarrad?none_roof',
        'DORM1_PARIN_00E:Surface Inside Face Lights Radiation Heat Gain Rate': 'swlights?none_intwalls',
        'DORM1_PARIN_00S:Surface Inside Face Lights Radiation Heat Gain Rate': 'swlights?none_intwalls',
        'DORM1_PORTAIN_0_00E:Surface Inside Face Lights Radiation Heat Gain Rate': 'swlights?none_intwalls',
        'DORM1_PAREX_00I:Surface Inside Face Lights Radiation Heat Gain Rate': 'swlights?south_extwalls',
        'DORM1_PAREX_00D:Surface Inside Face Lights Radiation Heat Gain Rate': 'swlights?east_extwalls',
        'DORM1_PISO:Surface Inside Face Lights Radiation Heat Gain Rate': 'swlights?none_floor',
        'DORM1_COB:Surface Inside Face Lights Radiation Heat Gain Rate': 'swlights?none_roof',
        'DORM1_PARIN_00E:Surface Inside Face Net Surface Thermal Radiation Heat Gain Rate': 'lwsurfaces?none_intwalls',
        'DORM1_PARIN_00S:Surface Inside Face Net Surface Thermal Radiation Heat Gain Rate': 'lwsurfaces?none_intwalls',
        'DORM1_PORTAIN_0_00E:Surface Inside Face Net Surface Thermal Radiation Heat Gain Rate': 'lwsurfaces?none_intwalls',
        'DORM1_PAREX_00I:Surface Inside Face Net Surface Thermal Radiation Heat Gain Rate': 'lwsurfaces?south_extwalls',
        'DORM1_PAREX_00D:Surface Inside Face Net Surface Thermal Radiation Heat Gain Rate': 'lwsurfaces?east_extwalls',
        'DORM1_PISO:Surface Inside Face Net Surface Thermal Radiation Heat Gain Rate': 'lwsurfaces?none_floor',
        'DORM1_COB:Surface Inside Face Net Surface Thermal Radiation Heat Gain Rate': 'lwsurfaces?none_roof',
        'DORM1_PARIN_00E:Surface Inside Face Internal Gains Radiation Heat Gain Rate': 'lwinternal?none_intwalls',
        'DORM1_PARIN_00S:Surface Inside Face Internal Gains Radiation Heat Gain Rate': 'lwinternal?none_intwalls',
        'DORM1_PORTAIN_0_00E:Surface Inside Face Internal Gains Radiation Heat Gain Rate': 'lwinternal?none_intwalls',
        'DORM1_PAREX_00I:Surface Inside Face Internal Gains Radiation Heat Gain Rate': 'lwinternal?south_extwalls',
        'DORM1_PAREX_00D:Surface Inside Face Internal Gains Radiation Heat Gain Rate': 'lwinternal?east_extwalls',
        'DORM1_PISO:Surface Inside Face Internal Gains Radiation Heat Gain Rate': 'lwinternal?none_floor',
        'DORM1_COB:Surface Inside Face Internal Gains Radiation Heat Gain Rate': 'lwinternal?none_roof'
    }
}
dorm2 = {
    "ZONE": "DORM2",
    "convection": {
        "DORM2_PARIN_00I:Surface Inside Face Convection Heat Gain Rate": "convection?none_intwalls",
        "DORM2_PARIN_01E:Surface Inside Face Convection Heat Gain Rate": "convection?none_intwalls",
        "DORM2_PORTAIN_0_01E:Surface Inside Face Convection Heat Gain Rate": "convection?none_intwalls",
        "DORM2_PAREX_00E:Surface Inside Face Convection Heat Gain Rate": "convection?west_extwalls",
        "DORM2_PAREX_00D:Surface Inside Face Convection Heat Gain Rate": "convection?east_extwalls",
        "DORM2_PAREX_00S:Surface Inside Face Convection Heat Gain Rate": "convection?north_extwalls",
        "DORM2_PISO:Surface Inside Face Convection Heat Gain Rate": "convection?none_floor",
        "DORM2_COB:Surface Inside Face Convection Heat Gain Rate": "convection?none_roof",
        "DORM2_JAN_0_00D:Surface Inside Face Convection Heat Gain Rate": "convection?east_windows",
        "DORM2_JAN_0_00D:Surface Window Inside Face Frame and Divider Zone Heat Gain Rate": "convection?east_frame",
        "DORM2:Zone Total Internal Convective Heating Rate": "convection?internal_gains",
        "DORM2:AFN Zone Ventilation Sensible Heat Gain Rate": "convection?vn_window_gain",
        "DORM2:AFN Zone Ventilation Sensible Heat Loss Rate": "convection?vn_window_loss",
        "DORM2:AFN Zone Mixing Sensible Heat Gain Rate": "convection?vn_interzone_gain",
        "DORM2:AFN Zone Mixing Sensible Heat Loss Rate": "convection?vn_interzone_loss",
        "DORM2:Zone Air System Sensible Heating Rate": "convection?heating",
        "DORM2:Zone Air System Sensible Cooling Rate": "convection?cooling"
        },
    "surface": {
        'DORM2_PARIN_00I:Surface Inside Face Convection Heat Gain Rate': 'convection?none_intwalls',
        'DORM2_PARIN_01E:Surface Inside Face Convection Heat Gain Rate': 'convection?none_intwalls',
        'DORM2_PORTAIN_0_01E:Surface Inside Face Convection Heat Gain Rate': 'convection?none_intwalls',
        'DORM2_PAREX_00E:Surface Inside Face Convection Heat Gain Rate': 'convection?west_extwalls',
        'DORM2_PAREX_00D:Surface Inside Face Convection Heat Gain Rate': 'convection?east_extwalls',
        'DORM2_PAREX_00S:Surface Inside Face Convection Heat Gain Rate': 'convection?north_extwalls',
        'DORM2_PISO:Surface Inside Face Convection Heat Gain Rate': 'convection?none_floor',
        'DORM2_COB:Surface Inside Face Convection Heat Gain Rate': 'convection?none_roof',
        'DORM2_PARIN_00I:Surface Inside Face Conduction Heat Transfer Rate': 'conduction?none_intwalls',
        'DORM2_PARIN_01E:Surface Inside Face Conduction Heat Transfer Rate': 'conduction?none_intwalls',
        'DORM2_PORTAIN_0_01E:Surface Inside Face Conduction Heat Transfer Rate': 'conduction?none_intwalls',
        'DORM2_PAREX_00E:Surface Inside Face Conduction Heat Transfer Rate': 'conduction?west_extwalls',
        'DORM2_PAREX_00D:Surface Inside Face Conduction Heat Transfer Rate': 'conduction?east_extwalls',
        'DORM2_PAREX_00S:Surface Inside Face Conduction Heat Transfer Rate': 'conduction?north_extwalls',
        'DORM2_PISO:Surface Inside Face Conduction Heat Transfer Rate': 'conduction?none_floor',
        'DORM2_COB:Surface Inside Face Conduction Heat Transfer Rate': 'conduction?none_roof',
        'DORM2_PARIN_00I:Surface Inside Face Solar Radiation Heat Gain Rate': 'solarrad?none_intwalls',
        'DORM2_PARIN_01E:Surface Inside Face Solar Radiation Heat Gain Rate': 'solarrad?none_intwalls',
        'DORM2_PORTAIN_0_01E:Surface Inside Face Solar Radiation Heat Gain Rate': 'solarrad?none_intwalls',
        'DORM2_PAREX_00E:Surface Inside Face Solar Radiation Heat Gain Rate': 'solarrad?west_extwalls',
        'DORM2_PAREX_00D:Surface Inside Face Solar Radiation Heat Gain Rate': 'solarrad?east_extwalls',
        'DORM2_PAREX_00S:Surface Inside Face Solar Radiation Heat Gain Rate': 'solarrad?north_extwalls',
        'DORM2_PISO:Surface Inside Face Solar Radiation Heat Gain Rate': 'solarrad?none_floor',
        'DORM2_COB:Surface Inside Face Solar Radiation Heat Gain Rate': 'solarrad?none_roof',
        'DORM2_PARIN_00I:Surface Inside Face Lights Radiation Heat Gain Rate': 'swlights?none_intwalls',
        'DORM2_PARIN_01E:Surface Inside Face Lights Radiation Heat Gain Rate': 'swlights?none_intwalls',
        'DORM2_PORTAIN_0_01E:Surface Inside Face Lights Radiation Heat Gain Rate': 'swlights?none_intwalls',
        'DORM2_PAREX_00E:Surface Inside Face Lights Radiation Heat Gain Rate': 'swlights?west_extwalls',
        'DORM2_PAREX_00D:Surface Inside Face Lights Radiation Heat Gain Rate': 'swlights?east_extwalls',
        'DORM2_PAREX_00S:Surface Inside Face Lights Radiation Heat Gain Rate': 'swlights?north_extwalls',
        'DORM2_PISO:Surface Inside Face Lights Radiation Heat Gain Rate': 'swlights?none_floor',
        'DORM2_COB:Surface Inside Face Lights Radiation Heat Gain Rate': 'swlights?none_roof',
        'DORM2_PARIN_00I:Surface Inside Face Net Surface Thermal Radiation Heat Gain Rate': 'lwsurfaces?none_intwalls',
        'DORM2_PARIN_01E:Surface Inside Face Net Surface Thermal Radiation Heat Gain Rate': 'lwsurfaces?none_intwalls',
        'DORM2_PORTAIN_0_01E:Surface Inside Face Net Surface Thermal Radiation Heat Gain Rate': 'lwsurfaces?none_intwalls',
        'DORM2_PAREX_00E:Surface Inside Face Net Surface Thermal Radiation Heat Gain Rate': 'lwsurfaces?west_extwalls',
        'DORM2_PAREX_00D:Surface Inside Face Net Surface Thermal Radiation Heat Gain Rate': 'lwsurfaces?east_extwalls',
        'DORM2_PAREX_00S:Surface Inside Face Net Surface Thermal Radiation Heat Gain Rate': 'lwsurfaces?north_extwalls',
        'DORM2_PISO:Surface Inside Face Net Surface Thermal Radiation Heat Gain Rate': 'lwsurfaces?none_floor',
        'DORM2_COB:Surface Inside Face Net Surface Thermal Radiation Heat Gain Rate': 'lwsurfaces?none_roof',
        'DORM2_PARIN_00I:Surface Inside Face Internal Gains Radiation Heat Gain Rate': 'lwinternal?none_intwalls',
        'DORM2_PARIN_01E:Surface Inside Face Internal Gains Radiation Heat Gain Rate': 'lwinternal?none_intwalls',
        'DORM2_PORTAIN_0_01E:Surface Inside Face Internal Gains Radiation Heat Gain Rate': 'lwinternal?none_intwalls',
        'DORM2_PAREX_00E:Surface Inside Face Internal Gains Radiation Heat Gain Rate': 'lwinternal?west_extwalls',
        'DORM2_PAREX_00D:Surface Inside Face Internal Gains Radiation Heat Gain Rate': 'lwinternal?east_extwalls',
        'DORM2_PAREX_00S:Surface Inside Face Internal Gains Radiation Heat Gain Rate': 'lwinternal?north_extwalls',
        'DORM2_PISO:Surface Inside Face Internal Gains Radiation Heat Gain Rate': 'lwinternal?none_floor',
        'DORM2_COB:Surface Inside Face Internal Gains Radiation Heat Gain Rate': 'lwinternal?none_roof'
    }
}
all = {
    'ZONE': 'ALL ZONES',
    'Environment': 'drybulb?temp_ext'
}

wanted_list = ['Date/Time', all['Environment']]
for item in sala['convection']:
    wanted_list.append(f"{sala['ZONE']}_{sala['convection'][item]}")
for item in sala['surface']:
    wanted_list.append(f"{sala['ZONE']}_{sala['surface'][item]}")
for item in dorm1['convection']:
    wanted_list.append(f"{dorm1['ZONE']}_{dorm1['convection'][item]}")
for item in dorm1['surface']:
    wanted_list.append(f"{dorm1['ZONE']}_{dorm1['surface'][item]}")
for item in dorm2['convection']:
    wanted_list.append(f"{dorm2['ZONE']}_{dorm2['convection'][item]}")
for item in dorm2['surface']:
    wanted_list.append(f"{dorm2['ZONE']}_{dorm2['surface'][item]}")
wanted_list = list(set(wanted_list))

dont_change_list = [all['Environment']]
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

items_list_for_surface = []
for ref in sala['surface']:
    items_list_for_surface.append(sala['surface'][ref].split('?')[1])
for ref in dorm1['surface']:
    items_list_for_surface.append(dorm1['surface'][ref].split('?')[1])
for ref in dorm2['surface']:
    items_list_for_surface.append(dorm2['surface'][ref].split('?')[1])
items_list_for_surface.append(all['Environment'].split('?')[1])
items_list_for_surface = list(set(items_list_for_surface))

# Paths
surface_output_path = r'output/surface/'
convection_output_path = r'output/convection/'
surface_input_path = r'input/surface/'
convection_input_path = r'input/convection/'
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
    