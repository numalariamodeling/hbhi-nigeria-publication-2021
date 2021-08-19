# This script generates CM estimates from 4 DHS surveys at the LGA level, State, representative DHS level and at the geopolitical level 


if (Variable == "CM"){
  cm.ls <-read.files( ".*NGKR.*\\.DTA", DataDir, read_dta)
  cm.ls <- cm.ls[-c(1, 2)]
  cm.ls[[3]][,"ml13e"] <-recoder(cm.ls[[3]][,"ml13e"]) 
  table(cm.ls[[2]]$ml13e) #clean up to create better recoder function 
  cm.ls[[2]][,"ml13e"] <-recoder(cm.ls[[2]][,"ml13e"]) 
  NGAshplist<- NGAshplist[-c(1, 2)]  # key datasets and dhs/mis datasets are joined  
  NGA_ID <- lapply(NGAshplist, "[[", "DHSCLUST")#QA this 
  key_list <- key_list[-c(1, 2)]
  key_list <- Map(cbind, key_list, v001 = NGA_ID)
  comboACT.list <- map2(cm.ls, key_list, left_join)
  comboACT.list <- lapply(comboACT.list, subset, b5 == 1 & h22 == 1)             
  rep_DS.ls <- list(rep_DS) # attach representative DS 
  ifelse(!dir.exists(file.path(ResultDir, "case_management")), 
         dir.create(file.path(ResultDir, "case_management")), FALSE)
  print_path <- file.path(ResultDir, "case_management")
  
  if (grepl("LGA|State|repDS|region|manuscript", subVariable)) {
  comboACT.list  <- map2(comboACT.list, rep_DS.ls, left_join) #PR datasets
  LGA_sf <- LGA_clean_names%>%  as_tibble() %>% dplyr::select(LGA, State)
  repDS_LGA<- rep_DS %>% left_join(LGA_sf)
  
  
    if(subVariable == "LGA"){
      print("computing raw case management coverage estimates at the LGA-level for years 2008, 2010, 2013, 2015 & 2018")
      var <- list("LGA")
      ACT_LGA <- map2(comboACT.list, var, generate.ACT.state_LGA_repDS)
      fin_df <- plyr::ldply(ACT_LGA, rbind)
      
   }else if(subVariable == "State"){
      print("computing raw case management coverage estimates at the state-level for years 2008, 2010, 2013, 2015 & 2018")
      var <- list("State")
      ACT_State <- map2(comboACT.list,var, generate.ACT.state_LGA_repDS)
      fin_df <- plyr::ldply(ACT_State, rbind)
      CM_State_with_LGA_DHS_2008_10 <- fin_df
      fin_df <- fin_df %>%  distinct(State, comboACT, se, year)
      state_ls <- list(CM_State_DHS_2008_10 = fin_df, CM_State_with_LGA_DHS_2008_10 = CM_State_with_LGA_DHS_2008_10)
      
    }else if(subVariable == "repDS"){
      print("computing raw case management coverage estimates at the representative DS-level for years 2008, 2010, 2013, 2015 & 2018")
      var <- list("repDS")
      ACT_rep <- map2(comboACT.list, var, generate.ACT.state_LGA_repDS)
      fin_df <- plyr::ldply(ACT_rep, rbind)
      
    }else if (grepl("region", subVariable)) {
      print("computing raw case management coverage estimates at the geopolitical-level for years 2008, 2010, 2013, 2015 & 2018")
      region_state<- data.frame(comboACT.list[[4]]$State, comboACT.list[[4]]$v024) %>%  distinct() %>% drop_na()
      colnames(region_state)<- c("State", "v024")
      repDS_region<- repDS_LGA %>% left_join(region_state)
      var <- list("v024")
      ACT_region <- map(comboACT.list,ACT.fun_region)
      fin_df <- plyr::ldply(ACT_region, rbind)
      
    }else if(subVariable == "manuscript"){
      print("computing case management coverage estimates at the LGA and archetype-level for manuscript figures for years 2008, 2010, 2013, 2015 & 2018")
      var <- list("LGA")
      ACT_LGA <- map2(comboACT.list, var, generate.ACT.state_LGA_repDS)
      ACT_LGA <- plyr::ldply(ACT_LGA, rbind) %>%  dplyr::rename(comboACT_LGA = comboACT) %>%  filter(year !=2008) %>%
        dplyr::select(-c(.id, se, repDS))
        
        
      var <- list("repDS")
      ACT_rep <- map2(comboACT.list, var, generate.ACT.state_LGA_repDS)
      ACT_rep <- plyr::ldply(ACT_rep, rbind)%>% dplyr::rename(comboACT_repDS = comboACT) %>%  filter(year !=2008) %>% 
        dplyr::select(-c(.id, se))
      
      fin_df<- ACT_LGA %>% left_join(ACT_rep, by =c('LGA', 'State', 'year')) %>% 
          mutate(U5_coverage = ifelse(comboACT_LGA =="0"| comboACT_LGA == "1" |is.na(comboACT_LGA),
                                   comboACT_repDS, comboACT_LGA), adult_coverage = U5_coverage)
      ACT_man <- split(fin_df, fin_df$year)
      if(SAVE == TRUE){
        write_csv(fin_df, paste0(print_path, "/", "HS_by_LGA.csv"))
      }
      
      
    }else{
  
  print("no subVariable to analyze")
  
  }

  
  } else {
  print("no variable to analyze")
}

}




