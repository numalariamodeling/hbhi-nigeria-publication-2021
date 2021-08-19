ifelse(!dir.exists(file.path(ResultDir, "ITN")), 
       dir.create(file.path(ResultDir, "ITN")), FALSE)
print_path <- file.path(ResultDir, "ITN")



# ITN coverage for year 2003 - 2018 with mapping script 

if (Variable == "ITN"){
  itn.ls <-read.files( ".*NGPR.*\\.DTA", DataDir, read_dta)
  itn.ls[[1]] <- NULL 
  itn.ls <- map(itn.ls, survey.month.fun)
  itn.ls <- lapply(itn.ls, subset, hv103 == 1)#slept in the household the night before (hv103)
  itn.ls <- lapply(itn.ls, recode_itn)
  #itn.ls <- map(itn.ls, survey.month.fun)
  
  #monthly ITN use values 
  col_names = c('YYYY', 'MM', 'hh_itn', 'hv005', 'v001', 'hv008', 'hv007', 'hv016', 'hv022', 'hv021')
  itn_ls_m = lapply(itn.ls, "[", col_names)
  itn_df <- plyr::ldply(itn_ls_m, rbind)
  itn_df<-itn_df %>% mutate(wt=hv005/1000000,strat=hv022,
           id=hv021, num_p=1)
  table(itn_df$MM)
  table(itn_df$YYYY)
  svyd <- svydesign.fun(itn_df)
  itn_use_month<-svyby(formula=~hh_itn, by=~MM, FUN=svymean, svyd, na.rm=T)
  write.csv(itn_use_month, paste0(print_path, "/", "itn_monthly_values.csv"))
  
  #continue making yearly values
  key_list[[1]] <- NULL
  NGAshplist[[1]]<- NULL
  NGA_ID <- lapply(NGAshplist, "[[", "DHSCLUST")
  key_list <- Map(cbind, key_list, v001 = NGA_ID)
  itn.ls <- map2(itn.ls, key_list, left_join)
  rep_DS.ls <- list(rep_DS)
 


      if (age == "18 or greater"){
        itn.ls <- lapply(itn.ls, subset, hv105 > 18)
      }else if (age == "U5"){
        itn.ls <-lapply(itn.ls, subset, hv105 <= 5)
      }else if (age == "6-9"){
        itn.ls <-lapply(itn.ls, subset, hv105 > 5 & hv105 < 10)
      }else if (age == "10-18"){
        itn.ls <-lapply(itn.ls, subset, hv105 > 9 & hv105 < 19)
      }else {
        itn.ls <- itn.ls
      }
      
  
  
      if (grepl("LGA|State|repDS|region|manuscript", subVariable)) {
        comboITN.list  <- map2(itn.ls, rep_DS.ls, left_join) #PR datasets
        LGA_sf <- LGA_clean_names%>%  as_tibble() %>% dplyr::select(LGA, State)
        repDS_LGA<- rep_DS %>% left_join(LGA_sf)
        
        
        if(subVariable == "LGA"){
          print("computing raw ITN coverage estimates at the LGA-level for years 2003, 2008, 2010, 2013, 2015 & 2018")
          var <- list("LGA")
          ITN_LGA <- map2(comboITN.list, var, generate.ITN.state_LGA_repDS)
          fin_df <- plyr::ldply(ITN_LGA, rbind)
          fin_df$age <- age 
            if(SAVE == TRUE){
              write_csv(fin_df, paste0(print_path, "/",age, '_', "ITN_LGA_DHS_2003_2018.csv"))
            }else{
              print('analysis completed')
            }

        }else if(subVariable == "State"){
          print("computing raw ITN coverage estimates at the State-level for years 2003, 2008, 2010, 2013, 2015 & 2018")
          var <- list("State")
          ITN_State <- map2(comboITN.list, var, generate.ITN.state_LGA_repDS)
          fin_df <- plyr::ldply(ITN_State, rbind)
          fin_df$age <- age 
          if(SAVE == TRUE){
            write_csv(fin_df, paste0(print_path, "/",age, '_', "ITN_State_est_DHS_2003_2018.csv"))
          }else{
            print('analysis completed')
          }
         
        }else if(subVariable == "repDS"){
          print("computing raw ITN coverage estimates at the archetype-level for years 2003, 2008, 2010, 2013, 2015 & 2018")
          var <- list("repDS")
          ITN_repDS <- map2(comboITN.list, var, generate.ITN.state_LGA_repDS)
          fin_df <- plyr::ldply(ITN_repDS, rbind)
          fin_df$age <- age 
          if(SAVE == TRUE){
            write_csv(fin_df, paste0(print_path, "/",age, '_', "ITN_repDS_est_DHS_2003_2018.csv"))
          }else{
            print('analysis completed')
          }
      
        }else if (grepl("region", subVariable)){
          print("computing raw ITN estimates at the geopolitical-level for years 2003, 2008, 2010, 2013, 2015 & 2018")
          region_state<- data.frame(comboITN.list[[6]]$State, comboITN.list[[6]]$hv024) %>%  distinct() %>% drop_na()
          colnames(region_state)<- c("State", "hv024")
          repDS_region<- repDS_LGA %>% left_join(region_state)
          var <- list("hv024")
          ITN_region <- map(comboITN.list,ITN.fun_region)
          fin_df <- plyr::ldply(ITN_region, rbind)
          fin_df$age <- age 
          if(SAVE == TRUE){
            write_csv(fin_df, paste0(print_path, "/",age, '_', "ITN_region_est_DHS_2003_2018.csv"))
          }else{
            print('analysis completed')
          }
        }else if(subVariable =="manuscript"){
          print("computing ITN coverage estimates at the LGA and archetype-level for manuscript tables and figures for years 2008, 2010, 2013, 2015 & 2018")
          
          #make manuscript table
          comboITN.list_U5 <-lapply(comboITN.list, subset, hv105 <=5)
          comboITN.list_6_9 <-lapply(comboITN.list, subset, hv105 > 5 & hv105 < 10)
          comboITN.list_10_18 <-lapply(comboITN.list, subset, hv105 > 9 & hv105 < 19)
          comboITN.list_over_18 <-lapply(comboITN.list, subset, hv105 > 18)
          
          data_list =list(comboITN.list_U5, comboITN.list_6_9, comboITN.list_10_18, comboITN.list_over_18)
          
          age_list = list("U5_ITN_use_LGA", "six_nine_ITN_use_LGA", "ten_eighteen_ITN_use_LGA", "over_eighteen_ITN_use_LGA")
          
          ITN_LGA_list = list()
      
          
          for (i in 1:length(data_list)){
          var <- list("LGA")
          ITN_LGA <- map2(data_list[[i]], var, generate.ITN.state_LGA_repDS)
          ITN_LGA <- plyr::ldply(ITN_LGA, rbind) %>% filter(year !=2003, year !=2008) %>% 
            dplyr::select(-c(.id, se)) 
          ITN_LGA[, age_list[[i]]]= ITN_LGA$ITN
          ITN_LGA$ITN = NULL
          ITN_LGA_list <- append(ITN_LGA_list, list(ITN_LGA))
          }
          
          
          ITN_repDS_list = list()
          age_list_rep = list("U5_ITN_use_rep", "six_nine_ITN_use_rep", "ten_eighteen_ITN_use_rep", "over_eighteen_ITN_use_rep")
          
          for (i in 1:length(data_list)){
            var <- list("repDS")
            ITN_repDS <- map2(data_list[[i]], var, generate.ITN.state_LGA_repDS)
            ITN_repDS <- plyr::ldply(ITN_repDS, rbind) %>% filter(year !=2003, year !=2008) %>% 
              dplyr::select(-c(.id, se)) 
            ITN_repDS[, age_list_rep[[i]]]= ITN_repDS$ITN
            ITN_repDS$ITN = NULL
            ITN_repDS_list <- append(ITN_repDS_list, list(ITN_repDS))
          }
          
         
          fin_df <-purrr::map2(ITN_LGA_list, ITN_repDS_list, dplyr::left_join, by = c('LGA', 'State', 'year', 'repDS'))
          fin_df[[1]]<- fin_df[[1]] %>%  mutate(U5_ITN_use = ifelse(U5_ITN_use_LGA == "0"|U5_ITN_use_LGA == "1"| is.na(U5_ITN_use_LGA),
                                                                    U5_ITN_use_rep, U5_ITN_use_LGA)) %>%  dplyr::select(-c(U5_ITN_use_rep, U5_ITN_use_LGA))
          
          fin_df[[2]]<- fin_df[[2]] %>%  mutate(six_nine_ITN_use = ifelse(six_nine_ITN_use_LGA == "0"|six_nine_ITN_use_LGA == "1"| is.na(six_nine_ITN_use_LGA),
                                                                          six_nine_ITN_use_rep,six_nine_ITN_use_LGA)) %>%  dplyr::select(-c(six_nine_ITN_use_rep, six_nine_ITN_use_LGA))
          
          fin_df[[3]]<- fin_df[[3]] %>%  mutate(ten_eighteen_ITN_use = ifelse(ten_eighteen_ITN_use_LGA == "0"|ten_eighteen_ITN_use_LGA == "1"| is.na(ten_eighteen_ITN_use_LGA),
                                                                          ten_eighteen_ITN_use_rep,ten_eighteen_ITN_use_LGA))%>%  dplyr::select(-c(ten_eighteen_ITN_use_rep, ten_eighteen_ITN_use_LGA))

          fin_df[[4]]<- fin_df[[4]] %>%  mutate(over_eighteen_ITN_use = ifelse(over_eighteen_ITN_use_LGA == "0"|over_eighteen_ITN_use_LGA == "1"| is.na(over_eighteen_ITN_use_LGA),
                                                                               over_eighteen_ITN_use_rep,over_eighteen_ITN_use_LGA)) %>% dplyr::select(-c(over_eighteen_ITN_use_rep, over_eighteen_ITN_use_LGA))
          fin_df<- fin_df %>%  reduce(left_join, by = c('LGA', 'State','repDS', 'year'))
          if(SAVE == TRUE){
            write_csv(fin_df, paste0(print_path, "/", "ITN_by_LGA.csv"))
          }
          
          #make table for manuscript map 
          var <- list("LGA")
          ITN_LGA <- map2(comboITN.list, var, generate.ITN.state_LGA_repDS)
          ITN_LGA <- plyr::ldply(ITN_LGA, rbind) %>%  rename(ITN_LG = ITN)%>%  dplyr::select(-se, -.id)
          ITN_LGA$age <- age 

          var <- list("repDS")
          ITN_repDS <- map2(comboITN.list, var, generate.ITN.state_LGA_repDS)
          ITN_repDS <- plyr::ldply(ITN_repDS, rbind) %>%  rename(ITN_rep = ITN) %>%  dplyr::select(-se, -.id)
          ITN_repDS$age <- age 
          
          ITN_all <-  left_join(ITN_LGA, ITN_repDS, by = c('LGA', 'State','repDS', 'year')) %>% 
            mutate(ITN_use = ifelse(ITN_LG == "0"|ITN_LG == "1"| is.na(ITN_LG),
                                                  ITN_rep,ITN_LG)) %>% dplyr::select(-c(ITN_LG,ITN_rep))%>% filter(year !=2003, year !=2008)
          
          ITN_split <- split(ITN_all, ITN_all$year)
        
          
        }else{
          print("no subVariable to analyze")
       }
       
  }
} else {
  print("no variable to analyze")
}



