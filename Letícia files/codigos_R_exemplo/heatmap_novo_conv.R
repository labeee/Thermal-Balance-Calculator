library(stringr)
library(ggplot2)
library(hrbrthemes)
library(viridis)
library(scales)
library(ggExtra)

# setwd("D:/OneDrive/OneDrive - UFSC/Artigos/2023_Thesis/simulacoes/2023-06-13/convection/reference/graphs") #pc leticia
setwd("C:/Users/Letícia/OneDrive - UFSC/Artigos/2023_Thesis/simulacoes/2023-06-13/convection/reference/graphs")

##fazendo o grafico anual e mensal juntos ----

timestep = "annual"
# timestep = "monthly"
# timestep = "daily_amp_inverno"
# timestep = "daily_amp_verao"
# timestep = "daily_max"
# timestep = "daily_min"

ano = read.csv(paste0("per_",timestep,".csv"))

ano = subset(ano, ano$case != "U001_Caso01_1a7_ac_nbr_1.csv")

ano$troca_graph[ano$exchange== "roof"] = "Roof"
ano$troca_graph[ano$exchange== "floor"] = "Floor"
ano$troca_graph[ano$exchange== "intwalls"] = "I.Walls"
ano$troca_graph[ano$exchange== "south_extwalls"] = "S E.Walls"
ano$troca_graph[ano$exchange== "north_extwalls"] = "N E.Walls"
ano$troca_graph[ano$exchange== "west_extwalls"] = "W E.Walls"
ano$troca_graph[ano$exchange== "east_extwalls"] = "E E.Walls"
ano$troca_graph[ano$exchange== "south_windows"] = "S Win"
ano$troca_graph[ano$exchange== "east_windows"] = "E Win"
ano$troca_graph[ano$exchange== "west_windows"] = "W Win"
ano$troca_graph[ano$exchange== "internal_gains"] = "IL"
ano$troca_graph[ano$exchange== "cooling"] = "Cooling"
ano$troca_graph[ano$exchange== "heating"] = "Heating"
ano$troca_graph[ano$exchange== "vn_window"] = "NV Win"
ano$troca_graph[ano$exchange== "vn_interzone"] = "NV Int"

ano$kWh = ano$value/1000

cooling = subset(ano, ano$troca_graph == "Cooling")
cooling$troca_graph = "System"
heating = subset(ano, ano$troca_graph == "Heating")
heating$troca_graph = "System"

ano = subset(ano, ano$troca_graph != "Cooling" & ano$troca_graph != "Heating")

ano = rbind(ano, cooling, heating)

# timestep = "annual"
timestep = "monthly"
# timestep = "daily_amp_inverno"
# timestep = "daily_amp_verao"
# timestep = "daily_max"
# timestep = "daily_min"

mes = read.csv(paste0("per_",timestep,".csv"))

mes = subset(mes, mes$case != "U001_Caso01_1a7_ac_nbr_1.csv")

mes$troca_graph[mes$exchange== "roof"] = "Roof"
mes$troca_graph[mes$exchange== "floor"] = "Floor"
mes$troca_graph[mes$exchange== "intwalls"] = "I.Walls"
mes$troca_graph[mes$exchange== "south_extwalls"] = "S E.Walls"
mes$troca_graph[mes$exchange== "north_extwalls"] = "N E.Walls"
mes$troca_graph[mes$exchange== "west_extwalls"] = "W E.Walls"
mes$troca_graph[mes$exchange== "east_extwalls"] = "E E.Walls"
mes$troca_graph[mes$exchange== "south_windows"] = "S Win"
mes$troca_graph[mes$exchange== "east_windows"] = "E Win"
mes$troca_graph[mes$exchange== "west_windows"] = "W Win"
mes$troca_graph[mes$exchange== "internal_gains"] = "IL"
mes$troca_graph[mes$exchange== "cooling"] = "Cooling"
mes$troca_graph[mes$exchange== "heating"] = "Heating"
mes$troca_graph[mes$exchange== "vn_window"] = "NV Win"
mes$troca_graph[mes$exchange== "vn_interzone"] = "NV Int"

mes$kWh = mes$value/1000

mes = transform(mes, MonthAbb = month.abb[month])

ano = subset(ano, select = c("city","case_graph","app","gains","troca_graph","value","kWh","per"))
ano$MonthAbb = "Annual"

