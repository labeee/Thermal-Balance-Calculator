import sqlite3
import pandas as pd

conn = sqlite3.connect(r'input/database.sql')

cursor = conn.cursor()

cursor.execute("SELECT ZoneIndex, ZoneName FROM Zones;")
result = cursor.fetchall()
result = pd.DataFrame(result, columns=['ZoneIndex', 'ZoneName'])
print(result)

cursor.execute("SELECT ZoneIndex, SurfaceName, ClassName, Azimuth, ExtBoundCond FROM Surfaces;")
result = cursor.fetchall()
result = pd.DataFrame(result, columns=['ZoneIndex', 'SurfaceName', 'ClassName', 'Azimuth', 'ExtBoundCond'])
print(result)

cursor.close()
conn.close()