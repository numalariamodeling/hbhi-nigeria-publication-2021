### ==========================================================================================
### HBHI modelling - NGA: Estimating IPTi impact
### ==========================================================================================

### Load Packages
library(plyr)
library(dplyr)
library(data.table)

### Define directories
user <- Sys.getenv("USERNAME")
Drive <- file.path(gsub("[\\]", "/", gsub("Documents", "", Sys.getenv("HOME"))))
boxdir <- file.path(Drive, "Box","NU-malaria-team")
if(dir.exists(boxdir)){
  ProjectDir <- file.path(boxdir, "projects", "hbhi_nigeria")
} else{
  boxdir <- file.path(Drive, "Box")
  ProjectDir <- file.path(boxdir, "hbhi_nigeria")
}
wdir <- file.path(getwd(), "IPTi_scaling")
cm_dir <- file.path(getwd(), "simulation_inputs")
simoutDir <- file.path(ProjectDir, "simulation_output", "2020_to_2030_v3")

## Define scenario names to run IPTi adjustment for
exp_names <- c("NGA projection scenario 2", "NGA projection scenario 3",
               "NGA projection scenario 4", "NGA projection scenario 5")
cm_names <- c("HS_placeholder_scen2_80_v5","cm_scen2_10_v3","cm_scen2_20_v3","cm_scen2_30_v3")
ipti_cov_multipliers <- c(0.8, 1.1, 1.2, 1.3)

## From to
fut_start_year <- 2020
fut_end_year <- 2031

### Specify CFR for calculating mortality
CFR_treated_severe <- 0.097
CFR_untreated_severe <- 0.539

### Helper functions
source(file.path(wdir, "f_scaleIPTi.R"))
source(file.path(wdir, "helper_functions.R"))

### Run IPTi scaling per scenario
print("Running IPTieffectiveness.R")
source(file.path(wdir, "IPTieffectiveness.R"))

### Combine scaling factor csvs for all scenarios
print("Running combineIPTi_files.R")
f_combineAndSave(exp_names, Uage = "U1", fnameOUT = "IPTi_adjustment.U1.csv")
f_combineAndSave(exp_names, Uage = "U5", fnameOUT = "IPTi_adjustment.csv")
f_combineAndSave(exp_names, Uage = "Uall", fnameOUT = "IPTi_adjustment.Uall.csv")
