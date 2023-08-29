library(stringr)
library(ggplot2)
library(hrbrthemes)
library(viridis)
library(scales)
library(ggExtra)

# setwd("D:/OneDrive/OneDrive - UFSC/Artigos/2023_Thesis/simulacoes/2023-06-13/convection/reference/graphs") #pc leticia
setwd("C:/Users/Letícia/OneDrive - UFSC/Artigos/2023_Thesis/simulacoes/2023-06-13/convection/reference/graphs")

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
amp$troca_graph[amp$exchange== "internal_gains"] = "IL"
amp$troca_graph[amp$exchange== "cooling"] = "Cooling"
amp$troca_graph[amp$exchange== "heating"] = "Heating"
amp$troca_graph[amp$exchange== "vn_window"] = "NV Win"
amp$troca_graph[amp$exchange== "vn_interzone"] = "NV Int"

# ano$kWh = ano$value/1000

cooling = subset(amp, amp$troca_graph == "Cooling")
cooling$troca_graph = "System"
heating = subset(amp, amp$troca_graph == "Heating")
heating$troca_graph = "System"

amp = subset(amp, amp$troca_graph != "Cooling" & amp$troca_graph != "Heating")

amp = rbind(amp, cooling, heating)

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
max$troca_graph[max$exchange== "internal_gains"] = "IL"
max$troca_graph[max$exchange== "cooling"] = "Cooling"
max$troca_graph[max$exchange== "heating"] = "Heating"
max$troca_graph[max$exchange== "vn_window"] = "NV Win"
max$troca_graph[max$exchange== "vn_interzone"] = "NV Int"

# ano$kWh = ano$value/1000

cooling = subset(max, max$troca_graph == "Cooling")
cooling$troca_graph = "System"
heating = subset(max, max$troca_graph == "Heating")
heating$troca_graph = "System"

max = subset(max, max$troca_graph != "Cooling" & max$troca_graph != "Heating")

max = rbind(max, cooling, heating)

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
min$troca_graph[min$exchange== "internal_gains"] = "IL"
min$troca_graph[min$exchange== "cooling"] = "Cooling"
min$troca_graph[min$exchange== "heating"] = "Heating"
min$troca_graph[min$exchange== "vn_window"] = "NV Win"
min$troca_graph[min$exchange== "vn_interzone"] = "NV Int"

# ano$kWh = ano$value/1000

cooling = subset(min, min$troca_graph == "Cooling")
cooling$troca_graph = "System"
heating = subset(min, min$troca_graph == "Heating")
heating$troca_graph = "System"

min = subset(min, min$troca_graph != "Cooling" & min$troca_graph != "Heating")

min = rbind(min, cooling, heating)

max = subset(max, max$city == "saopaulo")
amp_sala = subset(amp, amp$app == "saopaulo_SALA") ## a divisao da cidade ficou errada
amp_D1 = subset(amp, amp$app == "saopaulo_DORM1") ## a divisao da cidade ficou errada

min$strip_y = "Jul., 15 and 16\nMinimum"
max$strip_y = "Oct., 1 and 2\nMaximum"
amp_sala$strip_y = "Nov., 23 and 24\nHigher Thermal Amplitude"

min = subset(min, min$app == "SALA")
min$date_teste = seq(ISOdate(2019,7,15,0,0,0),by='1 hour',length.out=2*24,tz='')

max = subset(max, max$app == "SALA")
max$date_teste = seq(ISOdate(2019,10,1,0,0,0),by='1 hour',length.out=2*24,tz='')

amp_sala$app = "SALA"
amp_sala = subset(amp_sala, amp_sala$app == "SALA")
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

df$troca <- factor(df$troca, levels = c("System -", "NV Win -","NV Int -","W Win -","E Win -", "S Win -", "W E.Walls -",
                                        "E E.Walls -","S E.Walls -", "N E.Walls -","I.Walls -", "Floor -",
                                        "Roof -","System +","NV Win +","NV Int +","W Win +","E Win +","S Win +",
                                        "W E.Walls +","E E.Walls +","S E.Walls +","N E.Walls +","I.Walls +","Floor +",
                                        "Roof +","IL +"))

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
df$strip_y <- factor(df$strip_y, levels = c("Oct., 1 and 2\nMaximum", "Nov., 23 and 24\nHigher Thermal Amplitude", "Jul., 15 and 16\nMinimum"))

df_hi_sala = subset(df, df$case_graph == "Hybrid")
df_ac_sala = subset(df, df$case_graph == "Air Conditioner")
df_vn_sala = subset(df, df$case_graph == "Natural Ventilation")

df_ac = subset(df, df$case_graph == "Air Conditioner")


# df_ac = subset(df, df$strip_y == "Jul., 15 and 16\nMinimum")


