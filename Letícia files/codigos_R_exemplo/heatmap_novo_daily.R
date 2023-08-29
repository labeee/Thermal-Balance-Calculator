library(stringr)
library(ggplot2)
library(hrbrthemes)
library(viridis)
library(scales)
library(ggExtra)

# setwd("D:/OneDrive/OneDrive - UFSC/Artigos/2023_Thesis/simulacoes/2023-06-13/surface/reference/graph") #pc leticia
setwd("C:/Users/Letícia/OneDrive - UFSC/Artigos/2023_Thesis/simulacoes/2023-06-13/surface/reference/graph/")

##para são paulo sala ----

# timestep = "annual"
# timestep = "monthly"
# timestep = "daily_amp_inverno"
timestep = "daily_amp_verao"
# timestep = "daily_max"
# timestep = "daily_min"

amp = read.csv(paste0("per_",timestep,".csv"))

amp = subset(amp, amp$case != "U001_Caso01_1a7_ac_nbr_1.csv")

amp$troca_graph[amp$exchange== "roof"] = "Roof"
amp$troca_graph[amp$exchange== "floor"] = "Floor"
amp$troca_graph[amp$exchange== "intwalls"] = "I.Walls"
amp$troca_graph[amp$exchange== "south_extwalls"] = "S E.Walls"
amp$troca_graph[amp$exchange== "north_extwalls"] = "N E.Walls"
amp$troca_graph[amp$exchange== "west_extwalls"] = "W E.Walls"
amp$troca_graph[amp$exchange== "east_extwalls"] = "E E.Walls"
amp$troca_graph[amp$exchange== "south_windows"] = "S Win"
amp$troca_graph[amp$exchange== "east_windows"] = "E Win"
amp$troca_graph[amp$exchange== "west_windows"] = "W Win"

timestep = "daily_max"

max = read.csv(paste0("per_",timestep,".csv"))

max = subset(max, max$case != "U001_Caso01_1a7_ac_nbr_1.csv")

max$troca_graph[max$exchange== "roof"] = "Roof"
max$troca_graph[max$exchange== "floor"] = "Floor"
max$troca_graph[max$exchange== "intwalls"] = "I.Walls"
max$troca_graph[max$exchange== "south_extwalls"] = "S E.Walls"
max$troca_graph[max$exchange== "north_extwalls"] = "N E.Walls"
max$troca_graph[max$exchange== "west_extwalls"] = "W E.Walls"
max$troca_graph[max$exchange== "east_extwalls"] = "E E.Walls"
max$troca_graph[max$exchange== "south_windows"] = "S Win"
max$troca_graph[max$exchange== "east_windows"] = "E Win"
max$troca_graph[max$exchange== "west_windows"] = "W Win"

timestep = "daily_min"

min = read.csv(paste0("per_",timestep,".csv"))

min = subset(min, min$case != "U001_Caso01_1a7_ac_nbr_1.csv")

min$troca_graph[min$exchange== "roof"] = "Roof"
min$troca_graph[min$exchange== "floor"] = "Floor"
min$troca_graph[min$exchange== "intwalls"] = "I.Walls"
min$troca_graph[min$exchange== "south_extwalls"] = "S E.Walls"
min$troca_graph[min$exchange== "north_extwalls"] = "N E.Walls"
min$troca_graph[min$exchange== "west_extwalls"] = "W E.Walls"
min$troca_graph[min$exchange== "east_extwalls"] = "E E.Walls"
min$troca_graph[min$exchange== "south_windows"] = "S Win"
min$troca_graph[min$exchange== "east_windows"] = "E Win"
min$troca_graph[min$exchange== "west_windows"] = "W Win"

max = subset(max, max$city == "saopaulo")
amp_sala = subset(amp, amp$app == "saopaulo_SALA") ## a divisao da cidade ficou errada
amp_D1 = subset(amp, amp$app == "saopaulo_DORM1") ## a divisao da cidade ficou errada

min$strip_y = "Jul., 15 and 16\nMinimum"
max$strip_y = "Oct., 1 and 2\nMaximum"
amp_sala$strip_y = "Nov., 23 and 24\nHigher Thermal Amplitude"

min = subset(min, min$app == "SALA", select = c("date_graph","gains_losses","value","flux","city","app","case_graph","gains","exchange","per","troca_graph","strip_y"))
min$date_teste = seq(ISOdate(2019,7,15,0,0,0),by='1 hour',length.out=2*24,tz='')

max = subset(max, max$app == "SALA", select = c("date_graph","gains_losses","value","flux","city","app","case_graph","gains","exchange","per","troca_graph","strip_y"))
max$date_teste = seq(ISOdate(2019,10,1,0,0,0),by='1 hour',length.out=2*24,tz='')

amp_sala$app = "SALA"
amp_sala = subset(amp_sala, amp_sala$app == "SALA", select = c("date_graph","gains_losses","value","flux","city","app","case_graph","gains","exchange","per","troca_graph","strip_y"))
amp_sala$date_teste = seq(ISOdate(2019,11,23,0,0,0),by='1 hour',length.out=2*24,tz='')

df = rbind(min, max, amp_sala)

# df = subset(df, df$app == "SALA")

df$gains_graph[df$gains == "gain"] = "+"
df$gains_graph[df$gains == "loss"] = "-"

# df$mes = paste0(df$MonthAbb, " - ", df$gains_graph)

# df$mes <- factor(df$mes, levels = c("Annual - Loss","Jan - Loss","Feb - Loss","Mar - Loss","Apr - Loss","May - Loss","Jun - Loss","Jul - Loss","Aug - Loss","Sep - Loss","Oct - Loss","Nov - Loss","Dec - Loss",
#                                     "Annual - Gain", "Jan - Gain","Feb - Gain","Mar - Gain","Apr - Gain","May - Gain","Jun - Gain","Jul - Gain","Aug - Gain","Sep - Gain","Oct - Gain","Nov - Gain","Dec - Gain"))
# 
# df$troca_graph <- factor(df$troca_graph, levels = c("IL","Roof","Floor","I.Walls","N E.Walls","S E.Walls","E E.Walls","W E.Walls","S Win","E Win","W Win","NV Win","NV Int","System"))

# df$troca_graph <- factor(df$troca_graph, levels = c("IL","Roof","Floor","I.Walls","N E.Walls","S E.Walls","E E.Walls","W E.Walls","S Win",
#                                                     "E Win","W Win","NV Win","NV Int","System"))

df$troca = paste0(df$troca_graph, " ", df$gains_graph)

df$troca <- factor(df$troca, levels = c("W E.Walls -","E E.Walls -","S E.Walls -","N E.Walls -","I.Walls -","Floor -","Roof -",
                                        "W E.Walls +","E E.Walls +","S E.Walls +","N E.Walls +","I.Walls +","Floor +","Roof +"))

df$flux[df$flux == "convection"] = "Convection"
df$flux[df$flux == "conduction"] = "Conduction"
df$flux[df$flux == "lwsurfaces"] = "LW. Surfaces"
df$flux[df$flux == "solarrad"] = "Solar Rad."
df$flux[df$flux == "swlights"] = "SW. Lights"
df$flux[df$flux == "lwinternal"] = "LW. Internal"

# df$troca <- factor(df$troca, levels = c("IL - Gain","Roof - Gain","Floor - Gain","I.Walls - Gain", "N E.Walls - Gain", "S E.Walls - Gain",
#                                         "E E.Walls - Gain", "W E.Walls - Gain", "S Win - Gain", "E Win - Gain","W Win - Gain", "NV Int - Gain",
#                                         "NV Win - Gain", "System - Gain", "Roof - Loss","Floor - Loss","I.Walls - Loss", "N E.Walls - Loss",
#                                         "S E.Walls - Loss","E E.Walls - Loss", "W E.Walls - Loss", "S Win - Loss", "E Win - Loss","W Win - Loss",
#                                         "NV Int - Loss","NV Win - Loss", "System - Loss"))

