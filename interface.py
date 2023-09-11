from source import *
from generators import *

def menu():
    execute = True
    while execute:
        clear_screen()
        print(software_name)
        separators()
        print(f'\n\tWhat would you like to do?\n\n\t[1] Generate dataframes for surface\n\t[2] Generate dataframes for convection\n\t[3] Generate full dataframe\n\t[4] Personalize separators\n\n\t[ENTER] End software\n')
        separators()
        opt = input('...')
        if opt == '':
            clear_screen()
            print(end_message)
            execute = False
        elif opt == '1':
            clear_screen()
            generate_df(surface_input_path, surface_output_path, surface, '_surface_')
        elif opt == '2':
            clear_screen(convection_input_path, convection_output_path, convection, '_convection_')
            generate_df()
        elif opt == '3':
            clear_screen()
            generate_full_df()
        elif opt == '4':
            clear_screen()
            separators()
            print(f'\n\tInsert your desired separators\n\n\t[ENTER] Exit\n')
            separators()
            new = input('...')
            if new != '':
                open('separators.txt', 'w').write(new)