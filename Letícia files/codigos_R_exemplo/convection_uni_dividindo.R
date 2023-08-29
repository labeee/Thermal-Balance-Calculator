# for using this code the EnergyPlus output need to be from version 9.4 or newest
# the csv output must be in hourly format - upgrade for other formats (e.g. timestep) is still being improved

## packages

library(ggplot2)
library(data.table)
library(plyr)
library(stringr)
library(dplyr)

## functions ----

sumcols = function(df, col_list, output_type){
  first = TRUE
  for(c in col_list){
    if(first == TRUE){
      main_col = df[,grepl(paste0(c,output_type),colnames(df))]
      first = FALSE
    }else{
      main_col = main_col + df[,grepl(paste0(c,output_type),colnames(df))]
    }
  }
  return(main_col)
}

df.balanco = function(df, zone, none_intwalls,none_intdoors, bwc_intwalls, dorm1_intwalls, dorm2_intwalls,sala_intwalls,
                      bwc_intdoors, dorm1_intdoors, dorm2_intdoors,sala_intdoors,
                      none_extwalls, none_windows, south_extwalls, north_extwalls, west_extwalls, east_extwalls, 
                      south_windows, north_windows,south_extdoors, north_extdoors, west_extdoors, east_extdoors,west_windows, 
                      east_windows,none_floor, none_roof){
  
  df_thermal_balance = data.frame( ##eu não pego mais a parte do Date.Time do csv porque lá está por timestep
    date_time = df$Date.Time, #column from csv file with information about day and time
    month = as.numeric(substr(df$Date.Time, 2,3)), #extract information about month, this could be useful for plotting just a couple of days
    day = as.numeric(substr(df$Date.Time, 5,6))) #extract information about day, this could be useful for plotting just a couple of days
  if(any(grepl(paste0('Environment.Site.Outdoor.Air.Drybulb.Temperature.'),colnames(df)))){
    df_thermal_balance$temp_ext = df$Environment.Site.Outdoor.Air.Drybulb.Temperature..C..Hourly.
  }else{NA}
  if(any(grepl(paste0(zone,'.Zone.Operative.Temperature..C..'),colnames(df)))){
    df_thermal_balance$temp_op = df[,grepl(paste0(zone,'.Zone.Operative.Temperature..C..'),colnames(df))]
  }else{NA}
  # if(divisor == "not used"){
  ##internal loads
  if(any(grepl(paste0(zone,'.Zone.Total.Internal.Convective.Heating.Rate..W..Hourly.'),colnames(df)))){
    df_thermal_balance$internal_gains = (df[,grepl(paste0(zone,'.Zone.Total.Internal.Convective.Heating'),colnames(df))])
  }else{
    if(any(grepl(paste0(zone,'.Zone.Electric.Equipment.Convective.Heating.'),colnames(df)))){
      df_thermal_balance$internal_gains = (((df[,grepl(paste0(zone,'.Zone.People.Convective.Heating.'),colnames(df))]))+
                                             ((df[,grepl(paste0(zone,'.Zone.Lights.Convective.Heating.'),colnames(df))]))+
                                             ((df[,grepl(paste0(zone,'.Zone.Electric.Equipment.Convective.Heating.'),colnames(df))])))
    }else{
      df_thermal_balance$internal_gains = (((df[,grepl(paste0(zone,'.Zone.People.Convective.Heating.'),colnames(df))]))+
                                             ((df[,grepl(paste0(zone,'.Zone.Lights.Convective.Heating.'),colnames(df))])))}}
  ##opaque surfaces outputs
  #none_roof
  df_thermal_balance$none_roof_convection = (sumcols(df,none_roof, '.Surface.Inside.Face.Convection.Heat.'))
  #none_floor
  df_thermal_balance$none_floor_convection = (sumcols(df,none_floor, '.Surface.Inside.Face.Convection.Heat.'))
  #internal walls
  if(length(none_intwalls) >= 1){
    df_thermal_balance$none_intwalls_convection = (sumcols(df,none_intwalls, '.Surface.Inside.Face.Convection.Heat.'))
  }else{NA}
  if(length(bwc_intwalls) >= 1){
    df_thermal_balance$bwc_intwalls_convection = (sumcols(df,bwc_intwalls, '.Surface.Inside.Face.Convection.Heat.'))
  }else{NA}
  if(length(dorm1_intwalls) >= 1){
    df_thermal_balance$dorm1_intwalls_convection = (sumcols(df,dorm1_intwalls, '.Surface.Inside.Face.Convection.Heat.'))
  }else{NA}
  if(length(dorm2_intwalls) >= 1){
    df_thermal_balance$dorm2_intwalls_convection = (sumcols(df,dorm2_intwalls, '.Surface.Inside.Face.Convection.Heat.'))
  }else{NA}
  if(length(sala_intwalls) >= 1){
    df_thermal_balance$sala_intwalls_convection = (sumcols(df,sala_intwalls, '.Surface.Inside.Face.Convection.Heat.'))
  }else{NA}
  #internal doors
  if(length(none_intdoors) >= 1){
    df_thermal_balance$none_intdoors_convection = (sumcols(df,none_intdoors, '.Surface.Inside.Face.Convection.Heat.'))
  }else{NA}
  if(length(bwc_intdoors) >= 1){
    df_thermal_balance$bwc_intdoors_convection = (sumcols(df,bwc_intdoors, '.Surface.Inside.Face.Convection.Heat.'))
  }else{NA}
  if(length(dorm1_intdoors) >= 1){
    df_thermal_balance$dorm1_intdoors_convection = (sumcols(df,dorm1_intdoors, '.Surface.Inside.Face.Convection.Heat.'))
  }else{NA}
  if(length(dorm2_intdoors) >= 1){
    df_thermal_balance$dorm2_intdoors_convection = (sumcols(df,dorm2_intdoors, '.Surface.Inside.Face.Convection.Heat.'))
  }else{NA}
  if(length(sala_intdoors) >= 1){
    df_thermal_balance$sala_intdoors_convection = (sumcols(df,sala_intdoors, '.Surface.Inside.Face.Convection.Heat.'))
  }else{NA}
  #external walls all orientations 
  if(length(none_extwalls) >= 1){
    df_thermal_balance$none_extwalls_convection = (sumcols(df,none_extwalls, '.Surface.Inside.Face.Convection.Heat.'))
  }else{NA}
  #external walls
  if(length(south_extwalls) >= 1){
    df_thermal_balance$south_extwalls_convection = (sumcols(df,south_extwalls, '.Surface.Inside.Face.Convection.Heat.'))
  }else{NA}
  if(length(north_extwalls) >= 1){
    df_thermal_balance$north_extwalls_convection = (sumcols(df,north_extwalls, '.Surface.Inside.Face.Convection.Heat.'))
  }else{NA}
  if(length(west_extwalls) >= 1){
    df_thermal_balance$west_extwalls_convection = (sumcols(df,west_extwalls, '.Surface.Inside.Face.Convection.Heat.'))
  }else{NA}
  if(length(east_extwalls) >= 1){
    df_thermal_balance$east_extwalls_convection = (sumcols(df,east_extwalls, '.Surface.Inside.Face.Convection.Heat.'))
  }else{NA}
  #external doors
  if(length(south_extdoors) >= 1){
    df_thermal_balance$south_extdoors_convection = (sumcols(df,south_extdoors, '.Surface.Inside.Face.Convection.Heat.'))
  }else{NA}
  if(length(north_extdoors) >= 1){
    df_thermal_balance$north_extdoors_convection = (sumcols(df,north_extdoors, '.Surface.Inside.Face.Convection.Heat.'))
  }else{NA}
  if(length(west_extdoors) >= 1){
    df_thermal_balance$west_extdoors_convection = (sumcols(df,west_extdoors, '.Surface.Inside.Face.Convection.Heat.'))
  }else{NA}
  if(length(east_extdoors) >= 1){
    df_thermal_balance$east_extdoors_convection = (sumcols(df,east_extdoors, '.Surface.Inside.Face.Convection.Heat.'))
  }else{NA}
  ##windows outputs all orientations
  if(length(none_windows) >= 1){
    df_thermal_balance$none_windows_convection = (sumcols(df,none_windows, '.Surface.Inside.Face.Convection.Heat.'))
    df_thermal_balance$none_frame_convection = (sumcols(df,none_windows, '.Surface.Window.Inside.Face.Frame.and.Divider.Zone.Heat.Gain.')) #If the output is in Joule, this line need to be remove
  }else{NA}
  ##windows outputs 
  if(length(south_windows) >= 1){
    df_thermal_balance$south_windows_convection = (sumcols(df,south_windows, '.Surface.Inside.Face.Convection.Heat.'))
    df_thermal_balance$south_frame_convection = (sumcols(df,south_windows, '.Surface.Window.Inside.Face.Frame.and.Divider.Zone.Heat.Gain.')) #If the output is in Joule, this line need to be remove
  }else{NA}
  if(length(north_windows) >= 1){
    df_thermal_balance$north_windows_convection = (sumcols(df,north_windows, '.Surface.Inside.Face.Convection.Heat.'))
    df_thermal_balance$north_frame_convection = (sumcols(df,north_windows, '.Surface.Window.Inside.Face.Frame.and.Divider.Zone.Heat.Gain.')) #If the output is in Joule, this line need to be remove
  }else{NA}
  if(length(west_windows) >= 1){
    df_thermal_balance$west_windows_convection = (sumcols(df,west_windows, '.Surface.Inside.Face.Convection.Heat.'))
    df_thermal_balance$west_frame_convection = (sumcols(df,west_windows, '.Surface.Window.Inside.Face.Frame.and.Divider.Zone.Heat.Gain.')) #If the output is in Joule, this line need to be remove
  }else{NA}
  if(length(east_windows) >= 1){
    df_thermal_balance$east_windows_convection = (sumcols(df,east_windows, '.Surface.Inside.Face.Convection.Heat.'))
    df_thermal_balance$east_frame_convection = (sumcols(df,east_windows, '.Surface.Window.Inside.Face.Frame.and.Divider.Zone.Heat.Gain.')) #If the output is in Joule, this line need to be remove
  }else{NA}
  if(any(grepl('.Zone.Air.System.Sensible',colnames(df)))){ 
    if((sum(df[,grepl(paste0(zone,'.Zone.Air.System.Sensible.Cooling.'),colnames(df))]) != 0)){
      df_thermal_balance$cooling = -df[,grepl(paste0(zone,'.Zone.Air.System.Sensible.Cooling.'),colnames(df))]
    }
    if((sum(df[,grepl(paste0(zone,'.Zone.Air.System.Sensible.Cooling.'),colnames(df))]) == 0)){
      df_thermal_balance$cooling = 0
    }
    if((sum(df[,grepl(paste0(zone,'.Zone.Air.System.Sensible.Heating.'),colnames(df))])) != 0){
      df_thermal_balance$heating = df[,grepl(paste0(zone,'.Zone.Air.System.Sensible.Heating.'),colnames(df))]
    }
    if((sum(df[,grepl(paste0(zone,'.Zone.Air.System.Sensible.Heating.'),colnames(df))])) == 0){
      df_thermal_balance$heating = 0
    }
  }
  if(any(grepl('Ventilation',colnames(df)))){
    df_thermal_balance$vn_window_loss = -df[,grepl(paste0(zone,'.AFN.Zone.Ventilation.Sensible.Heat.Loss.'),colnames(df))]
    df_thermal_balance$vn_window_gain = df[,grepl(paste0(zone,'.AFN.Zone.Ventilation.Sensible.Heat.Gain.'),colnames(df))]
  }  
  if(any(grepl('Mixing',colnames(df)))){
    df_thermal_balance$vn_interzone_loss = -df[,grepl(paste0(zone,'.AFN.Zone.Mixing.Sensible.Heat.Loss.'),colnames(df))]
    df_thermal_balance$vn_interzone_gain = df[,grepl(paste0(zone,'.AFN.Zone.Mixing.Sensible.Heat.Gain.'),colnames(df))]
  }
  
  return(df_thermal_balance)
  
}