mes = subset(mes, select = c("city","case_graph","app","gains","troca_graph","MonthAbb","value","kWh","per"))

cooling = subset(mes, mes$troca_graph == "Cooling")
cooling$troca_graph = "System"
heating = subset(mes, mes$troca_graph == "Heating")
heating$troca_graph = "System"

mes = subset(mes, mes$troca_graph != "Cooling" & mes$troca_graph != "Heating")

mes = rbind(mes, cooling, heating)

df = rbind(ano, mes)

# df$per = round(df$per*100,1)

df$MonthAbb <- factor(df$MonthAbb, levels = c("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec","Annual"))

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

df$cidade[df$city == "belem"] = "Belém"
df$cidade[df$city == "saopaulo"] = "São Paulo"

df$app_graph[df$app == "SALA"] = "Living Room"
df$app_graph[df$app == "DORM1"] = "Bedroom 1"
df$app_graph[df$app == "DORM2"] = "Bedroom 2"

df$strip_x = paste0(df$cidade, "\n", df$app_graph)

be = subset(df, df$city == "belem")

df$strip_x <- factor(df$strip_x, levels = c("Belém\nLiving Room","São Paulo\nLiving Room","Belém\nBedroom 1", "São Paulo\nBedroom 1", "Belém\nBedroom 2", "São Paulo\nBedroom 2"))

graph = subset(df, df$app == "SALA" | df$app == "DORM1")

png(filename = paste0("conv_heatmap_monthly_per.png"), width = 15, height = 22, units = "cm", res = 500)
plot(
  ggplot(graph,aes(x=MonthAbb,y=troca,fill=per))+
    geom_tile(color= "white",linewidth=0.1) +
    # geom_text(aes(label = round(kWh,0)), color = "black", size = 2)+
    scale_fill_gradientn(colours=c("#d8f3dc","#D9ED92","#B5E48C","#99D98C","#76C893","#52B69A","#34A0A4","#168AAD","#1A759F","#1E6091","#184E77"),
                         values=rescale(c(0,10,20,30,40,50,60,70,80,90,100)),
                         limits = c(0,1),
                         guide="colorbar")+
    theme_minimal(base_size = 8)+
    labs(x=NULL, y="Heat Exchanges", fill = "Heat Exchanges Index:")+
    theme(legend.position = "bottom",
          legend.key.width= unit(0.3, 'cm'),
          strip.background = element_rect(colour="white"),
          axis.ticks=element_blank(),
          axis.text.y =element_text(size=8),
          axis.text.x = element_text(size=8, angle = 90, vjust = 0.5, hjust = 1),
          legend.title=element_text(size=8),
          legend.text=element_text(size=7),
          strip.text = element_text(size = 8))+
    removeGrid()+
    facet_grid(case_graph~strip_x, scales = "free_y")
)
dev.off()


png(filename = paste0("conv_heatmap_monthly_per_teste.png"), width = 15, height = 20, units = "cm", res = 500)
plot(
  ggplot(graph,aes(x=MonthAbb,y=troca,fill=per))+
    geom_tile(color= "white",linewidth=0.1) +
    # geom_text(aes(label = round(kWh,0)), color = "black", size = 2)+
    scale_fill_gradientn(colours=c("#d8f3dc","#D9ED92","#B5E48C","#99D98C","#76C893","#52B69A","#34A0A4","#168AAD","#1A759F","#1E6091","#184E77"),
                         values=rescale(c(0,.10,.20,.30,.40,.50,.60,.70,.80,.90,1)),
                         limits = c(0,1),
                         guide="colorbar")+
    theme_minimal(base_size = 8)+
    labs(x=NULL, y="Heat Exchanges", fill = "HEI:")+
    theme(legend.position = "right",
          legend.key.width= unit(0.3, 'cm'),
          strip.background = element_rect(colour="white"),
          axis.ticks=element_blank(),
          axis.text.y =element_text(size=8),
          axis.text.x = element_text(size=7, angle = 90, vjust = 0.5, hjust = 1),
          legend.title=element_text(size=7),
          legend.text=element_text(size=7),
          strip.text = element_text(size = 8))+
    removeGrid()+
    facet_grid(case_graph~strip_x, scales = "free_y")
)
dev.off()

living = subset(df, df$app == "SALA")