# df$cidade[df$city == "belem"] = "Belém"
# df$cidade[df$city == "saopaulo"] = "São Paulo"
# 
# df$app_graph[df$app == "SALA"] = "Living Room"
# df$app_graph[df$app == "DORM1"] = "Bedroom 1"
# df$app_graph[df$app == "DORM2"] = "Bedroom 2"
# 
# df$strip_x = paste0(df$cidade, "\n", df$app_graph)
# 
# be = subset(df, df$city == "belem")
# 
# df$strip_x <- factor(df$strip_x, levels = c("Belém\nLiving Room","São Paulo\nLiving Room","Belém\nBedroom 1", "São Paulo\nBedroom 1", "Belém\nBedroom 2", "São Paulo\nBedroom 2"))
# 
# graph = subset(df, df$app == "SALA" | df$app == "DORM1")
df$strip_y <- factor(df$strip_y, levels = c("Oct., 1 and 2\nMaximum","Nov., 23 and 24\nHigher Thermal Amplitude","Jul., 15 and 16\nMinimum"))
# df = subset(df, df$flux != "LW. Internal" & df$flux != "SW. Lights")

solar = subset(df, df$flux == "Solar Rad." | df$flux == "LW. Internal" | df$flux == "SW. Lights")
solar = subset(solar, solar$gains != "loss")
df = subset(df, df$flux != "Solar Rad." & df$flux != "LW. Internal" & df$flux != "SW. Lights")

df = rbind(df, solar)

df$flux = factor(df$flux, levels = c("Convection","Conduction","LW. Surfaces","Solar Rad.","LW. Internal","SW. Lights"))

df_ac = subset(df, df$case_graph == "Air Conditioner")


# df_ac = subset(df, df$strip_y == "Jul., 15 and 16\nMinimum")


# df_ac$date_graph = strptime(df_ac$date_graph, "%Y-%m-%d %H:%M:%S", tz = "")

# df_ac$date_teste = seq(ISOdate(2019,df_ac$month,df_ac$day,0,0,0),by='1 hour',length.out=2*24,tz='')


png(filename = paste0("heatmap_daily_sp_sala_ac_per.png"), width = 15, height = 12, units = "cm", res = 500)
plot(
  ggplot(df_ac,aes(x=date_teste,y=troca,fill=per))+
    geom_tile(color= "white",linewidth=0.1) +
    # geom_text(aes(label = round(kWh,0)), color = "black", size = 2)+
    scale_fill_gradientn(colours=c("#8ecae6","#a8dadc","#ffcf70","#ffc243","#ffc300","#f4a261","#fa8b01","#e85d04","#dc2f02","#d00000","#7a0103"),
                         values=rescale(c(0,.10,.20,.30,.40,.50,.60,.70,.80,.90,1)),
                         limits = c(0,1),
                         guide="colorbar")+
    theme_minimal(base_size = 6)+
    labs(x="Hours", y="Heat Exchanges", fill = "HEI:")+
    theme(legend.position = "right",
          legend.key.width= unit(0.3, 'cm'),
          strip.background = element_rect(colour="white"),
          axis.ticks=element_blank(),
          axis.text.y =element_text(size=5),
          axis.text.x = element_text(size=6, angle = 90, vjust = 0.5, hjust = 1),
          legend.title=element_text(size=5),
          legend.text=element_text(size=5),
          strip.text = element_text(size = 6))+
    scale_x_datetime(date_breaks='4 hour', date_labels='%H:%M',expand = c(0, 0))+
    removeGrid()+
    facet_grid(flux~strip_y, scales = "free", space = "free_y")
)
dev.off()

df_hi = subset(df, df$case_graph == "Hybrid")

png(filename = paste0("heatmap_daily_sp_sala_hi_per.png"), width = 15, height = 12, units = "cm", res = 500)
plot(
  ggplot(df_hi,aes(x=date_teste,y=troca,fill=per))+
    geom_tile(color= "white",linewidth=0.1) +
    # geom_text(aes(label = round(kWh,0)), color = "black", size = 2)+
    scale_fill_gradientn(colours=c("#8ecae6","#a8dadc","#ffcf70","#ffc243","#ffc300","#f4a261","#fa8b01","#e85d04","#dc2f02","#d00000","#7a0103"),
                         values=rescale(c(0,.10,.20,.30,.40,.50,.60,.70,.80,.90,1)),
                         limits = c(0,1),
                         guide="colorbar")+
    theme_minimal(base_size = 6)+
    labs(x="Hours", y="Heat Exchanges", fill = "HEI:")+
    theme(legend.position = "right",
          legend.key.width= unit(0.3, 'cm'),
          strip.background = element_rect(colour="white"),
          axis.ticks=element_blank(),
          axis.text.y =element_text(size=5),
          axis.text.x = element_text(size=6, angle = 90, vjust = 0.5, hjust = 1),
          legend.title=element_text(size=5),
          legend.text=element_text(size=5),
          strip.text = element_text(size = 6))+
    scale_x_datetime(date_breaks='4 hour', date_labels='%H:%M',expand = c(0, 0))+
    removeGrid()+
    facet_grid(flux~strip_y, scales = "free", space = "free_y")
)
dev.off()

df_vn = subset(df, df$case_graph == "Natural Ventilation")
# df_vn = subset(df_vn, df_vn$troca_graph != "System")

png(filename = paste0("heatmap_daily_sp_sala_vn_per.png"), width = 15, height = 12, units = "cm", res = 500)
plot(
  ggplot(df_vn,aes(x=date_teste,y=troca,fill=per))+
    geom_tile(color= "white",linewidth=0.1) +
    # geom_text(aes(label = round(kWh,0)), color = "black", size = 2)+
    scale_fill_gradientn(colours=c("#8ecae6","#a8dadc","#ffcf70","#ffc243","#ffc300","#f4a261","#fa8b01","#e85d04","#dc2f02","#d00000","#7a0103"),
                         values=rescale(c(0,.10,.20,.30,.40,.50,.60,.70,.80,.90,1)),
                         limits = c(0,1),
                         guide="colorbar")+
    theme_minimal(base_size = 6)+
    labs(x="Hours", y="Heat Exchanges", fill = "HEI:")+
    theme(legend.position = "right",
          legend.key.width= unit(0.3, 'cm'),
          strip.background = element_rect(colour="white"),
          axis.ticks=element_blank(),
          axis.text.y =element_text(size=5),
          axis.text.x = element_text(size=6, angle = 90, vjust = 0.5, hjust = 1),
          legend.title=element_text(size=5),
          legend.text=element_text(size=5),
          strip.text = element_text(size = 6))+
    scale_x_datetime(date_breaks='4 hour', date_labels='%H:%M',expand = c(0, 0))+
    removeGrid()+
    facet_grid(flux~strip_y, scales = "free", space = "free_y")
)
dev.off()

##para são paulo D1 ----

# timestep = "annual"
# timestep = "monthly"
# timestep = "daily_amp_inverno"
timestep = "daily_amp_verao"
# timestep = "daily_max"
# timestep = "daily_min"

amp = read.csv(paste0("per_",timestep,".csv"))

amp = subset(amp, amp$case != "U001_Caso01_1a7_ac_nbr_1.csv")

amp$troca_graph[amp$exchange== "roof"] = "Roof"
amp$troca_graph[amp$exchange== "floor"] = "Floor"
amp$troca_graph[amp$exchange== "intwalls"] = "I.Walls"
amp$troca_graph[amp$exchange== "south_extwalls"] = "S E.Walls"
amp$troca_graph[amp$exchange== "north_extwalls"] = "N E.Walls"
amp$troca_graph[amp$exchange== "west_extwalls"] = "W E.Walls"
amp$troca_graph[amp$exchange== "east_extwalls"] = "E E.Walls"
amp$troca_graph[amp$exchange== "south_windows"] = "S Win"
amp$troca_graph[amp$exchange== "east_windows"] = "E Win"
amp$troca_graph[amp$exchange== "west_windows"] = "W Win"

