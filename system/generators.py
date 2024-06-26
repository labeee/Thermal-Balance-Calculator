from system.source import *


def rename_cols(columns_list: list, df: pd.DataFrame, way: str, dicionario: dict) -> pd.DataFrame:
    """Renomeia todas as colunas e gera as listas de configurações"""
    wanted_list = ['drybulb?temp_ext', 'Date/Time']
    for specific_zone in dicionario:
        for item in columns_list:
                for new_name in dicionario[specific_zone][way]:
                    if new_name in item:
                        oficial = f"{specific_zone}_{dicionario[specific_zone][way][new_name]}"
                        df.rename(columns={item: oficial}, inplace=True)
                        wanted_list.append(oficial)
    searchword, new_name = list(drybulb_rename['EXTERNAL'].keys())[0], drybulb_rename['EXTERNAL']['Environment']
    columns_list = df.columns
    for item in columns_list:
        if searchword in item:
            df.rename(columns={item: new_name}, inplace=True)

    print('- Building utility dicts\n')

    dont_change_list = ['drybulb?temp_ext']
    for item in wanted_list:
        if item.endswith('loss') or item.endswith('gains') or item.endswith('gain') or item.endswith('cooling') or item.endswith('heating'):
            dont_change_list.append(item)
    dont_change_list = list(set(dont_change_list))

    ref_multiply_list = ["heating", "vn_window_gain", "vn_interzone_gain", "frame", "internal"]
    multiply_list = []
    for item in ref_multiply_list:
        for i in wanted_list:
            if item in i:
                multiply_list.append(i)
    multiply_list = list(set(multiply_list))

    return df, wanted_list, dont_change_list, multiply_list


def sum_separated(coluna) -> pd.Series:
    """
    Soma separadamente os positivos e os negativos, retornando um objeto 
    Series contendo em uma coluna os positivos e em outra os negativos de cada linha
    """
    positivos = coluna[coluna >= 0].sum()
    negativos = coluna[coluna < 0].sum()
    # negativos = negativos.sum()
    # negativos = negativos * -1
    return pd.Series([positivos, negativos])


def divide(df: pd.DataFrame, dont_change_list: list) -> pd.DataFrame:
    """
    Divide algumas colunas em gain e loss. Ao fim, adiciona às colunas os nomes de 
    gains_losses e value
    """
    divided = pd.DataFrame()
    col = df.columns
    windows_and_frames = {}
    for column in col:
        if column in dont_change_list:
            pass
        elif "Window" in column or "GlassDoor" in column:
            azimuth_boundsurface = column.split("_")[-1]
            configs_name = column.replace(azimuth_boundsurface, "frame")
            windows_and_frames[f"{configs_name}_gain"] = f"{column}_gain"
            windows_and_frames[f"{configs_name}_loss"] = f"{column}_loss"
    for column in col:
        if column in dont_change_list:
            divided[column] = df[column]
        else:
            divided[f'{column}_gain'] = df[column].apply(lambda item: item if item>0 else 0)
            divided[f'{column}_loss'] = df[column].apply(lambda item: item if item<0 else 0)
    divided.rename(columns=windows_and_frames, inplace=True)
    divided = divided.groupby(level=0, axis=1).sum()
    divided.reset_index(inplace=True)
    divided.drop(columns='index', axis=1, inplace=True)
    divided = divided.sum().reset_index()
    divided.columns = ['gains_losses', 'value']
    return divided


def invert_values(dataframe: pd.DataFrame, way: str, output: str, type_name: str, dataframe_name: str, multiply_list: list, zones_for_name: str) -> pd.DataFrame:
    """Multiplica as colunas específicas por -1."""
    if way == 'convection':
        df_copy = dataframe.copy()
        colunas = list(df_copy.columns)
        colunas.remove('Date/Time')
        for coluna in colunas:
            for item in multiply_list:
                if item not in coluna:
                    df_copy[coluna] = df_copy[coluna] *-1
        print('- Inverted specific columns')
    else:
        df_copy = dataframe.copy()
    return df_copy


def renamer_and_formater(df: pd.DataFrame, way: str, zones_dict: dict) -> pd.DataFrame:
    """
    Recebe o dataframe e uma lista de zonas, então manipula-o renomeando cada lista de 
    colunas e excluindo as colunas desnecessárias 
    """
    columns_list = df.columns
    df, wanted_list, dont_change_list, multiply_list = rename_cols(columns_list=columns_list, df=df, way=way, dicionario=zones_dict)
    columns_list = df.columns
    unwanted_list = []
    for item in columns_list:
        if item not in wanted_list:
            unwanted_list.append(item)
    df.drop(columns=unwanted_list, axis=1, inplace=True)
    return df, dont_change_list, multiply_list


