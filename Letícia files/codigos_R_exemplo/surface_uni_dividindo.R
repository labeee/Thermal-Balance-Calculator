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
  ##opaque surfaces outputs
  #none_roof
  df_thermal_balance$none_roof_convection = (sumcols(df,none_roof, '.Surface.Inside.Face.Convection.Heat.'))
  df_thermal_balance$none_roof_conduction = (sumcols(df,none_roof, '.Surface.Inside.Face.Conduction.Heat.Transfer'))
  df_thermal_balance$none_roof_solarrad = (sumcols(df,none_roof, '.Surface.Inside.Face.Solar.Radiation.Heat'))
  df_thermal_balance$none_roof_swlights = (sumcols(df,none_roof, '.Surface.Inside.Face.Lights.Radiation.Heat.'))
  df_thermal_balance$none_roof_lwinternal = (sumcols(df,none_roof, '.Surface.Inside.Face.Internal.Gains.Radiation'))
  df_thermal_balance$none_roof_lwsurfaces = (sumcols(df,none_roof, '.Surface.Inside.Face.Net.Surface.Thermal.Radiation.Heat'))
  #none_floor
  df_thermal_balance$none_floor_convection = (sumcols(df,none_floor, '.Surface.Inside.Face.Convection.Heat.'))
  df_thermal_balance$none_floor_conduction = (sumcols(df,none_floor, '.Surface.Inside.Face.Conduction.Heat.Transfer'))
  df_thermal_balance$none_floor_solarrad = (sumcols(df,none_floor, '.Surface.Inside.Face.Solar.Radiation.Heat'))
  df_thermal_balance$none_floor_swlights = (sumcols(df,none_floor, '.Surface.Inside.Face.Lights.Radiation.Heat.'))
  df_thermal_balance$none_floor_lwinternal = (sumcols(df,none_floor, '.Surface.Inside.Face.Internal.Gains.Radiation'))
  df_thermal_balance$none_floor_lwsurfaces = (sumcols(df,none_floor, '.Surface.Inside.Face.Net.Surface.Thermal.Radiation.Heat'))
  #internal walls
  if(length(none_intwalls) >= 1){
    df_thermal_balance$none_intwalls_convection = (sumcols(df,none_intwalls, '.Surface.Inside.Face.Convection.Heat.'))
    df_thermal_balance$none_intwalls_conduction = (sumcols(df,none_intwalls, '.Surface.Inside.Face.Conduction.Heat.Transfer'))
    df_thermal_balance$none_intwalls_solarrad = (sumcols(df,none_intwalls, '.Surface.Inside.Face.Solar.Radiation.Heat'))
    df_thermal_balance$none_intwalls_swlights = (sumcols(df,none_intwalls, '.Surface.Inside.Face.Lights.Radiation.Heat.'))
    df_thermal_balance$none_intwalls_lwinternal = (sumcols(df,none_intwalls, '.Surface.Inside.Face.Internal.Gains.Radiation'))
    df_thermal_balance$none_intwalls_lwsurfaces = (sumcols(df,none_intwalls, '.Surface.Inside.Face.Net.Surface.Thermal.Radiation.Heat'))
  }else{NA}
  if(length(bwc_intwalls) >= 1){
    df_thermal_balance$bwc_intwalls_convection = (sumcols(df,bwc_intwalls, '.Surface.Inside.Face.Convection.Heat.'))
    df_thermal_balance$bwc_intwalls_conduction = (sumcols(df,bwc_intwalls, '.Surface.Inside.Face.Conduction.Heat.Transfer'))
    df_thermal_balance$bwc_intwalls_solarrad = (sumcols(df,bwc_intwalls, '.Surface.Inside.Face.Solar.Radiation.Heat'))
    df_thermal_balance$bwc_intwalls_swlights = (sumcols(df,bwc_intwalls, '.Surface.Inside.Face.Lights.Radiation.Heat.'))
    df_thermal_balance$bwc_intwalls_lwinternal = (sumcols(df,bwc_intwalls, '.Surface.Inside.Face.Internal.Gains.Radiation'))
    df_thermal_balance$bwc_intwalls_lwsurfaces = (sumcols(df,bwc_intwalls, '.Surface.Inside.Face.Net.Surface.Thermal.Radiation.Heat'))
  }else{NA}
  if(length(dorm1_intwalls) >= 1){
    df_thermal_balance$dorm1_intwalls_convection = (sumcols(df,dorm1_intwalls, '.Surface.Inside.Face.Convection.Heat.'))
    df_thermal_balance$dorm1_intwalls_conduction = (sumcols(df,dorm1_intwalls, '.Surface.Inside.Face.Conduction.Heat.Transfer'))
    df_thermal_balance$dorm1_intwalls_solarrad = (sumcols(df,dorm1_intwalls, '.Surface.Inside.Face.Solar.Radiation.Heat'))
    df_thermal_balance$dorm1_intwalls_swlights = (sumcols(df,dorm1_intwalls, '.Surface.Inside.Face.Lights.Radiation.Heat.'))
    df_thermal_balance$dorm1_intwalls_lwinternal = (sumcols(df,dorm1_intwalls, '.Surface.Inside.Face.Internal.Gains.Radiation'))
    df_thermal_balance$dorm1_intwalls_lwsurfaces = (sumcols(df,dorm1_intwalls, '.Surface.Inside.Face.Net.Surface.Thermal.Radiation.Heat'))
  }else{NA}
  if(length(dorm2_intwalls) >= 1){
    df_thermal_balance$dorm2_intwalls_convection = (sumcols(df,dorm2_intwalls, '.Surface.Inside.Face.Convection.Heat.'))
    df_thermal_balance$dorm2_intwalls_conduction = (sumcols(df,dorm2_intwalls, '.Surface.Inside.Face.Conduction.Heat.Transfer'))
    df_thermal_balance$dorm2_intwalls_solarrad = (sumcols(df,dorm2_intwalls, '.Surface.Inside.Face.Solar.Radiation.Heat'))
    df_thermal_balance$dorm2_intwalls_swlights = (sumcols(df,dorm2_intwalls, '.Surface.Inside.Face.Lights.Radiation.Heat.'))
    df_thermal_balance$dorm2_intwalls_lwinternal = (sumcols(df,dorm2_intwalls, '.Surface.Inside.Face.Internal.Gains.Radiation'))
    df_thermal_balance$dorm2_intwalls_lwsurfaces = (sumcols(df,dorm2_intwalls, '.Surface.Inside.Face.Net.Surface.Thermal.Radiation.Heat'))
  }else{NA}
  if(length(sala_intwalls) >= 1){
    df_thermal_balance$sala_intwalls_convection = (sumcols(df,sala_intwalls, '.Surface.Inside.Face.Convection.Heat.'))
    df_thermal_balance$sala_intwalls_conduction = (sumcols(df,sala_intwalls, '.Surface.Inside.Face.Conduction.Heat.Transfer'))
    df_thermal_balance$sala_intwalls_solarrad = (sumcols(df,sala_intwalls, '.Surface.Inside.Face.Solar.Radiation.Heat'))
    df_thermal_balance$sala_intwalls_swlights = (sumcols(df,sala_intwalls, '.Surface.Inside.Face.Lights.Radiation.Heat.'))
    df_thermal_balance$sala_intwalls_lwinternal = (sumcols(df,sala_intwalls, '.Surface.Inside.Face.Internal.Gains.Radiation'))
    df_thermal_balance$sala_intwalls_lwsurfaces = (sumcols(df,sala_intwalls, '.Surface.Inside.Face.Net.Surface.Thermal.Radiation.Heat'))
  }else{NA}
  #internal doors
  if(length(none_intdoors) >= 1){
    df_thermal_balance$none_intdoors_convection = (sumcols(df,none_intdoors, '.Surface.Inside.Face.Convection.Heat.'))
    df_thermal_balance$none_intdoors_conduction = (sumcols(df,none_intdoors, '.Surface.Inside.Face.Conduction.Heat.Transfer'))
    df_thermal_balance$none_intdoors_solarrad = (sumcols(df,none_intdoors, '.Surface.Inside.Face.Solar.Radiation.Heat'))
    df_thermal_balance$none_intdoors_swlights = (sumcols(df,none_intdoors, '.Surface.Inside.Face.Lights.Radiation.Heat.'))
    df_thermal_balance$none_intdoors_lwinternal = (sumcols(df,none_intdoors, '.Surface.Inside.Face.Internal.Gains.Radiation'))
    df_thermal_balance$none_intdoors_lwsurfaces = (sumcols(df,none_intdoors, '.Surface.Inside.Face.Net.Surface.Thermal.Radiation.Heat'))
  }else{NA}
  if(length(bwc_intdoors) >= 1){
    df_thermal_balance$bwc_intdoors_convection = (sumcols(df,bwc_intdoors, '.Surface.Inside.Face.Convection.Heat.'))
    df_thermal_balance$bwc_intdoors_conduction = (sumcols(df,bwc_intdoors, '.Surface.Inside.Face.Conduction.Heat.Transfer'))
    df_thermal_balance$bwc_intdoors_solarrad = (sumcols(df,bwc_intdoors, '.Surface.Inside.Face.Solar.Radiation.Heat'))
    df_thermal_balance$bwc_intdoors_swlights = (sumcols(df,bwc_intdoors, '.Surface.Inside.Face.Lights.Radiation.Heat.'))
    df_thermal_balance$bwc_intdoors_lwinternal = (sumcols(df,bwc_intdoors, '.Surface.Inside.Face.Internal.Gains.Radiation'))
    df_thermal_balance$bwc_intdoors_lwsurfaces = (sumcols(df,bwc_intdoors, '.Surface.Inside.Face.Net.Surface.Thermal.Radiation.Heat'))
  }else{NA}
  if(length(dorm1_intdoors) >= 1){
    df_thermal_balance$dorm1_intdoors_convection = (sumcols(df,dorm1_intdoors, '.Surface.Inside.Face.Convection.Heat.'))
    df_thermal_balance$dorm1_intdoors_conduction = (sumcols(df,dorm1_intdoors, '.Surface.Inside.Face.Conduction.Heat.Transfer'))
    df_thermal_balance$dorm1_intdoors_solarrad = (sumcols(df,dorm1_intdoors, '.Surface.Inside.Face.Solar.Radiation.Heat'))
    df_thermal_balance$dorm1_intdoors_swlights = (sumcols(df,dorm1_intdoors, '.Surface.Inside.Face.Lights.Radiation.Heat.'))
    df_thermal_balance$dorm1_intdoors_lwinternal = (sumcols(df,dorm1_intdoors, '.Surface.Inside.Face.Internal.Gains.Radiation'))
    df_thermal_balance$dorm1_intdoors_lwsurfaces = (sumcols(df,dorm1_intdoors, '.Surface.Inside.Face.Net.Surface.Thermal.Radiation.Heat'))
  }else{NA}
  if(length(dorm2_intdoors) >= 1){
    df_thermal_balance$dorm2_intdoors_convection = (sumcols(df,dorm2_intdoors, '.Surface.Inside.Face.Convection.Heat.'))
    df_thermal_balance$dorm2_intdoors_conduction = (sumcols(df,dorm2_intdoors, '.Surface.Inside.Face.Conduction.Heat.Transfer'))
    df_thermal_balance$dorm2_intdoors_solarrad = (sumcols(df,dorm2_intdoors, '.Surface.Inside.Face.Solar.Radiation.Heat'))
    df_thermal_balance$dorm2_intdoors_swlights = (sumcols(df,dorm2_intdoors, '.Surface.Inside.Face.Lights.Radiation.Heat.'))
    df_thermal_balance$dorm2_intdoors_lwinternal = (sumcols(df,dorm2_intdoors, '.Surface.Inside.Face.Internal.Gains.Radiation'))
    df_thermal_balance$dorm2_intdoors_lwsurfaces = (sumcols(df,dorm2_intdoors, '.Surface.Inside.Face.Net.Surface.Thermal.Radiation.Heat'))
  }else{NA}
  if(length(sala_intdoors) >= 1){
    df_thermal_balance$sala_intdoors_convection = (sumcols(df,sala_intdoors, '.Surface.Inside.Face.Convection.Heat.'))
    df_thermal_balance$sala_intdoors_conduction = (sumcols(df,sala_intdoors, '.Surface.Inside.Face.Conduction.Heat.Transfer'))
    df_thermal_balance$sala_intdoors_solarrad = (sumcols(df,sala_intdoors, '.Surface.Inside.Face.Solar.Radiation.Heat'))
    df_thermal_balance$sala_intdoors_swlights = (sumcols(df,sala_intdoors, '.Surface.Inside.Face.Lights.Radiation.Heat.'))
    df_thermal_balance$sala_intdoors_lwinternal = (sumcols(df,sala_intdoors, '.Surface.Inside.Face.Internal.Gains.Radiation'))
    df_thermal_balance$sala_intdoors_lwsurfaces = (sumcols(df,sala_intdoors, '.Surface.Inside.Face.Net.Surface.Thermal.Radiation.Heat'))
  }else{NA}
  #external walls all orientations 
  if(length(none_extwalls) >= 1){
    df_thermal_balance$none_extwalls_convection = (sumcols(df,none_extwalls, '.Surface.Inside.Face.Convection.Heat.'))
    df_thermal_balance$none_extwalls_conduction = (sumcols(df,none_extwalls, '.Surface.Inside.Face.Conduction.Heat.Transfer'))
    df_thermal_balance$none_extwalls_solarrad = (sumcols(df,none_extwalls, '.Surface.Inside.Face.Solar.Radiation.Heat'))
    df_thermal_balance$none_extwalls_swlights = (sumcols(df,none_extwalls, '.Surface.Inside.Face.Lights.Radiation.Heat.'))
    df_thermal_balance$none_extwalls_lwinternal = (sumcols(df,none_extwalls, '.Surface.Inside.Face.Internal.Gains.Radiation'))
    df_thermal_balance$none_extwalls_lwsurfaces = (sumcols(df,none_extwalls, '.Surface.Inside.Face.Net.Surface.Thermal.Radiation.Heat'))
  }else{NA}
  #external walls
  if(length(south_extwalls) >= 1){
    df_thermal_balance$south_extwalls_convection = (sumcols(df,south_extwalls, '.Surface.Inside.Face.Convection.Heat.'))
    df_thermal_balance$south_extwalls_conduction = (sumcols(df,south_extwalls, '.Surface.Inside.Face.Conduction.Heat.Transfer'))
    df_thermal_balance$south_extwalls_solarrad = (sumcols(df,south_extwalls, '.Surface.Inside.Face.Solar.Radiation.Heat'))
    df_thermal_balance$south_extwalls_swlights = (sumcols(df,south_extwalls, '.Surface.Inside.Face.Lights.Radiation.Heat.'))
    df_thermal_balance$south_extwalls_lwinternal = (sumcols(df,south_extwalls, '.Surface.Inside.Face.Internal.Gains.Radiation'))
    df_thermal_balance$south_extwalls_lwsurfaces = (sumcols(df,south_extwalls, '.Surface.Inside.Face.Net.Surface.Thermal.Radiation.Heat'))
  }else{NA}
  if(length(north_extwalls) >= 1){
    df_thermal_balance$north_extwalls_convection = (sumcols(df,north_extwalls, '.Surface.Inside.Face.Convection.Heat.'))
    df_thermal_balance$north_extwalls_conduction = (sumcols(df,north_extwalls, '.Surface.Inside.Face.Conduction.Heat.Transfer'))
    df_thermal_balance$north_extwalls_solarrad = (sumcols(df,north_extwalls, '.Surface.Inside.Face.Solar.Radiation.Heat'))
    df_thermal_balance$north_extwalls_swlights = (sumcols(df,north_extwalls, '.Surface.Inside.Face.Lights.Radiation.Heat.'))
    df_thermal_balance$north_extwalls_lwinternal = (sumcols(df,north_extwalls, '.Surface.Inside.Face.Internal.Gains.Radiation'))
    df_thermal_balance$north_extwalls_lwsurfaces = (sumcols(df,north_extwalls, '.Surface.Inside.Face.Net.Surface.Thermal.Radiation.Heat'))
  }else{NA}
  if(length(west_extwalls) >= 1){
    df_thermal_balance$west_extwalls_convection = (sumcols(df,west_extwalls, '.Surface.Inside.Face.Convection.Heat.'))
    df_thermal_balance$west_extwalls_conduction = (sumcols(df,west_extwalls, '.Surface.Inside.Face.Conduction.Heat.Transfer'))
    df_thermal_balance$west_extwalls_solarrad = (sumcols(df,west_extwalls, '.Surface.Inside.Face.Solar.Radiation.Heat'))
    df_thermal_balance$west_extwalls_swlights = (sumcols(df,west_extwalls, '.Surface.Inside.Face.Lights.Radiation.Heat.'))
    df_thermal_balance$west_extwalls_lwinternal = (sumcols(df,west_extwalls, '.Surface.Inside.Face.Internal.Gains.Radiation'))
    df_thermal_balance$west_extwalls_lwsurfaces = (sumcols(df,west_extwalls, '.Surface.Inside.Face.Net.Surface.Thermal.Radiation.Heat'))
  }else{NA}
  if(length(east_extwalls) >= 1){
    df_thermal_balance$east_extwalls_convection = (sumcols(df,east_extwalls, '.Surface.Inside.Face.Convection.Heat.'))
    df_thermal_balance$east_extwalls_conduction = (sumcols(df,east_extwalls, '.Surface.Inside.Face.Conduction.Heat.Transfer'))
    df_thermal_balance$east_extwalls_solarrad = (sumcols(df,east_extwalls, '.Surface.Inside.Face.Solar.Radiation.Heat'))
    df_thermal_balance$east_extwalls_swlights = (sumcols(df,east_extwalls, '.Surface.Inside.Face.Lights.Radiation.Heat.'))
    df_thermal_balance$east_extwalls_lwinternal = (sumcols(df,east_extwalls, '.Surface.Inside.Face.Internal.Gains.Radiation'))
    df_thermal_balance$east_extwalls_lwsurfaces = (sumcols(df,east_extwalls, '.Surface.Inside.Face.Net.Surface.Thermal.Radiation.Heat'))
  }else{NA}
  #external doors
  if(length(south_extdoors) >= 1){
    df_thermal_balance$south_extdoors_convection = (sumcols(df,south_extdoors, '.Surface.Inside.Face.Convection.Heat.'))
    df_thermal_balance$south_extdoors_conduction = (sumcols(df,south_extdoors, '.Surface.Inside.Face.Conduction.Heat.Transfer'))
    df_thermal_balance$south_extdoors_solarrad = (sumcols(df,south_extdoors, '.Surface.Inside.Face.Solar.Radiation.Heat'))
    df_thermal_balance$south_extdoors_swlights = (sumcols(df,south_extdoors, '.Surface.Inside.Face.Lights.Radiation.Heat.'))
    df_thermal_balance$south_extdoors_lwinternal = (sumcols(df,south_extdoors, '.Surface.Inside.Face.Internal.Gains.Radiation'))
    df_thermal_balance$south_extdoors_lwsurfaces = (sumcols(df,south_extdoors, '.Surface.Inside.Face.Net.Surface.Thermal.Radiation.Heat'))
  }else{NA}
  if(length(north_extdoors) >= 1){
    df_thermal_balance$north_extdoors_convection = (sumcols(df,north_extdoors, '.Surface.Inside.Face.Convection.Heat.'))
    df_thermal_balance$north_extdoors_conduction = (sumcols(df,north_extdoors, '.Surface.Inside.Face.Conduction.Heat.Transfer'))
    df_thermal_balance$north_extdoors_solarrad = (sumcols(df,north_extdoors, '.Surface.Inside.Face.Solar.Radiation.Heat'))
    df_thermal_balance$north_extdoors_swlights = (sumcols(df,north_extdoors, '.Surface.Inside.Face.Lights.Radiation.Heat.'))
    df_thermal_balance$north_extdoors_lwinternal = (sumcols(df,north_extdoors, '.Surface.Inside.Face.Internal.Gains.Radiation'))
    df_thermal_balance$north_extdoors_lwsurfaces = (sumcols(df,north_extdoors, '.Surface.Inside.Face.Net.Surface.Thermal.Radiation.Heat'))
  }else{NA}
  if(length(west_extdoors) >= 1){
    df_thermal_balance$west_extdoors_convection = (sumcols(df,west_extdoors, '.Surface.Inside.Face.Convection.Heat.'))
    df_thermal_balance$west_extdoors_conduction = (sumcols(df,west_extdoors, '.Surface.Inside.Face.Conduction.Heat.Transfer'))
    df_thermal_balance$west_extdoors_solarrad = (sumcols(df,west_extdoors, '.Surface.Inside.Face.Solar.Radiation.Heat'))
    df_thermal_balance$west_extdoors_swlights = (sumcols(df,west_extdoors, '.Surface.Inside.Face.Lights.Radiation.Heat.'))
    df_thermal_balance$west_extdoors_lwinternal = (sumcols(df,west_extdoors, '.Surface.Inside.Face.Internal.Gains.Radiation'))
    df_thermal_balance$west_extdoors_lwsurfaces = (sumcols(df,west_extdoors, '.Surface.Inside.Face.Net.Surface.Thermal.Radiation.Heat'))
  }else{NA}
  if(length(east_extdoors) >= 1){
    df_thermal_balance$east_extdoors_convection = (sumcols(df,east_extdoors, '.Surface.Inside.Face.Convection.Heat.'))
    df_thermal_balance$east_extdoors_conduction = (sumcols(df,east_extdoors, '.Surface.Inside.Face.Conduction.Heat.Transfer'))
    df_thermal_balance$east_extdoors_solarrad = (sumcols(df,east_extdoors, '.Surface.Inside.Face.Solar.Radiation.Heat'))
    df_thermal_balance$east_extdoors_swlights = (sumcols(df,east_extdoors, '.Surface.Inside.Face.Lights.Radiation.Heat.'))
    df_thermal_balance$east_extdoors_lwinternal = (sumcols(df,east_extdoors, '.Surface.Inside.Face.Internal.Gains.Radiation'))
    df_thermal_balance$east_extdoors_lwsurfaces = (sumcols(df,east_extdoors, '.Surface.Inside.Face.Net.Surface.Thermal.Radiation.Heat'))
  }else{NA}
  ##windows outputs all orientations
  # if(length(none_windows) >= 1){
  #   df_thermal_balance$none_windows_convection = (sumcols(df,none_windows, '.Surface.Inside.Face.Convection.Heat.'))
  #   df_thermal_balance$none_windows_lwsurfaces = (sumcols(df,none_windows, '.Surface.Inside.Face.Net.Surface.Thermal.Radiation.Heat'))
  # }else{NA}
  # ##windows outputs 
  # if(length(south_windows) >= 1){
  #   df_thermal_balance$south_windows_convection = (sumcols(df,south_windows, '.Surface.Inside.Face.Convection.Heat.'))
  #   df_thermal_balance$south_windows_lwsurfaces = (sumcols(df,south_windows, '.Surface.Inside.Face.Net.Surface.Thermal.Radiation.Heat'))
  # }else{NA}
  # if(length(north_windows) >= 1){
  #   df_thermal_balance$north_windows_convection = (sumcols(df,north_windows, '.Surface.Inside.Face.Convection.Heat.'))
  #   df_thermal_balance$north_windows_lwsurfaces = (sumcols(df,north_windows, '.Surface.Inside.Face.Net.Surface.Thermal.Radiation.Heat'))
  # }else{NA}
  # if(length(west_windows) >= 1){
  #   df_thermal_balance$west_windows_convection = (sumcols(df,west_windows, '.Surface.Inside.Face.Convection.Heat.'))
  #   df_thermal_balance$west_windows_lwsurfaces = (sumcols(df,west_windows, '.Surface.Inside.Face.Net.Surface.Thermal.Radiation.Heat'))
  # }else{NA}
  # if(length(east_windows) >= 1){
  #   df_thermal_balance$east_windows_convection = (sumcols(df,east_windows, '.Surface.Inside.Face.Convection.Heat.'))
  #   df_thermal_balance$east_windows_lwsurfaces = (sumcols(df,east_windows, '.Surface.Inside.Face.Net.Surface.Thermal.Radiation.Heat'))
  # }else{NA}
  
  return(df_thermal_balance)
  
}