timestep = "daily_max"

max = read.csv(paste0("per_",timestep,".csv"))

max = subset(max, max$case != "U001_Caso01_1a7_ac_nbr_1.csv")

max$troca_graph[max$exchange== "roof"] = "Roof"
max$troca_graph[max$exchange== "floor"] = "Floor"
max$troca_graph[max$exchange== "intwalls"] = "I.Walls"
max$troca_graph[max$exchange== "south_extwalls"] = "S E.Walls"
max$troca_graph[max$exchange== "north_extwalls"] = "N E.Walls"
max$troca_graph[max$exchange== "west_extwalls"] = "W E.Walls"
max$troca_graph[max$exchange== "east_extwalls"] = "E E.Walls"
max$troca_graph[max$exchange== "south_windows"] = "S Win"
max$troca_graph[max$exchange== "east_windows"] = "E Win"
max$troca_graph[max$exchange== "west_windows"] = "W Win"

timestep = "daily_min"

min = read.csv(paste0("per_",timestep,".csv"))

min = subset(min, min$case != "U001_Caso01_1a7_ac_nbr_1.csv")

min$troca_graph[min$exchange== "roof"] = "Roof"
min$troca_graph[min$exchange== "floor"] = "Floor"
min$troca_graph[min$exchange== "intwalls"] = "I.Walls"
min$troca_graph[min$exchange== "south_extwalls"] = "S E.Walls"
min$troca_graph[min$exchange== "north_extwalls"] = "N E.Walls"
min$troca_graph[min$exchange== "west_extwalls"] = "W E.Walls"
min$troca_graph[min$exchange== "east_extwalls"] = "E E.Walls"
min$troca_graph[min$exchange== "south_windows"] = "S Win"
min$troca_graph[min$exchange== "east_windows"] = "E Win"
min$troca_graph[min$exchange== "west_windows"] = "W Win"

max = subset(max, max$city == "saopaulo")
amp_sala = subset(amp, amp$app == "saopaulo_SALA") ## a divisao da cidade ficou errada
amp_D1 = subset(amp, amp$app == "saopaulo_DORM1") ## a divisao da cidade ficou errada

min$strip_y = "Jul., 15 and 16\nMinimum"
max$strip_y = "Oct., 1 and 2\nMaximum"
amp_D1$strip_y = "Nov., 23 and 24\nHigher Thermal Amplitude"

min = subset(min, min$app == "DORM1", select = c("date_graph","gains_losses","value","flux","city","app","case_graph","gains","exchange","per","troca_graph","strip_y"))
min$date_teste = seq(ISOdate(2019,7,15,0,0,0),by='1 hour',length.out=2*24,tz='')

max = subset(max, max$app == "DORM1", select = c("date_graph","gains_losses","value","flux","city","app","case_graph","gains","exchange","per","troca_graph","strip_y"))
max$date_teste = seq(ISOdate(2019,10,1,0,0,0),by='1 hour',length.out=2*24,tz='')

amp_D1$app = "DORM1"
amp_D1 = subset(amp_D1, amp_D1$app == "DORM1", select = c("date_graph","gains_losses","value","flux","city","app","case_graph","gains","exchange","per","troca_graph","strip_y"))
amp_D1$date_teste = seq(ISOdate(2019,11,23,0,0,0),by='1 hour',length.out=2*24,tz='')

df = rbind(min, max, amp_D1)

# df = subset(df, df$app == "SALA")

df$gains_graph[df$gains == "gain"] = "+"
df$gains_graph[df$gains == "loss"] = "-"

# df$mes = paste0(df$MonthAbb, " - ", df$gains_graph)

# df$mes <- factor(df$mes, levels = c("Annual - Loss","Jan - Loss","Feb - Loss","Mar - Loss","Apr - Loss","May - Loss","Jun - Loss","Jul - Loss","Aug - Loss","Sep - Loss","Oct - Loss","Nov - Loss","Dec - Loss",
#                                     "Annual - Gain", "Jan - Gain","Feb - Gain","Mar - Gain","Apr - Gain","May - Gain","Jun - Gain","Jul - Gain","Aug - Gain","Sep - Gain","Oct - Gain","Nov - Gain","Dec - Gain"))
# 
# df$troca_graph <- factor(df$troca_graph, levels = c("IL","Roof","Floor","I.Walls","N E.Walls","S E.Walls","E E.Walls","W E.Walls","S Win","E Win","W Win","NV Win","NV Int","System"))

# df$troca_graph <- factor(df$troca_graph, levels = c("IL","Roof","Floor","I.Walls","N E.Walls","S E.Walls","E E.Walls","W E.Walls","S Win",
#                                                     "E Win","W Win","NV Win","NV Int","System"))

df$troca = paste0(df$troca_graph, " ", df$gains_graph)

df$troca <- factor(df$troca, levels = c("W E.Walls -","E E.Walls -","S E.Walls -","N E.Walls -","I.Walls -","Floor -","Roof -",
                                        "W E.Walls +","E E.Walls +","S E.Walls +","N E.Walls +","I.Walls +","Floor +","Roof +"))

df$flux[df$flux == "convection"] = "Convection"
df$flux[df$flux == "conduction"] = "Conduction"
df$flux[df$flux == "lwsurfaces"] = "LW. Surfaces"
df$flux[df$flux == "solarrad"] = "Solar Rad."
df$flux[df$flux == "swlights"] = "SW. Lights"
df$flux[df$flux == "lwinternal"] = "LW. Internal"

# df$troca <- factor(df$troca, levels = c("IL - Gain","Roof - Gain","Floor - Gain","I.Walls - Gain", "N E.Walls - Gain", "S E.Walls - Gain",
#                                         "E E.Walls - Gain", "W E.Walls - Gain", "S Win - Gain", "E Win - Gain","W Win - Gain", "NV Int - Gain",
#                                         "NV Win - Gain", "System - Gain", "Roof - Loss","Floor - Loss","I.Walls - Loss", "N E.Walls - Loss",
#                                         "S E.Walls - Loss","E E.Walls - Loss", "W E.Walls - Loss", "S Win - Loss", "E Win - Loss","W Win - Loss",
#                                         "NV Int - Loss","NV Win - Loss", "System - Loss"))

# df$cidade[df$city == "belem"] = "Belém"
# df$cidade[df$city == "saopaulo"] = "São Paulo"
# 
# df$app_graph[df$app == "SALA"] = "Living Room"
# df$app_graph[df$app == "DORM1"] = "Bedroom 1"
# df$app_graph[df$app == "DORM2"] = "Bedroom 2"
# 
# df$strip_x = paste0(df$cidade, "\n", df$app_graph)
# 
# be = subset(df, df$city == "belem")
# 
# df$strip_x <- factor(df$strip_x, levels = c("Belém\nLiving Room","São Paulo\nLiving Room","Belém\nBedroom 1", "São Paulo\nBedroom 1", "Belém\nBedroom 2", "São Paulo\nBedroom 2"))
# 
# graph = subset(df, df$app == "SALA" | df$app == "DORM1")
df$strip_y <- factor(df$strip_y, levels = c("Oct., 1 and 2\nMaximum","Nov., 23 and 24\nHigher Thermal Amplitude","Jul., 15 and 16\nMinimum"))
# df = subset(df, df$flux != "LW. Internal" & df$flux != "SW. Lights")

solar = subset(df, df$flux == "Solar Rad." | df$flux == "LW. Internal" | df$flux == "SW. Lights")
solar = subset(solar, solar$gains != "loss")
df = subset(df, df$flux != "Solar Rad." & df$flux != "LW. Internal" & df$flux != "SW. Lights")

