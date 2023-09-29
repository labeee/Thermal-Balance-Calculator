from system.source import *


def rename_sala(columns_list: list, df: pd.DataFrame):
    for item in columns_list:
        for new_name in sala:
            if new_name in item:
                df.rename(columns={item: f"{sala['ZONE']}_{sala[new_name]}"}, inplace=True)
    return df


def rename_dorm1(columns_list: list, df: pd.DataFrame):
    for item in columns_list:
        for new_name in dorm1:
            if new_name in item:
                df.rename(columns={item: f"{dorm1['ZONE']}_{dorm1[new_name]}"}, inplace=True)
    return df


def rename_dorm2(columns_list: list, df: pd.DataFrame):
    for item in columns_list:
        for new_name in dorm2:
            if new_name in item:
                df.rename(columns={item: f"{dorm2['ZONE']}_{dorm2[new_name]}"}, inplace=True)
    return df

def rename_special(columns_list: list, df: pd.DataFrame):
    for item in columns_list:
        for new_name in all:
            if new_name in item:
                df.rename(columns={item: all[new_name]}, inplace=True)
    return df

def sum_separated(coluna):
    """
    Soma separadamente os positivos e os negativos, retornando um objeto 
    Series contendo em uma coluna os positivos e em outra os negativos de cada linha
    """
    positivos = coluna[coluna > 0].sum()
    negativos = coluna[coluna < 0].sum()
    return pd.Series([positivos, negativos])


def divide(df: pd.DataFrame):
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

def invert_values(dataframe: pd.DataFrame):
    """
    Multiplica as colunas específicas por -1.
    """
    df_copy = dataframe.copy()
    valid_cols = [col for col in df_copy.columns if col in multiply_list]
    if not valid_cols:
        return df_copy
    df_copy[valid_cols] = df_copy[valid_cols].multiply(-1)
    return df_copy

