import sqlite3
import pandas as pd
import warnings
warnings.filterwarnings("ignore")

conn = sqlite3.connect(r'input/database.sql')

cursor = conn.cursor()

cursor.execute("SELECT ZoneIndex, ZoneName FROM Zones;")
result = cursor.fetchall()
zones_dict = {}
for i in result:
    zones_dict[i[1]] = i[0]
print(zones_dict)
print('-'*80)

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

for key, value in surfaces_dict.items():
    print(key)
    print(value)
    print('-'*80)

cursor.close()
conn.close() 
