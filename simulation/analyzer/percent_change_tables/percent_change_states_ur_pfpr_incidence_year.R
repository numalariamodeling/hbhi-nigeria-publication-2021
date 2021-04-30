#This script processes simulation output to generate percent change with 
#2020 baseline at the national level and for SMC areas in Nigeria. Scripts can be modified to use other baselines 
# Created by Ifeoma Ozodiegwu 
#


###############################################################################
# create file paths 
###############################################################################



rm(list = ls())
TeamDir <-"C:/Users/ido0493/Box/NU-malaria-team"
ProjectDir<- file.path(TeamDir, "projects/hbhi_nigeria")
WorkDir <- file.path(ProjectDir, "simulation_output")
ProcessDir <- file.path(WorkDir, "2020_to_2030_v3")
ScriptDir <- file.path(TeamDir,"data/nigeria_dhs/data_analysis/src/DHS/1_variables_scripts")
simInDir <- file.path(ProjectDir, "simulation_inputs/projection_csvs/projection_v3")
PrintDir <- file.path(ProcessDir, "percent_change_tables")
UpdatePrintDir <- file.path(ProcessDir, "percent_change_tables", "updated_tables_each_run_number")
SMC_areas <- file.path(PrintDir, "SMC_areas")
source(file.path(ScriptDir, "generic_functions", "DHS_fun.R"))


###############################################################################
# create functions 
###############################################################################

percent_change_fun <- function(df, boolean){
  
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






###############################################################################
# national level % change 
###############################################################################

all_df  = list()

names = c("mean", "0", "1", "2", "3", "4")

for (i in 1:length(names)){

    scen_dat <- read.csv(file.path(ProcessDir, "scenario_adjustment_info.csv"))

  for (row in 1:nrow(scen_dat)){
  files <- list.files(path = file.path(ProcessDir, scen_dat[, "ScenarioName"]), pattern = paste0("*annual_indicators_2020_2030_", names[i], ".csv"), full.names = TRUE)
  df <- sapply(files, read_csv, simplify = F)
  }

#read in 2019 annual indicators

df_2019 <- read_csv(file.path(WorkDir, "2010_to_2020_v10/NGA 2010-20 burnin_hs+itn+smc", "annual_indicators_2011_2020.csv")) %>% 
  rename(death_rate_mean_all_ages = death_rate_mean,
         death_rate_mean_U5 = U5_death_rate_mean)

df[['C:/Users/ido0493/Box/NU-malaria-team/projects/hbhi_nigeria/simulation_output/2020_to_2030_v3/NGA projection scenario 0/annual_indicators_2020_2030.csv']] <- df_2019



 fin_df <- plyr::ldply(df, rbind)%>%  dplyr::select(.id,year, PfPR_all_ages, PfPR_U5,  incidence_all_ages, incidence_U5, death_rate_mean_all_ages, 
                                               death_rate_mean_U5) %>% 
  mutate(scenario = str_split(.id, "/", simplify = T)[, 10])



df_2020_base  <- percent_change_fun(fin_df, FALSE)

df_2020_base$run_number <- paste0('run number', " ", names[i]) 



write_csv(df_2020_base, paste0(UpdatePrintDir, "/",  Sys.Date(), "_percent_change_indicators_2020_base_", names[i], ".csv"))

all_df[[i]] <- df_2020_base

}

all_df2 = all_df %>%  map(~filter(., (year == 2020| year == 2025| year == 2030) & run_number != "run number mean"))

df_com = plyr::ldply(all_df2, rbind) %>%  group_by(scenario, year) %>% summarise_at(vars(ends_with('_change')), list(min = min, max = max))

mean_df2 = all_df %>%  map(~filter(., (year == 2020| year == 2025| year == 2030) & run_number == "run number mean")) %>%  plyr::ldply(rbind)

mean_df2 = mean_df2 %>%  dplyr::select(scenario, year, ends_with('_change'))

fin_df = left_join(df_com, mean_df2)%>% 
  dplyr::select(scenario, year, sort(names(.)))

write_csv(fin_df, paste0(UpdatePrintDir, "/",  Sys.Date(), "_2020_base_2020_2025_2030_with_intervals", ".csv"))

###############################################################################
# SMC States
###############################################################################
all_df  = list()

names = c("mean", "0", "1", "2", "3", "4")

for (i in 1:length(names)){
  scen_dat <- read.csv(file.path(ProcessDir, "scenario_adjustment_info.csv")) %>%  filter(Scenario_no %in% c(1, 2, 6, 7))

      for (row in 1:nrow(scen_dat)){
        files <- list.files(path = file.path(ProcessDir, scen_dat[, "ScenarioName"]), pattern = paste0("*annual_indicators_each_LGA_", names[i], ".csv"), full.names = TRUE)
        df <- sapply(files, read_csv, simplify = F)
      }
    


files <- list.files(path = simInDir, pattern = "*smc_PAAR_2020_2030.csv", full.names = T)
SMC_df <- sapply(files, read_csv, simplify = F)



SMC_LGA <- map(SMC_df, ~ .x %>% 
      distinct(LGA)) 




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


df_ls <- map2(df, SMC_LGA, sum_fun)

df <- plyr::ldply(df_ls, rbind)



df_all<- df %>% mutate(scenario = str_split(.id, "/", simplify = T)[, 10]) 


fin_df <- percent_change_fun(df_all, FALSE) 
fin_df$run_number <- paste0('run number', " ", names[i]) 

write_csv(fin_df, paste0(SMC_areas,"/",  Sys.Date(), "_percent_change_indicators_2020_base_SMC_states", names[i], ".csv"))

all_df[[i]] <- fin_df 

}


all_df2 = all_df %>%  map(~filter(., (year == 2020| year == 2025| year == 2030) & run_number != "run number mean"))

df_com = plyr::ldply(all_df2, rbind) %>%  group_by(scenario, year) %>% summarise_at(vars(ends_with('_change')), list(min = min, max = max))

mean_df2 = all_df %>%  map(~filter(., (year == 2020| year == 2025| year == 2030) & run_number == "run number mean")) %>%  plyr::ldply(rbind)

mean_df2 = mean_df2 %>%  dplyr::select(scenario, year, ends_with('_change'))

fin_df = left_join(df_com, mean_df2)%>% 
  dplyr::select(scenario, year, sort(names(.)))

write_csv(fin_df, paste0(SMC_areas, "/",  Sys.Date(), "_2020_base_2020_2025_2030_with_intervals_SMC_states", ".csv"))