# df_ac$date_graph = strptime(df_ac$date_graph, "%Y-%m-%d %H:%M:%S", tz = "")

# df_ac$date_teste = seq(ISOdate(2019,df_ac$month,df_ac$day,0,0,0),by='1 hour',length.out=2*24,tz='')


png(filename = paste0("conv_heatmap_daily_sp_sala_ac_per.png"), width = 15, height = 10, units = "cm", res = 500)
plot(
  ggplot(df_ac,aes(x=date_teste,y=troca,fill=per))+
    geom_tile(color= "white",linewidth=0.1) +
    # geom_text(aes(label = round(kWh,0)), color = "black", size = 2)+
    scale_fill_gradientn(colours=c("#d8f3dc","#D9ED92","#B5E48C","#99D98C","#76C893","#52B69A","#34A0A4","#168AAD","#1A759F","#1E6091","#184E77"),
                         values=rescale(c(0,.10,.20,.30,.40,.50,.60,.70,.80,.90,1)),
                         limits = c(0,1),
                         guide="colorbar")+
    theme_minimal(base_size = 7)+
    labs(x="Hours", y="Heat Exchanges", fill = "HEI:")+
    theme(legend.position = "right",
          legend.key.width= unit(0.3, 'cm'),
          strip.background = element_rect(colour="white"),
          axis.ticks=element_blank(),
          axis.text.y =element_text(size=7),
          axis.text.x = element_text(size=6, angle = 90, vjust = 0.5, hjust = 1),
          legend.title=element_text(size=6),
          legend.text=element_text(size=6),
          strip.text = element_text(size = 7))+
    scale_x_datetime(date_breaks='4 hour', date_labels='%H:%M',expand = c(0, 0))+
    removeGrid()+
    facet_wrap(.~strip_y, scales = "free_x", ncol = 3)
)
dev.off()

df_hi = subset(df, df$case_graph == "Hybrid")

png(filename = paste0("conv_heatmap_daily_sp_sala_hi_per.png"), width = 15, height = 10, units = "cm", res = 500)
plot(
  ggplot(df_hi,aes(x=date_teste,y=troca,fill=per))+
    geom_tile(color= "white",linewidth=0.1) +
    # geom_text(aes(label = round(kWh,0)), color = "black", size = 2)+
    scale_fill_gradientn(colours=c("#d8f3dc","#D9ED92","#B5E48C","#99D98C","#76C893","#52B69A","#34A0A4","#168AAD","#1A759F","#1E6091","#184E77"),
                         values=rescale(c(0,.10,.20,.30,.40,.50,.60,.70,.80,.90,1)),
                         limits = c(0,1),
                         guide="colorbar")+
    theme_minimal(base_size = 7)+
    labs(x="Hours", y="Heat Exchanges", fill = "HEI:")+
    theme(legend.position = "right",
          legend.key.width= unit(0.3, 'cm'),
          strip.background = element_rect(colour="white"),
          axis.ticks=element_blank(),
          axis.text.y =element_text(size=7),
          axis.text.x = element_text(size=6, angle = 90, vjust = 0.5, hjust = 1),
          legend.title=element_text(size=6),
          legend.text=element_text(size=6),
          strip.text = element_text(size = 7))+
    scale_x_datetime(date_breaks='4 hour', date_labels='%H:%M',expand = c(0, 0))+
    removeGrid()+
    facet_wrap(.~strip_y, scales = "free_x", ncol = 3)
)
dev.off()

df_vn = subset(df, df$case_graph == "Natural Ventilation")
df_vn = subset(df_vn, df_vn$troca_graph != "System")