def reorderer(df: pd.DataFrame) -> pd.DataFrame:
    """Reordena as colunas do dataframe para o Date/Time ser o primeiro item"""
    reorder = ['Date/Time']
    for item in df.columns:
        if item != 'Date/Time':
            reorder.append(item)
    df = df[reorder]
    return df


def basic_manipulator(df: pd.DataFrame, dont_change_list: list) -> pd.DataFrame:
    """Faz o procedimento básico para todos os dataframes serem manipulados"""
    df.drop(columns='Date/Time', axis=1, inplace=True)
    df = df.apply(sum_separated)
    df = divide(df, dont_change_list=dont_change_list)
    return df


def zone_breaker(df: pd.DataFrame) -> pd.DataFrame:
    """
    Renomeia cada item da coluna zone para sua respectiva zona, renomeia 
    também o gains_losses para remover a zona nele aplicada
    """
    for j in df.index:
        if drybulb_rename['EXTERNAL']['Environment'] in df.at[j, 'gains_losses']:
            df.at[j, 'zone'] = 'EXTERNAL'
        else:
            zones = df.at[j, 'gains_losses'].split('_')[0]
            lenght = (len(zones)+1)
            new_name = df.at[j, 'gains_losses'][lenght:]
            df.at[j, 'zone'] = zones
            df.at[j, 'gains_losses'] = new_name
    return df


def concatenator() -> pd.DataFrame:
    """
    Concatena todos os itens dentro de organizer e retorna o 
    dataframe resultante
    """
    glob_organizer = glob(organizer_path+'*.csv')
    df = pd.read_csv(glob_organizer[0], sep=',')
    glob_organizer.pop(0)
    for item in glob_organizer:
        each_df = pd.read_csv(item, sep=',')
        df = pd.concat([df, each_df], axis=0, ignore_index=True)
    df.drop(columns='Unnamed: 0', axis=1, inplace=True)
    clean_cache()
    return df


def way_breaker(df: pd.DataFrame) -> pd.DataFrame:
    """
    Irá formatar o arquivo adicionando adequadamente o tipo de
    forma de transmissão de calor
    """
    df.loc[:, 'flux'] = 'Empty'
    for i in df.index:
            splited = df.at[i, 'gains_losses'].split('?')
            df.at[i, 'flux'] = splited[0]
            df.at[i, 'gains_losses'] = splited[1] 
    return df


def heat_direction_breaker(df: pd.DataFrame) -> pd.DataFrame:
    """
    Irá formatar o arquivo adicionando adequadamente o sentido de transferência de calor
    """
    df.loc[:, 'heat_direction'] = 'no direction'
    verification = drybulb_rename['EXTERNAL']['Environment'].split('?')[-1]
    for j in df.index:
        name = df.at[j, 'gains_losses']
        if verification in name:
            continue
        else:
            heat_direction = name.split('_')[-1]
            lenght = (len(heat_direction)+1)
            new_name = name[:-lenght]
            df.at[j, 'heat_direction'] = heat_direction
            df.at[j, 'gains_losses'] = new_name
    return df


def days_finder(date_str: str) -> list:
    """Busca e retorna uma lista contendo o dia, dia anterior e 
    dia seguinte ao evento"""
    date_str_splt = date_str.split(' ')
    if date_str_splt[0] == '':
        date_obj = datetime.strptime(date_str_splt[1], '%m/%d')
    else:
        date_obj = datetime.strptime(date_str_splt[0], '%m/%d')
    date_str = date_obj.strftime('%m/%d')
    day_bf = (date_obj - timedelta(days=1)).strftime('%m/%d')
    day_af = (date_obj + timedelta(days=1)).strftime('%m/%d')
    days_list = [date_str, day_bf, day_af]
    return days_list