df.graph.annual.convection = function(df_manipulate){
  
  if(any(grepl('cooling',colnames(df_manipulate))) & (sum(df_manipulate$cooling) != 0)){
    df_convection = data.frame(subset(df_manipulate, select = c(date_time, month, day,internal_gains)),
                               df_manipulate[,grepl(('convection'),colnames(df_manipulate))],
                               df_manipulate[,grepl(('vn'),colnames(df_manipulate))],
                               subset(df_manipulate, select = c(cooling, heating)))
  }else{
    df_convection = data.frame(subset(df_manipulate, select = c(date_time,  month, day, internal_gains)),
                               df_manipulate[,grepl(('convection'),colnames(df_manipulate))],
                               df_manipulate[,grepl(('vn'),colnames(df_manipulate))])
  }
  
  df_convection[,grepl('walls',colnames(df_convection))] = df_convection[,grepl('walls',colnames(df_convection))]*-1
  df_convection[,grepl('roof',colnames(df_convection))] = df_convection[,grepl('roof',colnames(df_convection))]*-1
  df_convection[,grepl('floor',colnames(df_convection))] = df_convection[,grepl('floor',colnames(df_convection))]*-1
  df_convection[,grepl('windows_convection',colnames(df_convection))] = df_convection[,grepl('windows_convection',colnames(df_convection))]*-1
  df_convection[,grepl('doors',colnames(df_convection))] = df_convection[,grepl('doors',colnames(df_convection))]*-1
  
  if(any(grepl('south_window',colnames(df_convection)))){
    df_convection$south_windows_convection = df_convection$south_windows_convection+df_convection$south_frame_convection
    df_convection = subset(df_convection, select = -c(south_frame_convection))
  }else{NA}
  if(any(grepl('north_window',colnames(df_convection)))){
    df_convection$north_windows_convection = df_convection$north_windows_convection+df_convection$north_frame_convection
    df_convection = subset(df_convection, select = -c(north_frame_convection))
  }else{NA}
  if(any(grepl('east_window',colnames(df_convection)))){
    df_convection$east_windows_convection = df_convection$east_windows_convection+df_convection$east_frame_convection
    df_convection = subset(df_convection, select = -c(east_frame_convection))
  }else{NA}
  if(any(grepl('west_window',colnames(df_convection)))){
    df_convection$west_windows_convection = df_convection$west_windows_convection+df_convection$west_frame_convection
    df_convection = subset(df_convection, select = -c(west_frame_convection))
  }else{NA}
  
  
  if(any(grepl('cooling',colnames(df_convection)))){
  gains_losses_surface = c(colnames(subset(df_convection, select = -c(date_time, month, day, internal_gains, cooling, heating, vn_window_loss,
                                                                      vn_window_gain, vn_interzone_loss, vn_interzone_gain))))
  gains_losses_other = c("internal_gains", "cooling", "heating", "vn_window_loss","vn_window_gain", "vn_interzone_loss", "vn_interzone_gain")
  }else{gains_losses_surface = c(colnames(subset(df_convection, select = -c(date_time, month, day, internal_gains, vn_window_loss,
                                                                           vn_window_gain, vn_interzone_loss, vn_interzone_gain))))
  gains_losses_other = c("internal_gains", "vn_window_loss","vn_window_gain", "vn_interzone_loss", "vn_interzone_gain")}
  
  df_graph_surface_gain = data.frame(gains_losses = gains_losses_surface, value = c(1:1)) 
  df_graph_surface_loss = data.frame(gains_losses = gains_losses_surface, value = c(1:1))
  df_graph_other = data.frame(gains_losses = gains_losses_other, value = c(1:1)) 
  
  for(k in gains_losses_surface){
    for(i in 1:nrow(df_convection)){
      df_graph_surface_gain$value[df_graph_surface_gain$gains_losses == k] = sum(df_convection[,k][which(df_convection[,k] >= 0)])
      df_graph_surface_loss$value[df_graph_surface_loss$gains_losses == k] = sum(df_convection[,k][which(df_convection[,k] < 0)])
    }
  }
  
  for(k in gains_losses_other){
    for(i in 1:nrow(df_convection)){
      df_graph_other$value[df_graph_other$gains_losses == k] = sum(df_convection[,k])
    }
  }
  
  df_graph_surface_gain$gains_losses = paste0(df_graph_surface_gain$gains_losses,"_gain")
  df_graph_surface_loss$gains_losses = paste0(df_graph_surface_loss$gains_losses,"_loss")
  
  df_graph = rbind(df_graph_surface_gain, df_graph_surface_loss, df_graph_other)
  
  return(df_graph)
  
}