if (smoothing == TRUE & subVariable == "LGA") {
  #smoothing 
  # adding a row number to the shape2 object, will be handy for plotting later on
  # smoothing, printing, plotting, mapping, saving 
  library(INLA); library(spdep)
  LGAshp@data$row_num<-1:nrow(LGAshp@data)
  key<-LGAshp@data[,c("State","LGA","row_num")]
  key_list <- list(key)
  
  ACT_logit <- lapply(ACT_LGA, generate_logit)
  
  ACT_logit<-map2(ACT_logit, key_list,left_join) # merge in key and put data in right order
  
  # setting up the outcome #
  ACT_logit <- lapply(ACT_logit, function(x) cbind(x, outcome = x[["logit_ACT"]], prec =1/ x[["var_logit_ACT"]]))
  
  # this takes the shape file and figures out which areas are neighbors
  nb.r <- poly2nb(LGAshp, queen=F)
  mat <- nb2mat(nb.r, style="B",zero.policy="TRUE") # mat is the 0/1 adjacency matrix
  
  # to double check that they are finding the neighbors, I like to plot a 
  # random LGA in blue and then the neighbors in red.
  row = 500
  indx=nb.r[[row]]  # Determine adjacent districts (by row in shapefile)
  indx
  
  # Plot the LGA and highlight the neighbors
  plot(LGAshp)
  plot(LGAshp[row,], col='blue', add=T)
  plot(LGAshp[indx,], col='red', add=T)
  # it works!
  
  
  #setting up the spatial model priors
  a<-1
  b<-5e-05
  if (smoothing_type == "space"){
    print("generating case management estimates for spatial model for years 2008, 2010, 2013, 2015 & 2018")
    # model formulation #
    smoothing.model.2 <- outcome ~ f(row_num, model="bym",graph=mat, param=c(a,b)) 
    df <- lapply(ACT_logit, generate_smooth_values)
    #creating data frame of all estimates for model 2
    
    values <- lapply(df, function(x){cbind(x[[49]]$.parent.frame$mod2$summary.fitted.values, year=x[[101]])})
    
    values <- lapply(values, function(x){cbind (x, saep.est= expit(x[["0.5quant"]]), saep.up= expit(x[["0.975quant"]]), saep.low= expit(x[["0.025quant"]]))})
    
    ACT_logit <- lapply(ACT_logit, function(x) x[!(names(x) %in% "year")])
    
    fin_df <- Map(cbind, ACT_logit, values)
    
    # combine list 
    fin_df <- plyr::ldply(fin_df, rbind)
    
  }else if (smoothing_type == "space-time"){
    print("generating case management estimates for space-time model for years 2008, 2010, 2013, 2015 & 2018")
    ACT_logit_combined <- plyr::ldply(ACT_logit, rbind)
    
    prec.prior <- list(prec = list(param = c(a, b)))
    
    ACT_space_time_mod <- inla(outcome ~ 1 + f(year, model = "rw1",
                                               hyper = prec.prior) + 
                                 f(as.numeric(row_num), model = "besag", graph = mat,
                                   hyper = prec.prior),
                               data =ACT_logit_combined, family = "gaussian",
                               control.predictor = list(compute = "TRUE"),
                               control.compute=list(cpo="TRUE",dic="TRUE",waic=T,config=T),
                               control.family=list(hyper=list(prec=list(initial=log(1),fixed="TRUE"))),
                               scale=prec)
    df <- ACT_space_time_mod$summary.fitted.values
    df$saep.est <- expit(df$`0.5quant`)
    ACT_raw <- fin_df %>%  dplyr::select(LGA, repDS, State,year, comboACT)
    fin_df <- cbind(ACT_raw, df) 
  }else {
    print("case management estimates will not be smoothed. Indicate type")
  }
}else {
  print("raw survey-adjusted case management estimates have been generated")
}



