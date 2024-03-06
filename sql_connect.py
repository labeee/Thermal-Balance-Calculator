import sqlite3
import pandas as pd

conn = sqlite3.connect('database.sql')

cursor = conn.cursor()

cursor.execute("SELECT * FROM sqlite_master WHERE type='table';")
# cursor.execute("SELECT * FROM ")
result = cursor.fetchall()
result = pd.DataFrame(result)

print(result)

cursor.close()
conn.close()