df.graph.monthly.convection = function(df_manipulate){
  
  if(any(grepl('cooling',colnames(df_manipulate))) & (sum(df_manipulate$cooling) != 0)){
    df_convection = data.frame(subset(df_manipulate, select = c(date_time, month, day,internal_gains)),  #para o AC
                               df_manipulate[,grepl(('convection'),colnames(df_manipulate))],
                               df_manipulate[,grepl(('vn'),colnames(df_manipulate))],
                               subset(df_manipulate, select = c(cooling, heating)))
  }else{
    df_convection = data.frame(subset(df_manipulate, select = c(date_time,  month, day, internal_gains)),  #para o AC
                               df_manipulate[,grepl(('convection'),colnames(df_manipulate))],
                               df_manipulate[,grepl(('vn'),colnames(df_manipulate))])
  }
  
  df_convection[,grepl('walls',colnames(df_convection))] = df_convection[,grepl('walls',colnames(df_convection))]*-1
  df_convection[,grepl('roof',colnames(df_convection))] = df_convection[,grepl('roof',colnames(df_convection))]*-1
  df_convection[,grepl('floor',colnames(df_convection))] = df_convection[,grepl('floor',colnames(df_convection))]*-1
  df_convection[,grepl('windows_convection',colnames(df_convection))] = df_convection[,grepl('windows_convection',colnames(df_convection))]*-1
  df_convection[,grepl('doors',colnames(df_convection))] = df_convection[,grepl('doors',colnames(df_convection))]*-1
  
  if(any(grepl('south_window',colnames(df_convection)))){
    df_convection$south_windows_convection = df_convection$south_windows_convection+df_convection$south_frame_convection
    df_convection = subset(df_convection, select = -c(south_frame_convection))
  }else{NA}
  if(any(grepl('north_window',colnames(df_convection)))){
    df_convection$north_windows_convection = df_convection$north_windows_convection+df_convection$north_frame_convection
    df_convection = subset(df_convection, select = -c(north_frame_convection))
  }else{NA}
  if(any(grepl('east_window',colnames(df_convection)))){
    df_convection$east_windows_convection = df_convection$east_windows_convection+df_convection$east_frame_convection
    df_convection = subset(df_convection, select = -c(east_frame_convection))
  }else{NA}
  if(any(grepl('west_window',colnames(df_convection)))){
    df_convection$west_windows_convection = df_convection$west_windows_convection+df_convection$west_frame_convection
    df_convection = subset(df_convection, select = -c(west_frame_convection))
  }else{NA}
  
  months = c(unique(df_convection$month))
  
  if(any(grepl('cooling',colnames(df_convection)))){
    gains_losses_surface = c(colnames(subset(df_convection, select = -c(date_time, month, day, internal_gains, cooling, heating, vn_window_loss,
                                                                        vn_window_gain, vn_interzone_loss, vn_interzone_gain))))
    gains_losses_other = c("internal_gains", "cooling", "heating", "vn_window_loss","vn_window_gain", "vn_interzone_loss", "vn_interzone_gain")
  }else{gains_losses_surface = c(colnames(subset(df_convection, select = -c(date_time, month, day, internal_gains, vn_window_loss,
                                                                            vn_window_gain, vn_interzone_loss, vn_interzone_gain))))
  gains_losses_other = c("internal_gains", "vn_window_loss","vn_window_gain", "vn_interzone_loss", "vn_interzone_gain")}
  
  df_graph_surface_gain = data.frame(month = rep(months, each = length(gains_losses_surface)), gains_losses = gains_losses_surface, value = c(1:1)) 
  df_graph_surface_loss = data.frame(month = rep(months, each = length(gains_losses_surface)), gains_losses = gains_losses_surface, value = c(1:1))
  df_graph_other = data.frame(month = rep(months, each = length(gains_losses_other)), gains_losses = gains_losses_other, value = c(1:1))
  
  for(m in months){
    for(k in gains_losses_surface){
      for(i in 1:nrow(df_convection)){
        df_graph_surface_gain$value[df_graph_surface_gain$gains_losses == k & df_graph_surface_gain$month == m] = sum(df_convection[,k][df_convection$month == m][which(df_convection[,k][df_convection$month == m] >= 0)])
        df_graph_surface_loss$value[df_graph_surface_loss$gains_losses == k & df_graph_surface_loss$month == m] = sum(df_convection[,k][df_convection$month == m][which(df_convection[,k][df_convection$month == m] < 0)])
      }
    }
  }
  
  for(m in months){
    for(k in gains_losses_other){
      for(i in 1:nrow(df_convection)){
        df_graph_other$value[df_graph_other$gains_losses == k & df_graph_other$month == m] = sum(df_convection[,k][df_convection$month == m])
      }
    }
  }
  
  df_graph_surface_gain$gains_losses = paste0(df_graph_surface_gain$gains_losses,"_gain")
  df_graph_surface_loss$gains_losses = paste0(df_graph_surface_loss$gains_losses,"_loss")
  
  df_graph = rbind(df_graph_surface_gain, df_graph_surface_loss, df_graph_other)
  
  
  return(df_graph)
  
}

