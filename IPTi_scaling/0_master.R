### ==========================================================================================
### HBHI modelling - Nigeria: Estimating IPTi coverage per LGA
### Feb 2020, MR
### ==========================================================================================
# setwd("~hbhi-nigeria/simulation/IPTi_scaling")
library(plyr)
library(dplyr)
SAVE <- TRUE

## -----------------------------------------
### Directories
## -----------------------------------------
user <- Sys.getenv("USERNAME")
if ("mambrose" %in% user) {
  user_path <- file.path("C:/Users", user)
  Drive <- file.path(gsub("[\\]", "/", gsub("Documents", "", Sys.getenv("HOME"))))
  ProjectDir <- file.path(Drive, "Box")
  script_directory <- file.path(Sys.getenv("HOME"), "hbhi-nigeria", "simulation", "IPTi_scaling")
  WorkingDir <- file.path(ProjectDir, "IPTi")
  shpDir <- file.path(ProjectDir, "nigeria_shapefiles")
  cm_dir <- file.path(ProjectDir, "hbhi_nigeria/simulation_inputs/projection_csvs/projection_v3")
} else {
  Drive <- "C:/Users/dhano_5" # file.path(gsub("[\\]", "/", gsub("Documents", "", Sys.getenv("HOME"))))
  NUDir <- file.path(Drive, "Box/NU-malaria-team")
  ProjectDir <- file.path(NUDir, "projects")
  WorkingDir <- file.path(ProjectDir, "IPTi")
  shpDir <- file.path(Drive, "Box/NU-malaria-team/data/nigeria_shapefiles")
  cm_dir <- file.path(ProjectDir, "hbhi_nigeria/simulation_inputs/projection_csvs/projection_v3")
  script_directory <- "C:/Users/dhano_5/Documents/hbhi-nigeria-publication-2021/IPTi_scaling" # file.path(getwd()) #' IPTi_scaling'
}



## -----------------------------------------
### Experiment specific objects
## -----------------------------------------
sim_iteration <- "2020_to_2030_v3"
simoutDir <- file.path(ProjectDir, "hbhi_nigeria", "simulation_output", sim_iteration)

fut_start_year <- 2020
fut_end_year <- 2030

## Load experiment details
exp_names <- list.dirs(simoutDir, recursive = F, full.names = F)
exp_names <- exp_names[grep("NGA projection scenario", exp_names)]
exp_names <- exp_names[!grepl("_missing", exp_names)]

scendat <- read.csv(file.path(cm_dir, "Intervention_scenarios_nigeria_v3.csv"))
scenariosWithIPTi <- scendat[scendat$IPTi_cov_muliplier != 0, "Scenario_no"]
exp_names <- exp_names[grep(paste(scenariosWithIPTi, collapse = "|"), exp_names)]

exp_names <- exp_names[order(as.numeric(gsub("[^0-9]+", "", exp_names)))]

## -----------------------------------------
### Required custom functions and settings
## -----------------------------------------
source(file.path(script_directory, "functions/setup.R"))
source(file.path(script_directory, "functions/f_scaleIPTi.R"))
source(file.path(script_directory, "functions/helper_functions.R"))


## -----------------------------------------
### Run R scripts
## -----------------------------------------
rerunCoverageTable <- F
generateDescriptive <- F

### 1 Optional, only run if rerun coverage data table
if (rerunCoverageTable) source("1_IPTicoverageNigeria.R")


### 2 Required
### Note this script needs to be edited for new intervention iterations
### Line 42 - 120  defineScenarioInformation
source(file.path(script_directory, "2_IPTieffectivenessNigeria.R"))


### 3 Required, after #2 completed for all scenarios
source(file.path(script_directory, "3_combineIPTi_files.R"))


### 4 Optional, generate descriptive plots
if (generateDescriptive) source("4_IPTieffectivenessNigeria_descriptive.R")