#plots

if (plot == TRUE & subVariable == "LGA" & smoothing == FALSE){
  line_plot<- ggplot(fin_df, aes(x = year, y = comboACT, group = LGA)) + 
    geom_line(color = "blue") +
    xlab('Time') +
    ylab('ACT coverage by LGA')+
    labs(caption = "No smoothing, 92 missing values")
    print("case management line plot generated at the LGA-level")
    # print(plot)
  
}else if (plot == TRUE & subVariable == "LGA" & smoothing == "TRUE" & smoothing_type == "space"){
  line_plot<- ggplot(fin_df, aes(x = year, y =  saep.est, group = LGA)) + 
    # geom_point() +
    geom_line(color = "blue")+
    xlab('Time') +
    ylab('ACT coverage by LGA')+ 
    labs(caption = "smoothed across space")
    print("space-smoothed case management line plot generated at the LGA-level")
    # print(plot)
  
}else if (plot == TRUE & subVariable == "LGA" & smoothing == "TRUE" & smoothing_type == "space-time"){
  line_plot<- ggplot(fin_df, aes(x = year, y = saep.est , group = LGA)) + 
    # geom_point() +
    geom_line(color = "blue")+
    xlab('Time') +
    ylab('ACT coverage by LGA')+
    labs(caption = "smoothed across space and time")
    print("space-time-smoothed case management line plot generated at the LGA-level")
    # print(plot)
  
}else if (plot == TRUE & subVariable == "State"){
  line_plot<- ggplot(fin_df, aes(x = year, y = comboACT, group = State)) + 
    geom_line(color = "blue") +
    xlab('Time') +
    ylab('ACT coverage by State')
    print("case management line plot generated at the State-level")
    # print(plot)
     
}else if (plot == TRUE & subVariable == "repDS"){
  line_plot<- ggplot(fin_df, aes(x = year, y = comboACT, group = LGA)) + 
    geom_line(color = "blue") +
    xlab('Time') +
    ylab('ACT coverage averaged by repDS')
    print("case management line plot generated at the archetype-level")
    # print(line_plot)
  
}else if (plot == TRUE & subVariable == "region"){
  line_plot<- ggplot(fin_df, aes(x = year, y = comboACT, group = LGA)) + 
    geom_line(color = "blue") +
    xlab('Time') +
    ylab('ACT coverage averaged by geopolitical zones')
    print("case management line plot generated at the region-level")
    # print(line_plot)

}else if(plot == TRUE & subVariable == "manuscript"){
  line_plot<- ggplot(fin_df, aes(x = year, y = U5_coverage, group = LGA)) + 
    geom_line(color = "blue") +
    xlab('Time') +
    ylab('ACT coverage averaged by LGA (missing values replaced by archetype-level values)')
  print("case management line plot generated at the LGA-level")
  # print(line_plot)
  
  
}else{
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
  
  map_val <- list("comboACT")
  var<-list("ACT averaged by State")
  maps <- pmap(list(join_state, map_val, var), map_fun)
  arrange_maps <- do.call(tmap_arrange, maps)
  print("case management maps generated at the state-level")
  # print(arrange_maps)
  

#LGA  
}else if (plot == TRUE & subVariable == "LGA"){
    #LGA_split <- split(fin_df, fin_df$year)
    LGA_map_ls <- list(LGA_clean_names)
    join_LGA <- Map(function(x, y) left_join(x, y, by = "LGA"), LGA_map_ls, ACT_LGA)
    
    map_val <- list("comboACT")
    var<-list("ACT by LGA (raw values)")
    maps <- pmap(list(join_LGA, map_val, var), map_fun)
    arrange_maps <- do.call(tmap_arrange, maps)
    print("case management maps generated at the LGA-level")
    #print(arrange_maps)
    
#manuscript    
}else if (plot == TRUE & subVariable == "manuscript"){
  LGA_map_ls <- list(LGA_clean_names)
  join_LGA <- Map(function(x, y) left_join(x, y, by = "LGA"), LGA_map_ls, ACT_man)
  map_val <- list("U5_coverage")
  var<-list("Effective cae management for uncomplicated malaria")
  maps <- pmap(list(join_LGA, map_val, var), map_fun)
  arrange_maps <- do.call(tmap_arrange, maps)
  print("case management maps generated at the LGA-level(missing values replaced by archetype estimate)")


#repDS  
}else if (plot == TRUE & subVariable == "repDS"){
  repDS_split <- split(fin_df, fin_df$year)
  LGA_map_ls <- list(LGA_clean_names)
  join_repDS <- Map(function(x, y) left_join(x, y, by = "LGA"), LGA_map_ls, repDS_split)
  
  map_val <- list("comboACT")
  var<-list("ACT averaged by repDS")
  maps <- pmap(list(join_repDS, map_val, var), map_fun)
  arrange_maps <- do.call(tmap_arrange, maps)
  print("case management maps generated at the archetype level")
  # print(arrange_maps)
  
  
#region
}else if (plot == TRUE & subVariable == "region"){
   fin_df <- fin_df %>% mutate(GPZ = dplyr::case_when(v024 == 1 ~ "North Central",
                                        v024== 2 ~"North East", 
                                        v024== 3 ~"North West", 
                                        v024== 4 ~"South East", 
                                        v024== 5 ~"South South", 
                                        v024== 6 ~"South West"))
  region_split <- split(fin_df, fin_df$year)
  LGA_map_ls <- list(LGA_clean_names)
  join_region <- Map(function(x, y) left_join(x, y, by = "LGA"), LGA_map_ls, region_split)
  
  map_val <- list("comboACT")
  var<-list("ACT averaged by GPZ")
  maps <- pmap(list(join_region, map_val, var), map_fun)
  arrange_maps <- do.call(tmap_arrange, maps)
  print("case management maps generated at the regional level")
  # print(arrange_maps)

  
#space-smoothed LGA values
}else if (plot == TRUE & subVariable == "LGA" & smoothing_type == "space"){
  smooth_df <- split(fin_df, fin_df$year)
  join <- Map(function(x, y) left_join(x, y, by = "LGA"), LGA_list, smooth_df)
  
  map_val <- list("saep.est")
  var<-list("ACT averaged by LGA (Smoothed across space")
  maps <- pmap(list(join, map_val, var), map_fun)
  arrange_maps <- do.call(tmap_arrange, maps)
  print("space-smoothed case management maps generated at the LGA level")
  # print(arrange_maps)

  
#space-time-smoothed LGA values
}else if (plot == TRUE & subVariable == "LGA" & smoothing_type == "space-time"){
  smooth_time_df <- split(fin_df, fin_df$year)
  join <- Map(function(x, y) left_join(x, y, by = "LGA"), LGA_list, smooth_time_df)
  
  map_val <- list("saep.est")
  var<-list("ACT averaged by LGA (Smoothed across space and time")
  maps <- pmap(list(join, map_val, var), map_fun)
  arrange_maps <- do.call(tmap_arrange, maps)
  print("printing space-time-smoothed case management maps generated at the LGA level")
  # print(arrange_maps)

}else {
  print("maps will not be printed")
}