df.graph.daily.convection = function(df_manipulate,cidade, temp){  ##esse eu vou ter que adaptar para o AC e VN
  
  # df_manipulate = trocas[[1]]
  
  if(cidade == 'saopaulo'){
    if(temp == 'max'){ ## valor para sao paulo
      df_daily = subset(df_manipulate, (df_manipulate$day == 1 | df_manipulate$day == 2) &
                          (df_manipulate$month == 10))
      g = 10
      f = 1
    }else{
      if(temp == 'amp_verao'){ ## valor para sao paulo
        df_daily = subset(df_manipulate, (df_manipulate$day == 23 | df_manipulate$day == 24) &
                            (df_manipulate$month == 11))
        g = 11
        f = 23
      }else{
        if(temp == 'amp_inverno'){ ## valor para sao paulo
          df_daily = subset(df_manipulate, (df_manipulate$day == 17 | df_manipulate$day == 18) &
                              (df_manipulate$month == 7))
          g = 7
          f = 17
        }else{
          df_daily = subset(df_manipulate, (df_manipulate$day == 15 | df_manipulate$day == 16) &
                              (df_manipulate$month == 7))
          g = 7
          f = 15
        }
      }
    }
  }else{
    if(temp == 'max'){ ## valor para belem
      df_daily = subset(df_manipulate, (df_manipulate$day == 12 | df_manipulate$day == 13) &
                          (df_manipulate$month == 9))
      g = 9
      f = 12
    }else{
        df_daily = subset(df_manipulate, (df_manipulate$day == 15 | df_manipulate$day == 16) &
                            (df_manipulate$month == 2))
        g = 2
        f = 15
      }
    }
    
  
  if(any(grepl('cooling',colnames(df_daily)))){
    df_convection = data.frame(subset(df_daily, select = c(date_time, month, day, internal_gains)), 
                               df_daily[,grepl(('convection'),colnames(df_daily))],
                               df_daily[,grepl(('vn'),colnames(df_daily))],
                               subset(df_daily, select = c(cooling, heating)))
  }else{
    df_convection = data.frame(subset(df_daily, select = c(date_time, month, day, internal_gains)), 
                               df_daily[,grepl(('convection'),colnames(df_daily))],
                               df_daily[,grepl(('vn'),colnames(df_daily))])
  }
  
  df_convection[,grepl('walls',colnames(df_convection))] = df_convection[,grepl('walls',colnames(df_convection))]*-1
  df_convection[,grepl('roof',colnames(df_convection))] = df_convection[,grepl('roof',colnames(df_convection))]*-1
  df_convection[,grepl('floor',colnames(df_convection))] = df_convection[,grepl('floor',colnames(df_convection))]*-1
  df_convection[,grepl('windows_convection',colnames(df_convection))] = df_convection[,grepl('windows_convection',colnames(df_convection))]*-1
  df_convection[,grepl('doors',colnames(df_convection))] = df_convection[,grepl('doors',colnames(df_convection))]*-1
  
  if(any(grepl('south_window',colnames(df_convection)))){
    df_convection$south_windows_convection = df_convection$south_windows_convection+df_convection$south_frame_convection
    df_convection = subset(df_convection, select = -c(south_frame_convection))
  }else{NA}
  if(any(grepl('north_window',colnames(df_convection)))){
    df_convection$north_windows_convection = df_convection$north_windows_convection+df_convection$north_frame_convection
    df_convection = subset(df_convection, select = -c(north_frame_convection))
  }else{NA}
  if(any(grepl('east_window',colnames(df_convection)))){
    df_convection$east_windows_convection = df_convection$east_windows_convection+df_convection$east_frame_convection
    df_convection = subset(df_convection, select = -c(east_frame_convection))
  }else{NA}
  if(any(grepl('west_window',colnames(df_convection)))){
    df_convection$west_windows_convection = df_convection$west_windows_convection+df_convection$west_frame_convection
    df_convection = subset(df_convection, select = -c(west_frame_convection))
  }else{NA}
  
  df_convection$time = as.numeric(substr(df_convection$date_time, 9,10))
  df_convection$time[df_convection$time == 0] = 24

  months = c(unique(df_convection$month))
  
  if(any(grepl('cooling',colnames(df_convection)))){
    gains_losses_surface = c(colnames(subset(df_convection, select = -c(date_time, time, month, day, internal_gains, cooling, heating, vn_window_loss,
                                                                        vn_window_gain, vn_interzone_loss, vn_interzone_gain))))
    gains_losses_other = c("internal_gains", "cooling", "heating", "vn_window_loss","vn_window_gain", "vn_interzone_loss", "vn_interzone_gain")
  }else{gains_losses_surface = c(colnames(subset(df_convection, select = -c(date_time, time, month, day, internal_gains, vn_window_loss,
                                                                            vn_window_gain, vn_interzone_loss, vn_interzone_gain))))
  gains_losses_other = c("internal_gains", "vn_window_loss","vn_window_gain", "vn_interzone_loss", "vn_interzone_gain")}
  
  
  df_graph_surface_gain = data.frame(date_graph = seq(ISOdate(2019,g,f,0,0,0),by='1 hour',length.out=2*24,tz=''),
                                     time = unique(df_convection$time),month = unique(df_convection$month),day=rep(unique(df_convection$day),each=24), 
                                     gains_losses = rep(gains_losses_surface, each = 24*2), value = c(1:1))
  df_graph_surface_loss = data.frame(date_graph = seq(ISOdate(2019,g,f,0,0,0),by='1 hour',length.out=2*24,tz=''),
                                     time = unique(df_convection$time),month = unique(df_convection$month),day=rep(unique(df_convection$day),each=24), 
                                     gains_losses = rep(gains_losses_surface, each = 24*2), value = c(1:1))
  df_graph_other = data.frame(date_graph = seq(ISOdate(2019,g,f,0,0,0),by='1 hour',length.out=2*24,tz=''),
                              time = unique(df_convection$time),month = unique(df_convection$month),day=rep(unique(df_convection$day),each=24), 
                              gains_losses = rep(gains_losses_other, each = 24*2), value = c(1:1))
  
  for(k in gains_losses_surface){
    for(i in 1:nrow(df_convection)){
      for(n in unique(df_convection$time)){
        for(d in unique(df_convection$day)){
          df_graph_surface_gain$value[df_graph_surface_gain$gains_losses == k & df_graph_surface_gain$time == n & df_graph_surface_gain$day == d] = sum(df_convection[,k][df_convection$time == n & df_convection$day == d][which(df_convection[,k][df_convection$time == n & df_convection$day == d] >= 0)])
          df_graph_surface_loss$value[df_graph_surface_loss$gains_losses == k & df_graph_surface_loss$time == n & df_graph_surface_loss$day == d] = sum(df_convection[,k][df_convection$time == n & df_convection$day == d][which(df_convection[,k][df_convection$time == n & df_convection$day == d] < 0)])
        }
      }
    }
  }
  
  for(k in gains_losses_other){
    for(i in 1:nrow(df_convection)){
      for(n in unique(df_convection$time)){
        for(d in unique(df_convection$day)){
          df_graph_other$value[df_graph_other$gains_losses == k & df_graph_other$time == n & df_graph_other$day == d] = sum(df_convection[,k][df_convection$time == n & df_convection$day == d])
        }
      }
    }
  }
  
  df_graph_surface_gain$gains_losses = paste0(df_graph_surface_gain$gains_losses,"_gain")
  df_graph_surface_loss$gains_losses = paste0(df_graph_surface_loss$gains_losses,"_loss")
  
  df_graph = rbind(df_graph_surface_gain, df_graph_surface_loss, df_graph_other)
  
  return(df_graph)
  
}

