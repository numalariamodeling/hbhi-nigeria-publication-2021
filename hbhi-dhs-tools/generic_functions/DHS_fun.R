#Make sure we have the right packages
list.of.packages <- c("tidyverse", "survey", "haven", "ggplot2", "purrr",  "stringr", "sp", "rgdal", "raster",
                      "lubridate", "RColorBrewer","sf", "shinyjs", "tmap", "knitr", "labelled", "plotrix", "arules", "foreign",
                      "fuzzyjoin", "splitstackshape","ggpubr", "nngeo", "locfit")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)



if (!("INLA" %in% installed.packages()[, 'Package'])){
  install.packages("INLA", repos=c(getOption("repos"), INLA="https://inla.r-inla-download.org/R/stable"), dep=TRUE)
}


lapply(list.of.packages , library, character.only = TRUE) #applying the library function to packages


options(survey.lonely.psu="adjust") # this option allows admin units with only one cluster to be analyzed


#This function read in all files with three different file patterns in all folders and subfolders in the working directory

read.files <- function(filepat1,path,fun) {
  filenames <- list.files(path = path, pattern = filepat1, recursive = TRUE, full.names = TRUE)
  #in_files_K <- list.files(path = path, pattern =  filepat2, recursive = TRUE, full.names = TRUE)
  #in_files_P <- list.files(path = path, pattern = filepat3, recursive = TRUE, full.names = TRUE)
  #filenames <- rbind(in_files_I, in_files_K, in_files_P)
  sapply(filenames, fun, simplify = F)
}


#function for cleaning other files 
dataclean<-function(data, filter_var, filter_var1, cols, new_col){
  filter_var <- enquo(filter_var)
  filter_var1 <- enquo(filter_var1)
  data <- data %>% filter(!is.na(!!filter_var) | (!is.na(!!filter_var1)))
  data5<-rename_(data, .dots = setNames(cols, new_col))  
  data5%>%   
    mutate(wt=v005/1000000,strat=v022,
           id=v021, num_p=1) 
}



dataclean2<-function(data, filter_var, filter_var1, cols, new_col){
  filter_var <- enquo(filter_var)
  filter_var1 <- enquo(filter_var1)
  data <- data %>% filter(!is.na(!!filter_var) | (!is.na(!!filter_var1)))
  data5<-rename_(data, .dots = setNames(cols, new_col))  
  data5%>%   
    mutate(wt=hv005/1000000,strat=hv022,
           id=hv021, num_p=1) 
}


#survey design function 
svydesign.fun <- function(filename){
  svydesign(id= ~id,
            strata=~strat,nest=T, 
            weights= ~wt, data=filename)
}


#generating results and table function with estimates 
result.fun<- function(var, var1, design, data) { #year
  year <- unique(na.omit(data$v007))
  p_est<-svyby(formula=make.formula(var), by=make.formula(var1), FUN=svymean, design, na.rm=T) # svyciprop, method ='logit', levels=0.95, vartype= "se"
  cbind(p_est, year)
  }

result.fun2<- function(var, var1, design, data) { #year
year <- unique(na.omit(data$hv007))
p_est<-svyby(formula=make.formula(var), by=make.formula(var1), FUN=svymean, design, na.rm=T) # svyciprop, method ='logit', levels=0.95, vartype= "se"
cbind(p_est, year)
}   
  
  # num_est<-svyby(formula=make.formula(var2), by=make.formula(var1), FUN=svytotal, design, na.rm=T)%>% 
  #   dplyr:: select(-se)%>% mutate(num_p = round(num_p, 0))
  
  # p_est%>%left_join(num_est)%>% rename(`Number of Participants` = num_p)
  
  #year <- data.frame(year = unique(data[,year]))
  
  
  



clean_LGA <- function(filepath, namefilepath) {
  
  LGAshp <- readOGR(filepath, layer ="NGA_LGAs", use_iconv=TRUE, encoding= "UTF-8")
  
  LGAshp_sf <- st_as_sf(LGAshp)
  
  LGA_names <- read.csv(namefilepath)
  
  left_join(LGAshp_sf, LGA_names, by=c("LGA" = "LGA_shape")) %>% 
    mutate(LGA = str_replace_all(LGA, "/", "-"), LGA = case_when(LGA == "kiyawa"~ "Kiyawa", LGA == "kaita" ~"Kaita", TRUE ~ LGA)) 
  
}

clean_LGA_2 <- function(filepath, namefilepath) {
  
  LGAshp <- readOGR(filepath, layer ="NGA_LGAs", use_iconv=TRUE, encoding= "UTF-8")
  
  LGAshp_sf <- st_as_sf(LGAshp)
  
  LGA_names <- read.csv(namefilepath)
  
  left_join(LGAshp_sf, LGA_names, by=c("LGA" = "LGA_shape")) %>% 
    mutate(LGA = case_when(LGA == "kiyawa"~ "Kiyawa", LGA == "kaita" ~"Kaita", TRUE ~ LGA)) 
  
}

map_fun <- function(shpfile, map_val, var) {
  year <- unique(na.omit(shpfile$year))
  tm_shape(shpfile) + #this is the health district shapfile with LLIn info
    tm_polygons(col = map_val, textNA = "No data", 
                title = "", palette = "seq", breaks=c(0, 0.1, 0.2, 
    0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 1.0))+
    tm_layout(title =paste0(year, " ", var, " ", "dhs"),
              aes.palette = list(seq="RdYlBu")) 
}



map_fun_2 <- function(shpfile, map_val, var) {
  year <- unique(na.omit(shpfile$year))
  tm_shape(shpfile) + #this is the health district shapfile with LLIn info
    tm_polygons(col = map_val, textNA = "No data", 
                title = "", palette = "seq", breaks=c(0, 0.2, 
                                                      0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0))+
    tm_layout(title =paste0(year, " ", var, " ", "dhs"),
              aes.palette = list(seq="-RdYlBu")) 
}




map_fun_3 <- function(shpfile, map_val, var) {
  year <- unique(na.omit(shpfile$year))
  tm_shape(shpfile) + #this is the health district shapfile with LLIn info
    tm_polygons(col = map_val, textNA = "No data", 
                title = "", palette = "seq", breaks=c(1, 2, 
                                                      3, 4, 5, 6, 7, 8, 9, 10))+
    tm_layout(title =paste0(year, " ", var, " ", "dhs"),
              aes.palette = list(seq="-PuRd")) 
}
# handy functions for transforming the data
logit<-function(x){
  log(x/(1-x))
}


expit<-function(x){
  exp(x)/(1+exp(x))
}



#over function 
over.fun <- function(df) {
  sp::over(SpatialPoints(coordinates(df),proj4string = df@proj4string), LGAshp)
}