def generate_df(path: str, output: str, way: str, type: str, zone: list, coverage: str):
    """
    Irá gerar os dataframes, separando por zona.
    path: path do input
    output: path do output
    way: convection/surface
    type: _convection_/_conduction_
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
            columns_list = df.columns
            if sala['ZONE'] in zone:
                df = rename_sala(columns_list=columns_list, df=df)
            if dorm1['ZONE'] in zone:
                df = rename_dorm1(columns_list=columns_list, df=df)
            if dorm2['ZONE'] in zone:
                df = rename_dorm2(columns_list=columns_list, df=df)
            df = rename_special(columns_list=columns_list, df=df)
            columns_list = df.columns
            unwanted_list = []
            for item in columns_list:
                if item not in wanted_list:
                    unwanted_list.append(item)
            df.drop(columns=unwanted_list, axis=1, inplace=True)
            columns_list = df.columns
            df = df.groupby(df.columns, axis=1).sum()
            df.reset_index(inplace=True)
            df.drop(columns='index', axis=1, inplace=True)
            reorder = ['Date/Time']
            for item in df.columns:
                if item != 'Date/Time':
                    reorder.append(item)
            df = df[reorder]
            df.to_csv(output+'initial_'+'-'.join(zone)+type+i.split('\\')[1], sep=';')
            print('- Initial dataframe created')
            df = invert_values(df)
            print('- Inverted specified columns')
            df.to_csv(output+'intermediary_'+'-'.join(zone)+type+i.split('\\')[1], sep=';')
            print('- Intermediary dataframe created')
            # Verifica o tipo de dataframe selecionado e cria-o
            match coverage:
                case 'annual':
                    df.drop(columns='Date/Time', axis=1, inplace=True)
                    soma = df.apply(sum_separated)
                    soma = divide(soma)
                    print('- Gains and losses separated and calculated')
                    soma.loc[:, 'case'] = i.split('\\')[1]
                    soma.loc[:, 'type'] = way
                    soma.loc[:, 'zone'] = 'no zone'
                    for j in soma.index:
                        if soma.at[j, 'gains_losses'] == 'temp_ext':
                            soma.at[j, 'zone'] = all['ZONE']
                        else:
                            zones = soma.at[j, 'gains_losses'].split('_')[0]
                            lenght = (len(zones)+1)
                            new_name = soma.at[j, 'gains_losses'][lenght:]
                            soma.at[j, 'zone'] = zones
                            soma.at[j, 'gains_losses'] = new_name
                    print('- Case, type and zone added')
                    soma.to_csv(output+'final_annual_'+'-'.join(zone)+type+i.split('\\')[1], sep=';')
                    print('- Final annual dataframe created')
                case 'monthly':
                    df.loc[:, 'month'] = 'no month'
                    for row in df.index:
                        month = str(df.at[row, 'Date/Time'])
                        df.at[row, 'month'] = month[1:3]
                    print('- Months column created')
                    df.drop(columns='Date/Time', axis=1, inplace=True)
                    months = df['month'].unique()
                    for unique_month in months:
                        df_monthly = df[df['month'] == unique_month]
                        df_monthly.drop(columns='month', axis=1, inplace=True)
                        soma = df_monthly.apply(sum_separated)
                        soma = divide(soma)
                        print(f'- Gains and losses separated and calculated for month {unique_month}')
                        soma.loc[:, 'case'] = i.split('\\')[1]
                        soma.loc[:, 'type'] = way
                        soma.loc[:, 'month'] = unique_month
                        soma.loc[:, 'zone'] = 'no zone'
                        for j in soma.index:
                            if soma.at[j, 'gains_losses'] == all['Environment']:
                                soma.at[j, 'zone'] = all['ZONE']
                            else:
                                zones = soma.at[j, 'gains_losses'].split('_')[0]
                                lenght = (len(zones)+1)
                                new_name = soma.at[j, 'gains_losses'][lenght:]
                                soma.at[j, 'zone'] = zones
                                soma.at[j, 'gains_losses'] = new_name
                        print(f'- Case, type and zone added for month {unique_month}')
                        soma.to_csv(organizer_path+'_month'+unique_month+'.csv', sep=';')
                    glob_organizer = glob(organizer_path+'*.csv')
                    df_total = pd.read_csv(glob_organizer[0], sep=';')
                    glob_organizer.pop(0)
                    for item in glob_organizer:
                        each_df = pd.read_csv(item, sep=';')
                        df_total = pd.concat([df_total, each_df], axis=0, ignore_index=True)
                    df_total.drop(columns='Unnamed: 0', axis=1, inplace=True)
                    df_total.to_csv(output+'final_monthly_'+'-'.join(zone)+type+i.split('\\')[1], sep=';')
                    print('- Final monthly dataframe created')
                    clean_cache()
                case 'daily':
                    ## Max
                    max_temp_idx = df['temp_ext'].idxmax()
                    max_value = df["temp_ext"].max()
                    date_str = df.loc[max_temp_idx, 'Date/Time']
                    date_obj = datetime.strptime(date_str.split(' ')[1], '%m/%d')
                    date_str = date_obj.strftime('%m/%d')
                    day_bf = (date_obj - timedelta(days=1)).strftime('%m/%d')
                    day_af = (date_obj + timedelta(days=1)).strftime('%m/%d')
                    days_list = [date_str, day_bf, day_af]
                    print('\n')
                    print(f'- Date with max value: {date_str} as [{max_value}]')
                    print(f'- Day before: {day_bf}')
                    print(f'- Day after: {day_af}')
                    df_max = df.copy()
                    for j in df_max.index:
                        date_splited = df_max.at[j, 'Date/Time'].split(' ')[1]
                        if date_splited not in days_list:
                            df_max.drop(j, axis=0, inplace=True)
                            print(f'- Removing date {date_splited}', end='\r')
                    days = df_max['Date/Time'].unique()
                    for unique_datetime in days:
                        print(f'- Manipulating {unique_datetime}', end='\r')
                        df_daily = df_max[df_max['Date/Time'] == unique_datetime]
                        df_daily.drop(columns='Date/Time', axis=1, inplace=True)
                        soma = df_daily.apply(sum_separated)
                        soma = divide(soma)
                        soma.loc[:, 'case'] = i.split('\\')[1]
                        soma.loc[:, 'type'] = way
                        soma.loc[:, 'Date/Time'] = unique_datetime
                        soma.loc[:, 'zone'] = 'no zone'
                        for j in soma.index:
                            if soma.at[j, 'gains_losses'] == all['Environment']:
                                soma.at[j, 'zone'] = all['ZONE']
                            else:
                                zones = soma.at[j, 'gains_losses'].split('_')[0]
                                lenght = (len(zones)+1)
                                new_name = soma.at[j, 'gains_losses'][lenght:]
                                soma.at[j, 'zone'] = zones
                                soma.at[j, 'gains_losses'] = new_name
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
                        soma.to_csv(organizer_path+'_datetime'+unique_datetime+'.csv', sep=';')
                    print('\n')
                    glob_organizer = glob(organizer_path+'*.csv')
                    df_total = pd.read_csv(glob_organizer[0], sep=';')
                    glob_organizer.pop(0)
                    for item in glob_organizer:
                        each_df = pd.read_csv(item, sep=';')
                        df_total = pd.concat([df_total, each_df], axis=0, ignore_index=True)
                    df_total.drop(columns='Unnamed: 0', axis=1, inplace=True)
                    df_total = df_total[['Date/Time', 'month', 'day', 'hour', 'type', 'zone', 'gains_losses', 'value', 'case']]
                    df_total.to_csv(output+'final_max_daily_'+'-'.join(zone)+type+i.split('\\')[1], sep=';')
                    clean_cache()
                    
                    ## Min
                    min_temp_idx = df['temp_ext'].idxmin()
                    min_value = df['temp_ext'].min()
                    date_str = df.loc[min_temp_idx, 'Date/Time']
                    date_obj = datetime.strptime(date_str.split(' ')[1], '%m/%d')
                    date_str = date_obj.strftime('%m/%d')
                    day_bf = (date_obj - timedelta(days=1)).strftime('%m/%d')
                    day_af = (date_obj + timedelta(days=1)).strftime('%m/%d')
                    days_list = [date_str, day_bf, day_af]
                    print(f'- Date with min value: {date_str} as [{min_value}]')
                    print(f'- Day before: {day_bf}')
                    print(f'- Day after: {day_af}')
                    df_min = df.copy()
                    for j in df_min.index:
                        date_splited = df.at[j, 'Date/Time'].split(' ')[1]
                        if date_splited not in days_list:
                            df_min.drop(j, axis=0, inplace=True)
                            print(f'- Removing date {date_splited}', end='\r')
                    days = df_min['Date/Time'].unique()
                    for unique_datetime in days:
                        print(f'- Manipulating {unique_datetime}', end='\r')
                        df_daily = df_min[df_min['Date/Time'] == unique_datetime]
                        df_daily.drop(columns='Date/Time', axis=1, inplace=True)
                        soma = df_daily.apply(sum_separated)
                        soma = divide(soma)
                        soma.loc[:, 'case'] = i.split('\\')[1]
                        soma.loc[:, 'type'] = way
                        soma.loc[:, 'Date/Time'] = unique_datetime
                        soma.loc[:, 'zone'] = 'no zone'
                        for j in soma.index:
                            if soma.at[j, 'gains_losses'] == all['Environment']:
                                soma.at[j, 'zone'] = all['ZONE']
                            else:
                                zones = soma.at[j, 'gains_losses'].split('_')[0]
                                lenght = (len(zones)+1)
                                new_name = soma.at[j, 'gains_losses'][lenght:]
                                soma.at[j, 'zone'] = zones
                                soma.at[j, 'gains_losses'] = new_name
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
                        soma.to_csv(organizer_path+'_datetime'+unique_datetime+'.csv', sep=';')
                    print('\n')
                    glob_organizer = glob(organizer_path+'*.csv')
                    df_total = pd.read_csv(glob_organizer[0], sep=';')
                    glob_organizer.pop(0)
                    for item in glob_organizer:
                        each_df = pd.read_csv(item, sep=';')
                        df_total = pd.concat([df_total, each_df], axis=0, ignore_index=True)
                    df_total.drop(columns='Unnamed: 0', axis=1, inplace=True)
                    df_total = df_total[['Date/Time', 'month', 'day', 'hour', 'type', 'zone', 'gains_losses', 'value', 'case']]
                    df_total.to_csv(output+'final_min_daily_'+'-'.join(zone)+type+i.split('\\')[1], sep=';')
                    clean_cache()

                    ## Max and Min amp
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
                    date_obj = datetime.strptime(date_str.split(' ')[1], '%m/%d')
                    date_str = date_obj.strftime('%m/%d')
                    day_bf = (date_obj - timedelta(days=1)).strftime('%m/%d')
                    day_af = (date_obj + timedelta(days=1)).strftime('%m/%d')
                    days_list = [date_str, day_bf, day_af]
                    print(f'- Date with max amplitude value: {date_str} as [{max_amp["value"]}]')
                    print(f'- Day before: {day_bf}')
                    print(f'- Day after: {day_af}')
                    df_max = df.copy()
                    for j in df_max.index:
                        date_splited = df_max.at[j, 'Date/Time'].split(' ')[1]
                        if date_splited not in days_list:
                            df_max.drop(j, axis=0, inplace=True)
                            print(f'- Removing date {date_splited}', end='\r')
                    days = df_max['Date/Time'].unique()
                    for unique_datetime in days:
                        print(f'- Manipulating {unique_datetime}', end='\r')
                        df_daily = df_max[df_max['Date/Time'] == unique_datetime]
                        df_daily.drop(columns='Date/Time', axis=1, inplace=True)
                        soma = df_daily.apply(sum_separated)
                        soma = divide(soma)
                        soma.loc[:, 'case'] = i.split('\\')[1]
                        soma.loc[:, 'type'] = way
                        soma.loc[:, 'Date/Time'] = unique_datetime
                        soma.loc[:, 'zone'] = 'no zone'
                        for j in soma.index:
                            if soma.at[j, 'gains_losses'] == all['Environment']:
                                soma.at[j, 'zone'] = all['ZONE']
                            else:
                                zones = soma.at[j, 'gains_losses'].split('_')[0]
                                lenght = (len(zones)+1)
                                new_name = soma.at[j, 'gains_losses'][lenght:]
                                soma.at[j, 'zone'] = zones
                                soma.at[j, 'gains_losses'] = new_name
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
                        soma.to_csv(organizer_path+'_datetime'+unique_datetime+'.csv', sep=';')
                    print('\n')
                    glob_organizer = glob(organizer_path+'*.csv')
                    df_total = pd.read_csv(glob_organizer[0], sep=';')
                    glob_organizer.pop(0)
                    for item in glob_organizer:
                        each_df = pd.read_csv(item, sep=';')
                        df_total = pd.concat([df_total, each_df], axis=0, ignore_index=True)
                    df_total.drop(columns='Unnamed: 0', axis=1, inplace=True)
                    df_total = df_total[['Date/Time', 'month', 'day', 'hour', 'type', 'zone', 'gains_losses', 'value', 'case']]
                    df_total.to_csv(output+'final_max_amp_daily_'+'-'.join(zone)+type+i.split('\\')[1], sep=';')
                    clean_cache()

                    # Min amp
                    date_str = df.loc[min_amp['index'], 'Date/Time']
                    date_obj = datetime.strptime(date_str.split(' ')[1], '%m/%d')
                    date_str = date_obj.strftime('%m/%d')
                    day_bf = (date_obj - timedelta(days=1)).strftime('%m/%d')
                    day_af = (date_obj + timedelta(days=1)).strftime('%m/%d')
                    days_list = [date_str, day_bf, day_af]
                    print(f'- Date with min amplitude value: {date_str} as [{min_amp["value"]}]')
                    print(f'- Day before: {day_bf}')
                    print(f'- Day after: {day_af}')
                    df_min = df.copy()
                    for j in df_min.index:
                        date_splited = df.at[j, 'Date/Time'].split(' ')[1]
                        if date_splited not in days_list:
                            df_min.drop(j, axis=0, inplace=True)
                            print(f'- Removing date {date_splited}', end='\r')
                    days = df_min['Date/Time'].unique()
                    for unique_datetime in days:
                        print(f'- Manipulating {unique_datetime}', end='\r')
                        df_daily = df_min[df_min['Date/Time'] == unique_datetime]
                        df_daily.drop(columns='Date/Time', axis=1, inplace=True)
                        soma = df_daily.apply(sum_separated)
                        soma = divide(soma)
                        soma.loc[:, 'case'] = i.split('\\')[1]
                        soma.loc[:, 'type'] = way
                        soma.loc[:, 'Date/Time'] = unique_datetime
                        soma.loc[:, 'zone'] = 'no zone'
                        for j in soma.index:
                            if soma.at[j, 'gains_losses'] == all['Environment']:
                                soma.at[j, 'zone'] = all['ZONE']
                            else:
                                zones = soma.at[j, 'gains_losses'].split('_')[0]
                                lenght = (len(zones)+1)
                                new_name = soma.at[j, 'gains_losses'][lenght:]
                                soma.at[j, 'zone'] = zones
                                soma.at[j, 'gains_losses'] = new_name
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
                        soma.to_csv(organizer_path+'_datetime'+unique_datetime+'.csv', sep=';')
                    print('\n')
                    glob_organizer = glob(organizer_path+'*.csv')
                    df_total = pd.read_csv(glob_organizer[0], sep=';')
                    glob_organizer.pop(0)
                    for item in glob_organizer:
                        each_df = pd.read_csv(item, sep=';')
                        df_total = pd.concat([df_total, each_df], axis=0, ignore_index=True)
                    df_total.drop(columns='Unnamed: 0', axis=1, inplace=True)
                    df_total = df_total[['Date/Time', 'month', 'day', 'hour', 'type', 'zone', 'gains_losses', 'value', 'case']]
                    df_total.to_csv(output+'final_min_amp_daily_'+'-'.join(zone)+type+i.split('\\')[1], sep=';')
                    clean_cache()
