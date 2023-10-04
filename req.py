import os
import sys

os.system('pip install pandas')
python_version = sys.version
print(python_version)
if int(''.join(python_version.split('.')[:2])) < 300:
    print('\nVersão do python inferior a 3.00, atualizando...\n')
    os.system('python -m pip install --upgrade pip')
    os.system('pip install --upgrade python')
else:
    print('\nVersão do python ok\n')