##single-family house -----

# epw = "BRA_PA_Belem.816800_TMYx.2007-2021"
# cidade = "belem"

epw = "BRA_SP_Sao.Paulo-Congonhas.AP.837800_TMYx.2007-2021"
cidade = "saopaulo"

setwd(paste0("D:/Frentes de Trabalho/simulacoes_tese/simulation/convection/reference/",epw,"/")) ##para a referencia no pc lab

#single-family livingroom
zone = 'SALA'
none_intwalls = c("SALA_PARIN_01S","SALA_PARIN_00E","SALA_PORTAIN_0_00E","SALA_PARIN_01D","SALA_PORTAIN_0_01D","SALA_PARIN_02D","SALA_PORTAIN_0_02D")
bwc_intwalls = c(NULL)
dorm1_intwalls = c(NULL)
dorm2_intwalls = c(NULL)
sala_intwalls = c(NULL)
none_intdoors = c(NULL)
bwc_intdoors = c(NULL) # I could use this for inform the thermal balance in internal doors or use them with internal walls
dorm1_intdoors = c(NULL) # I could use this for inform the thermal balance in internal doors or use them with internal walls
dorm2_intdoors = c(NULL) # I could use this for inform the thermal balance in internal doors or use them with internal walls
sala_intdoors = c(NULL) # I could use this for inform the thermal balance in internal doors or use them with internal walls
none_extwalls = c(NULL) # If I not going to use different orientations in the analysis
south_extwalls = c("SALA_PAREX_00I")
none_extdoors = c(NULL) # If I not going to use different orientations in the analysis
south_extdoors = c(NULL) # I could use this for informe the thermal balance in external doors or use them with external walls in respective orientation
west_extwalls = c("SALA_PAREX_01E")
west_extdoors = c(NULL)
east_extwalls = c("SALA_PAREX_00D","SALA_PORTAEX_0_00D")
east_extdoors = c(NULL)
north_extwalls = c("SALA_PAREX_00S","SALA_PORTAEX_0_00S")
north_extdoors = c(NULL)
none_floor = c("SALA_PISO")
none_roof = c("SALA_COB_1","SALA_COB_0")
none_windows = c(NULL) # If I not going to use different orientations in the analysis
south_windows = c("SALA_JAN_0_00I")
west_windows = c("SALA_JAN_0_01E")
north_windows = c(NULL)
east_windows = c(NULL)

# modelo = "vn" #referencia
# modelo = "ac" #referencia
modelo = "U001" #referencia
# modelo = "vn" #referencia

## criando uma lista com os nomes de todos os .csv da pasta com vn no nome ----
file_list = intersect(list.files(pattern=".csv"), list.files(pattern=modelo)) # todos os csv menos o table

## para transformar em uma lista unica

