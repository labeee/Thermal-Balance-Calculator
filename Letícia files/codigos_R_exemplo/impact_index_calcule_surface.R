library(dplyr)
library(data.table)
library(stringr)

setwd("D:/OneDrive/OneDrive - UFSC/Artigos/2023_Thesis/simulacoes/2023-06-13/surface/reference") #pc labeee
# setwd("C:/Users/Letícia/OneDrive - UFSC/Artigos/2023_Thesis/simulacoes/2023-06-13/convection/reference/") #pc leticia
# setwd("C:/Users/Letícia/OneDrive - UFSC/Artigos/2023_Thesis/simulacoes/2023-06-13/surface/reference/") #pc leticia

# timestep = "annual"
# timestep = "monthly"
# timestep = "daily_amp_inverno"
timestep = "daily_amp_verao"
# timestep = "daily_max"
# timestep = "daily_min"

file_list = intersect(list.files(pattern=".csv"), list.files(pattern=timestep))

trocas = list()
for (i in seq_along(file_list)) {
  df = read.csv(file_list[i]) %>% select(- "X")
  
  trocas[[i]] = df
}

##arrumando as colunas dentro da lista
for(i in c(1:length(trocas))){
  trocas[[i]]$city = ifelse(substr(timestep, 1,5) == "daily", str_split_fixed(file_list, "_", 5)[i,3], #pegando a info de cidade do file_list
                            str_split_fixed(file_list, "_", 3)[i,2])
  trocas[[i]]$app = ifelse(substr(timestep, 1,5) == "daily", gsub(".csv*", "", str_split_fixed(file_list, "_", 4)[i,4]), #pegando a info de APP do file_list
                           gsub(".csv*", "", str_split_fixed(file_list, "_", 3)[i,3]))
  trocas[[i]]$case_graph = ifelse(str_split_fixed(trocas[[i]]$case, "_", 6)[,4] == "ac", "Air Conditioner", 
                                  ifelse(str_split_fixed(trocas[[i]]$case, "_", 6)[,4] == "vn", "Natural Ventilation", "Hybrid"))
  trocas[[i]]$gains = ifelse(str_split_i(trocas[[i]]$gains_losses, "_", -1) == "gains", "gain", 
                             ifelse(str_split_i(trocas[[i]]$gains_losses, "_", -1) == "cooling", "loss",
                                    ifelse(str_split_i(trocas[[i]]$gains_losses, "_", -1) == "heating", "gain",
                                    str_split_i(trocas[[i]]$gains_losses, "_", -1))))
  trocas[[i]]$exchange = ifelse(str_split_fixed(trocas[[i]]$gains_losses, "_", 3)[,1] == "none", 
                                str_split_fixed(trocas[[i]]$gains_losses, "_", 3)[,2], 
                                ifelse((str_split_fixed(trocas[[i]]$gains_losses, "_", 3)[,1] == "cooling" | str_split_fixed(trocas[[i]]$gains_losses, "_", 3)[,1] == "heating"), 
                                       str_split_fixed(trocas[[i]]$gains_losses, "_", 3)[,1],
                                       paste(str_split_fixed(trocas[[i]]$gains_losses, "_", 3)[,1], str_split_fixed(trocas[[i]]$gains_losses, "_", 3)[,2], sep = "_")))
  trocas[[i]]$flux = str_split_fixed(trocas[[i]]$gains_losses, "_", 4)[,3]
  
  if(timestep == "monthly"){
    trocas[[i]] = transform(trocas[[i]], MonthAbb = month.abb[month])
  }else{NA}
}

##calculando o percentual

