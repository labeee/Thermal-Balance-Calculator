from system.source import *


def rename_cols(columns_list: list, df: pd.DataFrame, way: str, dicionario: dict) -> pd.DataFrame:
    """Renomeia todas as colunas"""
    for item in columns_list:
        for specific_zone in dicionario:
            for new_name in dicionario[specific_zone][way]:
                if new_name in item:
                    df.rename(columns={item: f"{specific_zone}_{new_name}"}, inplace=True)
    searchword, new_name = drybulb_rename['EXTERNAL'].items()
    columns_list = df.columns
    for item in columns_list:
        if searchword[0] in item:
            df.rename(columns={item: new_name[0]}, inplace=True)
    return df

def sum_separated(coluna) -> pd.Series:
    """
    Soma separadamente os positivos e os negativos, retornando um objeto 
    Series contendo em uma coluna os positivos e em outra os negativos de cada linha
    """
    positivos = coluna[coluna >= 0].sum()
    negativos = coluna[coluna < 0] * -1
    negativos = negativos.sum()
    negativos = negativos * -1
    return pd.Series([positivos, negativos])


def divide(df: pd.DataFrame, dont_change_list: list) -> pd.DataFrame:
    """
    Divide algumas colunas em gain e loss. Ao fim, adiciona às colunas os nomes de 
    gains_losses e value, além de excluir os valores iguais a zero
    """
    divided = pd.DataFrame()
    col = df.columns
    for column in col:
        if column in dont_change_list:
            divided[column] = df[column]
        else:
            divided[f'{column}_gain'] = df[column].apply(lambda item: item if item>0 else 0)
            divided[f'{column}_loss'] = df[column].apply(lambda item: item if item<0 else 0)
    divided = divided.sum().reset_index()
    divided.columns = ['gains_losses', 'value']
    # divided = divided[divided['value'] != 0]
    return divided

def invert_values(dataframe: pd.DataFrame, way: str, output: str, zone: list, type_name: str, dataframe_name: str, multiply_list: list) -> pd.DataFrame:
    """Multiplica as colunas específicas por -1."""
    if way == 'convection':
        df_copy = dataframe.copy()
        valid_cols = [col for col in df_copy.columns if col in multiply_list]
        if not valid_cols:
            return df_copy
        df_copy[valid_cols] = df_copy[valid_cols] * -1
        print('- Inverted specified columns')
        df_copy.to_csv(output+'intermediary_'+'-'.join(zone)+type_name+dataframe_name.split('\\')[1], sep=',')
        print('- Intermediary dataframe created')
    else:
        df_copy = dataframe.copy()
    return df_copy

def renamer_and_formater(df: pd.DataFrame, way: str, zones_dict: dict, wanted_list: list) -> pd.DataFrame:
    """
    Recebe o dataframe e uma lista de zonas, então manipula-o renomeando cada lista de 
    colunas e excluindo as colunas desnecessárias 
    """
    columns_list = df.columns
    df = rename_cols(columns_list=columns_list, df=df, way=way, dicionario=zones_dict)
    columns_list = df.columns
    unwanted_list = []
    for item in columns_list:
        if item not in wanted_list:
            unwanted_list.append(item)
    df.drop(columns=unwanted_list, axis=1, inplace=True)
    return df

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
        if df.at[j, 'gains_losses'] in all['Environment']:
            df.at[j, 'zone'] = all['ZONE']
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
            df.at[i, 'flux'] = df.at[i, 'gains_losses'].split('?')[0]
            df.at[i, 'gains_losses'] = df.at[i, 'gains_losses'].split('?')[1] 
    return df

def days_finder(date_str: str) -> list:
    """Busca e retorna uma lista contendo o dia, dia anterior e 
    dia seguinte ao evento"""
    date_str_splt = date_str.split(' ')
    if date_str_splt[0] == '':
        date_obj = datetime.strptime(date_str.split(' ')[1], '%m/%d')
    else:
        date_obj = datetime.strptime(date_str.split(' ')[0], '%m/%d')
    date_str = date_obj.strftime('%m/%d')
    day_bf = (date_obj - timedelta(days=1)).strftime('%m/%d')
    day_af = (date_obj + timedelta(days=1)).strftime('%m/%d')
    days_list = [date_str, day_bf, day_af]
    return days_list

