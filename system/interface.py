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
        print(f'\n\n\tZones: [bright_blue]{zones}[/bright_blue]\n\n\tDataframe type: [bright_green]{df_type}[/bright_green]\n\n\t[bright_yellow underline]What would you like to do?[/bright_yellow underline]\n\n\n\t[1] Generate dataframes for surface\n\t[2] Generate dataframes for convection\n\n\t[3] Change zones\n\t[4] Change dataframe type\n\t[5] Customize screen separators\n\n\n\t[ENTER] [bright_red]End software[/bright_red]\n')
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
                if zones == []:
                    zones = 'All'
                separators()
                print(f'\n\tCurrent zones: [bright_blue]{zones}[/bright_blue]\n\t[bright_yellow]Choose and option:[/bright_yellow]\n\n\t[1] [bright_green]Add items to zones list[/bright_green]\n\t[2] [bright_magenta]Reset zones list to all zones[/bright_magenta]\n\n\t[ENTER] [bright_red]Exit[/bright_red]\n')
                separators()
                options = input('...')
                if options == '':
                    zone_select = False
                elif options == '1':
                    clear_screen()
                    escolhendo = True
                    if zones == 'All':
                        zones = []
                    separators()
                    print(f'\n\tCurrent zones: [bright_blue]{zones}[/bright_blue]\n\n\tSimply [bright_yellow underline]type the name of the zone[/bright_yellow underline] you wish to add to\n\tthe list and [bright_yellow underline]press ENTER to save it[/bright_yellow underline].\n\n\tWhen finished, [bright_yellow underline]press ENTER without any typing anything[/bright_yellow underline] and\n\tyour choises will be saved.\n')
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
            print(f'\n\t[bright_yellow]Choose your desired type of calculation[/bright_yellow]\n\n\tSelected: [bright_green]{df_type}[/bright_green]\n\n\t[1] annual\n\t[2] monthly\n\t[3] daily\n\n\t[ENTER] [bright_red]Exit[/bright_red]\n')
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
            print(f'\n\t[bright_yellow]Insert your desired separators and press [bright_green underline]ENTER[/bright_green underline] to apply and save it[/bright_yellow]\n\n\t[ENTER] [bright_red]Exit[/bright_red]\n')
            separators()
            new = input('/ ')
            if new != '':
                open('system/separators.txt', 'w').write(new*(round(100/len(new))))