if(timestep == "monthly"){
  for(i in c(1:length(trocas))){
    for(j in c(1:nrow(trocas[[i]]))){
      c = trocas[[i]]$case[j]
      k = trocas[[i]]$gains[j]
      m = trocas[[i]]$MonthAbb[j]
      f = trocas[[i]]$flux[j]
      e = trocas[[i]]$exchange[j]
      
      
      # trocas[[i]]$per[j] = ifelse(trocas[[i]]$value[j] != 0,
      #                             round(trocas[[i]]$value[j]/sum(trocas[[i]]$value[which(trocas[[i]]$gains == k & trocas[[i]]$case == c & trocas[[i]]$MonthAbb == m)]),4),
      #                             0)
      # trocas[[i]]$per[j] = ifelse(trocas[[i]]$value[j] != 0,
      #                             round(trocas[[i]]$value[j]/sum(trocas[[i]]$value[which(trocas[[i]]$gains == k & trocas[[i]]$case == c & trocas[[i]]$MonthAbb == m & trocas[[i]]$flux == f)]),4),
      #                             0)
      
      trocas[[i]]$sum[j] = sum(trocas[[i]]$value[which(trocas[[i]]$gains == k & trocas[[i]]$case == c & trocas[[i]]$MonthAbb == m & trocas[[i]]$exchange == e)])
      trocas[[i]]$per[j] = ifelse(trocas[[i]]$value[j] != 0,
                                  round(trocas[[i]]$value[j]/trocas[[i]]$sum[j],4),0)
      
    }
  }
}else{
  if(timestep == "annual"){
    for(i in c(1:length(trocas))){
      for(j in c(1:nrow(trocas[[i]]))){
        c = trocas[[i]]$case[j]
        k = trocas[[i]]$gains[j]
        f = trocas[[i]]$flux[j]
        e = trocas[[i]]$exchange[j]
        
        # trocas[[i]]$per[j] = ifelse(trocas[[i]]$value[j] != 0,
        #                             round(trocas[[i]]$value[j]/sum(trocas[[i]]$value[which(trocas[[i]]$gains == k & trocas[[i]]$case == c)]),4),
        #                             0)
        # trocas[[i]]$per[j] = ifelse(trocas[[i]]$value[j] != 0,
        #          round(trocas[[i]]$value[j]/sum(trocas[[i]]$value[which(trocas[[i]]$gains == k & trocas[[i]]$case == c & trocas[[i]]$flux == f)]),4),
        #        0)
        trocas[[i]]$sum[j] = sum(trocas[[i]]$value[which(trocas[[i]]$gains == k & trocas[[i]]$case == c & trocas[[i]]$exchange == e)])
        trocas[[i]]$per[j] = ifelse(trocas[[i]]$value[j] != 0,
                                    round(trocas[[i]]$value[j]/trocas[[i]]$sum[j],4),0)
       
      }
    }
  }else{
    for(i in c(1:length(trocas))){
      for(j in c(1:nrow(trocas[[i]]))){
        c = trocas[[i]]$case[j]
        k = trocas[[i]]$gains[j]
        m = trocas[[i]]$month[j]
        # h = trocas[[i]]$city[j]
        # p = trocas[[i]]$app[j]
        d = trocas[[i]]$day[j]
        t = trocas[[i]]$time[j]
        f = trocas[[i]]$flux[j]
        e = trocas[[i]]$exchange[j]
        
        # trocas[[i]]$per[j] = ifelse(trocas[[i]]$value[j] != 0,
        #   round(trocas[[i]]$value[j]/sum(trocas[[i]]$value[which(trocas[[i]]$gains == k & trocas[[i]]$case == c & trocas[[i]]$time == t & trocas[[i]]$day == d & trocas[[i]]$month == m & trocas[[i]]$flux == f)]),4),
        #        0)
        # trocas[[i]]$per[j] = ifelse(trocas[[i]]$value[j] != 0,
        #                             round(trocas[[i]]$value[j]/sum(trocas[[i]]$value[which(trocas[[i]]$gains == k & trocas[[i]]$case == c & trocas[[i]]$time == t & trocas[[i]]$day == d & trocas[[i]]$month == m)]),4),
        #                             0)
        
        trocas[[i]]$sum[j] = sum(trocas[[i]]$value[which(trocas[[i]]$gains == k & trocas[[i]]$case == c & trocas[[i]]$time == t & trocas[[i]]$day == d & trocas[[i]]$month == m & trocas[[i]]$exchange == e)])
        
        trocas[[i]]$per[j] = ifelse(trocas[[i]]$value[j] != 0,
                                    round(trocas[[i]]$value[j]/trocas[[i]]$sum[j],4),
                                    0)
        
      }
    }
  }
}

trocas_graph = do.call(rbind.data.frame, trocas)

setwd("D:/OneDrive/OneDrive - UFSC/Artigos/2023_Thesis/simulacoes/2023-06-13/surface/reference/graph/") #pc labeee
# setwd("C:/Users/Letícia/OneDrive - UFSC/Artigos/2023_Thesis/simulacoes/2023-06-13/surface/reference/graph/")

write.csv(trocas_graph, paste0("per_",timestep,".csv"))