df = rbind(df, solar)

df$flux = factor(df$flux, levels = c("Convection","Conduction","LW. Surfaces","Solar Rad.","LW. Internal","SW. Lights"))

df_ac = subset(df, df$case_graph == "Air Conditioner")


# df_ac = subset(df, df$strip_y == "Jul., 15 and 16\nMinimum")


# df_ac$date_graph = strptime(df_ac$date_graph, "%Y-%m-%d %H:%M:%S", tz = "")

# df_ac$date_teste = seq(ISOdate(2019,df_ac$month,df_ac$day,0,0,0),by='1 hour',length.out=2*24,tz='')


png(filename = paste0("heatmap_daily_sp_D1_ac_per.png"), width = 15, height = 12, units = "cm", res = 500)
plot(
  ggplot(df_ac,aes(x=date_teste,y=troca,fill=per))+
    geom_tile(color= "white",linewidth=0.1) +
    scale_fill_gradientn(colours=c("#8ecae6","#a8dadc","#ffcf70","#ffc243","#ffc300","#f4a261","#fa8b01","#e85d04","#dc2f02","#d00000","#7a0103"),
                         values=rescale(c(0,.10,.20,.30,.40,.50,.60,.70,.80,.90,1)),
                         limits = c(0,1),
                         guide="colorbar")+
    theme_minimal(base_size = 6)+
    labs(x="Hours", y="Heat Exchanges", fill = "HEI:")+
    theme(legend.position = "right",
          legend.key.width= unit(0.3, 'cm'),
          strip.background = element_rect(colour="white"),
          axis.ticks=element_blank(),
          axis.text.y =element_text(size=5),
          axis.text.x = element_text(size=6, angle = 90, vjust = 0.5, hjust = 1),
          legend.title=element_text(size=5),
          legend.text=element_text(size=5),
          strip.text = element_text(size = 6))+
    scale_x_datetime(date_breaks='4 hour', date_labels='%H:%M',expand = c(0, 0))+
    removeGrid()+
    facet_grid(flux~strip_y, scales = "free", space = "free_y")
)
dev.off()

df_hi = subset(df, df$case_graph == "Hybrid")

png(filename = paste0("heatmap_daily_sp_D1_hi_per.png"), width = 15, height = 12, units = "cm", res = 500)
plot(
  ggplot(df_hi,aes(x=date_teste,y=troca,fill=per))+
    geom_tile(color= "white",linewidth=0.1) +
    scale_fill_gradientn(colours=c("#8ecae6","#a8dadc","#ffcf70","#ffc243","#ffc300","#f4a261","#fa8b01","#e85d04","#dc2f02","#d00000","#7a0103"),
                         values=rescale(c(0,.10,.20,.30,.40,.50,.60,.70,.80,.90,1)),
                         limits = c(0,1),
                         guide="colorbar")+
    theme_minimal(base_size = 6)+
    labs(x="Hours", y="Heat Exchanges", fill = "HEI:")+
    theme(legend.position = "right",
          legend.key.width= unit(0.3, 'cm'),
          strip.background = element_rect(colour="white"),
          axis.ticks=element_blank(),
          axis.text.y =element_text(size=5),
          axis.text.x = element_text(size=6, angle = 90, vjust = 0.5, hjust = 1),
          legend.title=element_text(size=5),
          legend.text=element_text(size=5),
          strip.text = element_text(size = 6))+
    scale_x_datetime(date_breaks='4 hour', date_labels='%H:%M',expand = c(0, 0))+
    removeGrid()+
    facet_grid(flux~strip_y, scales = "free", space = "free_y")
)
dev.off()

df_vn = subset(df, df$case_graph == "Natural Ventilation")
# df_vn = subset(df_vn, df_vn$troca_graph != "System")

png(filename = paste0("heatmap_daily_sp_D1_vn_per.png"), width = 15, height = 12, units = "cm", res = 500)
plot(
  ggplot(df_vn,aes(x=date_teste,y=troca,fill=per))+
    geom_tile(color= "white",linewidth=0.1) +
    scale_fill_gradientn(colours=c("#8ecae6","#a8dadc","#ffcf70","#ffc243","#ffc300","#f4a261","#fa8b01","#e85d04","#dc2f02","#d00000","#7a0103"),
                         values=rescale(c(0,.10,.20,.30,.40,.50,.60,.70,.80,.90,1)),
                         limits = c(0,1),
                         guide="colorbar")+
    theme_minimal(base_size = 6)+
    labs(x="Hours", y="Heat Exchanges", fill = "HEI:")+
    theme(legend.position = "right",
          legend.key.width= unit(0.3, 'cm'),
          strip.background = element_rect(colour="white"),
          axis.ticks=element_blank(),
          axis.text.y =element_text(size=5),
          axis.text.x = element_text(size=6, angle = 90, vjust = 0.5, hjust = 1),
          legend.title=element_text(size=5),
          legend.text=element_text(size=5),
          strip.text = element_text(size = 6))+
    scale_x_datetime(date_breaks='4 hour', date_labels='%H:%M',expand = c(0, 0))+
    removeGrid()+
    facet_grid(flux~strip_y, scales = "free", space = "free_y")
)
dev.off()


##para BELÉM sala ----

# timestep = "annual"
# timestep = "monthly"
# timestep = "daily_amp_inverno"
timestep = "daily_amp_verao"
# timestep = "daily_max"
# timestep = "daily_min"

amp = read.csv(paste0("per_",timestep,".csv"))

amp = subset(amp, amp$case != "U001_Caso01_1a7_ac_nbr_1.csv")

amp$troca_graph[amp$exchange== "roof"] = "Roof"
amp$troca_graph[amp$exchange== "floor"] = "Floor"
amp$troca_graph[amp$exchange== "intwalls"] = "I.Walls"
amp$troca_graph[amp$exchange== "south_extwalls"] = "S E.Walls"
amp$troca_graph[amp$exchange== "north_extwalls"] = "N E.Walls"
amp$troca_graph[amp$exchange== "west_extwalls"] = "W E.Walls"
amp$troca_graph[amp$exchange== "east_extwalls"] = "E E.Walls"
amp$troca_graph[amp$exchange== "south_windows"] = "S Win"
amp$troca_graph[amp$exchange== "east_windows"] = "E Win"
amp$troca_graph[amp$exchange== "west_windows"] = "W Win"

timestep = "daily_max"

max = read.csv(paste0("per_",timestep,".csv"))

max = subset(max, max$case != "U001_Caso01_1a7_ac_nbr_1.csv")

max$troca_graph[max$exchange== "roof"] = "Roof"
max$troca_graph[max$exchange== "floor"] = "Floor"
max$troca_graph[max$exchange== "intwalls"] = "I.Walls"
max$troca_graph[max$exchange== "south_extwalls"] = "S E.Walls"
max$troca_graph[max$exchange== "north_extwalls"] = "N E.Walls"
max$troca_graph[max$exchange== "west_extwalls"] = "W E.Walls"
max$troca_graph[max$exchange== "east_extwalls"] = "E E.Walls"
max$troca_graph[max$exchange== "south_windows"] = "S Win"
max$troca_graph[max$exchange== "east_windows"] = "E Win"
max$troca_graph[max$exchange== "west_windows"] = "W Win"

max = subset(max, max$city == "belem")
amp_sala = subset(amp, amp$app == "belem_SALA") ## a divisao da cidade ficou errada
amp_D1 = subset(amp, amp$app == "belem_DORM1") ## a divisao da cidade ficou errada

max$strip_y = "Sep., 12 and 13\nMaximum"
amp_sala$strip_y = "Feb., 15 and 16\nHigher Thermal Amplitude"

max = subset(max, max$app == "SALA", select = c("date_graph","gains_losses","value","flux","city","app","case_graph","gains","exchange","per","troca_graph","strip_y"))
max$date_teste = seq(ISOdate(2019,9,12,0,0,0),by='1 hour',length.out=2*24,tz='')

