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
    execute = True
    while execute:
        clear_screen()
        print(software_name)
        separators()
        print(f'\n\n\tWhat would you like to do?\n\n\n\t[1] Generate dataframes for surface (maintenance)\n\n\t[2] Generate dataframes for convection\n\n\t[3] Choose zones for dataframe generation\n\n\t[4] Personalize separators\n\n\n\t[ENTER] End software\n')
        separators()
        opt = input('...')
        if opt == '':
            clear_screen()
            print(end_message)
            execute = False
        elif opt == '1':
            pass
            # clear_screen()
            # generate_df(surface_input_path, surface_output_path, surface, '_surface_')
        elif opt == '2':
            clear_screen()
            generate_df(path=convection_input_path, output=convection_output_path, way=convection, type='_convection_', zone=zones)
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
            print(f'\n\tInsert your desired separators\n\n\t[ENTER] Exit\n')
            separators()
            new = input('...')
            if new != '':
                open('system/separators.txt', 'w').write(new*(round(100/len(new))))