#LGA 
if (SAVE == TRUE & subVariable == "LGA") {
  write_csv(fin_df, paste0(print_path, "/", "CM_LGA_est_DHS_2008_2018.csv"))
  
  if (plot == TRUE){
    pdf(file=paste0(print_path, "/", "CM_plots_LGA_DHS_2008_2018.pdf"))
    plot(line_plot)
    dev.off()
    tmap_save(tm =arrange_maps, filename = file.path(print_path, "/CM_maps_LGA_2008_2018.pdf"), width=13, height=13, units ="in", asp=0,
              paper ="A4r", useDingbats=FALSE)
  }else {
      print("analysis completed")
  }

 

  
#manuscript
} else if (SAVE == TRUE & subVariable == "manuscript") {
    if (plot == TRUE){
      pdf(file=paste0(print_path, "/", "CM_manuscript_plots_LGA_DHS_2008_2018.pdf"))
      plot(line_plot)
      dev.off()
      tmap_save(tm =arrange_maps, filename = file.path(print_path, "/CM_manuscript_maps_LGA_2008_2018.pdf"), width=13, height=13, units ="in", asp=0,
                paper ="A4r", useDingbats=FALSE)
    }else {
      print("analysis completed")
    }
  
#State   
}else if (SAVE == TRUE & subVariable == "State"){
  mapply(write_csv, state_ls, path=paste0(print_path,"/",names(state_ls), '.csv'))
  
  if (plot == TRUE){
  pdf(file=paste0(print_path, "/", "CM_plots_state_DHS_2008_2018.pdf"))
  plot(line_plot)
  dev.off()
  tmap_save(tm =arrange_maps, filename = file.path(print_path, "/CM_maps_state_2008_2018.pdf"), width=13, height=13, units ="in", asp=0,
            paper ="A4r", useDingbats=FALSE)
  }else {
    print("analysis completed")
  }
  
#region  
}else if (SAVE == TRUE & subVariable == "region"){
  write_csv(fin_df, paste0(print_path, "/", "CM_GPZ_est_DHS_2008_2018.csv"))
  
  if (plot == TRUE){
  pdf(file=paste0(print_path, "/", "CM_plots_GPZ_DHS_2008_2018.pdf"))
  plot(line_plot)
  dev.off()
  tmap_save(tm =arrange_maps, filename = file.path(print_path, "/CM_maps_region_2008_2018.pdf"), width=13, height=13, units ="in", asp=0,
            paper ="A4r", useDingbats=FALSE)
  }else {
    print("analysis completed")
  }
  
  
#repDS
}else if(SAVE == TRUE & subVariable == "repDS"){
  write_csv(fin_df, paste0(print_path, "/", "CM_repDS_est_DHS_2008_2018.csv"))
  
  if (plot == TRUE){
  pdf(file=paste0(print_path, "/", "CM_plots_repDS_DHS_2008_2018.pdf"))
  plot(line_plot)
  dev.off()
  tmap_save(tm =arrange_maps, filename = file.path(print_path, "/CM_maps_repDS_2008_2018.pdf"), width=13, height=13, units ="in", asp=0,
            paper ="A4r", useDingbats=FALSE)
  }else {
    print("analysis completed")
  }
  
  
#LGA-space-smoothed 
}else if (SAVE == TRUE & subVariable == "LGA" & smoothing_type == "space"){
  write_csv(fin_df, paste0(print_path, "/", "CM_LGA_space_smooth_DHS_2008_2018.csv"))
  
  if (plot == TRUE){
  pdf(file=paste0(print_path, "/", "CM_plots_LGA_space_smooth_DHS_2008_2018.pdf"))
  plot(line_plot)
  dev.off()
  tmap_save(tm =arrange_maps, filename = file.path(print_path, "/CM_maps_LGA_space_2008_2018.pdf"), width=13, height=13, units ="in", asp=0,
            paper ="A4r", useDingbats=FALSE)
  }else {
    print("analysis completed")
  }
  
#LGA space-time smoothed   
}else if (SAVE == TRUE & subVariable == "LGA" & smoothing_type == "space-time"){
  write_csv(fin_df, paste0(print_path, "/", "CM_LGA_space_time_DHS_2008_2018.csv"))
  
  if (plot == TRUE){
  pdf(file=paste0(print_path, "/", "CM_plots_LGA_space_time_DHS_2008_2018.pdf"))
  plot(line_plot)
  dev.off()
  tmap_save(tm =arrange_maps, filename = file.path(print_path, "/CM_maps_LGA_space_time_2008_2018.pdf"), width=13, height=13, units ="in", asp=0,
            paper ="A4r", useDingbats=FALSE)
  }else {
    print("analysis completed")
  }
  
}else{
  print("analysis completed")
}









