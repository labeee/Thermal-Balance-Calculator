from system.source import *
from system.generators import *
import time


def menu():
    """
    Meio de interação com o usuário. Loop que irá ir e voltar perguntando o que o
    usuário deseja e administrando adequada e automaticamente as funções a serem
    executadas.
    """
    clean_cache()
    zones = 'All'
    df_type = 'annual'
    execute = True
    while execute:
        clear_screen()
        print(software_name)
        separators()
        print(f'\n\n\tWhat would you like to do?\n\n\n\tZones: {zones}\n\n\tDataframe type: {df_type}\n\n\n\n\t[1] Generate dataframes for surface\n\t[2] Generate dataframes for convection\n\t[3] Change zones\n\t[4] Change dataframe type\n\t[5] Personalize separators\n\n\n\t[ENTER] End software\n')
        separators()
        opt = input('...')
        if opt == '':
            clear_screen()
            print(end_message)
            execute = False
        elif opt == '1':
            clear_screen()
            generate_df(path=surface_input_path, output=surface_output_path, way="surface", type_name='_surface_', zone=zones, coverage=df_type)
        elif opt == '2':
            clear_screen()
            generate_df(path=convection_input_path, output=convection_output_path, way="convection", type_name='_convection_', zone=zones, coverage=df_type)
        elif opt == '3':
            zone_select = True
            while zone_select:
                clear_screen()
                separators()
                print(f'\nCurrent zones: {zones}\n\n\tChoose and option:\n\n[1] Add items to zones list\n[2] Reset zones list to all zones\n\n\t[ENTER] Exit\n')
                separators()
                options = input('...')
                if options == '':
                    zone_select = False
                elif options == '1':
                    escolhendo = True
                    if zones == 'All':
                        zones = []
                    separators()
                    print(f'\nCurrent zones: {zones}\n\nSimply type the name of the zone you wish to add to\nthe list and press ENTER to save it.\n\nWhen finished, press ENTER without any typing anything and\nyour choises will be saved.\n')
                    separators()
                    while escolhendo:
                        nova_zona = str(input('/ '))
                        if nova_zona != '':
                            zones.append(nova_zona)
                        else:
                            escolhendo = False
                    clear_screen()
                elif options == '2':
                    zones = 'All'
        elif opt == '4':
            clear_screen()
            separators()
            print(f'\n\tSelect or remove your desired zones\n\n\tSelected: {df_type}\n\n\t[1] annual\n\t[2] monthly\n\t[3] daily\n\n\t[ENTER] Exit\n')
            separators()
            options = input('...')
            if options == '':
                pass
            elif options == '1':
                df_type = 'annual'
            elif options == '2':
                df_type = 'monthly'
            elif options == '3':
                df_type = 'daily'
        elif opt == '5':
            clear_screen()
            separators()
            print(f'\n\tInsert your desired separators\n\n\t[ENTER] Exit\n')
            separators()
            new = input('...')
            if new != '':
                open('system/separators.txt', 'w').write(new*(round(100/len(new))))