df.graph.annual.convection = function(df_manipulate){
  
  df_convection = data.frame(df_manipulate[,grepl(('convection'),colnames(df_manipulate))])
  
  df_conduction = data.frame(df_manipulate[,grepl(('conduction'),colnames(df_manipulate))])
  
  df_solarrad = data.frame(df_manipulate[,grepl(('solarrad'),colnames(df_manipulate))])
  
  df_swlights = data.frame(df_manipulate[,grepl(('swlights'),colnames(df_manipulate))])
  
  df_lwinternal = data.frame(df_manipulate[,grepl(('lwinternal'),colnames(df_manipulate))])
  
  df_lwsurfaces = data.frame(df_manipulate[,grepl(('lwsurfaces'),colnames(df_manipulate))])
  
  ##convection
  
  gains_losses = c(colnames(df_convection)) #para o AC
  
  df_graph_gain = data.frame(gains_losses = gains_losses, value = c(1:1))
  
  df_graph_loss = data.frame(gains_losses = gains_losses, value = c(1:1))
  
  for(k in gains_losses){
    for(i in 1:nrow(df_convection)){
      df_graph_gain$value[df_graph_gain$gains_losses == k] = sum(df_convection[,k][which(df_convection[,k] >= 0)])
      df_graph_loss$value[df_graph_loss$gains_losses == k] = sum(df_convection[,k][which(df_convection[,k] < 0)])
    }
  }
  
  df_graph_gain$gains_losses = paste0(df_graph_gain$gains_losses,"_gain")
  df_graph_loss$gains_losses = paste0(df_graph_loss$gains_losses,"_loss")
  
  df_graph_convection = rbind(df_graph_gain, df_graph_loss)
  
  df_graph_convection$flux = "Convection"
  
  ##conduction
  
  gains_losses = c(colnames(df_conduction)) #para o AC
  
  df_graph_gain = data.frame(gains_losses = gains_losses, value = c(1:1))
  
  df_graph_loss = data.frame(gains_losses = gains_losses, value = c(1:1))
  
  for(k in gains_losses){
    for(i in 1:nrow(df_conduction)){
      df_graph_gain$value[df_graph_gain$gains_losses == k] = sum(df_conduction[,k][which(df_conduction[,k] >= 0)])
      df_graph_loss$value[df_graph_loss$gains_losses == k] = sum(df_conduction[,k][which(df_conduction[,k] < 0)])
    }
  }
  
  df_graph_gain$gains_losses = paste0(df_graph_gain$gains_losses,"_gain")
  df_graph_loss$gains_losses = paste0(df_graph_loss$gains_losses,"_loss")
  
  df_graph_conduction = rbind(df_graph_gain, df_graph_loss)
  
  df_graph_conduction$flux = "Conduction"
  
  ##solarrad
  
  gains_losses = c(colnames(df_solarrad)) #para o AC
  
  df_graph_gain = data.frame(gains_losses = gains_losses, value = c(1:1))
  
  df_graph_loss = data.frame(gains_losses = gains_losses, value = c(1:1))
  
  for(k in gains_losses){
    for(i in 1:nrow(df_solarrad)){
      df_graph_gain$value[df_graph_gain$gains_losses == k] = sum(df_solarrad[,k][which(df_solarrad[,k] >= 0)])
      df_graph_loss$value[df_graph_loss$gains_losses == k] = sum(df_solarrad[,k][which(df_solarrad[,k] < 0)])
    }
  }
  
  df_graph_gain$gains_losses = paste0(df_graph_gain$gains_losses,"_gain")
  df_graph_loss$gains_losses = paste0(df_graph_loss$gains_losses,"_loss")
  
  df_graph_solarrad = rbind(df_graph_gain, df_graph_loss)
  
  df_graph_solarrad$flux = "Solar Rad."
  
  ##swlights
  
  gains_losses = c(colnames(df_swlights)) #para o AC
  
  df_graph_gain = data.frame(gains_losses = gains_losses, value = c(1:1))
  
  df_graph_loss = data.frame(gains_losses = gains_losses, value = c(1:1))
  
  for(k in gains_losses){
    for(i in 1:nrow(df_swlights)){
      df_graph_gain$value[df_graph_gain$gains_losses == k] = sum(df_swlights[,k][which(df_swlights[,k] >= 0)])
      df_graph_loss$value[df_graph_loss$gains_losses == k] = sum(df_swlights[,k][which(df_swlights[,k] < 0)])
    }
  }
  
  df_graph_gain$gains_losses = paste0(df_graph_gain$gains_losses,"_gain")
  df_graph_loss$gains_losses = paste0(df_graph_loss$gains_losses,"_loss")
  
  df_graph_swlights = rbind(df_graph_gain, df_graph_loss)
  
  df_graph_swlights$flux = "SW. Lights"
  
  ##lwinternal
  
  gains_losses = c(colnames(df_lwinternal)) #para o AC
  
  df_graph_gain = data.frame(gains_losses = gains_losses, value = c(1:1))
  
  df_graph_loss = data.frame(gains_losses = gains_losses, value = c(1:1))
  
  for(k in gains_losses){
    for(i in 1:nrow(df_lwinternal)){
      df_graph_gain$value[df_graph_gain$gains_losses == k] = sum(df_lwinternal[,k][which(df_lwinternal[,k] >= 0)])
      df_graph_loss$value[df_graph_loss$gains_losses == k] = sum(df_lwinternal[,k][which(df_lwinternal[,k] < 0)])
    }
  }
  
  df_graph_gain$gains_losses = paste0(df_graph_gain$gains_losses,"_gain")
  df_graph_loss$gains_losses = paste0(df_graph_loss$gains_losses,"_loss")
  
  df_graph_lwinternal = rbind(df_graph_gain, df_graph_loss)
  
  df_graph_lwinternal$flux = "LW. Internal"
  
  ##lwsurfaces
  
  gains_losses = c(colnames(df_lwsurfaces)) #para o AC
  
  df_graph_gain = data.frame(gains_losses = gains_losses, value = c(1:1))
  
  df_graph_loss = data.frame(gains_losses = gains_losses, value = c(1:1))
  
  for(k in gains_losses){
    for(i in 1:nrow(df_lwsurfaces)){
      df_graph_gain$value[df_graph_gain$gains_losses == k] = sum(df_lwsurfaces[,k][which(df_lwsurfaces[,k] >= 0)])
      df_graph_loss$value[df_graph_loss$gains_losses == k] = sum(df_lwsurfaces[,k][which(df_lwsurfaces[,k] < 0)])
    }
  }
  
  df_graph_gain$gains_losses = paste0(df_graph_gain$gains_losses,"_gain")
  df_graph_loss$gains_losses = paste0(df_graph_loss$gains_losses,"_loss")
  
  df_graph_lwsurfaces = rbind(df_graph_gain, df_graph_loss)
  
  df_graph_lwsurfaces$flux = "LW. Surfaces"
  
  df_graph = rbind(df_graph_convection, df_graph_conduction, df_graph_solarrad, df_graph_swlights,df_graph_lwinternal, df_graph_lwsurfaces)
  
  return(df_graph)
  
}