#plots

if (plot == TRUE & subVariable == "LGA"){
  line_plot<- ggplot(fin_df, aes(x = year, y = ITN, group = LGA)) + 
    geom_line(color = "blue") +
    xlab('Year') +
    ylab('ITN coverage by LGA')
    print("ITN line plot generated at the LGA-level")
  if(SAVE == TRUE){
  pdf(file=paste0(print_path, "/",age, '_', "ITN_plots_LGA_DHS_2003_2018.pdf"))
  plot(line_plot)
  dev.off()
  }
  
}else if (plot == TRUE & subVariable == "State"){
  line_plot<- ggplot(fin_df, aes(x = year, y = ITN, group = State)) + 
    geom_line(color = "blue") +
    xlab('Year') +
    ylab('ITN coverage by State')
  print("ITN line plot generated at the State-level")
  if(SAVE == TRUE){
    pdf(file=paste0(print_path, "/", age, '_',"ITN_plots_state_DHS_2003_2018.pdf"))
    plot(line_plot)
    dev.off()
  }
  
}else if (plot == TRUE & subVariable == "repDS"){
  line_plot<- ggplot(fin_df, aes(x = year, y = ITN, group = repDS)) + 
    geom_line(color = "blue") +
    xlab('Year') +
    ylab('ITN coverage averaged by repDS')
  print("ITN line plot generated at the repDS-level")
  if(SAVE == TRUE){
    pdf(file=paste0(print_path, "/",age, '_', "ITN_plots_repDS_DHS_2003_2018.pdf"))
    plot(line_plot)
    dev.off()
  }
  
}else if (plot == TRUE & subVariable == "region"){
  line_plot<- ggplot(fin_df, aes(x = year, y = ITN, group = region)) + 
    geom_line(color = "blue") +
    xlab('Year') +
    ylab('ITN coverage averaged by geopolitical zones')
  print("ITN line plot generated at the region-level")
  if(SAVE == TRUE){
    pdf(file=paste0(print_path, "/", age, '_', "ITN_plots_region_DHS_2003_2018.pdf"))
    plot(line_plot)
    dev.off()
  }
  
}else {
  print("values will not be plotted")
}



