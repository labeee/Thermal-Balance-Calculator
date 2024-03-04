import sqlite3

# Connect to the database
conn = sqlite3.connect('database.sql')

# Create a cursor object
cursor = conn.cursor()

# Get the table names from the database
cursor.execute("SELECT name FROM sqlite_master WHERE type='table'")
tables = cursor.fetchall()

# Iterate over the table names
for table in tables:
    table_name = table[0]

    print(f'TABLE NAME: {table_name}')

# Close the cursor and connection
cursor.close()
conn.close()