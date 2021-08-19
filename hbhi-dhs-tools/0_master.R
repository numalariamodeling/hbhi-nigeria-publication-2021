### ==========================================================================================
### HBHI modeling - Nigeria: Estimating intervention coverage by LGA 
### This script generates DHS estimates at various levels for variables indicated in the analysis_variables_requirements.csv. 
### In analysis_variables_requirements.csv make sure that the variable_to_run column is set to TRUE for the variable and subvariable of interest 
### Check file paths and make sure they are correct. That is Box folders are correctly linked, as well as the data and script directory 
### September 2020, Ifeoma Doreen Ozodiegwu
### ==========================================================================================
rm(list = ls())
memory.limit(size = 50000)

## -----------------------------------------
### Directories
## -----------------------------------------
user <- Sys.getenv("USERNAME")
if ("mambrose" %in% user) {
  user_path <- file.path("C:/Users", user)
  Drive <- file.path(gsub("[\\]", "/", gsub("Documents", "", Sys.getenv("HOME"))))
  NuDir <- file.path(Drive, "NU-malaria-team")
  NGDir <-file.path(NuDir, "data", "nigeria_dhs",  "data_analysis")
  DataDir <-file.path(NGDir, "data")
  ResultDir <-file.path(NGDir, "results")
  SrcDir <- file.path(NGDir, "src", "DHS")
  BinDir <- file.path(NGDir, "bin")
} else {
  Drive <- file.path(gsub("[\\]", "/", gsub("Documents", "", Sys.getenv("HOME"))))
  NuDir <- file.path(Drive, "Box", "NU-malaria-team")
  NGDir <-file.path(NuDir, "data", "nigeria_dhs",  "data_analysis")
  DataDir <-file.path(NGDir, "data")
  ResultDir <-file.path(NGDir, "results")
  BinDir <- file.path(NGDir, "bin")
  SrcDir <- file.path(NGDir, "src", "DHS")
  VarDir <- file.path(SrcDir, "1_variables_scripts")
  ProjectDir <- file.path(NuDir, "projects", "hbhi_nigeria")
  SimDir <- file.path(ProjectDir, 'simulation_input')
}


## -----------------------------------------
### Required functions and settings
## -----------------------------------------
source(file.path(VarDir, "generic_functions", "DHS_fun.R"))

## -----------------------------------------
### Other files 
## -----------------------------------------

# state shape file 
stateshp <- readOGR(file.path(DataDir,'shapefiles',"gadm36_NGA_shp"), layer ="gadm36_NGA_1", use_iconv=TRUE, encoding= "UTF-8")
state_sf <- st_as_sf(stateshp)
colnames(state_sf)[4] <- "State"


# LGA shape file
LGAshp <- readOGR(file.path(DataDir,'shapefiles', "Nigeria_LGAs_shapefile_191016"), layer ="NGA_LGAs", use_iconv=TRUE, encoding= "UTF-8")
LGA_clean_names <- clean_LGA_2(file.path(DataDir,'shapefiles', "Nigeria_LGAs_shapefile_191016"), file.path(BinDir,"names/LGA_shp_pop_names.csv"))
class(LGA_clean_names)



# rep DS file
rep_DS <- read.csv(file.path(BinDir, "rep_DS/representative_DS_orig60clusters.csv")) %>% dplyr::select(-X) 

## -----------------------------------------
### Variables  
## -----------------------------------------

library(nngeo)
var_df <- read.csv(file.path(SrcDir, "analysis_variables_requirements_manuscript.csv"))
for (i in 1:nrow(var_df)){
      if (var_df[, "variable_to_run"][i] == TRUE){
      Variable <-  var_df[, "Variable"][i]
      subVariable <- var_df[, "subVariable"][i]
      smoothing <- var_df[, "smoothing"][i]
      smoothing_type <- var_df[, "smoothing_type"][i]
      plot <- var_df[, "plot"][i]
      SAVE <- var_df[, "SAVE"][i]
      age <- var_df[, "age"][i]
      
      # cluster locations 
      NGAshplist<-read.files("*FL.shp$", DataDir, shapefile)
      key_list <- map(NGAshplist, over.fun)
      NGAshplist <- lapply(NGAshplist, st_as_sf)
      #key_list <- lapply(key_list, st_as_sf)
      #key_list <- lapply(NGAshplist, function(x) x %>%st_join(LGA_clean_names, join = st_nn, maxdist = 10000))
      
      source(file.path(VarDir, var_df[, "fun_path"][i]))
      source(file.path(VarDir, var_df[, "main_path"][i]))
      }
}