amp_sala$app = "SALA"
amp_sala = subset(amp_sala, amp_sala$app == "SALA", select = c("date_graph","gains_losses","value","flux","city","app","case_graph","gains","exchange","per","troca_graph","strip_y"))
amp_sala$date_teste = seq(ISOdate(2019,2,15,0,0,0),by='1 hour',length.out=2*24,tz='')

df = rbind(max, amp_sala)

# df = subset(df, df$app == "SALA")

df$gains_graph[df$gains == "gain"] = "+"
df$gains_graph[df$gains == "loss"] = "-"

# df$mes = paste0(df$MonthAbb, " - ", df$gains_graph)

# df$mes <- factor(df$mes, levels = c("Annual - Loss","Jan - Loss","Feb - Loss","Mar - Loss","Apr - Loss","May - Loss","Jun - Loss","Jul - Loss","Aug - Loss","Sep - Loss","Oct - Loss","Nov - Loss","Dec - Loss",
#                                     "Annual - Gain", "Jan - Gain","Feb - Gain","Mar - Gain","Apr - Gain","May - Gain","Jun - Gain","Jul - Gain","Aug - Gain","Sep - Gain","Oct - Gain","Nov - Gain","Dec - Gain"))
# 
# df$troca_graph <- factor(df$troca_graph, levels = c("IL","Roof","Floor","I.Walls","N E.Walls","S E.Walls","E E.Walls","W E.Walls","S Win","E Win","W Win","NV Win","NV Int","System"))

# df$troca_graph <- factor(df$troca_graph, levels = c("IL","Roof","Floor","I.Walls","N E.Walls","S E.Walls","E E.Walls","W E.Walls","S Win",
#                                                     "E Win","W Win","NV Win","NV Int","System"))

df$troca = paste0(df$troca_graph, " ", df$gains_graph)

df$troca <- factor(df$troca, levels = c("W E.Walls -","E E.Walls -","S E.Walls -","N E.Walls -","I.Walls -","Floor -","Roof -",
                                        "W E.Walls +","E E.Walls +","S E.Walls +","N E.Walls +","I.Walls +","Floor +","Roof +"))

df$flux[df$flux == "convection"] = "Convection"
df$flux[df$flux == "conduction"] = "Conduction"
df$flux[df$flux == "lwsurfaces"] = "LW. Surfaces"
df$flux[df$flux == "solarrad"] = "Solar Rad."
df$flux[df$flux == "swlights"] = "SW. Lights"
df$flux[df$flux == "lwinternal"] = "LW. Internal"

# df$troca <- factor(df$troca, levels = c("IL - Gain","Roof - Gain","Floor - Gain","I.Walls - Gain", "N E.Walls - Gain", "S E.Walls - Gain",
#                                         "E E.Walls - Gain", "W E.Walls - Gain", "S Win - Gain", "E Win - Gain","W Win - Gain", "NV Int - Gain",
#                                         "NV Win - Gain", "System - Gain", "Roof - Loss","Floor - Loss","I.Walls - Loss", "N E.Walls - Loss",
#                                         "S E.Walls - Loss","E E.Walls - Loss", "W E.Walls - Loss", "S Win - Loss", "E Win - Loss","W Win - Loss",
#                                         "NV Int - Loss","NV Win - Loss", "System - Loss"))

# df$cidade[df$city == "belem"] = "Belém"
# df$cidade[df$city == "saopaulo"] = "São Paulo"
# 
# df$app_graph[df$app == "SALA"] = "Living Room"
# df$app_graph[df$app == "DORM1"] = "Bedroom 1"
# df$app_graph[df$app == "DORM2"] = "Bedroom 2"
# 
# df$strip_x = paste0(df$cidade, "\n", df$app_graph)
# 
# be = subset(df, df$city == "belem")
# 
# df$strip_x <- factor(df$strip_x, levels = c("Belém\nLiving Room","São Paulo\nLiving Room","Belém\nBedroom 1", "São Paulo\nBedroom 1", "Belém\nBedroom 2", "São Paulo\nBedroom 2"))
# 
# graph = subset(df, df$app == "SALA" | df$app == "DORM1")
df$strip_y <- factor(df$strip_y, levels = c("Sep., 12 and 13\nMaximum","Feb., 15 and 16\nHigher Thermal Amplitude"))

solar = subset(df, df$flux == "Solar Rad." | df$flux == "LW. Internal" | df$flux == "SW. Lights")
solar = subset(solar, solar$gains != "loss")
df = subset(df, df$flux != "Solar Rad." & df$flux != "LW. Internal" & df$flux != "SW. Lights")

df = rbind(df, solar)

df$flux = factor(df$flux, levels = c("Convection","Conduction","LW. Surfaces","Solar Rad.","LW. Internal","SW. Lights"))

df_ac = subset(df, df$case_graph == "Air Conditioner")


# df_ac = subset(df, df$strip_y == "Jul., 15 and 16\nMinimum")


# df_ac$date_graph = strptime(df_ac$date_graph, "%Y-%m-%d %H:%M:%S", tz = "")

# df_ac$date_teste = seq(ISOdate(2019,df_ac$month,df_ac$day,0,0,0),by='1 hour',length.out=2*24,tz='')


png(filename = paste0("heatmap_daily_belem_sala_ac_per.png"), width = 15, height = 12, units = "cm", res = 500)
plot(
  ggplot(df_ac,aes(x=date_teste,y=troca,fill=per))+
    geom_tile(color= "white",linewidth=0.1) +
    scale_fill_gradientn(colours=c("#8ecae6","#a8dadc","#ffcf70","#ffc243","#ffc300","#f4a261","#fa8b01","#e85d04","#dc2f02","#d00000","#7a0103"),
                         values=rescale(c(0,.10,.20,.30,.40,.50,.60,.70,.80,.90,1)),
                         limits = c(0,1),
                         guide="colorbar")+
    theme_minimal(base_size = 6)+
    labs(x="Hours", y="Heat Exchanges", fill = "HEI:")+
    theme(legend.position = "right",
          legend.key.width= unit(0.3, 'cm'),
          strip.background = element_rect(colour="white"),
          axis.ticks=element_blank(),
          axis.text.y =element_text(size=5),
          axis.text.x = element_text(size=6, angle = 90, vjust = 0.5, hjust = 1),
          legend.title=element_text(size=5),
          legend.text=element_text(size=5),
          strip.text = element_text(size = 6))+
    scale_x_datetime(date_breaks='4 hour', date_labels='%H:%M',expand = c(0, 0))+
    removeGrid()+
    facet_grid(flux~strip_y, scales = "free", space = "free_y")
)
dev.off()

df_hi = subset(df, df$case_graph == "Hybrid")

png(filename = paste0("heatmap_daily_belem_sala_hi_per.png"), width = 15, height = 12, units = "cm", res = 500)
plot(
  ggplot(df_hi,aes(x=date_teste,y=troca,fill=per))+
    geom_tile(color= "white",linewidth=0.1) +
    scale_fill_gradientn(colours=c("#8ecae6","#a8dadc","#ffcf70","#ffc243","#ffc300","#f4a261","#fa8b01","#e85d04","#dc2f02","#d00000","#7a0103"),
                         values=rescale(c(0,.10,.20,.30,.40,.50,.60,.70,.80,.90,1)),
                         limits = c(0,1),
                         guide="colorbar")+
    theme_minimal(base_size = 6)+
    labs(x="Hours", y="Heat Exchanges", fill = "HEI:")+
    theme(legend.position = "right",
          legend.key.width= unit(0.3, 'cm'),
          strip.background = element_rect(colour="white"),
          axis.ticks=element_blank(),
          axis.text.y =element_text(size=5),
          axis.text.x = element_text(size=6, angle = 90, vjust = 0.5, hjust = 1),
          legend.title=element_text(size=5),
          legend.text=element_text(size=5),
          strip.text = element_text(size = 6))+
    scale_x_datetime(date_breaks='4 hour', date_labels='%H:%M',expand = c(0, 0))+
    removeGrid()+
    facet_grid(flux~strip_y, scales = "free", space = "free_y")
)
dev.off()