def daily_manipulator(df: pd.DataFrame, days_list: list, name: str, way: str, zone: list, dont_change_list: list) -> pd.DataFrame:
    """Manipula e gera os dataframes para cada datetime 
    dentro do período do evento"""
    new_daily_df = df.copy()
    for j in new_daily_df.index:
        date_splited = new_daily_df.at[j, 'Date/Time'].split(' ')[1]
        if date_splited not in days_list:
            new_daily_df.drop(j, axis=0, inplace=True)
            print(f'- Removing date {date_splited}', end='\r')
    days = new_daily_df['Date/Time'].unique()
    for unique_datetime in days:
        print(f'- Manipulating {unique_datetime}', end='\r')
        df_daily = new_daily_df[new_daily_df['Date/Time'] == unique_datetime]
        soma = basic_manipulator(df=df_daily, dont_change_list=dont_change_list)
        soma.loc[:, 'case'] = name.split('\\')[1]
        soma.loc[:, 'Date/Time'] = unique_datetime
        soma.loc[:, 'zone'] = 'no zone'
        soma = zone_breaker(df=soma)
        soma = way_breaker(df=soma)
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
        soma = hei(df=soma, type=way, zone=zone)
        soma.to_csv(organizer_path+'_datetime'+unique_datetime+'.csv', sep=',')
    print('\n')
    df_total = concatenator()
    df_total = df_total[['Date/Time', 'month', 'day', 'hour', 'flux', 'zone', 'gains_losses', 'value', 'HEI', 'case']]
    return df_total

def hei(df: pd.DataFrame, type: str, zone: list, dicionario: dict) -> pd.DataFrame:
    """Cria uma coluna módulo e HEI e efetua os cálculos HEI"""
    df.loc[:, 'absolute'] = 'no abs'
    df.loc[:, 'HEI'] = 'no HEI'
    for j in df.index:
        df.at[j, 'absolute'] = abs(df.at[j, 'value'])
    if type == 'convection':
        for local in zone:
            module_total = 0
            for j in df.index:
                if df.at[j, 'zone'] == local:
                    module_total += df.at[j, 'absolute']
            for j in df.index:
                if df.at[j, 'zone'] == local:
                    df.at[j, 'HEI'] = df.at[j, 'absolute'] / module_total
    elif type == 'surface':
        surf_list = []
        for i in zone:    
            surf_list.append(dicionario[i]['surface'].values())
        for local in zone:
            for surf in surf_list:
                module_total = 0
                for j in df.index:
                    if (surf in df.at[j, 'gains_losses']) and (local == df.at[j, 'zone']):
                        module_total += int(df.at[j, 'absolute'])
                for j in df.index:
                    if (surf in df.at[j, 'gains_losses']) and (local == df.at[j, 'zone']):
                        df.at[j, 'HEI'] = df.at[j, 'absolute'] / module_total
    return df

def proccess_windows_complex(df: pd.DataFrame) -> pd.DataFrame:
    lista_de_colunas = []
    for colunas in df.columns:
        if colunas in frames_and_windows:
            lista_de_colunas.append(frames_and_windows[colunas])
        else:
            lista_de_colunas.append(colunas)
    df.columns = lista_de_colunas
    df = df.groupby(level=0, axis=1).sum()
    return df

