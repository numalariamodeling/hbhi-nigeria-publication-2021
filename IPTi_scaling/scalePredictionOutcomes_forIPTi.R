### ========================================================================================================================================
### R script to scale simulation outputs for the additional effect of IPTi 
###
### February 2020, MR
###
### Simulation output: U5_PfPR_ClinicalIncidence_severeTreatment.csv, All_Age_Monthly_Cases.csv, 
### IPTi adjustment tables: IPTi_adjustment.csv and  IPTi_adjustment.Uall.csv 
### Output:  Simulation output with scaled malaria event variables 
### 
### Comments:
### The IPTi adjustment tables were generated using IPTieffectivenessNigeria.R, 
### based on the simulation output, population, CM coverage, and IPTi coverage per LGA. 
### The script generates adjustment tables that include the relative reductions due to IPTi in the  U5 and Uall population
### Since relative reductions are used, the script can be used to scale malaria events in U5 and Uall independent of the timeunit.
### Outcomes that are scaled: malaria prevalence, uncomplicated cases, severe cases and deaths
### The outcomes can be extended to aneamia and hospitalizations if included in the simulation output
### Assumptions: 
### IPTi was assumed to have an effect only on infants up to an age of 12 months and the adjustment was made on an annual level.
### Further improvements might improve IPTi adjustment per months and with effectiveness beyond 12 months, in which case this script needs to be updated. 
### ========================================================================================================================================


library(tidyverse)
library(lubridate)


#### Define paths
 user = Sys.getenv("USERNAME")
 Box = file.path("C:/Users",user,"Box/NU-malaria-team")
 simout_dir = file.path(Box,"projects/hbhi_nigeria/simulation_output/2020_to_2025")
   
 iptiDir = file.path(simout_dir, "cache4_Agebins_FineMonthly")
 scenario_dirs_to_analyze = file.path(simout_dir,"cache4")
 scenarioNames = list.dirs(scenario_dirs, recursive = F, full.names = F)
 
### requires IPTi_adjustment.csv and  IPTi_adjustment.Uall.csv  found in the respective simulation output folder
# source(file.path(..., "IPTieffectivenessNigeria.R"))
 

 scaleIPTi <- function(iptidat, 
                       simdat, 
                       pos,
                       cases,
                       severeCases,
                       deaths ){
 
   #' scaleIPTi
   #' @description  scale simulation outputs for the additional effect of IPTi 
   #' variables that cannot be found in the dataset are skipped (i.e for deaths)
   #' @param iptidat dataframe with IPTi adjustments that corresponds to the scenarios in the simulation output
   #' @param simdat  simulation outputs for U5 or Uall that contains the outcome variables per LGA, scenario and year
   #' @param pos variable name for malaria prevalence
   #' @param cases  variable name for malaria uncomplicated cases
   #' @param severeCases variable name for malaria severe cases
   #' @param deaths variable name for malaria direct or indirect deaths (if available)
   #'  
        
   df = as.data.frame(left_join(simdat, iptidat, by=c("LGA","year")))
   
   colsnotfound = c()
   
   if(pos %in% colnames(df)){
     df[, pos] = df[, pos] * df[, 'IPTiscl.pos']
   } else colsnotfound = c(colsnotfound, "pos" )
   
   if(cases %in% colnames(df)){
     df[, cases] = df[, cases]  *df[, 'IPTiscl.cases']
   } else  colsnotfound = c(colsnotfound, "cases" )
   
   if(severeCases %in% colnames(df)){
     df[, severeCases] =  df[, severeCases]  *  df[,'IPTiscl.Severe.cases']
   } else  colsnotfound = c(colsnotfound, "severeCases" )
   
   if(deaths %in% colnames(df)){
     df[, deaths] = df[, deaths]  *  df[,'IPTiscl.deaths']
   } else  colsnotfound = c(colsnotfound,"deaths" )
   
   if(length(colsnotfound)>0) warning("Variables not found for: ",  colsnotfound )
   
   df = df %>% dplyr::select(colnames(simdat))
   
   return(df)
   
   
 }
 
 
#### Example: loop through IPTi-relevant scenarios and apply IPTi scaling
 
datlist_U5 = list()
datlist_Uall = list()

for (scenarioName in scenarioNames[6:length(scenarioNames)]){
  # scenarioName = scenarioNames[6]
  
  scen = list.dirs(scenario_dirs, recursive = F, full.names = F)

  ipti_adj_U5 = read.csv(file.path(iptiDir, 'IPTi_adjustment.csv'))
  ipti_adj_U5 = ipti_adj_U5[ ipti_adj_U5[,'scenario'] == scenarioName, ]

  ipti_adj_Uall = read.csv(file.path(iptiDir, 'IPTi_adjustment.Uall.csv'))
  ipti_adj_Uall = ipti_adj_Uall[ipti_adj_Uall[,'scenario'] == scenarioName, ]

  df_U5 = read.csv(file.path(scenario_dirs_to_analyze, scenarioName, 'U5_PfPR_ClinicalIncidence_severeTreatment.csv'))
  df_Uall = read.csv(file.path(scenario_dirs_to_analyze, scenarioName, 'All_Age_Monthly_Cases.csv'))
  df_Uall$year = year( df_Uall[,"date"])

  
  df_U5_IPTi = scaleIPTi(iptidat = ipti_adj_U5, 
            simdat = df_U5,
            pos  ="PfPR.U5",
            cases ="Cases.U5" ,
            severeCases ="Severe.cases.U5",
            deaths ="")   # deaths
  
  
  df_Uall_IPTi = scaleIPTi(iptidat = ipti_adj_Uall, 
                        simdat = df_Uall,
                        pos  ="PfHRP2.Prevalence",
                        cases ="New.Clinical.Cases" ,
                        severeCases ="New.Severe.Cases",
                        deaths ="")   # deaths
 
  df_U5_IPTi$scenario = scenarioName
  df_Uall_IPTi$scenario = scenarioName  
    
  datlist_U5[[scenarioName]] <- df_U5_IPTi
  datlist_Uall[[scenarioName]] <- df_Uall_IPTi
  
  rm(df_U5_IPTi, df_Uall_IPTi)
  
  
}


df_U5_IPTi <-  datlist_U5 %>% bind_rows()
df_Uall_IPTi <-  datlist_Uall %>% bind_rows()