def daily_manipulator(df: pd.DataFrame, days_list: list, name: str, way: str, zone: list, dont_change_list: list, dicionario: dict) -> pd.DataFrame:
    """Manipula e gera os dataframes para cada datetime 
    dentro do período do evento"""
    new_daily_df = df.copy()
    # VERSÃO ANTIGA DO MÉTODO
    # for j in track(new_daily_df.index, description=f'[bright_blue]Deleting unwanted DateTimes[/bright_blue]', style=track_bar_color, complete_style=track_complete_color, finished_style=track_complete_color, ):
    #     date_splited = new_daily_df.at[j, 'Date/Time'].split(' ')[1]
    #     if date_splited not in days_list:
    #         new_daily_df.drop(j, axis=0, inplace=True)
    print("\n\t- Separating correct [bright_blue]timestamps[/bright_blue]...")
    mask = new_daily_df['Date/Time'].str.split(' ').str.get(1).isin(days_list)
    new_daily_df = new_daily_df[mask]
    days = new_daily_df['Date/Time'].unique()
    for unique_datetime in track(days, description=f'[bright_cyan]Manipulating DateTimes[/bright_cyan]', style=track_bar_color, complete_style=track_complete_color, finished_style=track_complete_color):
        # print(f'/ {unique_datetime}', end='\r')
        df_daily = new_daily_df[new_daily_df['Date/Time'] == unique_datetime]
        soma = basic_manipulator(df=df_daily, dont_change_list=dont_change_list)
        soma.loc[:, 'case'] = name.split('\\')[1]
        soma.loc[:, 'Date/Time'] = unique_datetime
        soma.loc[:, 'zone'] = 'no zone'
        soma = zone_breaker(df=soma)
        soma = way_breaker(df=soma)
        soma = heat_direction_breaker(df=soma)
        for row in soma.index:
            day = str(soma.at[row, 'Date/Time']).strip()
            soma.at[row, 'day'] = day[3:5]
        soma.loc[:, 'month'] = 'no month'
        for row in soma.index:
            month = str(soma.at[row, 'Date/Time'])
            soma.at[row, 'month'] = month.split('/')[0].strip()
        soma.loc[:, 'hour'] = 'no hour'
        for row in soma.index:
            hour = str(soma.at[row, 'Date/Time'])
            soma.at[row, 'hour'] = hour[8:10]
        unique_datetime = unique_datetime.replace('/', '-').replace('  ', '_').replace(' ', '_').replace(':', '-')
        soma = hei_organizer(df=soma, way=way, zone=zone)
        soma.to_csv(organizer_path+'_datetime'+unique_datetime+'.csv', sep=',')
    df_total = concatenator()
    df_total = df_total[['Date/Time', 'month', 'day', 'hour', 'flux', 'zone', 'gains_losses', 'value', 'HEI', 'case']]
    return df_total


def calculate_module_total_and_hei(df: pd.DataFrame) -> pd.DataFrame:
    """Cálculo do HEI em si
    df: pd.DataFrame"""
    module_total = df.groupby('zone')['absolute'].transform('sum')
    df['HEI'] = df['absolute'] / module_total
    return df


def hei_organizer(df: pd.DataFrame, way: str, zone) -> pd.DataFrame:
    """
    Prepara a planilha para o cálculo do HEI.
    df (pd.DataFrame): O dataframe contendo os dados a serem organizados.
    way (str): O método de organização, pode ser 'convection' ou 'surface'.
    zone: A zona a ser considerada, pode ser 'All' ou uma lista de zonas.
    """
    df['absolute'] = df['value'].abs()
    df['HEI'] = np.nan

    if zone == 'All':
        zones_to_consider = df['zone'].unique()
    else:
        zones_to_consider = zone

    if way == 'convection':
        for local in zones_to_consider:
            df.loc[df['zone'] == local] = calculate_module_total_and_hei(df.loc[df['zone'] == local])

    if way == 'surface':
        for local in zones_to_consider:
            for superficie in df['gains_losses'].unique():
                if WALL in superficie or FLOOR in superficie or ROOF in superficie:
                    mask = (df['zone'] == local) & (df['gains_losses'] == superficie)
                    df.loc[mask] = calculate_module_total_and_hei(df.loc[mask])

    df.drop(['absolute'], axis=1, inplace=True)
    return df


