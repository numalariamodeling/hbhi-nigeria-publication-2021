percent_change_fun_19 <- function(df, boolean){
  
  if(boolean == TRUE){
    df %>% group_by(State) %>% mutate(PfPR_percent_change = (PfPR_all_ages - PfPR_all_ages[year =="2019" & scenario == "NGA projection scenario 0"])/PfPR_all_ages[year =="2019" & scenario == 'NGA projection scenario 0']* 100, 
                                      U5_PfPR_percent_change = 
                                        ( PfPR_U5 -  PfPR_U5[year =="2019" & scenario == "NGA projection scenario 0"])/ PfPR_U5[year =="2019" & scenario == "NGA projection scenario 0"]* 100, 
                                      incidence_percent_change = 
                                        (incidence_all_ages - incidence_all_ages[year =="2019" & scenario == "NGA projection scenario 0"])/incidence_all_ages[year =="2019" & scenario == "NGA projection scenario 0"]* 100, 
                                      U5_incidence_percent_change = 
                                        (incidence_U5 - incidence_U5[year =="2019" & scenario == "NGA projection scenario 0"])/incidence_U5[year =="2019" & scenario == "NGA projection scenario 0"]* 100,
                                      death_percent_change = 
                                        (death_rate_mean_all_ages - death_rate_mean_all_ages[year =="2019" & scenario == "NGA projection scenario 0"])/death_rate_mean_all_ages[year =="2019" & scenario == "NGA projection scenario 0"]* 100,
                                      U5_death_percent_change = 
                                        (death_rate_mean_U5 - death_rate_mean_U5[year =="2019" & scenario == "NGA projection scenario 0"])/death_rate_mean_U5[year =="2019" & scenario == "NGA projection scenario 0"]* 100)
  } else if(boolean == FALSE){
    df %>% mutate(PfPR_percent_change = (PfPR_all_ages - PfPR_all_ages[year =="2019" & scenario == "NGA projection scenario 0"])/PfPR_all_ages[year =="2019" & scenario == 'NGA projection scenario 0']* 100, 
                  U5_PfPR_percent_change = 
                    ( PfPR_U5 -  PfPR_U5[year =="2019" & scenario == "NGA projection scenario 0"])/ PfPR_U5[year =="2019" & scenario == "NGA projection scenario 0"]* 100, 
                  incidence_percent_change = 
                    (incidence_all_ages - incidence_all_ages[year =="2019" & scenario == "NGA projection scenario 0"])/incidence_all_ages[year =="2019" & scenario == "NGA projection scenario 0"]* 100, 
                  U5_incidence_percent_change = 
                    (incidence_U5 - incidence_U5[year =="2019" & scenario == "NGA projection scenario 0"])/incidence_U5[year =="2019" & scenario == "NGA projection scenario 0"]* 100,
                  death_percent_change = 
                    (death_rate_mean_all_ages - death_rate_mean_all_ages[year =="2019" & scenario == "NGA projection scenario 0"])/death_rate_mean_all_ages[year =="2019" & scenario == "NGA projection scenario 0"]* 100,
                  U5_death_percent_change = 
                    (death_rate_mean_U5 - death_rate_mean_U5[year =="2019" & scenario == "NGA projection scenario 0"])/death_rate_mean_U5[year =="2019" & scenario == "NGA projection scenario 0"]* 100)
  }
  
}  