df_vn = subset(df, df$case_graph == "Natural Ventilation")
# df_vn = subset(df_vn, df_vn$troca_graph != "System")

png(filename = paste0("heatmap_daily_belem_sala_vn_per.png"), width = 15, height = 12, units = "cm", res = 500)
plot(
  ggplot(df_vn,aes(x=date_teste,y=troca,fill=per))+
    geom_tile(color= "white",linewidth=0.1) +
    scale_fill_gradientn(colours=c("#8ecae6","#a8dadc","#ffcf70","#ffc243","#ffc300","#f4a261","#fa8b01","#e85d04","#dc2f02","#d00000","#7a0103"),
                         values=rescale(c(0,.10,.20,.30,.40,.50,.60,.70,.80,.90,1)),
                         limits = c(0,1),
                         guide="colorbar")+
    theme_minimal(base_size = 6)+
    labs(x="Hours", y="Heat Exchanges", fill = "HEI:")+
    theme(legend.position = "right",
          legend.key.width= unit(0.3, 'cm'),
          strip.background = element_rect(colour="white"),
          axis.ticks=element_blank(),
          axis.text.y =element_text(size=5),
          axis.text.x = element_text(size=6, angle = 90, vjust = 0.5, hjust = 1),
          legend.title=element_text(size=5),
          legend.text=element_text(size=5),
          strip.text = element_text(size = 6))+
    scale_x_datetime(date_breaks='4 hour', date_labels='%H:%M',expand = c(0, 0))+
    removeGrid()+
    facet_grid(flux~strip_y, scales = "free", space = "free_y")
)
dev.off()

png(filename = paste0("heatmap_daily_belem_sala_ac_per2.png"), width = 9, height = 12, units = "cm", res = 500)
plot(
  ggplot(df_ac,aes(x=date_teste,y=troca,fill=per))+
    geom_tile(color= "white",linewidth=0.1) +
    scale_fill_gradientn(colours=c("#8ecae6","#a8dadc","#ffcf70","#ffc243","#ffc300","#f4a261","#fa8b01","#e85d04","#dc2f02","#d00000","#7a0103"),
                         values=rescale(c(0,.10,.20,.30,.40,.50,.60,.70,.80,.90,1)),
                         limits = c(0,1),
                         guide="colorbar")+
    theme_minimal(base_size = 6)+
    labs(x="Hours", y="Heat Exchanges", fill = "HEI:")+
    theme(legend.position = "right",
          legend.key.width= unit(0.3, 'cm'),
          strip.background = element_rect(colour="white"),
          axis.ticks=element_blank(),
          axis.text.y =element_text(size=5),
          axis.text.x = element_text(size=6, angle = 90, vjust = 0.5, hjust = 1),
          legend.title=element_text(size=5),
          legend.text=element_text(size=5),
          strip.text = element_text(size = 6))+
    scale_x_datetime(date_breaks='4 hour', date_labels='%H:%M',expand = c(0, 0))+
    removeGrid()+
    facet_grid(flux~strip_y, scales = "free", space = "free_y")
)
dev.off()

df_hi = subset(df, df$case_graph == "Hybrid")

png(filename = paste0("heatmap_daily_belem_sala_hi_per2.png"), width = 9, height = 12, units = "cm", res = 500)
plot(
  ggplot(df_hi,aes(x=date_teste,y=troca,fill=per))+
    geom_tile(color= "white",linewidth=0.1) +
    scale_fill_gradientn(colours=c("#8ecae6","#a8dadc","#ffcf70","#ffc243","#ffc300","#f4a261","#fa8b01","#e85d04","#dc2f02","#d00000","#7a0103"),
                         values=rescale(c(0,.10,.20,.30,.40,.50,.60,.70,.80,.90,1)),
                         limits = c(0,1),
                         guide="colorbar")+
    theme_minimal(base_size = 6)+
    labs(x="Hours", y="Heat Exchanges", fill = "HEI:")+
    theme(legend.position = "right",
          legend.key.width= unit(0.3, 'cm'),
          strip.background = element_rect(colour="white"),
          axis.ticks=element_blank(),
          axis.text.y =element_text(size=5),
          axis.text.x = element_text(size=6, angle = 90, vjust = 0.5, hjust = 1),
          legend.title=element_text(size=5),
          legend.text=element_text(size=5),
          strip.text = element_text(size = 6))+
    scale_x_datetime(date_breaks='4 hour', date_labels='%H:%M',expand = c(0, 0))+
    removeGrid()+
    facet_grid(flux~strip_y, scales = "free", space = "free_y")
)
dev.off()

df_vn = subset(df, df$case_graph == "Natural Ventilation")
# df_vn = subset(df_vn, df_vn$troca_graph != "System")

png(filename = paste0("heatmap_daily_belem_sala_vn_per2.png"), width = 9, height = 12, units = "cm", res = 500)
plot(
  ggplot(df_vn,aes(x=date_teste,y=troca,fill=per))+
    geom_tile(color= "white",linewidth=0.1) +
    scale_fill_gradientn(colours=c("#8ecae6","#a8dadc","#ffcf70","#ffc243","#ffc300","#f4a261","#fa8b01","#e85d04","#dc2f02","#d00000","#7a0103"),
                         values=rescale(c(0,.10,.20,.30,.40,.50,.60,.70,.80,.90,1)),
                         limits = c(0,1),
                         guide="colorbar")+
    theme_minimal(base_size = 6)+
    labs(x="Hours", y="Heat Exchanges", fill = "HEI:")+
    theme(legend.position = "right",
          legend.key.width= unit(0.3, 'cm'),
          strip.background = element_rect(colour="white"),
          axis.ticks=element_blank(),
          axis.text.y =element_text(size=5),
          axis.text.x = element_text(size=6, angle = 90, vjust = 0.5, hjust = 1),
          legend.title=element_text(size=5),
          legend.text=element_text(size=5),
          strip.text = element_text(size = 6))+
    scale_x_datetime(date_breaks='4 hour', date_labels='%H:%M',expand = c(0, 0))+
    removeGrid()+
    facet_grid(flux~strip_y, scales = "free", space = "free_y")
)
dev.off()

##para BELÉM D1 ----

# timestep = "annual"
# timestep = "monthly"
# timestep = "daily_amp_inverno"
timestep = "daily_amp_verao"
# timestep = "daily_max"
# timestep = "daily_min"

amp = read.csv(paste0("per_",timestep,".csv"))

amp = subset(amp, amp$case != "U001_Caso01_1a7_ac_nbr_1.csv")

amp$troca_graph[amp$exchange== "roof"] = "Roof"
amp$troca_graph[amp$exchange== "floor"] = "Floor"
amp$troca_graph[amp$exchange== "intwalls"] = "I.Walls"
amp$troca_graph[amp$exchange== "south_extwalls"] = "S E.Walls"
amp$troca_graph[amp$exchange== "north_extwalls"] = "N E.Walls"
amp$troca_graph[amp$exchange== "west_extwalls"] = "W E.Walls"
amp$troca_graph[amp$exchange== "east_extwalls"] = "E E.Walls"
amp$troca_graph[amp$exchange== "south_windows"] = "S Win"
amp$troca_graph[amp$exchange== "east_windows"] = "E Win"
amp$troca_graph[amp$exchange== "west_windows"] = "W Win"

timestep = "daily_max"

max = read.csv(paste0("per_",timestep,".csv"))

max = subset(max, max$case != "U001_Caso01_1a7_ac_nbr_1.csv")

