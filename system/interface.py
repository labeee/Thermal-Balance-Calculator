from system.source import *
from system.generators import *
import time


def menu():
    """
    Meio de interação com o usuário. Loop que irá ir e voltar perguntando o que o
    usuário deseja e administrando adequada e automaticamente as funções a serem
    executadas.
    """
    zones = [sala['ZONE'], dorm1['ZONE'], dorm2['ZONE']]
    df_type = 'annual'
    execute = True
    while execute:
        clear_screen()
        print(software_name)
        separators()
        print(f'\n\n\tWhat would you like to do?\n\n\n\tZones: {zones}\n\n\tDataframe type: {df_type}\n\n\n\n\t[1] Generate dataframes for surface (maintenance)\n\t[2] Generate dataframes for convection\n\t[3] Change zones\n\t[4] Change dataframe type\n\t[5] Personalize separators\n\n\n\t[ENTER] End software\n')
        separators()
        opt = input('...')
        if opt == '':
            clear_screen()
            print(end_message)
            execute = False
        elif opt == '1':
            clear_screen()
            generate_df(path=surface_input_path, output=surface_output_path, way="surface", type='_surface_', zone=zones, coverage=df_type)
            clear_screen()
            print(warn)
            separators()
            print('\nFUNCTION NOT YET READY\n')
            separators()
            time.sleep(2)
        elif opt == '2':
            clear_screen()
            generate_df(path=convection_input_path, output=convection_output_path, way="convection", type='_convection_', zone=zones, coverage=df_type)
        elif opt == '3':
            zone_select = True
            while zone_select:
                clear_screen()
                separators()
                print(f'\n\tSelect or remove your desired zones\n\n\tSelected: {zones}\n\n\t[1] {sala["ZONE"]}\n\t[2] {dorm1["ZONE"]}\n\t[3] {dorm2["ZONE"]}\n\n\t[ENTER] Exit\n')
                separators()
                options = input('...')
                if options == '':
                    if zones == []:
                        clear_screen()
                        print(warn)
                        separators()
                        print('\nSELECT AT LEAST ONE ZONE\n')
                        separators()
                        time.sleep(3)
                    else:
                        zone_select = False
                elif options == '1':
                    if sala['ZONE'] in zones:
                        zones.remove(sala['ZONE'])
                    else:
                        zones.append(sala["ZONE"])
                elif options == '2':
                    if dorm1['ZONE'] in zones:
                        zones.remove(dorm1['ZONE'])
                    else:
                        zones.append(dorm1["ZONE"])
                elif options == '3':
                    if dorm2['ZONE'] in zones:
                        zones.remove(dorm2['ZONE'])
                    else:
                        zones.append(dorm2["ZONE"])
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