df.graph.monthly.convection = function(df_manipulate){
  
  df_convection = data.frame(subset(df_manipulate, select = c(date_time, month, day)), 
                             df_manipulate[,grepl(('convection'),colnames(df_manipulate))])
  
  df_conduction = data.frame(subset(df_manipulate, select = c(date_time, month, day)), 
                             df_manipulate[,grepl(('conduction'),colnames(df_manipulate))])
  
  df_solarrad = data.frame(subset(df_manipulate, select = c(date_time, month, day)), 
                           df_manipulate[,grepl(('solarrad'),colnames(df_manipulate))])
  
  df_swlights = data.frame(subset(df_manipulate, select = c(date_time, month, day)), 
                           df_manipulate[,grepl(('swlights'),colnames(df_manipulate))])
  
  df_lwinternal = data.frame(subset(df_manipulate, select = c(date_time, month, day)), 
                             df_manipulate[,grepl(('lwinternal'),colnames(df_manipulate))])
  
  df_lwsurfaces = data.frame(subset(df_manipulate, select = c(date_time, month, day)), 
                             df_manipulate[,grepl(('lwsurfaces'),colnames(df_manipulate))])
  
  ##convection
  
  gains_losses = c(colnames(subset(df_convection, select = -c(date_time, month, day))))  #para o ac
  
  months = c(unique(df_convection$month))
  
  df_graph_gain = data.frame(month = rep(months, each = length(gains_losses)), gains_losses = gains_losses, value = c(1:1)) 
  df_graph_loss = data.frame(month = rep(months, each = length(gains_losses)), gains_losses = gains_losses, value = c(1:1))

  for(m in months){
    for(k in gains_losses){
      for(i in 1:nrow(df_convection)){
        df_graph_gain$value[df_graph_gain$gains_losses == k & df_graph_gain$month == m] = sum(df_convection[,k][df_convection$month == m][which(df_convection[,k][df_convection$month == m] >= 0)])
        df_graph_loss$value[df_graph_loss$gains_losses == k & df_graph_loss$month == m] = sum(df_convection[,k][df_convection$month == m][which(df_convection[,k][df_convection$month == m] < 0)])
      }
    }
  }
  
  df_graph_gain$gains_losses = paste0(df_graph_gain$gains_losses,"_gain")
  df_graph_loss$gains_losses = paste0(df_graph_loss$gains_losses,"_loss")
  
  df_graph_convection = rbind(df_graph_gain, df_graph_loss)
  
  df_graph_convection$flux = "Convection"
  
  ##conduction
  
  gains_losses = c(colnames(subset(df_conduction, select = -c(date_time, month, day))))  #para o ac
  
  months = c(unique(df_conduction$month))
  
  df_graph_gain = data.frame(month = rep(months, each = length(gains_losses)), gains_losses = gains_losses, value = c(1:1)) 
  df_graph_loss = data.frame(month = rep(months, each = length(gains_losses)), gains_losses = gains_losses, value = c(1:1))
  
  for(m in months){
    for(k in gains_losses){
      for(i in 1:nrow(df_conduction)){
        df_graph_gain$value[df_graph_gain$gains_losses == k & df_graph_gain$month == m] = sum(df_conduction[,k][df_conduction$month == m][which(df_conduction[,k][df_conduction$month == m] >= 0)])
        df_graph_loss$value[df_graph_loss$gains_losses == k & df_graph_loss$month == m] = sum(df_conduction[,k][df_conduction$month == m][which(df_conduction[,k][df_conduction$month == m] < 0)])
      }
    }
  }
  
  df_graph_gain$gains_losses = paste0(df_graph_gain$gains_losses,"_gain")
  df_graph_loss$gains_losses = paste0(df_graph_loss$gains_losses,"_loss")
  
  df_graph_conduction = rbind(df_graph_gain, df_graph_loss)
  
  df_graph_conduction$flux = "Conduction"
  
  ##solarrad
  
  gains_losses = c(colnames(subset(df_solarrad, select = -c(date_time, month, day))))  #para o ac
  
  months = c(unique(df_solarrad$month))
  
  df_graph_gain = data.frame(month = rep(months, each = length(gains_losses)), gains_losses = gains_losses, value = c(1:1)) 
  df_graph_loss = data.frame(month = rep(months, each = length(gains_losses)), gains_losses = gains_losses, value = c(1:1))
  
  for(m in months){
    for(k in gains_losses){
      for(i in 1:nrow(df_solarrad)){
        df_graph_gain$value[df_graph_gain$gains_losses == k & df_graph_gain$month == m] = sum(df_solarrad[,k][df_solarrad$month == m][which(df_solarrad[,k][df_solarrad$month == m] >= 0)])
        df_graph_loss$value[df_graph_loss$gains_losses == k & df_graph_loss$month == m] = sum(df_solarrad[,k][df_solarrad$month == m][which(df_solarrad[,k][df_solarrad$month == m] < 0)])
      }
    }
  }
  
  df_graph_gain$gains_losses = paste0(df_graph_gain$gains_losses,"_gain")
  df_graph_loss$gains_losses = paste0(df_graph_loss$gains_losses,"_loss")
  
  df_graph_solarrad = rbind(df_graph_gain, df_graph_loss)
  
  df_graph_solarrad$flux = "Solar Rad."
  
  ##swlights
  
  gains_losses = c(colnames(subset(df_swlights, select = -c(date_time, month, day))))  #para o ac
  
  months = c(unique(df_swlights$month))
  
  df_graph_gain = data.frame(month = rep(months, each = length(gains_losses)), gains_losses = gains_losses, value = c(1:1)) 
  df_graph_loss = data.frame(month = rep(months, each = length(gains_losses)), gains_losses = gains_losses, value = c(1:1))
  
  for(m in months){
    for(k in gains_losses){
      for(i in 1:nrow(df_swlights)){
        df_graph_gain$value[df_graph_gain$gains_losses == k & df_graph_gain$month == m] = sum(df_swlights[,k][df_swlights$month == m][which(df_swlights[,k][df_swlights$month == m] >= 0)])
        df_graph_loss$value[df_graph_loss$gains_losses == k & df_graph_loss$month == m] = sum(df_swlights[,k][df_swlights$month == m][which(df_swlights[,k][df_swlights$month == m] < 0)])
      }
    }
  }
  
  df_graph_gain$gains_losses = paste0(df_graph_gain$gains_losses,"_gain")
  df_graph_loss$gains_losses = paste0(df_graph_loss$gains_losses,"_loss")
  
  df_graph_swlights = rbind(df_graph_gain, df_graph_loss)
  
  df_graph_swlights$flux = "SW. Lights"
  
  ##lwinternal
  
  gains_losses = c(colnames(subset(df_lwinternal, select = -c(date_time, month, day))))  #para o ac
  
  months = c(unique(df_lwinternal$month))
  
  df_graph_gain = data.frame(month = rep(months, each = length(gains_losses)), gains_losses = gains_losses, value = c(1:1)) 
  df_graph_loss = data.frame(month = rep(months, each = length(gains_losses)), gains_losses = gains_losses, value = c(1:1))
  
  for(m in months){
    for(k in gains_losses){
      for(i in 1:nrow(df_lwinternal)){
        df_graph_gain$value[df_graph_gain$gains_losses == k & df_graph_gain$month == m] = sum(df_lwinternal[,k][df_lwinternal$month == m][which(df_lwinternal[,k][df_lwinternal$month == m] >= 0)])
        df_graph_loss$value[df_graph_loss$gains_losses == k & df_graph_loss$month == m] = sum(df_lwinternal[,k][df_lwinternal$month == m][which(df_lwinternal[,k][df_lwinternal$month == m] < 0)])
      }
    }
  }
  
  df_graph_gain$gains_losses = paste0(df_graph_gain$gains_losses,"_gain")
  df_graph_loss$gains_losses = paste0(df_graph_loss$gains_losses,"_loss")
  
  df_graph_lwinternal = rbind(df_graph_gain, df_graph_loss)
  
  df_graph_lwinternal$flux = "LW. Internal"
  
  ##lwsurfaces
  
  gains_losses = c(colnames(subset(df_lwsurfaces, select = -c(date_time, month, day))))  #para o ac
  
  months = c(unique(df_lwsurfaces$month))
  
  df_graph_gain = data.frame(month = rep(months, each = length(gains_losses)), gains_losses = gains_losses, value = c(1:1)) 
  df_graph_loss = data.frame(month = rep(months, each = length(gains_losses)), gains_losses = gains_losses, value = c(1:1))
  
  for(m in months){
    for(k in gains_losses){
      for(i in 1:nrow(df_lwsurfaces)){
        df_graph_gain$value[df_graph_gain$gains_losses == k & df_graph_gain$month == m] = sum(df_lwsurfaces[,k][df_lwsurfaces$month == m][which(df_lwsurfaces[,k][df_lwsurfaces$month == m] >= 0)])
        df_graph_loss$value[df_graph_loss$gains_losses == k & df_graph_loss$month == m] = sum(df_lwsurfaces[,k][df_lwsurfaces$month == m][which(df_lwsurfaces[,k][df_lwsurfaces$month == m] < 0)])
      }
    }
  }
  
  df_graph_gain$gains_losses = paste0(df_graph_gain$gains_losses,"_gain")
  df_graph_loss$gains_losses = paste0(df_graph_loss$gains_losses,"_loss")
  
  df_graph_lwsurfaces = rbind(df_graph_gain, df_graph_loss)
  
  df_graph_lwsurfaces$flux = "LW. Surfaces"
  
  df_graph = rbind(df_graph_convection, df_graph_conduction, df_graph_solarrad, df_graph_swlights,df_graph_lwinternal, df_graph_lwsurfaces)
  
  
  return(df_graph)
  
}