def generate_df(path: str, output: str, way: str, type_name: str, zone, coverage: str):
    """
    Irá gerar os dataframes, separando por zona.
    path: path do input
    output: path do output
    way: convection/surface
    type_name: _convection_/_surface_
    zone: lista de zonas (SALA, DORM1, DORM2) ou string
    coverage: annual/monthly/daily
    """
    # Engloba arquivos dentro de input
    globed = glob(f'{path}*.csv')
    print(f'Found inputs: [bright_magenta]{globed}[/bright_magenta]\n\n')
    print(f'Choosen zones: [bright_blue]{zone}[/bright_blue]\n\n')
    print(f'Choosen type: [bright_green]{coverage}[/bright_green]\n\n')
    print(f'Generating for: [bright_cyan]{type_name}[/bright_cyan]\n\n')
    if globed != []:
        for i in globed:
            separators()
            df = pd.read_csv(i)
            print(f'\n\n- CSV beign used: [bright_blue]{i}[/bright_blue]')
            df = df.dropna()
            print('- [bright_yellow]NaN[/bright_yellow] rows removed')
            dicionario = read_db_and_build_dicts(selected_zones=zone, way=way)
            if zone == 'All':
                zones_for_name = 'All-Zones'
            else:
                zones_for_name = []
                for key in dicionario.keys():
                    zones_for_name.append(key)
                zones_for_name = '-'.join(zones_for_name)
            df, dont_change_list, multiply_list = renamer_and_formater(df=df, way=way, zones_dict=dicionario)
            # São agrupadas e somadas as colunas iguais
            df = df.groupby(level=0, axis=1).sum()
            df.reset_index(inplace=True)
            df.drop(columns='index', axis=1, inplace=True)
            df = reorderer(df=df)
            df = invert_values(dataframe=df, way=way, output=output, type_name=type_name, dataframe_name=i, multiply_list=multiply_list, zones_for_name=zones_for_name)
            # Verifica o tipo de dataframe selecionado e cria-o
            match coverage:
                case 'annual':
                    soma = basic_manipulator(df=df, dont_change_list=dont_change_list)
                    print('- [bright_green]Gains[/bright_green] and [bright_red]losses[/bright_red] separated and calculated')
                    soma.loc[:, 'case'] = i.split('\\')[1]
                    soma.loc[:, 'zone'] = 'no zone'
                    soma = zone_breaker(df=soma)
                    soma = way_breaker(df=soma)
                    soma = heat_direction_breaker(df=soma)
                    print('- [bright_blue]Case[/bright_blue], [bright_blue]type[/bright_blue] and [bright_blue]zone[/bright_blue] added')
                    soma = hei_organizer(df=soma, way=way, zone=zone)
                    print('- [bright_blue]Absolute[/bright_blue] and [bright_blue]HEI[/bright_blue] calculated')
                    soma.to_csv(output+'annual_'+zones_for_name+type_name+i.split('\\')[1], sep=',', index=False)
                    print('- [bright_green]Annual dataframe created\n')
                case 'monthly':
                    df.loc[:, 'month'] = 'no month'
                    for row in df.index:
                        month = str(df.at[row, 'Date/Time'])
                        df.at[row, 'month'] = month.split('/')[0].strip()
                    print('- Months column created')
                    months = df['month'].unique()
                    for unique_month in track(months, description=f'[bright_cyan]Processing each month[/bright_cyan]', style=track_bar_color, complete_style=track_complete_color, finished_style=track_complete_color):
                        df_monthly = df[df['month'] == unique_month]
                        df_monthly.drop(columns='month', axis=1, inplace=True)
                        soma = basic_manipulator(df=df_monthly, dont_change_list=dont_change_list)
                        print(f'- [bright_green]Gains[/bright_green] and [bright_red]losses[/bright_red] separated and calculated for month {unique_month}')
                        soma.loc[:, 'case'] = i.split('\\')[1]
                        soma.loc[:, 'month'] = unique_month
                        soma.loc[:, 'zone'] = 'no zone'
                        soma = zone_breaker(df=soma)
                        soma = way_breaker(df=soma)
                        soma = heat_direction_breaker(df=soma)
                        print(f'- [bright_blue]Case[/bright_blue], [bright_blue]type[/bright_blue] and [bright_blue]zone[/bright_blue] added for month {unique_month}')
                        soma = hei_organizer(df=soma, way=way, zone=zone)
                        soma.to_csv(organizer_path+'_month'+unique_month+'.csv', sep=',')
                    df_total = concatenator()
                    df_total.to_csv(output+'monthly_'+zones_for_name+type_name+i.split('\\')[1], sep=',', index=False)
                    print('- [bright_green]Monthly dataframe created\n')
                case 'daily':
                    ## Max
                    max_temp_idx = df[drybulb_rename['EXTERNAL']['Environment']].idxmax()
                    max_value = df[drybulb_rename['EXTERNAL']['Environment']].max()
                    date_str = df.loc[max_temp_idx, 'Date/Time']
                    days_list = days_finder(date_str=date_str)
                    print('\n')
                    print(f'- Date with [bright_magenta]max value[/bright_magenta]: {days_list[0]} as [{max_value}]')
                    print(f'- Day [bright_yellow]before[/bright_yellow]: {days_list[1]}')
                    print(f'- Day [bright_yellow]after[/bright_yellow]: {days_list[2]}')
                    df_total = daily_manipulator(df=df, days_list=days_list, name=i, way=way, zone=zone, dont_change_list=dont_change_list, dicionario=dicionario)
                    df_total.to_csv(output+'max_daily_'+zones_for_name+type_name+i.split('\\')[1], sep=',', index=False)
                    print('- [bright_green]Daily MAX dataframe created\n')
                    
                    ## Min
                    min_temp_idx = df[drybulb_rename['EXTERNAL']['Environment']].idxmin()
                    min_value = df[drybulb_rename['EXTERNAL']['Environment']].min()
                    date_str = df.loc[min_temp_idx, 'Date/Time']
                    days_list = days_finder(date_str=date_str)
                    print(f'- Date with [bright_magenta]min value[/bright_magenta]: {days_list[0]} as [{min_value}]')
                    print(f'- Day [bright_yellow]before[/bright_yellow]: {days_list[1]}')
                    print(f'- Day [bright_yellow]after[/bright_yellow]: {days_list[2]}')
                    df_total = daily_manipulator(df=df, days_list=days_list, name=i, way=way, zone=zone, dont_change_list=dont_change_list, dicionario=dicionario)
                    df_total.to_csv(output+'min_daily_'+zones_for_name+type_name+i.split('\\')[1], sep=',', index=False)
                    print('- [bright_green]Daily MIN dataframe created\n')

                    ## Max and Min amp locator
                    df_amp = df.copy()
                    df_amp.loc[:, 'date'] = 'no date'
                    for row in df_amp.index:
                        date = str(df_amp.at[row, 'Date/Time']).strip()
                        df_amp.at[row, 'date'] = date[0:5]
                    max_amp = {'date': None, 'value': 0, 'index': 0}
                    min_amp = {'date': None, 'value': 1000, 'index': 0}
                    dates_list = df_amp['date'].unique()
                    for days in dates_list:
                        df_day = df_amp[df_amp['date'] == days]
                        max_daily = df_day[drybulb_rename['EXTERNAL']['Environment']].max()
                        idx_daily = df_day[drybulb_rename['EXTERNAL']['Environment']].idxmax()
                        min_daily = df_day[drybulb_rename['EXTERNAL']['Environment']].min()
                        total = abs(max_daily - min_daily)
                        if total > max_amp['value']:
                            max_amp['date'] = days
                            max_amp['value'] = total
                            max_amp['index'] = idx_daily
                        if total < min_amp['value']:
                            min_amp['date'] = days
                            min_amp['value'] = total
                            min_amp['index'] = idx_daily

                    # Max amp
                    date_str = df.loc[max_amp['index'], 'Date/Time']
                    days_list = days_finder(date_str=date_str)
                    print(f'- Date with [bright_magenta]max amplitude value[/bright_magenta]: {days_list[0]} as [{max_amp["value"]}]')
                    print(f'- Day [bright_yellow]before[/bright_yellow]: {days_list[1]}')
                    print(f'- Day [bright_yellow]after[/bright_yellow]: {days_list[2]}')
                    df_total = daily_manipulator(df=df, days_list=days_list, name=i, way=way, zone=zone, dont_change_list=dont_change_list, dicionario=dicionario)
                    df_total.to_csv(output+'max_amp_daily_'+zones_for_name+type_name+i.split('\\')[1], sep=',', index=False)
                    print('- [bright_green]Daily MAX AMP dataframe created\n')

                    # Min amp
                    date_str = df.loc[min_amp['index'], 'Date/Time']
                    days_list = days_finder(date_str=date_str)
                    print(f'- Date with [bright_magenta]min amplitude value[/bright_magenta]: {days_list[0]} as [{min_amp["value"]}]')
                    print(f'- Day [bright_yellow]before[/bright_yellow]: {days_list[1]}')
                    print(f'- Day [bright_yellow]after[/bright_yellow]: {days_list[2]}')
                    df_total = daily_manipulator(df=df, days_list=days_list, name=i, way=way, zone=zone, dont_change_list=dont_change_list, dicionario=dicionario)
                    df_total.to_csv(output+'min_amp_daily_'+zones_for_name+type_name+i.split('\\')[1], sep=',', index=False)
                    print('- [bright_green]Daily MIN AMP dataframe created\n')
        separators()