trocas = list()
trocas_annual = list()
trocas_monthly = list()
trocas_daily = list() #por enquanto só o híbrido

for (i in seq_along(file_list)) {
  df = read.csv(file_list[i]) %>% select("Date.Time",contains("Hourly")) %>% na.omit()
  
  trocas[[i]] = df.balanco(df, zone, none_intwalls,none_intdoors, bwc_intwalls,
                              dorm1_intwalls, dorm2_intwalls,sala_intwalls,
                              bwc_intdoors, dorm1_intdoors, dorm2_intdoors,sala_intdoors,
                              none_extwalls, none_windows, south_extwalls, north_extwalls, west_extwalls, east_extwalls,
                              south_windows, north_windows,south_extdoors, north_extdoors, west_extdoors, east_extdoors,west_windows,
                              east_windows,none_floor, none_roof)
}

#o caso híbrido não veio com a temperatura externa por que lá está em timestep
trocas[[3]]$temp_ext = trocas[[1]]$temp_ext

rm(df)

temp = "max"

for(i in seq_along(trocas)) {
  df_manipulate = trocas[[i]]
  trocas_annual[[i]] = df.graph.annual.convection(df_manipulate)
  trocas_monthly[[i]] = df.graph.monthly.convection(df_manipulate) ## ano todo
  trocas_daily[[i]] = df.graph.daily.convection(df_manipulate,cidade, temp) ## ano todo
}
rm(df_manipulate)

df_names = data.frame(file_list)
df_names$number = as.character(c(1:length(file_list)))


for(i in c(1:length(trocas))){
  trocas_annual[[i]]$case = df_names$file_list[df_names$number == i]
  trocas_monthly[[i]]$case = df_names$file_list[df_names$number == i]
  trocas_daily[[i]]$case = df_names$file_list[df_names$number == i]
}

rm(df_names)

trocas_graph_daily = do.call(rbind.data.frame, trocas_daily)
trocas_graph_montlhy = do.call(rbind.data.frame, trocas_monthly)
trocas_graph_annual = do.call(rbind.data.frame, trocas_annual)

# setwd(paste0("D:/Frentes de Trabalho/simulacoes_tese/simulation/convection/reference/resultados/")) ##para a referencia no pc lab
setwd(paste0("D:/Frentes de Trabalho/simulacoes_tese/simulation/convection/reference/resultados/dividindo_gain_loss/")) ##para a referencia no pc lab

write.csv(trocas_graph_daily, paste0("daily_",temp,"_",cidade,"_",zone,".csv"))
write.csv(trocas_graph_montlhy, paste0("monthly_",cidade,"_",zone,".csv"))
write.csv(trocas_graph_annual, paste0("annual_",cidade,"_",zone,".csv"))

## Amplitute verão ----

temp = "amp_verao"

df = trocas[[1]]

for(i in seq_along(trocas)) {
  df_manipulate = trocas[[i]]
  trocas_daily[[i]] = df.graph.daily.convection(df_manipulate,cidade, temp) ## ano todo
}
rm(df_manipulate)

df_names = data.frame(file_list)
df_names$number = as.character(c(1:length(file_list)))


for(i in c(1:length(trocas))){
  trocas_daily[[i]]$case = df_names$file_list[df_names$number == i]
}

rm(df_names)

trocas_graph_daily = do.call(rbind.data.frame, trocas_daily)

write.csv(trocas_graph_daily, paste0("daily_",temp,"_",cidade,"_",zone,".csv"))

## amplitude inverno -- somente para são paulo

if(cidade == "saopaulo"){
  temp = "amp_inverno" 
  
  for(i in seq_along(trocas)) {
    df_manipulate = trocas[[i]]
    trocas_daily[[i]] = df.graph.daily.convection(df_manipulate,cidade, temp) ## ano todo
  }
  rm(df_manipulate)
  
  df_names = data.frame(file_list)
  df_names$number = as.character(c(1:length(file_list)))
  
  
  for(i in c(1:length(trocas))){
    trocas_daily[[i]]$case = df_names$file_list[df_names$number == i]
  }
  
  rm(df_names)
  
  trocas_graph_daily = do.call(rbind.data.frame, trocas_daily)
  
  write.csv(trocas_graph_daily, paste0("daily_",temp,"_",cidade,"_",zone,".csv"))

  temp = "min"
  
  for(i in seq_along(trocas)) {
    df_manipulate = trocas[[i]]
    trocas_daily[[i]] = df.graph.daily.convection(df_manipulate,cidade, temp) ## ano todo
  }
  rm(df_manipulate)
  
  df_names = data.frame(file_list)
  df_names$number = as.character(c(1:length(file_list)))
  
  
  for(i in c(1:length(trocas))){
    trocas_daily[[i]]$case = df_names$file_list[df_names$number == i]
  }
  
  rm(df_names)
  
  trocas_graph_daily = do.call(rbind.data.frame, trocas_daily)
  
  write.csv(trocas_graph_daily, paste0("daily_",temp,"_",cidade,"_",zone,".csv"))
  
}else{NA}

## DORMITÓRIO 1 ----

setwd(paste0("D:/Frentes de Trabalho/simulacoes_tese/simulation/convection/reference/",epw,"/")) ##para a referencia no pc lab

#single-family bedroom1
zone = 'DORM1'
none_intwalls = c("DORM1_PARIN_00E","DORM1_PARIN_00S","DORM1_PORTAIN_0_00E")
bwc_intwalls = c(NULL)
dorm1_intwalls = c(NULL)
dorm2_intwalls = c(NULL)
sala_intwalls = c(NULL)
none_intdoors = c(NULL)
bwc_intdoors = c(NULL) # I could use this for inform the thermal balance in internal doors or use them with internal walls
dorm1_intdoors = c(NULL) # I could use this for inform the thermal balance in internal doors or use them with internal walls
dorm2_intdoors = c(NULL) # I could use this for inform the thermal balance in internal doors or use them with internal walls
sala_intdoors = c(NULL) # I could use this for inform the thermal balance in internal doors or use them with internal walls
none_extwalls = c(NULL) # If I not going to use different orientations in the analysis
south_extwalls = c("DORM1_PAREX_00I")
none_extdoors = c(NULL) # If I not going to use different orientations in the analysis
south_extdoors = c(NULL) # I could use this for informe the thermal balance in external doors or use them with external walls in respective orientation
west_extwalls = c(NULL)
west_extdoors = c(NULL)
east_extwalls = c("DORM1_PAREX_00D")
east_extdoors = c(NULL)
north_extwalls = c(NULL)
north_extdoors = c(NULL)
none_floor = c("DORM1_PISO")
none_roof = c("DORM1_COB")
none_windows = c(NULL) # If I not going to use different orientations in the analysis
south_windows = c("DORM1_JAN_0_00I")
west_windows = c(NULL)
north_windows = c(NULL)
east_windows = c(NULL)

