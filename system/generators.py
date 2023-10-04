from system.source import *


def rename_sala(columns_list: list, df: pd.DataFrame, way: str) -> pd.DataFrame:
    """Renomeia todos os itens em SALA"""
    for item in columns_list:
        for new_name in sala[way]:
            if new_name in item:
                df.rename(columns={item: f"{sala['ZONE']}_{sala[way][new_name]}"}, inplace=True)
    return df


def rename_dorm1(columns_list: list, df: pd.DataFrame, way: str) -> pd.DataFrame:
    """Renomeia todos os itens em DORM1"""
    for item in columns_list:
        for new_name in dorm1[way]:
            if new_name in item:
                df.rename(columns={item: f"{dorm1['ZONE']}_{dorm1[way][new_name]}"}, inplace=True)
    return df


def rename_dorm2(columns_list: list, df: pd.DataFrame, way: str) -> pd.DataFrame:
    """Renomeia todos os itens em DORM2"""
    for item in columns_list:
        for new_name in dorm2[way]:
            if new_name in item:
                df.rename(columns={item: f"{dorm2['ZONE']}_{dorm2[way][new_name]}"}, inplace=True)
    return df

def rename_special(columns_list: list, df: pd.DataFrame) -> pd.DataFrame:
    """Renomeia todos os itens em ALL (itens especiais fora de categorias de zonas específicas)"""
    for item in columns_list:
        for new_name in all:
            if new_name in item:
                df.rename(columns={item: all[new_name]}, inplace=True)
    return df

def sum_separated(coluna) -> pd.Series:
    """
    Soma separadamente os positivos e os negativos, retornando um objeto 
    Series contendo em uma coluna os positivos e em outra os negativos de cada linha
    """
    positivos = coluna[coluna > 0].sum()
    negativos = coluna[coluna < 0].sum()
    return pd.Series([positivos, negativos])


def divide(df: pd.DataFrame) -> pd.DataFrame:
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
    divided = divided[divided['value'] != 0]
    return divided

def invert_values(dataframe: pd.DataFrame) -> pd.DataFrame:
    """Multiplica as colunas específicas por -1."""
    df_copy = dataframe.copy()
    valid_cols = [col for col in df_copy.columns if col in multiply_list]
    if not valid_cols:
        return df_copy
    df_copy[valid_cols] = df_copy[valid_cols].multiply(-1)
    return df_copy

def renamer_and_formater(df: pd.DataFrame, zone: list, way: str) -> pd.DataFrame:
    """
    Recebe o dataframe e uma lista de zonas, então manipula-o renomeando cada lista de 
    colunas e excluindo as colunas desnecessárias 
    """
    columns_list = df.columns
    if sala['ZONE'] in zone:
        df = rename_sala(columns_list=columns_list, df=df, way=way)
    if dorm1['ZONE'] in zone:
        df = rename_dorm1(columns_list=columns_list, df=df, way=way)
    if dorm2['ZONE'] in zone:
        df = rename_dorm2(columns_list=columns_list, df=df, way=way)
    df = rename_special(columns_list=columns_list, df=df)
    columns_list = df.columns
    unwanted_list = []
    for item in columns_list:
        if item not in wanted_list:
            unwanted_list.append(item)
    df.drop(columns=unwanted_list, axis=1, inplace=True)
    return df

def adjust_values(df: pd.DataFrame) -> pd.DataFrame:
    try:
        for j in df.index:
                df.at[j, 'value'] = int(str(df.at[j, 'value']).split('.')[1])
    except:
        pass
    return df

def reorderer(df: pd.DataFrame) -> pd.DataFrame:
    """Reordena as colunas do dataframe para o Date/Time ser o primeiro item"""
    reorder = ['Date/Time']
    for item in df.columns:
        if item != 'Date/Time':
            reorder.append(item)
    df = df[reorder]
    return df

def basic_manipulator(df: pd.DataFrame) -> pd.DataFrame:
    """Faz o procedimento básico para todos os dataframes serem manipulados"""
    df.drop(columns='Date/Time', axis=1, inplace=True)
    df = df.apply(sum_separated)
    df = divide(df)
    return df

def zone_breaker(df: pd.DataFrame) -> pd.DataFrame:
    """
    Renomeia cada item da coluna zone para sua respectiva zona, renomeia 
    também o gains_losses para remover a zona nele aplicada
    """
    for j in df.index:
        if df.at[j, 'gains_losses'] == 'temp_ext':
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

def way_breaker(df: pd.DataFrame, way: str) -> pd.DataFrame:
    """
    Irá formatar o arquivo adicionando adequadamente o tipo de
    forma de transmissão de calor, caso seja do tipo surface
    """
    if way == 'surface':
        pass
    return df