max$troca_graph[max$exchange== "roof"] = "Roof"
max$troca_graph[max$exchange== "floor"] = "Floor"
max$troca_graph[max$exchange== "intwalls"] = "I.Walls"
max$troca_graph[max$exchange== "south_extwalls"] = "S E.Walls"
max$troca_graph[max$exchange== "north_extwalls"] = "N E.Walls"
max$troca_graph[max$exchange== "west_extwalls"] = "W E.Walls"
max$troca_graph[max$exchange== "east_extwalls"] = "E E.Walls"
max$troca_graph[max$exchange== "south_windows"] = "S Win"
max$troca_graph[max$exchange== "east_windows"] = "E Win"
max$troca_graph[max$exchange== "west_windows"] = "W Win"

max = subset(max, max$city == "belem")
amp_sala = subset(amp, amp$app == "belem_SALA") ## a divisao da cidade ficou errada
amp_D1 = subset(amp, amp$app == "belem_DORM1") ## a divisao da cidade ficou errada

max$strip_y = "Sep., 12 and 13\nMaximum"
amp_D1$strip_y = "Feb., 15 and 16\nHigher Thermal Amplitude"

max = subset(max, max$app == "DORM1", select = c("date_graph","gains_losses","value","flux","city","app","case_graph","gains","exchange","per","troca_graph","strip_y"))
max$date_teste = seq(ISOdate(2019,9,12,0,0,0),by='1 hour',length.out=2*24,tz='')

amp_D1$app = "DORM1"
amp_D1 = subset(amp_D1, amp_D1$app == "DORM1", select = c("date_graph","gains_losses","value","flux","city","app","case_graph","gains","exchange","per","troca_graph","strip_y"))
amp_D1$date_teste = seq(ISOdate(2019,2,15,0,0,0),by='1 hour',length.out=2*24,tz='')

df = rbind(max, amp_D1)

# df = subset(df, df$app == "SALA")

df$gains_graph[df$gains == "gain"] = "+"
df$gains_graph[df$gains == "loss"] = "-"

# df$mes = paste0(df$MonthAbb, " - ", df$gains_graph)

# df$mes <- factor(df$mes, levels = c("Annual - Loss","Jan - Loss","Feb - Loss","Mar - Loss","Apr - Loss","May - Loss","Jun - Loss","Jul - Loss","Aug - Loss","Sep - Loss","Oct - Loss","Nov - Loss","Dec - Loss",
#                                     "Annual - Gain", "Jan - Gain","Feb - Gain","Mar - Gain","Apr - Gain","May - Gain","Jun - Gain","Jul - Gain","Aug - Gain","Sep - Gain","Oct - Gain","Nov - Gain","Dec - Gain"))
# 
# df$troca_graph <- factor(df$troca_graph, levels = c("IL","Roof","Floor","I.Walls","N E.Walls","S E.Walls","E E.Walls","W E.Walls","S Win","E Win","W Win","NV Win","NV Int","System"))

# df$troca_graph <- factor(df$troca_graph, levels = c("IL","Roof","Floor","I.Walls","N E.Walls","S E.Walls","E E.Walls","W E.Walls","S Win",
#                                                     "E Win","W Win","NV Win","NV Int","System"))

df$troca = paste0(df$troca_graph, " ", df$gains_graph)

df$troca <- factor(df$troca, levels = c("W E.Walls -","E E.Walls -","S E.Walls -","N E.Walls -","I.Walls -","Floor -","Roof -",
                                        "W E.Walls +","E E.Walls +","S E.Walls +","N E.Walls +","I.Walls +","Floor +","Roof +"))

df$flux[df$flux == "convection"] = "Convection"
df$flux[df$flux == "conduction"] = "Conduction"
df$flux[df$flux == "lwsurfaces"] = "LW. Surfaces"
df$flux[df$flux == "solarrad"] = "Solar Rad."
df$flux[df$flux == "swlights"] = "SW. Lights"
df$flux[df$flux == "lwinternal"] = "LW. Internal"

# df$troca <- factor(df$troca, levels = c("IL - Gain","Roof - Gain","Floor - Gain","I.Walls - Gain", "N E.Walls - Gain", "S E.Walls - Gain",
#                                         "E E.Walls - Gain", "W E.Walls - Gain", "S Win - Gain", "E Win - Gain","W Win - Gain", "NV Int - Gain",
#                                         "NV Win - Gain", "System - Gain", "Roof - Loss","Floor - Loss","I.Walls - Loss", "N E.Walls - Loss",
#                                         "S E.Walls - Loss","E E.Walls - Loss", "W E.Walls - Loss", "S Win - Loss", "E Win - Loss","W Win - Loss",
#                                         "NV Int - Loss","NV Win - Loss", "System - Loss"))

# df$cidade[df$city == "belem"] = "Belém"
# df$cidade[df$city == "saopaulo"] = "São Paulo"
# 
# df$app_graph[df$app == "SALA"] = "Living Room"
# df$app_graph[df$app == "DORM1"] = "Bedroom 1"
# df$app_graph[df$app == "DORM2"] = "Bedroom 2"
# 
# df$strip_x = paste0(df$cidade, "\n", df$app_graph)
# 
# be = subset(df, df$city == "belem")
# 
# df$strip_x <- factor(df$strip_x, levels = c("Belém\nLiving Room","São Paulo\nLiving Room","Belém\nBedroom 1", "São Paulo\nBedroom 1", "Belém\nBedroom 2", "São Paulo\nBedroom 2"))
# 
# graph = subset(df, df$app == "SALA" | df$app == "DORM1")
df$strip_y <- factor(df$strip_y, levels = c("Sep., 12 and 13\nMaximum","Feb., 15 and 16\nHigher Thermal Amplitude"))
solar = subset(df, df$flux == "Solar Rad." | df$flux == "LW. Internal" | df$flux == "SW. Lights")
solar = subset(solar, solar$gains != "loss")
df = subset(df, df$flux != "Solar Rad." & df$flux != "LW. Internal" & df$flux != "SW. Lights")

df = rbind(df, solar)

df$flux = factor(df$flux, levels = c("Convection","Conduction","LW. Surfaces","Solar Rad.","LW. Internal","SW. Lights"))

df_ac = subset(df, df$case_graph == "Air Conditioner")


# df_ac = subset(df, df$strip_y == "Jul., 15 and 16\nMinimum")


# df_ac$date_graph = strptime(df_ac$date_graph, "%Y-%m-%d %H:%M:%S", tz = "")

# df_ac$date_teste = seq(ISOdate(2019,df_ac$month,df_ac$day,0,0,0),by='1 hour',length.out=2*24,tz='')


png(filename = paste0("heatmap_daily_belem_D1_ac_per.png"), width = 15, height = 12, units = "cm", res = 500)
plot(
  ggplot(df_ac,aes(x=date_teste,y=troca,fill=per))+
    geom_tile(color= "white",linewidth=0.1) +
    scale_fill_gradientn(colours=c("#8ecae6","#a8dadc","#ffcf70","#ffc243","#ffc300","#f4a261","#fa8b01","#e85d04","#dc2f02","#d00000","#7a0103"),
                         values=rescale(c(0,.10,.20,.30,.40,.50,.60,.70,.80,.90,1)),
                         limits = c(0,1),
                         guide="colorbar")+
    theme_minimal(base_size = 6)+
    labs(x="Hours", y="Heat Exchanges", fill = "HEI:")+
    theme(legend.position = "right",
          legend.key.width= unit(0.3, 'cm'),
          strip.background = element_rect(colour="white"),
          axis.ticks=element_blank(),
          axis.text.y =element_text(size=5),
          axis.text.x = element_text(size=6, angle = 90, vjust = 0.5, hjust = 1),
          legend.title=element_text(size=5),
          legend.text=element_text(size=5),
          strip.text = element_text(size = 6))+
    scale_x_datetime(date_breaks='4 hour', date_labels='%H:%M',expand = c(0, 0))+
    removeGrid()+
    facet_grid(flux~strip_y, scales = "free", space = "free_y")
)
dev.off()