png(filename = paste0("conv_heatmap_daily_sp_sala_vn_per.png"), width = 15, height = 10, units = "cm", res = 500)
plot(
  ggplot(df_vn,aes(x=date_teste,y=troca,fill=per))+
    geom_tile(color= "white",linewidth=0.1) +
    # geom_text(aes(label = round(kWh,0)), color = "black", size = 2)+
    scale_fill_gradientn(colours=c("#d8f3dc","#D9ED92","#B5E48C","#99D98C","#76C893","#52B69A","#34A0A4","#168AAD","#1A759F","#1E6091","#184E77"),
                         values=rescale(c(0,.10,.20,.30,.40,.50,.60,.70,.80,.90,1)),
                         limits = c(0,1),
                         guide="colorbar")+
    theme_minimal(base_size = 7)+
    labs(x="Hours", y="Heat Exchanges", fill = "HEI:")+
    theme(legend.position = "right",
          legend.key.width= unit(0.3, 'cm'),
          strip.background = element_rect(colour="white"),
          axis.ticks=element_blank(),
          axis.text.y =element_text(size=7),
          axis.text.x = element_text(size=6, angle = 90, vjust = 0.5, hjust = 1),
          legend.title=element_text(size=6),
          legend.text=element_text(size=6),
          strip.text = element_text(size = 7))+
    scale_x_datetime(date_breaks='4 hour', date_labels='%H:%M',expand = c(0, 0))+
    removeGrid()+
    facet_wrap(.~strip_y, scales = "free_x", ncol = 3)
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
amp$troca_graph[amp$exchange== "internal_gains"] = "IL"
amp$troca_graph[amp$exchange== "cooling"] = "Cooling"
amp$troca_graph[amp$exchange== "heating"] = "Heating"
amp$troca_graph[amp$exchange== "vn_window"] = "NV Win"
amp$troca_graph[amp$exchange== "vn_interzone"] = "NV Int"

# ano$kWh = ano$value/1000

cooling = subset(amp, amp$troca_graph == "Cooling")
cooling$troca_graph = "System"
heating = subset(amp, amp$troca_graph == "Heating")
heating$troca_graph = "System"

amp = subset(amp, amp$troca_graph != "Cooling" & amp$troca_graph != "Heating")

amp = rbind(amp, cooling, heating)

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
max$troca_graph[max$exchange== "internal_gains"] = "IL"
max$troca_graph[max$exchange== "cooling"] = "Cooling"
max$troca_graph[max$exchange== "heating"] = "Heating"
max$troca_graph[max$exchange== "vn_window"] = "NV Win"
max$troca_graph[max$exchange== "vn_interzone"] = "NV Int"

# ano$kWh = ano$value/1000

cooling = subset(max, max$troca_graph == "Cooling")
cooling$troca_graph = "System"
heating = subset(max, max$troca_graph == "Heating")
heating$troca_graph = "System"

max = subset(max, max$troca_graph != "Cooling" & max$troca_graph != "Heating")

max = rbind(max, cooling, heating)

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
min$troca_graph[min$exchange== "internal_gains"] = "IL"
min$troca_graph[min$exchange== "cooling"] = "Cooling"
min$troca_graph[min$exchange== "heating"] = "Heating"
min$troca_graph[min$exchange== "vn_window"] = "NV Win"
min$troca_graph[min$exchange== "vn_interzone"] = "NV Int"

# ano$kWh = ano$value/1000

cooling = subset(min, min$troca_graph == "Cooling")
cooling$troca_graph = "System"
heating = subset(min, min$troca_graph == "Heating")
heating$troca_graph = "System"

min = subset(min, min$troca_graph != "Cooling" & min$troca_graph != "Heating")

min = rbind(min, cooling, heating)

max = subset(max, max$city == "saopaulo")
amp_sala = subset(amp, amp$app == "saopaulo_SALA") ## a divisao da cidade ficou errada
amp_D1 = subset(amp, amp$app == "saopaulo_DORM1") ## a divisao da cidade ficou errada

min$strip_y = "Jul., 15 and 16\nMinimum"
max$strip_y = "Oct., 1 and 2\nMaximum"
amp_D1$strip_y = "Nov., 23 and 24\nHigher Thermal Amplitude"

min = subset(min, min$app == "DORM1")
min$date_teste = seq(ISOdate(2019,7,15,0,0,0),by='1 hour',length.out=2*24,tz='')

max = subset(max, max$app == "DORM1")
max$date_teste = seq(ISOdate(2019,10,1,0,0,0),by='1 hour',length.out=2*24,tz='')

amp_D1$app = "DORM1"
amp_D1 = subset(amp_D1, amp_D1$app == "DORM1")
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

df$troca <- factor(df$troca, levels = c("System -", "NV Win -","NV Int -","W Win -","E Win -", "S Win -", "W E.Walls -",
                                        "E E.Walls -","S E.Walls -", "N E.Walls -","I.Walls -", "Floor -",
                                        "Roof -","System +","NV Win +","NV Int +","W Win +","E Win +","S Win +",
                                        "W E.Walls +","E E.Walls +","S E.Walls +","N E.Walls +","I.Walls +","Floor +",
                                        "Roof +","IL +"))

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
df$strip_y <- factor(df$strip_y, levels = c("Oct., 1 and 2\nMaximum", "Nov., 23 and 24\nHigher Thermal Amplitude", "Jul., 15 and 16\nMinimum"))

df_hi_d1 = subset(df, df$case_graph == "Hybrid")
df_ac_d1 = subset(df, df$case_graph == "Air Conditioner")
df_vn_d1 = subset(df, df$case_graph == "Natural Ventilation")

df_ac = subset(df, df$case_graph == "Air Conditioner")


# df_ac = subset(df, df$strip_y == "Jul., 15 and 16\nMinimum")


# df_ac$date_graph = strptime(df_ac$date_graph, "%Y-%m-%d %H:%M:%S", tz = "")

# df_ac$date_teste = seq(ISOdate(2019,df_ac$month,df_ac$day,0,0,0),by='1 hour',length.out=2*24,tz='')


png(filename = paste0("conv_heatmap_daily_sp_D1_ac_per.png"), width = 15, height = 10, units = "cm", res = 500)
plot(
  ggplot(df_ac,aes(x=date_teste,y=troca,fill=per))+
    geom_tile(color= "white",linewidth=0.1) +
    # geom_text(aes(label = round(kWh,0)), color = "black", size = 2)+
    scale_fill_gradientn(colours=c("#d8f3dc","#D9ED92","#B5E48C","#99D98C","#76C893","#52B69A","#34A0A4","#168AAD","#1A759F","#1E6091","#184E77"),
                         values=rescale(c(0,.10,.20,.30,.40,.50,.60,.70,.80,.90,1)),
                         limits = c(0,1),
                         guide="colorbar")+
    theme_minimal(base_size = 7)+
    labs(x="Hours", y="Heat Exchanges", fill = "HEI:")+
    theme(legend.position = "right",
          legend.key.width= unit(0.3, 'cm'),
          strip.background = element_rect(colour="white"),
          axis.ticks=element_blank(),
          axis.text.y =element_text(size=7),
          axis.text.x = element_text(size=6, angle = 90, vjust = 0.5, hjust = 1),
          legend.title=element_text(size=6),
          legend.text=element_text(size=6),
          strip.text = element_text(size = 7))+
    scale_x_datetime(date_breaks='4 hour', date_labels='%H:%M',expand = c(0, 0))+
    removeGrid()+
    facet_wrap(.~strip_y, scales = "free_x", ncol = 3)
)
dev.off()

df_hi = subset(df, df$case_graph == "Hybrid")

png(filename = paste0("conv_heatmap_daily_sp_D1_hi_per.png"), width = 15, height = 10, units = "cm", res = 500)
plot(
  ggplot(df_hi,aes(x=date_teste,y=troca,fill=per))+
    geom_tile(color= "white",linewidth=0.1) +
    # geom_text(aes(label = round(kWh,0)), color = "black", size = 2)+
    scale_fill_gradientn(colours=c("#d8f3dc","#D9ED92","#B5E48C","#99D98C","#76C893","#52B69A","#34A0A4","#168AAD","#1A759F","#1E6091","#184E77"),
                         values=rescale(c(0,.10,.20,.30,.40,.50,.60,.70,.80,.90,1)),
                         limits = c(0,1),
                         guide="colorbar")+
    theme_minimal(base_size = 7)+
    labs(x="Hours", y="Heat Exchanges", fill = "HEI:")+
    theme(legend.position = "right",
          legend.key.width= unit(0.3, 'cm'),
          strip.background = element_rect(colour="white"),
          axis.ticks=element_blank(),
          axis.text.y =element_text(size=7),
          axis.text.x = element_text(size=6, angle = 90, vjust = 0.5, hjust = 1),
          legend.title=element_text(size=6),
          legend.text=element_text(size=6),
          strip.text = element_text(size = 7))+
    scale_x_datetime(date_breaks='4 hour', date_labels='%H:%M',expand = c(0, 0))+
    removeGrid()+
    facet_wrap(.~strip_y, scales = "free_x", ncol = 3)
)
dev.off()

df_vn = subset(df, df$case_graph == "Natural Ventilation")
df_vn = subset(df_vn, df_vn$troca_graph != "System")

png(filename = paste0("conv_heatmap_daily_sp_D1_vn_per.png"), width = 15, height = 10, units = "cm", res = 500)
plot(
  ggplot(df_vn,aes(x=date_teste,y=troca,fill=per))+
    geom_tile(color= "white",linewidth=0.1) +
    # geom_text(aes(label = round(kWh,0)), color = "black", size = 2)+
    scale_fill_gradientn(colours=c("#d8f3dc","#D9ED92","#B5E48C","#99D98C","#76C893","#52B69A","#34A0A4","#168AAD","#1A759F","#1E6091","#184E77"),
                         values=rescale(c(0,.10,.20,.30,.40,.50,.60,.70,.80,.90,1)),
                         limits = c(0,1),
                         guide="colorbar")+
    theme_minimal(base_size = 7)+
    labs(x="Hours", y="Heat Exchanges", fill = "HEI:")+
    theme(legend.position = "right",
          legend.key.width= unit(0.3, 'cm'),
          strip.background = element_rect(colour="white"),
          axis.ticks=element_blank(),
          axis.text.y =element_text(size=7),
          axis.text.x = element_text(size=6, angle = 90, vjust = 0.5, hjust = 1),
          legend.title=element_text(size=6),
          legend.text=element_text(size=6),
          strip.text = element_text(size = 7))+
    scale_x_datetime(date_breaks='4 hour', date_labels='%H:%M',expand = c(0, 0))+
    removeGrid()+
    facet_wrap(.~strip_y, scales = "free_x", ncol = 3)
)
dev.off()

##montando o gráfico com os dois apps

df_hi = rbind(df_hi_sala, df_hi_d1)

df_hi$app[df_hi$app == "SALA"] = "Living Room"
df_hi$app[df_hi$app == "DORM1"] = "Bedroom 1"

# df_hi$strip[df_hi$strip_y == "Oct., 1 and 2\nMaximum"] = "Oct., 1 and 2 (Maximum)"
# df_hi$strip[df_hi$strip_y == "Nov., 23 and 24\nHigher Thermal Amplitude"] = "Nov., 23 and 24 (Higher Thermal Amplitude)"
# df_hi$strip[df_hi$strip_y == "Jul., 15 and 16\nMinimum"] = "Jul., 15 and 16 (Minimum)"

# df_hi$strip_y <- factor(df_hi$strip_y, levels = c("Oct., 1 and 2 (Maximum)", "Nov., 23 and 24 (Higher Thermal Amplitude)", "Jul., 15 and 16 (Minimum)"))

df_hi$app <- factor(df_hi$app, levels = c("Living Room", "Bedroom 1"))

df_hi_min = subset(df_hi, df_hi$month == 7)

png(filename = paste0("heatmap_daily_sp_hi_min_per.png"), width = 15, height = 7, units = "cm", res = 500)
plot(
  ggplot(df_hi_min,aes(x=date_teste,y=troca,fill=per))+
    geom_tile(color= "white",linewidth=0.1) +
    # geom_text(aes(label = round(kWh,0)), color = "black", size = 2)+
    scale_fill_gradientn(colours=c("#d8f3dc","#D9ED92","#B5E48C","#99D98C","#76C893","#52B69A","#34A0A4","#168AAD","#1A759F","#1E6091","#184E77"),
                         values=rescale(c(0,.10,.20,.30,.40,.50,.60,.70,.80,.90,1)),
                         limits = c(0,1),
                         guide="colorbar")+
    theme_minimal(base_size = 7)+
    labs(x="Hours", y="Heat Exchanges", fill = "HEI:")+
    theme(legend.position = "right",
          legend.key.width= unit(0.3, 'cm'),
          strip.background = element_rect(colour="white"),
          axis.ticks=element_blank(),
          axis.text.y =element_text(size=7),
          axis.text.x = element_text(size=6, angle = 90, vjust = 0.5, hjust = 1),
          legend.title=element_text(size=6),
          legend.text=element_text(size=6),
          strip.text = element_text(size = 7))+
    scale_x_datetime(date_breaks='4 hour', date_labels='%H:%M',expand = c(0, 0))+
    removeGrid()+
    facet_grid(.~app, scales = "free_x")
)
dev.off()

##para belem sala ----

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
amp$troca_graph[amp$exchange== "internal_gains"] = "IL"
amp$troca_graph[amp$exchange== "cooling"] = "Cooling"
amp$troca_graph[amp$exchange== "heating"] = "Heating"
amp$troca_graph[amp$exchange== "vn_window"] = "NV Win"
amp$troca_graph[amp$exchange== "vn_interzone"] = "NV Int"

# ano$kWh = ano$value/1000

cooling = subset(amp, amp$troca_graph == "Cooling")
cooling$troca_graph = "System"
heating = subset(amp, amp$troca_graph == "Heating")
heating$troca_graph = "System"

amp = subset(amp, amp$troca_graph != "Cooling" & amp$troca_graph != "Heating")

amp = rbind(amp, cooling, heating)

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
max$troca_graph[max$exchange== "internal_gains"] = "IL"
max$troca_graph[max$exchange== "cooling"] = "Cooling"
max$troca_graph[max$exchange== "heating"] = "Heating"
max$troca_graph[max$exchange== "vn_window"] = "NV Win"
max$troca_graph[max$exchange== "vn_interzone"] = "NV Int"

# ano$kWh = ano$value/1000

cooling = subset(max, max$troca_graph == "Cooling")
cooling$troca_graph = "System"
heating = subset(max, max$troca_graph == "Heating")
heating$troca_graph = "System"

max = subset(max, max$troca_graph != "Cooling" & max$troca_graph != "Heating")

max = rbind(max, cooling, heating)

max = subset(max, max$city == "belem")
amp_sala = subset(amp, amp$app == "belem_SALA") ## a divisao da cidade ficou errada
amp_D1 = subset(amp, amp$app == "belem_DORM1") ## a divisao da cidade ficou errada

max$strip_y = "Sep., 12 and 13\nMaximum"
amp_sala$strip_y = "Feb., 15 and 16\nHigher Thermal Amplitude"

max = subset(max, max$app == "SALA")
max$date_teste = seq(ISOdate(2019,9,12,0,0,0),by='1 hour',length.out=2*24,tz='')

amp_sala$app = "SALA"
amp_sala = subset(amp_sala, amp_sala$app == "SALA")
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

df$troca <- factor(df$troca, levels = c("System -", "NV Win -","NV Int -","W Win -","E Win -", "S Win -", "W E.Walls -",
                                        "E E.Walls -","S E.Walls -", "N E.Walls -","I.Walls -", "Floor -",
                                        "Roof -","System +","NV Win +","NV Int +","W Win +","E Win +","S Win +",
                                        "W E.Walls +","E E.Walls +","S E.Walls +","N E.Walls +","I.Walls +","Floor +",
                                        "Roof +","IL +"))

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
df$strip_y <- factor(df$strip_y, levels = c("Sep., 12 and 13\nMaximum", "Feb., 15 and 16\nHigher Thermal Amplitude"))

df_ac = subset(df, df$case_graph == "Air Conditioner")


# df_ac = subset(df, df$strip_y == "Jul., 15 and 16\nMinimum")


# df_ac$date_graph = strptime(df_ac$date_graph, "%Y-%m-%d %H:%M:%S", tz = "")

# df_ac$date_teste = seq(ISOdate(2019,df_ac$month,df_ac$day,0,0,0),by='1 hour',length.out=2*24,tz='')


png(filename = paste0("conv_heatmap_daily_belem_sala_ac_per.png"), width = 15, height = 10, units = "cm", res = 500)
plot(
  ggplot(df_ac,aes(x=date_teste,y=troca,fill=per))+
    geom_tile(color= "white",linewidth=0.1) +
    # geom_text(aes(label = round(kWh,0)), color = "black", size = 2)+
    scale_fill_gradientn(colours=c("#d8f3dc","#D9ED92","#B5E48C","#99D98C","#76C893","#52B69A","#34A0A4","#168AAD","#1A759F","#1E6091","#184E77"),
                         values=rescale(c(0,.10,.20,.30,.40,.50,.60,.70,.80,.90,1)),
                         limits = c(0,1),
                         guide="colorbar")+
    theme_minimal(base_size = 7)+
    labs(x="Hours", y="Heat Exchanges", fill = "HEI:")+
    theme(legend.position = "right",
          legend.key.width= unit(0.3, 'cm'),
          strip.background = element_rect(colour="white"),
          axis.ticks=element_blank(),
          axis.text.y =element_text(size=7),
          axis.text.x = element_text(size=6, angle = 90, vjust = 0.5, hjust = 1),
          legend.title=element_text(size=6),
          legend.text=element_text(size=6),
          strip.text = element_text(size = 7))+
    scale_x_datetime(date_breaks='4 hour', date_labels='%H:%M',expand = c(0, 0))+
    removeGrid()+
    facet_wrap(.~strip_y, scales = "free_x", ncol = 3)
)
dev.off()

df_hi = subset(df, df$case_graph == "Hybrid")

png(filename = paste0("conv_heatmap_daily_belem_sala_hi_per.png"), width = 15, height = 10, units = "cm", res = 500)
plot(
  ggplot(df_hi,aes(x=date_teste,y=troca,fill=per))+
    geom_tile(color= "white",linewidth=0.1) +
    # geom_text(aes(label = round(kWh,0)), color = "black", size = 2)+
    scale_fill_gradientn(colours=c("#d8f3dc","#D9ED92","#B5E48C","#99D98C","#76C893","#52B69A","#34A0A4","#168AAD","#1A759F","#1E6091","#184E77"),
                         values=rescale(c(0,.10,.20,.30,.40,.50,.60,.70,.80,.90,1)),
                         limits = c(0,1),
                         guide="colorbar")+
    theme_minimal(base_size = 7)+
    labs(x="Hours", y="Heat Exchanges", fill = "HEI:")+
    theme(legend.position = "right",
          legend.key.width= unit(0.3, 'cm'),
          strip.background = element_rect(colour="white"),
          axis.ticks=element_blank(),
          axis.text.y =element_text(size=7),
          axis.text.x = element_text(size=6, angle = 90, vjust = 0.5, hjust = 1),
          legend.title=element_text(size=6),
          legend.text=element_text(size=6),
          strip.text = element_text(size = 7))+
    scale_x_datetime(date_breaks='4 hour', date_labels='%H:%M',expand = c(0, 0))+
    removeGrid()+
    facet_wrap(.~strip_y, scales = "free_x", ncol = 3)
)
dev.off()

df_vn = subset(df, df$case_graph == "Natural Ventilation")
df_vn = subset(df_vn, df_vn$troca_graph != "System")

png(filename = paste0("conv_heatmap_daily_belem_sala_vn_per.png"), width = 15, height = 10, units = "cm", res = 500)
plot(
  ggplot(df_vn,aes(x=date_teste,y=troca,fill=per))+
    geom_tile(color= "white",linewidth=0.1) +
    # geom_text(aes(label = round(kWh,0)), color = "black", size = 2)+
    scale_fill_gradientn(colours=c("#d8f3dc","#D9ED92","#B5E48C","#99D98C","#76C893","#52B69A","#34A0A4","#168AAD","#1A759F","#1E6091","#184E77"),
                         values=rescale(c(0,.10,.20,.30,.40,.50,.60,.70,.80,.90,1)),
                         limits = c(0,1),
                         guide="colorbar")+
    theme_minimal(base_size = 7)+
    labs(x="Hours", y="Heat Exchanges", fill = "HEI:")+
    theme(legend.position = "right",
          legend.key.width= unit(0.3, 'cm'),
          strip.background = element_rect(colour="white"),
          axis.ticks=element_blank(),
          axis.text.y =element_text(size=7),
          axis.text.x = element_text(size=6, angle = 90, vjust = 0.5, hjust = 1),
          legend.title=element_text(size=6),
          legend.text=element_text(size=6),
          strip.text = element_text(size = 7))+
    scale_x_datetime(date_breaks='4 hour', date_labels='%H:%M',expand = c(0, 0))+
    removeGrid()+
    facet_wrap(.~strip_y, scales = "free_x", ncol = 3)
)
dev.off()

#para belem D1 ----

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
amp$troca_graph[amp$exchange== "internal_gains"] = "IL"
amp$troca_graph[amp$exchange== "cooling"] = "Cooling"
amp$troca_graph[amp$exchange== "heating"] = "Heating"
amp$troca_graph[amp$exchange== "vn_window"] = "NV Win"
amp$troca_graph[amp$exchange== "vn_interzone"] = "NV Int"

# ano$kWh = ano$value/1000

cooling = subset(amp, amp$troca_graph == "Cooling")
cooling$troca_graph = "System"
heating = subset(amp, amp$troca_graph == "Heating")
heating$troca_graph = "System"

amp = subset(amp, amp$troca_graph != "Cooling" & amp$troca_graph != "Heating")

amp = rbind(amp, cooling, heating)

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
max$troca_graph[max$exchange== "internal_gains"] = "IL"
max$troca_graph[max$exchange== "cooling"] = "Cooling"
max$troca_graph[max$exchange== "heating"] = "Heating"
max$troca_graph[max$exchange== "vn_window"] = "NV Win"
max$troca_graph[max$exchange== "vn_interzone"] = "NV Int"

# ano$kWh = ano$value/1000

cooling = subset(max, max$troca_graph == "Cooling")
cooling$troca_graph = "System"
heating = subset(max, max$troca_graph == "Heating")
heating$troca_graph = "System"

max = subset(max, max$troca_graph != "Cooling" & max$troca_graph != "Heating")

max = rbind(max, cooling, heating)

max = subset(max, max$city == "belem")
amp_sala = subset(amp, amp$app == "belem_SALA") ## a divisao da cidade ficou errada
amp_D1 = subset(amp, amp$app == "belem_DORM1") ## a divisao da cidade ficou errada

max$strip_y = "Sep., 12 and 13\nMaximum"
amp_D1$strip_y = "Feb., 15 and 16\nHigher Thermal Amplitude"

max = subset(max, max$app == "DORM1")
max$date_teste = seq(ISOdate(2019,9,12,0,0,0),by='1 hour',length.out=2*24,tz='')

amp_D1$app = "DORM1"
amp_D1 = subset(amp_D1, amp_D1$app == "DORM1")
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

df$troca <- factor(df$troca, levels = c("System -", "NV Win -","NV Int -","W Win -","E Win -", "S Win -", "W E.Walls -",
                                        "E E.Walls -","S E.Walls -", "N E.Walls -","I.Walls -", "Floor -",
                                        "Roof -","System +","NV Win +","NV Int +","W Win +","E Win +","S Win +",
                                        "W E.Walls +","E E.Walls +","S E.Walls +","N E.Walls +","I.Walls +","Floor +",
                                        "Roof +","IL +"))

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
df$strip_y <- factor(df$strip_y, levels = c("Sep., 12 and 13\nMaximum", "Feb., 15 and 16\nHigher Thermal Amplitude"))

df_ac = subset(df, df$case_graph == "Air Conditioner")


# df_ac = subset(df, df$strip_y == "Jul., 15 and 16\nMinimum")


# df_ac$date_graph = strptime(df_ac$date_graph, "%Y-%m-%d %H:%M:%S", tz = "")

# df_ac$date_teste = seq(ISOdate(2019,df_ac$month,df_ac$day,0,0,0),by='1 hour',length.out=2*24,tz='')


png(filename = paste0("conv_heatmap_daily_belem_D1_ac_per.png"), width = 15, height = 10, units = "cm", res = 500)
plot(
  ggplot(df_ac,aes(x=date_teste,y=troca,fill=per))+
    geom_tile(color= "white",linewidth=0.1) +
    # geom_text(aes(label = round(kWh,0)), color = "black", size = 2)+
    scale_fill_gradientn(colours=c("#d8f3dc","#D9ED92","#B5E48C","#99D98C","#76C893","#52B69A","#34A0A4","#168AAD","#1A759F","#1E6091","#184E77"),
                         values=rescale(c(0,.10,.20,.30,.40,.50,.60,.70,.80,.90,1)),
                         limits = c(0,1),
                         guide="colorbar")+
    theme_minimal(base_size = 7)+
    labs(x="Hours", y="Heat Exchanges", fill = "HEI:")+
    theme(legend.position = "right",
          legend.key.width= unit(0.3, 'cm'),
          strip.background = element_rect(colour="white"),
          axis.ticks=element_blank(),
          axis.text.y =element_text(size=7),
          axis.text.x = element_text(size=6, angle = 90, vjust = 0.5, hjust = 1),
          legend.title=element_text(size=6),
          legend.text=element_text(size=6),
          strip.text = element_text(size = 7))+
    scale_x_datetime(date_breaks='4 hour', date_labels='%H:%M',expand = c(0, 0))+
    removeGrid()+
    facet_wrap(.~strip_y, scales = "free_x", ncol = 3)
)
dev.off()

df_hi = subset(df, df$case_graph == "Hybrid")

png(filename = paste0("conv_heatmap_daily_belem_D1_hi_per.png"), width = 15, height = 10, units = "cm", res = 500)
plot(
  ggplot(df_hi,aes(x=date_teste,y=troca,fill=per))+
    geom_tile(color= "white",linewidth=0.1) +
    # geom_text(aes(label = round(kWh,0)), color = "black", size = 2)+
    scale_fill_gradientn(colours=c("#d8f3dc","#D9ED92","#B5E48C","#99D98C","#76C893","#52B69A","#34A0A4","#168AAD","#1A759F","#1E6091","#184E77"),
                         values=rescale(c(0,.10,.20,.30,.40,.50,.60,.70,.80,.90,1)),
                         limits = c(0,1),
                         guide="colorbar")+
    theme_minimal(base_size = 7)+
    labs(x="Hours", y="Heat Exchanges", fill = "HEI:")+
    theme(legend.position = "right",
          legend.key.width= unit(0.3, 'cm'),
          strip.background = element_rect(colour="white"),
          axis.ticks=element_blank(),
          axis.text.y =element_text(size=7),
          axis.text.x = element_text(size=6, angle = 90, vjust = 0.5, hjust = 1),
          legend.title=element_text(size=6),
          legend.text=element_text(size=6),
          strip.text = element_text(size = 7))+
    scale_x_datetime(date_breaks='4 hour', date_labels='%H:%M',expand = c(0, 0))+
    removeGrid()+
    facet_wrap(.~strip_y, scales = "free_x", ncol = 3)
)
dev.off()

df_vn = subset(df, df$case_graph == "Natural Ventilation")
# df_vn = subset(df_vn, df_vn$troca_graph != "System")

png(filename = paste0("conv_heatmap_daily_belem_D1_vn_per.png"), width = 15, height = 10, units = "cm", res = 500)
plot(
  ggplot(df_vn,aes(x=date_teste,y=troca,fill=per))+
    geom_tile(color= "white",linewidth=0.1) +
    # geom_text(aes(label = round(kWh,0)), color = "black", size = 2)+
    scale_fill_gradientn(colours=c("#d8f3dc","#D9ED92","#B5E48C","#99D98C","#76C893","#52B69A","#34A0A4","#168AAD","#1A759F","#1E6091","#184E77"),
                         values=rescale(c(0,.10,.20,.30,.40,.50,.60,.70,.80,.90,1)),
                         limits = c(0,1),
                         guide="colorbar")+
    theme_minimal(base_size = 7)+
    labs(x="Hours", y="Heat Exchanges", fill = "HEI:")+
    theme(legend.position = "right",
          legend.key.width= unit(0.3, 'cm'),
          strip.background = element_rect(colour="white"),
          axis.ticks=element_blank(),
          axis.text.y =element_text(size=7),
          axis.text.x = element_text(size=6, angle = 90, vjust = 0.5, hjust = 1),
          legend.title=element_text(size=6),
          legend.text=element_text(size=6),
          strip.text = element_text(size = 7))+
    scale_x_datetime(date_breaks='4 hour', date_labels='%H:%M',expand = c(0, 0))+
    removeGrid()+
    facet_wrap(.~strip_y, scales = "free_x", ncol = 3)
)
dev.off()