def days_finder(date_str: str) -> list:
    """Busca e retorna uma lista contendo o dia, dia anterior e 
    dia seguinte ao evento"""
    date_obj = datetime.strptime(date_str.split(' ')[1], '%m/%d')
    date_str = date_obj.strftime('%m/%d')
    day_bf = (date_obj - timedelta(days=1)).strftime('%m/%d')
    day_af = (date_obj + timedelta(days=1)).strftime('%m/%d')
    days_list = [date_str, day_bf, day_af]
    return days_list

def daily_manipulator(df: pd.DataFrame, days_list: list, way: str, name: str) -> pd.DataFrame:
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
        soma = basic_manipulator(df=df_daily)
        soma.loc[:, 'case'] = name.split('\\')[1]
        soma.loc[:, 'type'] = way
        soma.loc[:, 'Date/Time'] = unique_datetime
        soma.loc[:, 'zone'] = 'no zone'
        soma = way_breaker(df=soma, way=way)
        soma = zone_breaker(df=soma)
        for row in soma.index:
            day = str(soma.at[row, 'Date/Time'])
            soma.at[row, 'day'] = day[4:6]
        soma.loc[:, 'month'] = 'no month'
        for row in soma.index:
            month = str(soma.at[row, 'Date/Time'])
            soma.at[row, 'month'] = month[1:3]
        soma.loc[:, 'hour'] = 'no hour'
        for row in soma.index:
            hour = str(soma.at[row, 'Date/Time'])
            soma.at[row, 'hour'] = hour[8:10]
        unique_datetime = unique_datetime.replace('/', '-').replace('  ', '_').replace(' ', '_').replace(':', '-')
        soma = adjust_values(df=soma)
        soma = hei(df=soma)
        soma.to_csv(organizer_path+'_datetime'+unique_datetime+'.csv', sep=',')
    print('\n')
    df_total = concatenator()
    df_total = df_total[['Date/Time', 'month', 'day', 'hour', 'type', 'zone', 'gains_losses', 'value', 'absolute', 'SUM', 'HEI', 'case']]
    return df_total

def hei(df: pd.DataFrame) -> pd.DataFrame:
    """Cria uma coluna módulo e HEI e efetua os cálculos HEI"""
    df.loc[:, 'absolute'] = 'no abs'
    df.loc[:, 'HEI'] = 'no HEI'
    for j in df.index:
        df.at[j, 'absolute'] = abs(df.at[j, 'value'])
    module_total = df['absolute'].sum()
    for j in df.index:
        df.at[j, 'HEI'] = df.at[j, 'absolute'] / module_total
    return df