df_hi = subset(df, df$case_graph == "Hybrid")

png(filename = paste0("heatmap_daily_belem_D1_hi_per.png"), width = 15, height = 12, units = "cm", res = 500)
plot(
  ggplot(df_hi,aes(x=date_teste,y=troca,fill=per))+
    geom_tile(color= "white",linewidth=0.1) +
    scale_fill_gradientn(colours=c("#8ecae6","#a8dadc","#ffcf70","#ffc243","#ffc300","#f4a261","#fa8b01","#e85d04","#dc2f02","#d00000","#7a0103"),
                         values=rescale(c(0,.10,.20,.30,.40,.50,.60,.70,.80,.90,1)),
                         limits = c(0,1),
                         guide="colorbar")+
    theme_minimal(base_size = 6)+
    labs(x="Hours", y="Heat Exchanges", fill = "HEI:")+
    theme(legend.position = "right",
          legend.key.width= unit(0.3, 'cm'),
          strip.background = element_rect(colour="white"),
          axis.ticks=element_blank(),
          axis.text.y =element_text(size=5),
          axis.text.x = element_text(size=6, angle = 90, vjust = 0.5, hjust = 1),
          legend.title=element_text(size=5),
          legend.text=element_text(size=5),
          strip.text = element_text(size = 6))+
    scale_x_datetime(date_breaks='4 hour', date_labels='%H:%M',expand = c(0, 0))+
    removeGrid()+
    facet_grid(flux~strip_y, scales = "free", space = "free_y")
)
dev.off()

df_vn = subset(df, df$case_graph == "Natural Ventilation")
# df_vn = subset(df_vn, df_vn$troca_graph != "System")

png(filename = paste0("heatmap_daily_belem_D1_vn_per.png"), width = 15, height = 12, units = "cm", res = 500)
plot(
  ggplot(df_vn,aes(x=date_teste,y=troca,fill=per))+
    geom_tile(color= "white",linewidth=0.1) +
    scale_fill_gradientn(colours=c("#8ecae6","#a8dadc","#ffcf70","#ffc243","#ffc300","#f4a261","#fa8b01","#e85d04","#dc2f02","#d00000","#7a0103"),
                         values=rescale(c(0,.10,.20,.30,.40,.50,.60,.70,.80,.90,1)),
                         limits = c(0,1),
                         guide="colorbar")+
    theme_minimal(base_size = 6)+
    labs(x="Hours", y="Heat Exchanges", fill = "HEI:")+
    theme(legend.position = "right",
          legend.key.width= unit(0.3, 'cm'),
          strip.background = element_rect(colour="white"),
          axis.ticks=element_blank(),
          axis.text.y =element_text(size=5),
          axis.text.x = element_text(size=6, angle = 90, vjust = 0.5, hjust = 1),
          legend.title=element_text(size=5),
          legend.text=element_text(size=5),
          strip.text = element_text(size = 6))+
    scale_x_datetime(date_breaks='4 hour', date_labels='%H:%M',expand = c(0, 0))+
    removeGrid()+
    facet_grid(flux~strip_y, scales = "free", space = "free_y")
)
dev.off()

png(filename = paste0("heatmap_daily_belem_D1_ac_per2.png"), width = 9, height = 12, units = "cm", res = 500)
plot(
  ggplot(df_ac,aes(x=date_teste,y=troca,fill=per))+
    geom_tile(color= "white",linewidth=0.1) +
    scale_fill_gradientn(colours=c("#8ecae6","#a8dadc","#ffcf70","#ffc243","#ffc300","#f4a261","#fa8b01","#e85d04","#dc2f02","#d00000","#7a0103"),
                         values=rescale(c(0,.10,.20,.30,.40,.50,.60,.70,.80,.90,1)),
                         limits = c(0,1),
                         guide="colorbar")+
    theme_minimal(base_size = 6)+
    labs(x="Hours", y="Heat Exchanges", fill = "HEI:")+
    theme(legend.position = "right",
          legend.key.width= unit(0.3, 'cm'),
          strip.background = element_rect(colour="white"),
          axis.ticks=element_blank(),
          axis.text.y =element_text(size=5),
          axis.text.x = element_text(size=6, angle = 90, vjust = 0.5, hjust = 1),
          legend.title=element_text(size=5),
          legend.text=element_text(size=5),
          strip.text = element_text(size = 6))+
    scale_x_datetime(date_breaks='4 hour', date_labels='%H:%M',expand = c(0, 0))+
    removeGrid()+
    facet_grid(flux~strip_y, scales = "free", space = "free_y")
)
dev.off()

df_hi = subset(df, df$case_graph == "Hybrid")

png(filename = paste0("heatmap_daily_belem_D1_hi_per2.png"), width = 9, height = 12, units = "cm", res = 500)
plot(
  ggplot(df_hi,aes(x=date_teste,y=troca,fill=per))+
    geom_tile(color= "white",linewidth=0.1) +
    scale_fill_gradientn(colours=c("#8ecae6","#a8dadc","#ffcf70","#ffc243","#ffc300","#f4a261","#fa8b01","#e85d04","#dc2f02","#d00000","#7a0103"),
                         values=rescale(c(0,.10,.20,.30,.40,.50,.60,.70,.80,.90,1)),
                         limits = c(0,1),
                         guide="colorbar")+
    theme_minimal(base_size = 6)+
    labs(x="Hours", y="Heat Exchanges", fill = "HEI:")+
    theme(legend.position = "right",
          legend.key.width= unit(0.3, 'cm'),
          strip.background = element_rect(colour="white"),
          axis.ticks=element_blank(),
          axis.text.y =element_text(size=5),
          axis.text.x = element_text(size=6, angle = 90, vjust = 0.5, hjust = 1),
          legend.title=element_text(size=5),
          legend.text=element_text(size=5),
          strip.text = element_text(size = 6))+
    scale_x_datetime(date_breaks='4 hour', date_labels='%H:%M',expand = c(0, 0))+
    removeGrid()+
    facet_grid(flux~strip_y, scales = "free", space = "free_y")
)
dev.off()

df_vn = subset(df, df$case_graph == "Natural Ventilation")
# df_vn = subset(df_vn, df_vn$troca_graph != "System")

png(filename = paste0("heatmap_daily_belem_D1_vn_per2.png"), width = 9, height = 12, units = "cm", res = 500)
plot(
  ggplot(df_vn,aes(x=date_teste,y=troca,fill=per))+
    geom_tile(color= "white",linewidth=0.1) +
    scale_fill_gradientn(colours=c("#8ecae6","#a8dadc","#ffcf70","#ffc243","#ffc300","#f4a261","#fa8b01","#e85d04","#dc2f02","#d00000","#7a0103"),
                         values=rescale(c(0,.10,.20,.30,.40,.50,.60,.70,.80,.90,1)),
                         limits = c(0,1),
                         guide="colorbar")+
    theme_minimal(base_size = 6)+
    labs(x="Hours", y="Heat Exchanges", fill = "HEI:")+
    theme(legend.position = "right",
          legend.key.width= unit(0.3, 'cm'),
          strip.background = element_rect(colour="white"),
          axis.ticks=element_blank(),
          axis.text.y =element_text(size=5),
          axis.text.x = element_text(size=6, angle = 90, vjust = 0.5, hjust = 1),
          legend.title=element_text(size=5),
          legend.text=element_text(size=5),
          strip.text = element_text(size = 6))+
    scale_x_datetime(date_breaks='4 hour', date_labels='%H:%M',expand = c(0, 0))+
    removeGrid()+
    facet_grid(flux~strip_y, scales = "free", space = "free_y")
)
dev.off()