# modelo = "vn" #referencia
# modelo = "ac" #referencia
modelo = "U001" #referencia
# modelo = "vn" #referencia

## criando uma lista com os nomes de todos os .csv da pasta com vn no nome ----
file_list = intersect(list.files(pattern=".csv"), list.files(pattern=modelo)) # todos os csv menos o table

## para transformar em uma lista unica

trocas = list()
trocas_annual = list()
trocas_monthly = list()
trocas_daily = list() #por enquanto só o híbrido

# trocas_all = list()

for (i in seq_along(file_list)) {
  df = read.csv(file_list[i]) %>% select("Date.Time",contains("Hourly")) %>% na.omit()
  
  trocas[[i]] = df.balanco(df, zone, none_intwalls,none_intdoors, bwc_intwalls,
                           dorm1_intwalls, dorm2_intwalls,sala_intwalls,
                           bwc_intdoors, dorm1_intdoors, dorm2_intdoors,sala_intdoors,
                           none_extwalls, none_windows, south_extwalls, north_extwalls, west_extwalls, east_extwalls,
                           south_windows, north_windows,south_extdoors, north_extdoors, west_extdoors, east_extdoors,west_windows,
                           east_windows,none_floor, none_roof)
}

rm(df)

#o caso híbrido não veio com a temperatura externa por que lá está em timestep
trocas[[3]]$temp_ext = trocas[[1]]$temp_ext

temp = "max"

for(i in seq_along(trocas)) {
  df_manipulate = trocas[[i]]
  trocas_annual[[i]] = df.graph.annual.convection(df_manipulate)
  trocas_monthly[[i]] = df.graph.monthly.convection(df_manipulate) ## ano todo
  trocas_daily[[i]] = df.graph.daily.convection(df_manipulate,cidade,  temp) ## ano todo
}
rm(df_manipulate)

df_names = data.frame(file_list)
df_names$number = as.character(c(1:length(file_list)))


for(i in c(1:length(trocas))){
  trocas_annual[[i]]$case = df_names$file_list[df_names$number == i]
  trocas_monthly[[i]]$case = df_names$file_list[df_names$number == i]
  trocas_daily[[i]]$case = df_names$file_list[df_names$number == i]
}

rm(df_names)

trocas_graph_daily = do.call(rbind.data.frame, trocas_daily)
trocas_graph_montlhy = do.call(rbind.data.frame, trocas_monthly)
trocas_graph_annual = do.call(rbind.data.frame, trocas_annual)

# setwd(paste0("D:/Frentes de Trabalho/simulacoes_tese/simulation/convection/reference/resultados/")) ##para a referencia no pc lab
setwd(paste0("D:/Frentes de Trabalho/simulacoes_tese/simulation/convection/reference/resultados/dividindo_gain_loss/")) ##para a referencia no pc lab

write.csv(trocas_graph_daily, paste0("daily_",temp,"_",cidade,"_",zone,".csv"))
write.csv(trocas_graph_montlhy, paste0("monthly_",cidade,"_",zone,".csv"))
write.csv(trocas_graph_annual, paste0("annual_",cidade,"_",zone,".csv"))

temp = "amp_verao"

for(i in seq_along(trocas)) {
  df_manipulate = trocas[[i]]
  trocas_daily[[i]] = df.graph.daily.convection(df_manipulate,cidade,  temp) ## ano todo
}
rm(df_manipulate)

df_names = data.frame(file_list)
df_names$number = as.character(c(1:length(file_list)))


for(i in c(1:length(trocas))){
  trocas_daily[[i]]$case = df_names$file_list[df_names$number == i]
}

rm(df_names)

trocas_graph_daily = do.call(rbind.data.frame, trocas_daily)

write.csv(trocas_graph_daily, paste0("daily_",temp,"_",cidade,"_",zone,".csv"))

## amplitude inverno -- somente para são paulo

if(cidade == "saopaulo"){
  temp = "amp_inverno" 
  
  for(i in seq_along(trocas)) {
    df_manipulate = trocas[[i]]
    trocas_daily[[i]] = df.graph.daily.convection(df_manipulate,cidade, temp) ## ano todo
  }
  rm(df_manipulate)
  
  df_names = data.frame(file_list)
  df_names$number = as.character(c(1:length(file_list)))
  
  
  for(i in c(1:length(trocas))){
    trocas_daily[[i]]$case = df_names$file_list[df_names$number == i]
  }
  
  rm(df_names)
  
  trocas_graph_daily = do.call(rbind.data.frame, trocas_daily)
  
  write.csv(trocas_graph_daily, paste0("daily_",temp,"_",cidade,"_",zone,".csv"))
  
  temp = "min"
  
  for(i in seq_along(trocas)) {
    df_manipulate = trocas[[i]]
    trocas_daily[[i]] = df.graph.daily.convection(df_manipulate,cidade, temp) ## ano todo
  }
  rm(df_manipulate)
  
  df_names = data.frame(file_list)
  df_names$number = as.character(c(1:length(file_list)))
  
  
  for(i in c(1:length(trocas))){
    trocas_daily[[i]]$case = df_names$file_list[df_names$number == i]
  }
  
  rm(df_names)
  
  trocas_graph_daily = do.call(rbind.data.frame, trocas_daily)
  
  write.csv(trocas_graph_daily, paste0("daily_",temp,"_",cidade,"_",zone,".csv"))
  
}else{NA}

## DORMITÓRIO 2 ----

setwd(paste0("D:/Frentes de Trabalho/simulacoes_tese/simulation/convection/reference/",epw,"/")) ##para a referencia no pc lab