df.graph.daily.convection = function(df_manipulate,cidade, temp){  ##esse eu vou ter que adaptar para o AC e VN
  
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
  
  df_daily$time = as.numeric(substr(df_daily$date_time, 9,10))
  df_daily$time[df_daily$time == 0] = 24
  
  df_convection = data.frame(subset(df_daily, select = c(date_time, month, day, time)), 
                             df_daily[,grepl(('convection'),colnames(df_daily))])
  
  df_conduction = data.frame(subset(df_daily, select = c(date_time, month, day, time)), 
                             df_daily[,grepl(('conduction'),colnames(df_daily))])
  
  df_solarrad = data.frame(subset(df_daily, select = c(date_time, month, day, time)), 
                           df_daily[,grepl(('solarrad'),colnames(df_daily))])
  
  df_swlights = data.frame(subset(df_daily, select = c(date_time, month, day, time)), 
                           df_daily[,grepl(('swlights'),colnames(df_daily))])
  
  df_lwinternal = data.frame(subset(df_daily, select = c(date_time, month, day, time)), 
                             df_daily[,grepl(('lwinternal'),colnames(df_daily))])
  
  df_lwsurfaces = data.frame(subset(df_daily, select = c(date_time, month, day, time)), 
                             df_daily[,grepl(('lwsurfaces'),colnames(df_daily))])
  
  ##convection
  
  gains_losses = c(colnames(subset(df_convection, select = -c(date_time, month, day, time))))  #para o ac
  
  df_graph_gain = data.frame(date_graph = seq(ISOdate(2019,g,f,0,0,0),by='1 hour',length.out=2*24,tz=''),
                                     time = unique(df_convection$time),month = unique(df_convection$month),day=rep(unique(df_convection$day),each=24), 
                                     gains_losses = rep(gains_losses, each = 24*2), value = c(1:1))
  df_graph_loss = data.frame(date_graph = seq(ISOdate(2019,g,f,0,0,0),by='1 hour',length.out=2*24,tz=''),
                                     time = unique(df_convection$time),month = unique(df_convection$month),day=rep(unique(df_convection$day),each=24), 
                                     gains_losses = rep(gains_losses, each = 24*2), value = c(1:1))
  
  for(k in gains_losses){
    for(i in 1:nrow(df_convection)){
      for(n in unique(df_convection$time)){
        for(d in unique(df_convection$day)){
          df_graph_gain$value[df_graph_gain$gains_losses == k & df_graph_gain$time == n & df_graph_gain$day == d] = sum(df_convection[,k][df_convection$time == n & df_convection$day == d][which(df_convection[,k][df_convection$time == n & df_convection$day == d] >= 0)])
          df_graph_loss$value[df_graph_loss$gains_losses == k & df_graph_loss$time == n & df_graph_loss$day == d] = sum(df_convection[,k][df_convection$time == n & df_convection$day == d][which(df_convection[,k][df_convection$time == n & df_convection$day == d] < 0)])
        }
      }
    }
  }
  
  df_graph_gain$gains_losses = paste0(df_graph_gain$gains_losses,"_gain")
  df_graph_loss$gains_losses = paste0(df_graph_loss$gains_losses,"_loss")
  
  df_graph_convection = rbind(df_graph_gain, df_graph_loss)
  
  df_graph_convection$flux = "Convection"
  
  ##conduction
  
  gains_losses = c(colnames(subset(df_conduction, select = -c(date_time, month, day, time))))  #para o ac
  
  df_graph_gain = data.frame(date_graph = seq(ISOdate(2019,g,f,0,0,0),by='1 hour',length.out=2*24,tz=''),
                             time = unique(df_conduction$time),month = unique(df_conduction$month),day=rep(unique(df_conduction$day),each=24), 
                             gains_losses = rep(gains_losses, each = 24*2), value = c(1:1))
  df_graph_loss = data.frame(date_graph = seq(ISOdate(2019,g,f,0,0,0),by='1 hour',length.out=2*24,tz=''),
                             time = unique(df_conduction$time),month = unique(df_conduction$month),day=rep(unique(df_conduction$day),each=24), 
                             gains_losses = rep(gains_losses, each = 24*2), value = c(1:1))
  
  for(k in gains_losses){
    for(i in 1:nrow(df_conduction)){
      for(n in unique(df_conduction$time)){
        for(d in unique(df_conduction$day)){
          df_graph_gain$value[df_graph_gain$gains_losses == k & df_graph_gain$time == n & df_graph_gain$day == d] = sum(df_conduction[,k][df_conduction$time == n & df_conduction$day == d][which(df_conduction[,k][df_conduction$time == n & df_conduction$day == d] >= 0)])
          df_graph_loss$value[df_graph_loss$gains_losses == k & df_graph_loss$time == n & df_graph_loss$day == d] = sum(df_conduction[,k][df_conduction$time == n & df_conduction$day == d][which(df_conduction[,k][df_conduction$time == n & df_conduction$day == d] < 0)])
        }
      }
    }
  }
  
  df_graph_gain$gains_losses = paste0(df_graph_gain$gains_losses,"_gain")
  df_graph_loss$gains_losses = paste0(df_graph_loss$gains_losses,"_loss")
  
  df_graph_conduction = rbind(df_graph_gain, df_graph_loss)
  
  df_graph_conduction$flux = "Conduction"
  
  ##solarrad
  
  gains_losses = c(colnames(subset(df_solarrad, select = -c(date_time, month, day, time))))  #para o ac
  
  df_graph_gain = data.frame(date_graph = seq(ISOdate(2019,g,f,0,0,0),by='1 hour',length.out=2*24,tz=''),
                             time = unique(df_solarrad$time),month = unique(df_solarrad$month),day=rep(unique(df_solarrad$day),each=24), 
                             gains_losses = rep(gains_losses, each = 24*2), value = c(1:1))
  df_graph_loss = data.frame(date_graph = seq(ISOdate(2019,g,f,0,0,0),by='1 hour',length.out=2*24,tz=''),
                             time = unique(df_solarrad$time),month = unique(df_solarrad$month),day=rep(unique(df_solarrad$day),each=24), 
                             gains_losses = rep(gains_losses, each = 24*2), value = c(1:1))
  
  for(k in gains_losses){
    for(i in 1:nrow(df_solarrad)){
      for(n in unique(df_solarrad$time)){
        for(d in unique(df_solarrad$day)){
          df_graph_gain$value[df_graph_gain$gains_losses == k & df_graph_gain$time == n & df_graph_gain$day == d] = sum(df_solarrad[,k][df_solarrad$time == n & df_solarrad$day == d][which(df_solarrad[,k][df_solarrad$time == n & df_solarrad$day == d] >= 0)])
          df_graph_loss$value[df_graph_loss$gains_losses == k & df_graph_loss$time == n & df_graph_loss$day == d] = sum(df_solarrad[,k][df_solarrad$time == n & df_solarrad$day == d][which(df_solarrad[,k][df_solarrad$time == n & df_solarrad$day == d] < 0)])
        }
      }
    }
  }
  
  df_graph_gain$gains_losses = paste0(df_graph_gain$gains_losses,"_gain")
  df_graph_loss$gains_losses = paste0(df_graph_loss$gains_losses,"_loss")
  
  df_graph_solarrad = rbind(df_graph_gain, df_graph_loss)
  
  df_graph_solarrad$flux = "Solar Rad."
  
  ##swlights
  
  gains_losses = c(colnames(subset(df_swlights, select = -c(date_time, month, day, time))))  #para o ac
  
  df_graph_gain = data.frame(date_graph = seq(ISOdate(2019,g,f,0,0,0),by='1 hour',length.out=2*24,tz=''),
                             time = unique(df_swlights$time),month = unique(df_swlights$month),day=rep(unique(df_swlights$day),each=24), 
                             gains_losses = rep(gains_losses, each = 24*2), value = c(1:1))
  df_graph_loss = data.frame(date_graph = seq(ISOdate(2019,g,f,0,0,0),by='1 hour',length.out=2*24,tz=''),
                             time = unique(df_swlights$time),month = unique(df_swlights$month),day=rep(unique(df_swlights$day),each=24), 
                             gains_losses = rep(gains_losses, each = 24*2), value = c(1:1))
  
  for(k in gains_losses){
    for(i in 1:nrow(df_swlights)){
      for(n in unique(df_swlights$time)){
        for(d in unique(df_swlights$day)){
          df_graph_gain$value[df_graph_gain$gains_losses == k & df_graph_gain$time == n & df_graph_gain$day == d] = sum(df_swlights[,k][df_swlights$time == n & df_swlights$day == d][which(df_swlights[,k][df_swlights$time == n & df_swlights$day == d] >= 0)])
          df_graph_loss$value[df_graph_loss$gains_losses == k & df_graph_loss$time == n & df_graph_loss$day == d] = sum(df_swlights[,k][df_swlights$time == n & df_swlights$day == d][which(df_swlights[,k][df_swlights$time == n & df_swlights$day == d] < 0)])
        }
      }
    }
  }
  
  df_graph_gain$gains_losses = paste0(df_graph_gain$gains_losses,"_gain")
  df_graph_loss$gains_losses = paste0(df_graph_loss$gains_losses,"_loss")
  
  df_graph_swlights = rbind(df_graph_gain, df_graph_loss)
  
  df_graph_swlights$flux = "SW. Lights"
  
  ##lwinternal
  
  gains_losses = c(colnames(subset(df_lwinternal, select = -c(date_time, month, day, time))))  #para o ac
  
  df_graph_gain = data.frame(date_graph = seq(ISOdate(2019,g,f,0,0,0),by='1 hour',length.out=2*24,tz=''),
                             time = unique(df_lwinternal$time),month = unique(df_lwinternal$month),day=rep(unique(df_lwinternal$day),each=24), 
                             gains_losses = rep(gains_losses, each = 24*2), value = c(1:1))
  df_graph_loss = data.frame(date_graph = seq(ISOdate(2019,g,f,0,0,0),by='1 hour',length.out=2*24,tz=''),
                             time = unique(df_lwinternal$time),month = unique(df_lwinternal$month),day=rep(unique(df_lwinternal$day),each=24), 
                             gains_losses = rep(gains_losses, each = 24*2), value = c(1:1))
  
  for(k in gains_losses){
    for(i in 1:nrow(df_lwinternal)){
      for(n in unique(df_lwinternal$time)){
        for(d in unique(df_lwinternal$day)){
          df_graph_gain$value[df_graph_gain$gains_losses == k & df_graph_gain$time == n & df_graph_gain$day == d] = sum(df_lwinternal[,k][df_lwinternal$time == n & df_lwinternal$day == d][which(df_lwinternal[,k][df_lwinternal$time == n & df_lwinternal$day == d] >= 0)])
          df_graph_loss$value[df_graph_loss$gains_losses == k & df_graph_loss$time == n & df_graph_loss$day == d] = sum(df_lwinternal[,k][df_lwinternal$time == n & df_lwinternal$day == d][which(df_lwinternal[,k][df_lwinternal$time == n & df_lwinternal$day == d] < 0)])
        }
      }
    }
  }
  
  df_graph_gain$gains_losses = paste0(df_graph_gain$gains_losses,"_gain")
  df_graph_loss$gains_losses = paste0(df_graph_loss$gains_losses,"_loss")
  
  df_graph_lwinternal = rbind(df_graph_gain, df_graph_loss)
  
  df_graph_lwinternal$flux = "LW. Internal"
  
  ##lwsurfaces
  
  gains_losses = c(colnames(subset(df_lwsurfaces, select = -c(date_time, month, day, time))))  #para o ac
  
  df_graph_gain = data.frame(date_graph = seq(ISOdate(2019,g,f,0,0,0),by='1 hour',length.out=2*24,tz=''),
                             time = unique(df_lwsurfaces$time),month = unique(df_lwsurfaces$month),day=rep(unique(df_lwsurfaces$day),each=24), 
                             gains_losses = rep(gains_losses, each = 24*2), value = c(1:1))
  df_graph_loss = data.frame(date_graph = seq(ISOdate(2019,g,f,0,0,0),by='1 hour',length.out=2*24,tz=''),
                             time = unique(df_lwsurfaces$time),month = unique(df_lwsurfaces$month),day=rep(unique(df_lwsurfaces$day),each=24), 
                             gains_losses = rep(gains_losses, each = 24*2), value = c(1:1))
  
  for(k in gains_losses){
    for(i in 1:nrow(df_lwsurfaces)){
      for(n in unique(df_lwsurfaces$time)){
        for(d in unique(df_lwsurfaces$day)){
          df_graph_gain$value[df_graph_gain$gains_losses == k & df_graph_gain$time == n & df_graph_gain$day == d] = sum(df_lwsurfaces[,k][df_lwsurfaces$time == n & df_lwsurfaces$day == d][which(df_lwsurfaces[,k][df_lwsurfaces$time == n & df_lwsurfaces$day == d] >= 0)])
          df_graph_loss$value[df_graph_loss$gains_losses == k & df_graph_loss$time == n & df_graph_loss$day == d] = sum(df_lwsurfaces[,k][df_lwsurfaces$time == n & df_lwsurfaces$day == d][which(df_lwsurfaces[,k][df_lwsurfaces$time == n & df_lwsurfaces$day == d] < 0)])
        }
      }
    }
  }
  
  df_graph_gain$gains_losses = paste0(df_graph_gain$gains_losses,"_gain")
  df_graph_loss$gains_losses = paste0(df_graph_loss$gains_losses,"_loss")
  
  df_graph_lwsurfaces = rbind(df_graph_gain, df_graph_loss)
  
  df_graph_lwsurfaces$flux = "LW. Surfaces"
  
  df_graph = rbind(df_graph_convection, df_graph_conduction, df_graph_solarrad, df_graph_swlights,df_graph_lwinternal, df_graph_lwsurfaces)
  
  return(df_graph)
  
}

