  library(stringr)
  library(ggplot2)
  library(hrbrthemes)
  library(viridis)
  library(scales)
  library(ggExtra)
  
  setwd("D:/OneDrive/OneDrive - UFSC/Artigos/2023_Thesis/simulacoes/2023-06-13/surface/reference/graph") #pc leticia
  # setwd("C:/Users/Letícia/OneDrive - UFSC/Artigos/2023_Thesis/simulacoes/2023-06-13/surface/reference/graph/")
  
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
  
  ano$kWh = ano$value/1000
  
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
  
  mes$kWh = mes$value/1000
  
  mes = transform(mes, MonthAbb = month.abb[month])
  
  ano = subset(ano, select = c("city","flux","case_graph","app","gains","troca_graph","value","kWh","per"))
  ano$MonthAbb = "Annual"
  
  mes = subset(mes, select = c("city","flux","case_graph","app","gains","troca_graph","MonthAbb","value","kWh","per"))
  
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

# df$troca <- factor(df$troca, levels = c("Convection: W E.Walls -","Convection: E E.Walls -","Convection: S E.Walls -", "Convection: N E.Walls -",
#                                         "Convection: I.Walls -", "Convection: Floor -","Convection: Roof -",
#                                         "Conduction: W E.Walls -","Conduction: E E.Walls -","Conduction: S E.Walls -", "Conduction: N E.Walls -",
#                                         "Conduction: I.Walls -", "Conduction: Floor -","Conduction: Roof -",
#                                         "Solar Rad.: W E.Walls -","Solar Rad.: E E.Walls -","Solar Rad.: S E.Walls -", "Solar Rad.: N E.Walls -",
#                                         "Solar Rad.: I.Walls -", "Solar Rad.: Floor -","Solar Rad.: Roof -",
#                                         "SW. Lights: W E.Walls -","SW. Lights: E E.Walls -","SW. Lights: S E.Walls -", "SW. Lights: N E.Walls -",
#                                         "SW. Lights: I.Walls -", "SW. Lights: Floor -","SW. Lights: Roof -",
#                                         "LW. Internal: W E.Walls -","LW. Internal: E E.Walls -","LW. Internal: S E.Walls -", "LW. Internal: N E.Walls -",
#                                         "LW. Internal: I.Walls -", "LW. Internal: Floor -","LW. Internal: Roof -",
#                                         "Convection: W E.Walls +","Convection: E E.Walls +","Convection: S E.Walls +","Convection: N E.Walls +","Convection: I.Walls +",
#                                         "Convection: Floor +","Convection: Roof +",
#                                         "Conduction: W E.Walls +","Conduction: E E.Walls +","Conduction: S E.Walls +","Conduction: N E.Walls +","Conduction: I.Walls +",
#                                         "Conduction: Floor +","Conduction: Roof +",
#                                         "Solar Rad.: W E.Walls +","Solar Rad.: E E.Walls +","Solar Rad.: S E.Walls +","Solar Rad.: N E.Walls +","Solar Rad.: I.Walls +",
#                                         "Solar Rad.: Floor +","Solar Rad.: Roof +",
#                                         "SW. Lights: W E.Walls -","SW. Lights: E E.Walls -","SW. Lights: S E.Walls -", "SW. Lights: N E.Walls -",
#                                         "SW. Lights: I.Walls -", "SW. Lights: Floor -","SW. Lights: Roof -",
#                                         "LW. Internal: W E.Walls +","LW. Internal: E E.Walls +","LW. Internal: S E.Walls +","LW. Internal: N E.Walls +","LW. Internal: I.Walls +",
#                                         "LW. Internal: Floor +","LW. Internal: Roof +"))

df$troca <- factor(df$troca, levels = c("W E.Walls -","E E.Walls -","S E.Walls -","N E.Walls -","I.Walls -","Floor -","Roof -",
                                        "W E.Walls +","E E.Walls +","S E.Walls +","N E.Walls +","I.Walls +","Floor +","Roof +"))

df$cidade[df$city == "belem"] = "Belém"
df$cidade[df$city == "saopaulo"] = "São Paulo"

df$app_graph[df$app == "SALA"] = "Living Room"
df$app_graph[df$app == "DORM1"] = "Bedroom 1"
df$app_graph[df$app == "DORM2"] = "Bedroom 2"

df$strip_x = paste0(df$cidade, "\n", df$app_graph)

# be = subset(df, df$city == "belem")

df$strip_x <- factor(df$strip_x, levels = c("Belém\nLiving Room","São Paulo\nLiving Room","Belém\nBedroom 1", "São Paulo\nBedroom 1", "Belém\nBedroom 2", "São Paulo\nBedroom 2"))
# df$strip_y = paste0(df$case_graph,"\n",df$flux)
# df$strip_y <- factor(df$strip_y, levels = c("Air Conditioner\nConvection","Air Conditioner\nConduction","Air Conditioner\nSolar Rad.",
                                            # "Air Conditioner\nLW. Surfaces","Air Conditioner\nLW. Internal","Air Conditioner\nSW. Lights",
                                            # "Hybrid\nConvection","Hybrid\nConduction","Hybrid\nSolar Rad.",
                                            # "Hybrid\nLW. Surfaces","Hybrid\nLW. Internal","Hybrid\nSW. Lights",
                                            # "Natural Ventilation\nConvection","Natural Ventilation\nConduction","Natural Ventilation\nSolar Rad.",
                                            # "Natural Ventilation\nLW. Surfaces","Natural Ventilation\nLW. Internal","Natural Ventilation\nSW. Lights"))