# map 

#state 

if (plot == TRUE & subVariable == "State"){
  fin_df <- fin_df %>%  mutate(State = case_when(grepl("Akwa", State) ~"Akwa Ibom", TRUE ~ State))
  state_split <- split(fin_df, fin_df$year)
  state_sf <- state_sf %>% 
    mutate(State = case_when(State == "Nassarawa" ~ "Nasarawa", 
                             grepl("Akwa", State) ~ "Akwa Ibom", TRUE ~State))
  state_map_ls <- list(state_sf)
  join_state <- Map(function(x, y) left_join(x, y, by = "State"), state_map_ls, state_split) 
  
  map_val <- list("ITN")
  var<-list("ITN averaged by State")
  maps <- pmap(list(join_state, map_val, var), map_fun)
  arrange_maps <- do.call(tmap_arrange, maps)
  print("ITN maps generated at the state-level")
  if(SAVE == TRUE){
    tmap_save(tm =arrange_maps, filename = paste0(print_path, "/",age, '_', "ITN_maps_state_2003_2018.pdf"), width=13, height=13, units ="in", asp=0,
              paper ="A4r", useDingbats=FALSE)
  }
  
  
  #LGA  
}else if (plot == TRUE & subVariable == "LGA"){
  #LGA_split <- split(fin_df, fin_df$year)
  LGA_map_ls <- list(LGA_clean_names)
  join_LGA <- Map(function(x, y) left_join(x, y, by = "LGA"), LGA_map_ls, ITN_LGA)
  
  map_val <- list("ITN")
  var<-list("ITN averaged by LGA")
  maps <- pmap(list(join_LGA, map_val, var), map_fun)
  arrange_maps <- do.call(tmap_arrange, maps)
  print("ITN maps generated at the LGA-level (missing values replace by archetype-level estimate)")
  if(SAVE == TRUE){
    tmap_save(tm =arrange_maps, filename = paste0(print_path, "/", age, '_', "ITN_maps_LGA_2003_2018.pdf"), width=13, height=13, units ="in", asp=0,
              paper ="A4r", useDingbats=FALSE)
  }
  

}else if (plot == TRUE & subVariable == "manuscript"){
  #LGA_split <- split(fin_df, fin_df$year)
  LGA_map_ls <- list(LGA_clean_names)
  join_LGA <- Map(function(x, y) left_join(x, y, by = "LGA"), LGA_map_ls, ITN_split)
  
  map_val <- list("ITN_use")
  var<-list("ITN averaged by LGA")
  maps <- pmap(list(join_LGA, map_val, var), map_fun)
  arrange_maps <- do.call(tmap_arrange, maps)
  print("ITN maps generated at the LGA-level(missing values replaced by archetype estimate)")
  if(SAVE == TRUE){
    tmap_save(tm =arrange_maps, filename = paste0(print_path, "/", "ITN_maps_manscript_LGA_2003_2018.pdf"), width=13, height=13, units ="in", asp=0,
              paper ="A4r", useDingbats=FALSE)
  }
  
  #repDS  
}else if (plot == TRUE & subVariable == "repDS"){
  repDS_split <- split(fin_df, fin_df$year)
  LGA_map_ls <- list(LGA_clean_names)
  join_repDS <- Map(function(x, y) left_join(x, y, by = "LGA"), LGA_map_ls, repDS_split)
  
  map_val <- list("ITN")
  var<-list("ITN averaged by repDS")
  maps <- pmap(list(join_repDS, map_val, var), map_fun)
  arrange_maps <- do.call(tmap_arrange, maps)
  print("ITN maps generated at the repDS")
  if(SAVE == TRUE){
    tmap_save(tm =arrange_maps, filename = paste0(print_path, "/", age, '_',"ITN_maps_repDS_2003_2018.pdf"), width=13, height=13, units ="in", asp=0,
              paper ="A4r", useDingbats=FALSE)
  }
  
  
  #region
}else if (plot == TRUE & subVariable == "region"){
  fin_df <- fin_df %>% mutate(GPZ = dplyr::case_when(hv024 == 1 ~ "North Central",
                                                     hv024== 2 ~"North East", 
                                                     hv024== 3 ~"North West", 
                                                     hv024== 4 ~"South East", 
                                                     hv024== 5 ~"South South", 
                                                     hv024== 6 ~"South West"))
  region_split <- split(fin_df, fin_df$year)
  LGA_map_ls <- list(LGA_clean_names)
  join_region <- Map(function(x, y) left_join(x, y, by = "LGA"), LGA_map_ls, region_split)
  
  map_val <- list("ITN")
  var<-list("ITN averaged by GPZ")
  maps <- pmap(list(join_region, map_val, var), map_fun)
  arrange_maps <- do.call(tmap_arrange, maps)
  print("ITN maps generated at the regional level")
  if(SAVE == TRUE){
    tmap_save(tm =arrange_maps, filename = paste0(print_path, "/", age, '_',"ITN_maps_region_2003_2018.pdf"), width=13, height=13, units ="in", asp=0,
              paper ="A4r", useDingbats=FALSE)
  }
  
  
}else {
  print("maps will not be printed")
}






































