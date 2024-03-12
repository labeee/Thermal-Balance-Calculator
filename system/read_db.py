import sqlite3
import pandas as pd
import warnings
warnings.filterwarnings("ignore")

def read_db():
    conn = sqlite3.connect(r'input/database.sql')

    cursor = conn.cursor()

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

    # zones_final = {
    #             'Zone Total Internal Convective Heating Rate': 'convection?internal_gains',
    #             'AFN Zone Ventilation Sensible Heat Gain Rate': 'convection?vn_window_gain',
    #             'AFN Zone Ventilation Sensible Heat Loss Rate': 'convection?vn_window_loss',
    #             'AFN Zone Mixing Sensible Heat Gain Rate': 'convection?vc_interzone_gain',
    #             'AFN Zone Mixing Sensible Heat Loss Rate': 'convection?vc_interzone_loss',
    #             'Zone Air System Sensible Heating Rate': 'convection?heating',
    #             'Zone Air System Sensible Cooling Rate': 'convection?cooling'
    #             }
    # for key, value in surfaces_dict.items():
    #     for idx in value.index:
    #         if 'Frame' in value.at[idx, 'SurfaceName']:
    #             zones_final[value.at[idx, 'SurfaceName']] = f"{value.at[idx, 'Azimuth']}_Frame"

    #         elif 'GlassDoor' in value.at[idx, 'SurfaceName']:
    #             zones_final[value.at[idx, 'SurfaceName']] = [f"{value.at[idx, 'Azimuth']}_Window", f"{value.at[idx, 'Azimuth']}_Frame"]
            
    #         elif 'Window' in value.at[idx, 'SurfaceName']:
    #             zones_final[value.at[idx, 'SurfaceName']] = [f"{value.at[idx, 'Azimuth']}_Window", f"{value.at[idx, 'Azimuth']}_Frame"]
            
    #         else:
    #             zones_final[value.at[idx, 'SurfaceName']] = f"{value.at[idx, 'Azimuth']}_{value.at[idx, 'ExtBoundCond']}{value.at[idx, 'ClassName']}"