df$flux[df$flux == "convection"] = "Convection"
df$flux[df$flux == "conduction"] = "Conduction"
df$flux[df$flux == "lwsurfaces"] = "LW. Surfaces"
df$flux[df$flux == "solarrad"] = "Solar Rad."
df$flux[df$flux == "swlights"] = "SW. Lights"
df$flux[df$flux == "lwinternal"] = "LW. Internal"

solar = subset(df, df$flux == "Solar Rad." | df$flux == "LW. Internal" | df$flux == "SW. Lights")
solar = subset(solar, solar$gains != "loss")
df = subset(df, df$flux != "Solar Rad." & df$flux != "LW. Internal" & df$flux != "SW. Lights")

df = rbind(df, solar)

df$flux = factor(df$flux, levels = c("Convection","Conduction","LW. Surfaces","Solar Rad.","LW. Internal","SW. Lights"))

graph_ac = subset(df, df$case_graph == "Air Conditioner")
graph_ac = subset(graph_ac, graph_ac$app == "SALA" | graph_ac$app == "DORM1")
graph_ac = subset(graph_ac, graph_ac$flux != "LW. Internal" & graph_ac$flux != "SW. Lights")

graph_vn = subset(df, df$case_graph == "Natural Ventilation")
graph_vn = subset(graph_vn, graph_vn$app == "SALA" | graph_vn$app == "DORM1")
graph_vn = subset(graph_vn, graph_vn$flux != "LW. Internal" & graph_vn$flux != "SW. Lights")

graph_hi = subset(df, df$case_graph == "Hybrid")
graph_hi = subset(graph_hi, graph_hi$app == "SALA" | graph_hi$app == "DORM1")
graph_hi = subset(graph_hi, graph_hi$flux != "LW. Internal" & graph_hi$flux != "SW. Lights")

graph_ac$flux = factor(graph_ac$flux, levels = c("Convection","Conduction","Solar Rad.","LW. Surfaces"))
graph_vn$flux = factor(graph_vn$flux, levels = c("Convection","Conduction","Solar Rad.","LW. Surfaces"))
graph_hi$flux = factor(graph_hi$flux, levels = c("Convection","Conduction","Solar Rad.","LW. Surfaces"))


# png(filename = paste0("legend.png"), width = 15, height = 22, units = "cm", res = 500)
# plot(
#   ggplot(graph_ac,aes(x=MonthAbb,y=troca,fill=per))+
#     geom_tile(color= "white",linewidth=0.1) +
#     # geom_text(aes(label = round(kWh,0)), color = "black", size = 2)+
#     scale_fill_gradientn(colours=c("#a8dadc","#ffcf70","#ffc243","#ffad03","#fa8b01","#f56a00","#7a0103"),
#                          values=rescale(c(0,.05,.1,0.15,0.2,0.25,.3,0.35)),
#                          limits = c(0,0.30),
#                          breaks = c(0,0.1,0.2,0.3),
#                          guide="colorbar")+
#     theme_minimal(base_size = 6)+
#     labs(x=NULL, y="Heat Exchanges", fill = "Heat Exchanges Index:")+
#     theme(legend.position = "bottom",
#           legend.key.width= unit(0.3, 'cm'),
#           strip.background = element_rect(colour="white"),
#           axis.ticks=element_blank(),
#           axis.text.y =element_text(size=6),
#           axis.text.x = element_text(size=6, angle = 90, vjust = 0.5, hjust = 1),
#           legend.title=element_text(size=6),
#           legend.text=element_text(size=6),
#           strip.text = element_text(size = 6))+
#     removeGrid()+
#     facet_grid(flux~strip_x, scales = "free_y")
# )
# dev.off()