percent_change_fun_20 <- function(df, boolean){
  
  if(boolean == TRUE){
    df %>% group_by(State) %>% mutate(PfPR_percent_change = (PfPR_all_ages - PfPR_all_ages[year =="2020" & scenario == "NGA projection scenario 1"])/PfPR_all_ages[year =="2020" & scenario == 'NGA projection scenario 1']* 100, 
                                      U5_PfPR_percent_change = 
                                        ( PfPR_U5 -  PfPR_U5[year =="2020" & scenario == "NGA projection scenario 1"])/ PfPR_U5[year =="2020" & scenario == "NGA projection scenario 1"]* 100, 
                                      incidence_percent_change = 
                                        (incidence_all_ages - incidence_all_ages[year =="2020" & scenario == "NGA projection scenario 1"])/incidence_all_ages[year =="2020" & scenario == "NGA projection scenario 1"]* 100, 
                                      U5_incidence_percent_change = 
                                        (incidence_U5 - incidence_U5[year =="2020" & scenario == "NGA projection scenario 1"])/incidence_U5[year =="2020" & scenario == "NGA projection scenario 1"]* 100,
                                      death_percent_change = 
                                        (death_rate_mean_all_ages - death_rate_mean_all_ages[year =="2020" & scenario == "NGA projection scenario 1"])/death_rate_mean_all_ages[year =="2020" & scenario == "NGA projection scenario 1"]* 100,
                                      U5_death_percent_change = 
                                        (death_rate_mean_U5 - death_rate_mean_U5[year =="2020" & scenario == "NGA projection scenario 1"])/death_rate_mean_U5[year =="2020" & scenario == "NGA projection scenario 1"]* 100)
  } else if(boolean == FALSE){
    df %>% mutate(PfPR_percent_change = (PfPR_all_ages - PfPR_all_ages[year =="2020" & scenario == "NGA projection scenario 1"])/PfPR_all_ages[year =="2020" & scenario == 'NGA projection scenario 1']* 100, 
                  U5_PfPR_percent_change = 
                    ( PfPR_U5 -  PfPR_U5[year =="2020" & scenario == "NGA projection scenario 1"])/ PfPR_U5[year =="2020" & scenario == "NGA projection scenario 1"]* 100, 
                  incidence_percent_change = 
                    (incidence_all_ages - incidence_all_ages[year =="2020" & scenario == "NGA projection scenario 1"])/incidence_all_ages[year =="2020" & scenario == "NGA projection scenario 1"]* 100, 
                  U5_incidence_percent_change = 
                    (incidence_U5 - incidence_U5[year =="2020" & scenario == "NGA projection scenario 1"])/incidence_U5[year =="2020" & scenario == "NGA projection scenario 1"]* 100,
                  death_percent_change = 
                    (death_rate_mean_all_ages - death_rate_mean_all_ages[year =="2020" & scenario == "NGA projection scenario 1"])/death_rate_mean_all_ages[year =="2020" & scenario == "NGA projection scenario 1"]* 100,
                  U5_death_percent_change = 
                    (death_rate_mean_U5 - death_rate_mean_U5[year =="2020" & scenario == "NGA projection scenario 1"])/death_rate_mean_U5[year =="2020" & scenario == "NGA projection scenario 1"]* 100)
  }
  
}  



percent_change_fun_15 <- function(df, boolean){
  
  if(boolean == TRUE){
    df %>% group_by(State) %>% mutate(PfPR_percent_change = (PfPR_all_ages - PfPR_all_ages[year =="2015" & scenario == "NGA projection scenario 0"])/PfPR_all_ages[year =="2015" & scenario == 'NGA projection scenario 0']* 100, 
                                      U5_PfPR_percent_change = 
                                        ( PfPR_U5 -  PfPR_U5[year =="2015" & scenario == "NGA projection scenario 0"])/ PfPR_U5[year =="2015" & scenario == "NGA projection scenario 0"]* 100, 
                                      incidence_percent_change = 
                                        (incidence_all_ages - incidence_all_ages[year =="2015" & scenario == "NGA projection scenario 0"])/incidence_all_ages[year =="2015" & scenario == "NGA projection scenario 0"]* 100, 
                                      U5_incidence_percent_change = 
                                        (incidence_U5 - incidence_U5[year =="2015" & scenario == "NGA projection scenario 0"])/incidence_U5[year =="2015" & scenario == "NGA projection scenario 0"]* 100,
                                      death_percent_change = 
                                        (death_rate_mean_all_ages - death_rate_mean_all_ages[year =="2015" & scenario == "NGA projection scenario 0"])/death_rate_mean_all_ages[year =="2015" & scenario == "NGA projection scenario 0"]* 100,
                                      U5_death_percent_change = 
                                        (death_rate_mean_U5 - death_rate_mean_U5[year =="2015" & scenario == "NGA projection scenario 0"])/death_rate_mean_U5[year =="2015" & scenario == "NGA projection scenario 0"]* 100)
  } else if(boolean == FALSE){
    df %>% mutate(PfPR_percent_change = (PfPR_all_ages - PfPR_all_ages[year =="2015" & scenario == "NGA projection scenario 0"])/PfPR_all_ages[year =="2015" & scenario == 'NGA projection scenario 0']* 100, 
                  U5_PfPR_percent_change = 
                    ( PfPR_U5 -  PfPR_U5[year =="2015" & scenario == "NGA projection scenario 0"])/ PfPR_U5[year =="2015" & scenario == "NGA projection scenario 0"]* 100, 
                  incidence_percent_change = 
                    (incidence_all_ages - incidence_all_ages[year =="2015" & scenario == "NGA projection scenario 0"])/incidence_all_ages[year =="2015" & scenario == "NGA projection scenario 0"]* 100, 
                  U5_incidence_percent_change = 
                    (incidence_U5 - incidence_U5[year =="2015" & scenario == "NGA projection scenario 0"])/incidence_U5[year =="2015" & scenario == "NGA projection scenario 0"]* 100,
                  death_percent_change = 
                    (death_rate_mean_all_ages - death_rate_mean_all_ages[year =="2015" & scenario == "NGA projection scenario 0"])/death_rate_mean_all_ages[year =="2015" & scenario == "NGA projection scenario 0"]* 100,
                  U5_death_percent_change = 
                    (death_rate_mean_U5 - death_rate_mean_U5[year =="2015" & scenario == "NGA projection scenario 0"])/death_rate_mean_U5[year =="2015" & scenario == "NGA projection scenario 0"]* 100)
  }
  
}  