png(filename = paste0("conv_heatmap_monthly_sala_kWh.png"), width = 15, height = 22, units = "cm", res = 500)
plot(
  ggplot(living,aes(x=MonthAbb,y=troca,fill=per))+
    geom_tile(color= "white",linewidth=0.1) +
    geom_text(aes(label = round(kWh,0)), color = "darkgray", size = 2)+
    scale_fill_gradientn(colours=c("#d8f3dc","#D9ED92","#B5E48C","#99D98C","#76C893","#52B69A","#34A0A4","#168AAD","#1A759F","#1E6091","#184E77"),
                         values=rescale(c(0,10,20,30,40,50,60,70,80,90,100)),
                         limits = c(0,1),
                         guide="colorbar")+
    theme_minimal(base_size = 8)+
    labs(x=NULL, y="Heat Exchanges", fill = "Heat Exchanges Index:")+
    theme(legend.position = "bottom",
          legend.key.width= unit(0.3, 'cm'),
          strip.background = element_rect(colour="white"),
          axis.ticks=element_blank(),
          axis.text.y =element_text(size=8),
          axis.text.x = element_text(size=8, angle = 90, vjust = 0.5, hjust = 1),
          legend.title=element_text(size=8),
          legend.text=element_text(size=7),
          strip.text = element_text(size = 8))+
    removeGrid()+
    facet_grid(case_graph~strip_x, scales = "free_y")
)
dev.off()

d1 = subset(df, df$app == "DORM1")


png(filename = paste0("conv_heatmap_monthly_d1_kWh.png"), width = 15, height = 22, units = "cm", res = 500)
plot(
  ggplot(d1,aes(x=MonthAbb,y=troca,fill=per))+
    geom_tile(color= "white",linewidth=0.1) +
    geom_text(aes(label = round(kWh,0)), color = "darkgray", size = 2)+
    scale_fill_gradientn(colours=c("#d8f3dc","#D9ED92","#B5E48C","#99D98C","#76C893","#52B69A","#34A0A4","#168AAD","#1A759F","#1E6091","#184E77"),
                         values=rescale(c(0,10,20,30,40,50,60,70,80,90,100)),
                         limits = c(0,1),
                         guide="colorbar")+
    theme_minimal(base_size = 8)+
    labs(x=NULL, y="Heat Exchanges", fill = "Heat Exchanges Index:")+
    theme(legend.position = "bottom",
          legend.key.width= unit(0.3, 'cm'),
          strip.background = element_rect(colour="white"),
          axis.ticks=element_blank(),
          axis.text.y =element_text(size=8),
          axis.text.x = element_text(size=8, angle = 90, vjust = 0.5, hjust = 1),
          legend.title=element_text(size=8),
          legend.text=element_text(size=7),
          strip.text = element_text(size = 8))+
    removeGrid()+
    facet_grid(case_graph~strip_x, scales = "free_y")
)
dev.off()

# png(filename = paste0("conv_heatmap_monthly_kWh.png"), width = 15, height = 22, units = "cm", res = 500)
# plot(
#   ggplot(graph,aes(x=MonthAbb,y=troca,fill=kWh))+
#     geom_tile(color= "white",linewidth=0.1) +
#     # geom_text(aes(label = round(kWh,0)), color = "black", size = 2)+
#     # scale_fill_gradientn(colours=c("#99D98C","#D9ED92","#d8f3dc","#76C893","#52B69A","#34A0A4","#168AAD","#1A759F","#1E6091","#184E77"),
#     #                      values=rescale(c(2000,1000,0,-1000,-2000,-3000,-4000,-5000,-6000,-7000)),
#     #                      # limits = c(0,100),
#     #                      guide="colorbar")+
#     theme_minimal(base_size = 8)+
#     labs(x=NULL, y="Months", fill = "Gains and Losses values [kWh]:")+
#     theme(legend.position = "bottom",
#           strip.background = element_rect(colour="white"),
#           axis.ticks=element_blank(),
#           axis.text.y =element_text(size=8),
#           axis.text.x = element_text(size=6, angle = 90, vjust = 0.5, hjust = 1),
#           legend.title=element_text(size=8),
#           legend.text=element_text(size=7),
#           strip.text = element_text(size = 8))+
#     removeGrid()+
#     facet_grid(case_graph~strip_x)
# )
# dev.off()