def generate_df(path: str, output: str, way: str, type_name: str, zone, coverage: str, zones_dict: dict):
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
    print(f'Found inputs: {globed}\n\n')
    print(f'Choosen zones: {zone}\n\n')
    print(f'Choosen type: {coverage}\n\n')
    if globed != []:
        for i in globed:
            separators()
            df = pd.read_csv(i)
            print(f'\n\n- CSV read {i}')
            df = df.dropna()
            print('- NaN rows removed')
            dicionario, wanted_list, dont_change_list, multiply_list = read_db_and_build_dicts(selected_zones=zone)
            df = renamer_and_formater(df=df, way=way, zones_dict=dicionario, wanted_list=wanted_list)
            df = df.groupby(level=0, axis=1).sum()
            df.reset_index(inplace=True)
            df.drop(columns='index', axis=1, inplace=True)
            df = reorderer(df=df)
            df.to_csv(output+'initial_'+'-'.join(zone)+type_name+i.split('\\')[1], sep=',')
            print('- Initial dataframe created')
            df = invert_values(dataframe=df, way=way, output=output, zone=zone, type_name=type_name, dataframe_name=i, multiply_list=multiply_list)
            df = proccess_windows_complex(df)
            # Verifica o tipo de dataframe selecionado e cria-o
            match coverage:
                case 'annual':
                    soma = basic_manipulator(df=df, dont_change_list=dont_change_list)
                    print('- Gains and losses separated and calculated')
                    soma.loc[:, 'case'] = i.split('\\')[1]
                    soma.loc[:, 'zone'] = 'no zone'
                    soma = zone_breaker(df=soma)
                    soma = way_breaker(df=soma)
                    print('- Case, type and zone added')
                    # soma = proccess_windows_complex(soma)
                    soma = hei(df=soma, type=way, zone=zone)
                    print('- Absolute and HEI calculated')
                    soma.to_csv(output+'final_annual_'+'-'.join(zone)+type_name+i.split('\\')[1], sep=',')
                    print('- Final annual dataframe created\n')
                case 'monthly':
                    df.loc[:, 'month'] = 'no month'
                    for row in df.index:
                        month = str(df.at[row, 'Date/Time'])
                        df.at[row, 'month'] = month.split('/')[0].strip()
                    print('- Months column created')
                    months = df['month'].unique()
                    for unique_month in months:
                        df_monthly = df[df['month'] == unique_month]
                        df_monthly.drop(columns='month', axis=1, inplace=True)
                        soma = basic_manipulator(df=df_monthly, dont_change_list=dont_change_list)
                        print(f'- Gains and losses separated and calculated for month {unique_month}')
                        soma.loc[:, 'case'] = i.split('\\')[1]
                        soma.loc[:, 'month'] = unique_month
                        soma.loc[:, 'zone'] = 'no zone'
                        soma = zone_breaker(df=soma)
                        soma = way_breaker(df=soma)
                        print(f'- Case, type and zone added for month {unique_month}')
                        # soma = proccess_windows_complex(soma)
                        soma = hei(df=soma, type=way, zone=zone)
                        soma.to_csv(organizer_path+'_month'+unique_month+'.csv', sep=',')
                    df_total = concatenator()
                    df_total.to_csv(output+'final_monthly_'+'-'.join(zone)+type_name+i.split('\\')[1], sep=',')
                    print('- Final monthly dataframe created\n')
                case 'daily':
                    ## Max
                    max_temp_idx = df[all['Environment']].idxmax()
                    max_value = df[all['Environment']].max()
                    date_str = df.loc[max_temp_idx, 'Date/Time']
                    days_list = days_finder(date_str=date_str)
                    print('\n')
                    print(f'- Date with max value: {days_list[0]} as [{max_value}]')
                    print(f'- Day before: {days_list[1]}')
                    print(f'- Day after: {days_list[2]}')
                    df_total = daily_manipulator(df=df, days_list=days_list, name=i, way=way, zone=zone, dont_change_list=dont_change_list)
                    df_total.to_csv(output+'final_max_daily_'+'-'.join(zone)+type_name+i.split('\\')[1], sep=',')
                    
                    ## Min
                    min_temp_idx = df[all['Environment']].idxmin()
                    min_value = df[all['Environment']].min()
                    date_str = df.loc[min_temp_idx, 'Date/Time']
                    days_list = days_finder(date_str=date_str)
                    print(f'- Date with min value: {days_list[0]} as [{min_value}]')
                    print(f'- Day before: {days_list[1]}')
                    print(f'- Day after: {days_list[2]}')
                    df_total = daily_manipulator(df=df, days_list=days_list, name=i, way=way, zone=zone, dont_change_list=dont_change_list)
                    df_total.to_csv(output+'final_min_daily_'+'-'.join(zone)+type_name+i.split('\\')[1], sep=',')

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
                        max_daily = df_day[all['Environment']].max()
                        idx_daily = df_day[all['Environment']].idxmax()
                        min_daily = df_day[all['Environment']].min()
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
                    print(f'- Date with max amplitude value: {days_list[0]} as [{max_amp["value"]}]')
                    print(f'- Day before: {days_list[1]}')
                    print(f'- Day after: {days_list[2]}')
                    df_total = daily_manipulator(df=df, days_list=days_list, name=i, way=way, zone=zone, dont_change_list=dont_change_list)
                    df_total.to_csv(output+'final_max_amp_daily_'+'-'.join(zone)+type_name+i.split('\\')[1], sep=',')

                    # Min amp
                    date_str = df.loc[min_amp['index'], 'Date/Time']
                    days_list = days_finder(date_str=date_str)
                    print(f'- Date with min amplitude value: {days_list[0]} as [{min_amp["value"]}]')
                    print(f'- Day before: {days_list[1]}')
                    print(f'- Day after: {days_list[2]}')
                    df_total = daily_manipulator(df=df, days_list=days_list, name=i, way=way, zone=zone, dont_change_list=dont_change_list)
                    df_total.to_csv(output+'final_min_amp_daily_'+'-'.join(zone)+type_name+i.split('\\')[1], sep=',')
        separators()