#single-family bedroom2
zone = 'DORM2'
none_intwalls = c("DORM2_PARIN_00I","DORM2_PARIN_01E","DORM2_PORTAIN_0_01E")
bwc_intwalls = c(NULL)
dorm1_intwalls = c(NULL)
dorm2_intwalls = c(NULL)
sala_intwalls = c(NULL)
none_intdoors = c(NULL)
bwc_intdoors = c(NULL) # I could use this for inform the thermal balance in internal doors or use them with internal walls
dorm1_intdoors = c(NULL) # I could use this for inform the thermal balance in internal doors or use them with internal walls
dorm2_intdoors = c(NULL) # I could use this for inform the thermal balance in internal doors or use them with internal walls
sala_intdoors = c(NULL) # I could use this for inform the thermal balance in internal doors or use them with internal walls
none_extwalls = c(NULL) # If I not going to use different orientations in the analysis
south_extwalls = c(NULL)
none_extdoors = c(NULL) # If I not going to use different orientations in the analysis
south_extdoors = c(NULL) # I could use this for informe the thermal balance in external doors or use them with external walls in respective orientation
west_extwalls = c("DORM2_PAREX_00E")
west_extdoors = c(NULL)
east_extwalls = c("DORM2_PAREX_00D")
east_extdoors = c(NULL)
north_extwalls = c("DORM2_PAREX_00S")
north_extdoors = c(NULL)
none_floor = c("DORM2_PISO")
none_roof = c("DORM2_COB")
none_windows = c(NULL) # If I not going to use different orientations in the analysis
south_windows = c(NULL)
west_windows = c(NULL)
north_windows = c(NULL)
east_windows = c("DORM2_JAN_0_00D")

# modelo = "vn" #referencia
# modelo = "ac" #referencia
modelo = "U001" #referencia
# modelo = "vn" #referencia

## criando uma lista com os nomes de todos os .csv da pasta com vn no nome ----
file_list = intersect(list.files(pattern=".csv"), list.files(pattern=modelo)) # todos os csv menos o table

## para transformar em uma lista unica

trocas = list()
trocas_annual = list()
trocas_monthly = list()
trocas_daily = list() #por enquanto só o híbrido

# trocas_all = list()

for (i in seq_along(file_list)) {
  df = read.csv(file_list[i]) %>% select("Date.Time",contains("Hourly")) %>% na.omit()
  
  trocas[[i]] = df.balanco(df, zone, none_intwalls,none_intdoors, bwc_intwalls,
                           dorm1_intwalls, dorm2_intwalls,sala_intwalls,
                           bwc_intdoors, dorm1_intdoors, dorm2_intdoors,sala_intdoors,
                           none_extwalls, none_windows, south_extwalls, north_extwalls, west_extwalls, east_extwalls,
                           south_windows, north_windows,south_extdoors, north_extdoors, west_extdoors, east_extdoors,west_windows,
                           east_windows,none_floor, none_roof)
}

rm(df)

#o caso híbrido não veio com a temperatura externa por que lá está em timestep
trocas[[3]]$temp_ext = trocas[[1]]$temp_ext

temp = "max"

for(i in seq_along(trocas)) {
  df_manipulate = trocas[[i]]
  trocas_annual[[i]] = df.graph.annual.convection(df_manipulate)
  trocas_monthly[[i]] = df.graph.monthly.convection(df_manipulate) ## ano todo
  trocas_daily[[i]] = df.graph.daily.convection(df_manipulate,cidade,  temp) ## ano todo
}
rm(df_manipulate)

df_names = data.frame(file_list)
df_names$number = as.character(c(1:length(file_list)))


for(i in c(1:length(trocas))){
  trocas_annual[[i]]$case = df_names$file_list[df_names$number == i]
  trocas_monthly[[i]]$case = df_names$file_list[df_names$number == i]
  trocas_daily[[i]]$case = df_names$file_list[df_names$number == i]
}

rm(df_names)

trocas_graph_daily = do.call(rbind.data.frame, trocas_daily)
trocas_graph_montlhy = do.call(rbind.data.frame, trocas_monthly)
trocas_graph_annual = do.call(rbind.data.frame, trocas_annual)

# setwd(paste0("D:/Frentes de Trabalho/simulacoes_tese/simulation/convection/reference/resultados/")) ##para a referencia no pc lab
setwd(paste0("D:/Frentes de Trabalho/simulacoes_tese/simulation/convection/reference/resultados/dividindo_gain_loss/")) ##para a referencia no pc lab

write.csv(trocas_graph_daily, paste0("daily_",temp,"_",cidade,"_",zone,".csv"))
write.csv(trocas_graph_montlhy, paste0("monthly_",cidade,"_",zone,".csv"))
write.csv(trocas_graph_annual, paste0("annual_",cidade,"_",zone,".csv"))

temp = "amp_verao"

for(i in seq_along(trocas)) {
  df_manipulate = trocas[[i]]
  trocas_daily[[i]] = df.graph.daily.convection(df_manipulate,cidade,  temp) ## ano todo
}
rm(df_manipulate)

df_names = data.frame(file_list)
df_names$number = as.character(c(1:length(file_list)))


for(i in c(1:length(trocas))){
  trocas_daily[[i]]$case = df_names$file_list[df_names$number == i]
}

rm(df_names)

trocas_graph_daily = do.call(rbind.data.frame, trocas_daily)

write.csv(trocas_graph_daily, paste0("daily_",temp,"_",cidade,"_",zone,".csv"))

if(cidade == "saopaulo"){
  temp = "amp_inverno" 
  
  for(i in seq_along(trocas)) {
    df_manipulate = trocas[[i]]
    trocas_daily[[i]] = df.graph.daily.convection(df_manipulate,cidade, temp) ## ano todo
  }
  rm(df_manipulate)
  
  df_names = data.frame(file_list)
  df_names$number = as.character(c(1:length(file_list)))
  
  
  for(i in c(1:length(trocas))){
    trocas_daily[[i]]$case = df_names$file_list[df_names$number == i]
  }
  
  rm(df_names)
  
  trocas_graph_daily = do.call(rbind.data.frame, trocas_daily)
  
  write.csv(trocas_graph_daily, paste0("daily_",temp,"_",cidade,"_",zone,".csv"))
  
  temp = "min"
  
  for(i in seq_along(trocas)) {
    df_manipulate = trocas[[i]]
    trocas_daily[[i]] = df.graph.daily.convection(df_manipulate,cidade, temp) ## ano todo
  }
  rm(df_manipulate)
  
  df_names = data.frame(file_list)
  df_names$number = as.character(c(1:length(file_list)))
  
  
  for(i in c(1:length(trocas))){
    trocas_daily[[i]]$case = df_names$file_list[df_names$number == i]
  }
  
  rm(df_names)
  
  trocas_graph_daily = do.call(rbind.data.frame, trocas_daily)
  
  write.csv(trocas_graph_daily, paste0("daily_",temp,"_",cidade,"_",zone,".csv"))
  
}else{NA}