def generate_df(path: str, output: str, way: str, type: str, zone: list, coverage: str):
    """
    Irá gerar os dataframes, separando por zona.
    path: path do input
    output: path do output
    way: convection/surface
    type: _convection_/_surface_
    zone: lista de zonas (SALA, DORM1, DORM2)
    coverage: annual/monthly/daily
    """
    clean_cache()
    # Engloba arquivos dentro de input
    globed = glob(f'{path}*.csv')
    print(f'Found inputs: {globed}\n\n')
    print(f'Choosen zones: {zone}\n\n')
    print(f'Choosen type: {coverage}\n\n')
    # Loop que exclui linhas com NaN e soma todos os valores
    if globed != []:
        for i in globed:
            separators()
            df = pd.read_csv(i)
            print(f'\n\n- CSV read {i}')
            df = df.dropna()
            print('- NaN rows removed')
            df = renamer_and_formater(df=df, zone=zone, way=way)
            df = df.groupby(df.columns, axis=1).sum()
            df.reset_index(inplace=True)
            df.drop(columns='index', axis=1, inplace=True)
            df = reorderer(df=df)
            df.to_csv(output+'initial_'+'-'.join(zone)+type+i.split('\\')[1], sep=',')
            print('- Initial dataframe created')
            df = invert_values(df)
            print('- Inverted specified columns')
            df.to_csv(output+'intermediary_'+'-'.join(zone)+type+i.split('\\')[1], sep=',')
            print('- Intermediary dataframe created')
            # Verifica o tipo de dataframe selecionado e cria-o
            match coverage:
                case 'annual':
                    soma = basic_manipulator(df=df)
                    print('- Gains and losses separated and calculated')
                    soma.loc[:, 'case'] = i.split('\\')[1]
                    soma.loc[:, 'type'] = way
                    soma.loc[:, 'zone'] = 'no zone'
                    soma = way_breaker(df=soma, way=way)
                    soma = zone_breaker(df=soma)
                    print('- Case, type and zone added')
                    soma = adjust_values(df=soma)
                    soma = hei(df=soma)
                    print('- Absolute and HEI calculated')
                    soma.to_csv(output+'final_annual_'+'-'.join(zone)+type+i.split('\\')[1], sep=',')
                    print('- Final annual dataframe created\n')
                case 'monthly':
                    df.loc[:, 'month'] = 'no month'
                    for row in df.index:
                        month = str(df.at[row, 'Date/Time'])
                        df.at[row, 'month'] = month[1:3]
                    print('- Months column created')
                    months = df['month'].unique()
                    for unique_month in months:
                        df_monthly = df[df['month'] == unique_month]
                        df_monthly.drop(columns='month', axis=1, inplace=True)
                        soma = basic_manipulator(df=df_monthly)
                        print(f'- Gains and losses separated and calculated for month {unique_month}')
                        soma.loc[:, 'case'] = i.split('\\')[1]
                        soma.loc[:, 'type'] = way
                        soma.loc[:, 'month'] = unique_month
                        soma.loc[:, 'zone'] = 'no zone'
                        soma = way_breaker(df=soma, way=way)
                        soma = zone_breaker(df=soma)
                        print(f'- Case, type and zone added for month {unique_month}')
                        soma = adjust_values(df=soma)
                        soma = hei(df=soma)
                        soma.to_csv(organizer_path+'_month'+unique_month+'.csv', sep=',')
                    df_total = concatenator()
                    df_total.to_csv(output+'final_monthly_'+'-'.join(zone)+type+i.split('\\')[1], sep=',')
                    print('- Final monthly dataframe created\n')
                case 'daily':
                    ## Max
                    max_temp_idx = df['temp_ext'].idxmax()
                    max_value = df["temp_ext"].max()
                    date_str = df.loc[max_temp_idx, 'Date/Time']
                    days_list = days_finder(date_str=date_str)
                    print('\n')
                    print(f'- Date with max value: {days_list[0]} as [{max_value}]')
                    print(f'- Day before: {days_list[1]}')
                    print(f'- Day after: {days_list[2]}')
                    df_total = daily_manipulator(df=df, days_list=days_list, way=way, name=i)
                    df_total.to_csv(output+'final_max_daily_'+'-'.join(zone)+type+i.split('\\')[1], sep=',')
                    
                    ## Min
                    min_temp_idx = df['temp_ext'].idxmin()
                    min_value = df['temp_ext'].min()
                    date_str = df.loc[min_temp_idx, 'Date/Time']
                    days_list = days_finder(date_str=date_str)
                    print(f'- Date with min value: {days_list[0]} as [{min_value}]')
                    print(f'- Day before: {days_list[1]}')
                    print(f'- Day after: {days_list[2]}')
                    df_total = daily_manipulator(df=df, days_list=days_list, way=way, name=i)
                    df_total.to_csv(output+'final_min_daily_'+'-'.join(zone)+type+i.split('\\')[1], sep=',')

                    ## Max and Min amp locator
                    df_amp = df.copy()
                    df_amp.loc[:, 'date'] = 'no date'
                    for row in df_amp.index:
                        date = str(df_amp.at[row, 'Date/Time'])
                        df_amp.at[row, 'date'] = date[1:6]
                    max_amp = {'date': None, 'value': 0, 'index': 0}
                    min_amp = {'date': None, 'value': 1000, 'index': 0}
                    dates_list = df_amp['date'].unique()
                    for days in dates_list:
                        df_day = df_amp[df_amp['date'] == days]
                        max_daily = df_day['temp_ext'].max()
                        idx_daily = df_day['temp_ext'].idxmax()
                        min_daily = df_day['temp_ext'].min()
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
                    df_total = daily_manipulator(df=df, days_list=days_list, way=way, name=i)
                    df_total.to_csv(output+'final_max_amp_daily_'+'-'.join(zone)+type+i.split('\\')[1], sep=',')

                    # Min amp
                    date_str = df.loc[min_amp['index'], 'Date/Time']
                    days_list = days_finder(date_str=date_str)
                    print(f'- Date with min amplitude value: {days_list[0]} as [{min_amp["value"]}]')
                    print(f'- Day before: {days_list[1]}')
                    print(f'- Day after: {days_list[2]}')
                    df_total = daily_manipulator(df=df, days_list=days_list, way=way, name=i)
                    df_total.to_csv(output+'final_min_amp_daily_'+'-'.join(zone)+type+i.split('\\')[1], sep=',')
        separators()