##single-family house -----

epw = "BRA_PA_Belem.816800_TMYx.2007-2021"
cidade = "belem"
# 
# epw = "BRA_SP_Sao.Paulo-Congonhas.AP.837800_TMYx.2007-2021"
# cidade = "saopaulo"

setwd(paste0("D:/Frentes de Trabalho/simulacoes_tese/simulation/surface/reference/",epw,"/")) ##para a referencia no pc lab

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
# trocas_annual = list()
# trocas_monthly = list()
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
  # trocas_annual[[i]] = df.graph.annual.convection(df_manipulate)
  # trocas_monthly[[i]] = df.graph.monthly.convection(df_manipulate) ## ano todo
  trocas_daily[[i]] = df.graph.daily.convection(df_manipulate,cidade, temp) ## ano todo
}
rm(df_manipulate)

df_names = data.frame(file_list)
df_names$number = as.character(c(1:length(file_list)))


for(i in c(1:length(trocas))){
  # trocas_annual[[i]]$case = df_names$file_list[df_names$number == i]
  # trocas_monthly[[i]]$case = df_names$file_list[df_names$number == i]
  trocas_daily[[i]]$case = df_names$file_list[df_names$number == i]
}

rm(df_names)

trocas_graph_daily = do.call(rbind.data.frame, trocas_daily)
# trocas_graph_montlhy = do.call(rbind.data.frame, trocas_monthly)
# trocas_graph_annual = do.call(rbind.data.frame, trocas_annual)