png(filename = paste0("heatmap_monthly_ac_per_full.png"), width = 15, height = 16, units = "cm", res = 500)
plot(
  ggplot(graph_ac,aes(x=MonthAbb,y=troca,fill=per))+
    geom_tile(color= "white",linewidth=0.1) +
    # geom_text(aes(label = round(kWh,0)), color = "black", size = 2)+
    scale_fill_gradientn(colours=c("#8ecae6","#a8dadc","#ffcf70","#ffc243","#ffc300","#f4a261","#fa8b01","#e85d04","#dc2f02","#d00000","#7a0103"),
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
    facet_grid(flux~strip_x, scales = "free", space = "free_y")
)
dev.off()

png(filename = paste0("heatmap_monthly_vn_per_full.png"), width = 15, height = 16, units = "cm", res = 500)
plot(
  ggplot(graph_vn,aes(x=MonthAbb,y=troca,fill=per))+
    geom_tile(color= "white",linewidth=0.1) +
    # geom_text(aes(label = round(kWh,0)), color = "black", size = 2)+
    scale_fill_gradientn(colours=c("#8ecae6","#a8dadc","#ffcf70","#ffc243","#ffc300","#f4a261","#fa8b01","#e85d04","#dc2f02","#d00000","#7a0103"),
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
    facet_grid(flux~strip_x, scales = "free", space = "free_y")
)
dev.off()

png(filename = paste0("heatmap_monthly_hi_per_full.png"), width = 15, height = 16, units = "cm", res = 500)
plot(
  ggplot(graph_hi,aes(x=MonthAbb,y=troca,fill=per))+
    geom_tile(color= "white",linewidth=0.1) +
    # geom_text(aes(label = round(kWh,0)), color = "black", size = 2)+
    scale_fill_gradientn(colours=c("#8ecae6","#a8dadc","#ffcf70","#ffc243","#ffc300","#f4a261","#fa8b01","#e85d04","#dc2f02","#d00000","#7a0103"),
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
    facet_grid(flux~strip_x, scales = "free", space = "free_y")
)
dev.off()

# png(filename = paste0("heatmap_monthly_ac_per.png"), width = 15, height = 10, units = "cm", res = 500)
# plot(
#   ggplot(graph_ac,aes(x=MonthAbb,y=troca,fill=per))+
#     geom_tile(color= "white",linewidth=0.1) +
#     # geom_text(aes(label = round(kWh,0)), color = "black", size = 2)+
#     scale_fill_gradientn(colours=c("#a8dadc","#ffcf70","#ffc243","#ffad03","#fa8b01","#f56a00","#7a0103"),
#                          values=rescale(c(0,.05,.1,0.15,0.2,0.25,.3,0.35)),
#                          limits = c(0,0.30),
#                          breaks = c(0,0.1,0.2,0.3),
#                          guide="colorbar")+
#     theme_minimal(base_size = 6)+
#     labs(x=NULL, y="Heat Exchanges")+
#     theme(legend.position = "none",
#           strip.background = element_rect(colour="white"),
#           axis.ticks=element_blank(),
#           axis.text.y =element_text(size=6),
#           axis.text.x = element_blank(),
#           strip.text.y = element_text(size = 7),
#           strip.text.x = element_blank())+
#     removeGrid()+
#     facet_grid(flux~strip_x, scales = "free_y")
# )
# dev.off()
# 
# png(filename = paste0("heatmap_monthly_vn_per.png"), width = 15, height = 10, units = "cm", res = 500)
# plot(
#   ggplot(graph_vn,aes(x=MonthAbb,y=troca,fill=per))+
#     geom_tile(color= "white",linewidth=0.1) +
#     # geom_text(aes(label = round(kWh,0)), color = "black", size = 2)+
#     scale_fill_gradientn(colours=c("#a8dadc","#ffcf70","#ffc243","#ffad03","#fa8b01","#f56a00","#7a0103"),
#                          values=rescale(c(0,.05,.1,0.15,0.2,0.25,.3,0.35)),
#                          limits = c(0,0.30),
#                          breaks = c(0,0.1,0.2,0.3),
#                          guide="colorbar")+
#     theme_minimal(base_size = 6)+
#     labs(x=NULL, y="Heat Exchanges")+
#     theme(legend.position = "none",
#           strip.background = element_rect(colour="white"),
#           axis.ticks=element_blank(),
#           axis.text.y =element_text(size=6),
#           axis.text.x = element_blank(),
#           strip.text.y = element_text(size = 7),
#           strip.text.x = element_blank())+
#     removeGrid()+
#     facet_grid(flux~strip_x, scales = "free_y")
# )
# dev.off()
# 
# png(filename = paste0("heatmap_monthly_hi_per.png"), width = 15, height = 10, units = "cm", res = 500)
# plot(
#   ggplot(graph_hi,aes(x=MonthAbb,y=troca,fill=per))+
#     geom_tile(color= "white",linewidth=0.1) +
#     # geom_text(aes(label = round(kWh,0)), color = "black", size = 2)+
#     scale_fill_gradientn(colours=c("#a8dadc","#ffcf70","#ffc243","#ffad03","#fa8b01","#f56a00","#7a0103"),
#                          values=rescale(c(0,.05,.1,0.15,0.2,0.25,.3,0.35)),
#                          limits = c(0,0.30),
#                          breaks = c(0,0.1,0.2,0.3),
#                          guide="colorbar")+
#     theme_minimal(base_size = 6)+
#     labs(x=NULL, y="Heat Exchanges")+
#     theme(legend.position = "none",
#           strip.background = element_rect(colour="white"),
#           axis.ticks=element_blank(),
#           axis.text.y =element_text(size=6),
#           axis.text.x = element_blank(),
#           strip.text.y = element_text(size = 7),
#           strip.text.x = element_blank())+
#     removeGrid()+
#     facet_grid(flux~strip_x, scales = "free_y")
# )
# dev.off()