percent_change_fun_30 <- function(df, boolean){
  
  if(boolean == TRUE){
    df %>% group_by(State) %>% mutate(PfPR_percent_change = (PfPR_all_ages - PfPR_all_ages[year =="2030" & scenario == "NGA projection scenario 7"])/PfPR_all_ages[year =="2030" & scenario == 'NGA projection scenario 7']* 100, 
                                      U5_PfPR_percent_change = 
                                        ( PfPR_U5 -  PfPR_U5[year =="2030" & scenario == "NGA projection scenario 7"])/ PfPR_U5[year =="2030" & scenario == "NGA projection scenario 7"]* 100, 
                                      incidence_percent_change = 
                                        (incidence_all_ages - incidence_all_ages[year =="2030" & scenario == "NGA projection scenario 7"])/incidence_all_ages[year =="2030" & scenario == "NGA projection scenario 7"]* 100, 
                                      U5_incidence_percent_change = 
                                        (incidence_U5 - incidence_U5[year =="2030" & scenario == "NGA projection scenario 7"])/incidence_U5[year =="2030" & scenario == "NGA projection scenario 7"]* 100,
                                      death_percent_change = 
                                        (death_rate_mean_all_ages - death_rate_mean_all_ages[year =="2030" & scenario == "NGA projection scenario 7"])/death_rate_mean_all_ages[year =="2030" & scenario == "NGA projection scenario 7"]* 100,
                                      U5_death_percent_change = 
                                        (death_rate_mean_U5 - death_rate_mean_U5[year =="2030" & scenario == "NGA projection scenario 7"])/death_rate_mean_U5[year =="2030" & scenario == "NGA projection scenario 7"]* 100)
  } else if(boolean == FALSE){
    df %>% mutate(PfPR_percent_change = (PfPR_all_ages - PfPR_all_ages[year =="2030" & scenario == "NGA projection scenario 7"])/PfPR_all_ages[year =="2030" & scenario == 'NGA projection scenario 7']* 100, 
                  U5_PfPR_percent_change = 
                    ( PfPR_U5 -  PfPR_U5[year =="2030" & scenario == "NGA projection scenario 7"])/ PfPR_U5[year =="2030" & scenario == "NGA projection scenario 7"]* 100, 
                  incidence_percent_change = 
                    (incidence_all_ages - incidence_all_ages[year =="2030" & scenario == "NGA projection scenario 7"])/incidence_all_ages[year =="2030" & scenario == "NGA projection scenario 7"]* 100, 
                  U5_incidence_percent_change = 
                    (incidence_U5 - incidence_U5[year =="2030" & scenario == "NGA projection scenario 7"])/incidence_U5[year =="2030" & scenario == "NGA projection scenario 7"]* 100,
                  death_percent_change = 
                    (death_rate_mean_all_ages - death_rate_mean_all_ages[year =="2030" & scenario == "NGA projection scenario 7"])/death_rate_mean_all_ages[year =="2030" & scenario == "NGA projection scenario 7"]* 100,
                  U5_death_percent_change = 
                    (death_rate_mean_U5 - death_rate_mean_U5[year =="2030" & scenario == "NGA projection scenario 7"])/death_rate_mean_U5[year =="2030" & scenario == "NGA projection scenario 7"]* 100)
  }
  
}  



#function to compute indicators 
sum_fun <- function(df1, df2){
  df<- df1 %>%  filter(LGA %in% df2$LGA)%>% 
    group_by(year) %>% 
    summarise(incidence_all_ages =sum(cases_all_ages)/sum(geopode.pop_all_ages) * 1000,
              incidence_U5 =sum(cases_U5)/sum(geopode.pop_U5) * 1000,
              PfPR_all_ages =sum(positives_all_ages)/sum(geopode.pop_all_ages),
              PfPR_U5 =sum(positives_U5)/sum(geopode.pop_U5),
              death_rate_1_all_ages = sum(deaths_1_all_ages)/sum(geopode.pop_all_ages) *1000,
              death_rate_2_all_ages = sum(deaths_2_all_ages)/sum(geopode.pop_all_ages) *1000,
              death_rate_1_U5 = sum(deaths_1_U5)/sum(geopode.pop_U5) *1000,
              death_rate_2_U5 = sum(deaths_2_U5)/sum(geopode.pop_U5) *1000,
              death_rate_mean_all_ages = (death_rate_1_all_ages+death_rate_2_all_ages)/2,
              death_rate_mean_U5 = (death_rate_1_U5+death_rate_2_U5)/2) %>% 
    dplyr::select(-c(death_rate_1_all_ages,death_rate_2_all_ages,death_rate_1_U5, death_rate_2_U5))
}