# setwd(paste0("D:/Frentes de Trabalho/simulacoes_tese/simulation/convection/reference/resultados/")) ##para a referencia no pc lab
setwd(paste0("D:/Frentes de Trabalho/simulacoes_tese/simulation/surface/reference/resultados/dividindo_gain_loss")) ##para a referencia no pc lab

write.csv(trocas_graph_daily, paste0("daily_",temp,"_",cidade,"_",zone,".csv"))
# write.csv(trocas_graph_montlhy, paste0("monthly_",cidade,"_",zone,".csv"))
# write.csv(trocas_graph_annual, paste0("annual_",cidade,"_",zone,".csv"))

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

setwd(paste0("D:/Frentes de Trabalho/simulacoes_tese/simulation/surface/reference/",epw,"/")) ##para a referencia no pc lab

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
# trocas_annual = list()
# trocas_monthly = list()
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
  # trocas_annual[[i]] = df.graph.annual.convection(df_manipulate)
  # trocas_monthly[[i]] = df.graph.monthly.convection(df_manipulate) ## ano todo
  trocas_daily[[i]] = df.graph.daily.convection(df_manipulate,cidade,  temp) ## ano todo
}
rm(df_manipulate)

df_names = data.frame(file_list)
df_names$number = as.character(c(1:length(file_list)))


