import sqlite3
import pandas as pd

conn = sqlite3.connect(r'input/database.sql')

cursor = conn.cursor()

cursor.execute("SELECT ZoneIndex, ZoneName FROM Zones;")
result = cursor.fetchall()
zones_dict = {}
for i in result:
    zones_dict[i[1]] = i[0]
print(zones_dict)
print('-'*50)

surfaces_dict = {}
for key, value in zones_dict.items():
    cursor.execute(f"SELECT ZoneIndex, SurfaceName, ClassName, Azimuth, ExtBoundCond FROM Surfaces WHERE ZoneIndex={value};")
    result = cursor.fetchall()
    surfaces_dict[key] = result
for key in zones_dict.keys():
    df = pd.DataFrame(surfaces_dict[key], columns=['ZoneIndex', 'SurfaceName', 'ClassName', 'Azimuth', 'ExtBoundCond'])
    print(df)
    print('-'*50)

cursor.close()
conn.close() 