for(i in c(1:length(trocas))){
  # trocas_annual[[i]]$case = df_names$file_list[df_names$number == i]
  # trocas_monthly[[i]]$case = df_names$file_list[df_names$number == i]
  trocas_daily[[i]]$case = df_names$file_list[df_names$number == i]
}

rm(df_names)

trocas_graph_daily = do.call(rbind.data.frame, trocas_daily)
# trocas_graph_montlhy = do.call(rbind.data.frame, trocas_monthly)
# trocas_graph_annual = do.call(rbind.data.frame, trocas_annual)

# setwd(paste0("D:/Frentes de Trabalho/simulacoes_tese/simulation/convection/reference/resultados/")) ##para a referencia no pc lab
setwd(paste0("D:/Frentes de Trabalho/simulacoes_tese/simulation/surface/reference/resultados/dividindo_gain_loss")) ##para a referencia no pc lab

write.csv(trocas_graph_daily, paste0("daily_",temp,"_",cidade,"_",zone,".csv"))
# write.csv(trocas_graph_montlhy, paste0("monthly_",cidade,"_",zone,".csv"))
# write.csv(trocas_graph_annual, paste0("annual_",cidade,"_",zone,".csv"))

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

setwd(paste0("D:/Frentes de Trabalho/simulacoes_tese/simulation/surface/reference/",epw,"/")) ##para a referencia no pc lab

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
# trocas_annual = list()
# trocas_monthly = list()
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
  # trocas_annual[[i]] = df.graph.annual.convection(df_manipulate)
  # trocas_monthly[[i]] = df.graph.monthly.convection(df_manipulate) ## ano todo
  trocas_daily[[i]] = df.graph.daily.convection(df_manipulate,cidade,  temp) ## ano todo
}
rm(df_manipulate)

df_names = data.frame(file_list)
df_names$number = as.character(c(1:length(file_list)))


for(i in c(1:length(trocas))){
  # trocas_annual[[i]]$case = df_names$file_list[df_names$number == i]
  # trocas_monthly[[i]]$case = df_names$file_list[df_names$number == i]
  trocas_daily[[i]]$case = df_names$file_list[df_names$number == i]
}

rm(df_names)

trocas_graph_daily = do.call(rbind.data.frame, trocas_daily)
# trocas_graph_montlhy = do.call(rbind.data.frame, trocas_monthly)
# trocas_graph_annual = do.call(rbind.data.frame, trocas_annual)

# setwd(paste0("D:/Frentes de Trabalho/simulacoes_tese/simulation/convection/reference/resultados/")) ##para a referencia no pc lab
setwd(paste0("D:/Frentes de Trabalho/simulacoes_tese/simulation/surface/reference/resultados/dividindo_gain_loss")) ##para a referencia no pc lab

write.csv(trocas_graph_daily, paste0("daily_",temp,"_",cidade,"_",zone,".csv"))
# write.csv(trocas_graph_montlhy, paste0("monthly_",cidade,"_",zone,".csv"))
# write.csv(trocas_graph_annual, paste0("annual_",cidade,"_",zone,".csv"))

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
