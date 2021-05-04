### ==========================================================================================
### HBHI modeling - NGA: Estimating IPTi impact
### ==========================================================================================
### DESCRIPTION:
# The effect of IPTi is estimated by combining assumed IPTi coverage estimates with IPTi efficacy parameter and
# applying these to the outcome predictions in infants.
# The averted malaria events in infants due to IPTi is subtracted from the malaria events in children under the age of five years
# and the total population to approximate the effect of IPTi in these age groups.
# The adjustment is applied for each LGA, each run number and each intervention scenario per year.
# Parameters varying per LGA are the predicted malaria events and the IPTi coverage.
#Outcomes that are scaled: malaria prevalence, uncomplicated cases, severe cases and deaths.
#
#Main assumptions:
# - IPTi only has an effect on infants up to an age of 12 months
# - IPTi adjustment was made at an annual level (averaging over all three doses currently recommended)
# - IPTi protective efficacy estimates from past clinical trials, included in the systematic review from
#    (Esu et al 2019)[https://www.cochranelibrary.com/cdsr/doi/10.1002/14651858.CD011525.pub2/full],
#    applicable to the Nigerian setting today
# - IPTi coverage approximated by Penta 2, Penta 3 & Measles vaccine coverage
#   (Source: (Demographic Health Survey)[https://dhsprogram.com/] Nigeria 2018)
#
### STEPS:
# Define experiment settings
# Run IPTi effectiveness (IPTieffectiveness.R)
#   1. Read in IPTi coverage and CM data
#   2. Read in simulation outputs, U1, U5, Uall
#   3. IPTi effectiveness adjustment for U1
#   4. Subtract malaria events averted in U1 from U5 and Uall
#   5. Generate IPTi relative reductions table used for scaling and save
# Combine csv files per scenario into single csv file per age group
#
### REQUIREMENTS:
# - Case management csv with estimates for U5 as used in the HBHI analyzers ("HS_placeholder_scen2_80_v5","cm_scen2_10_v3","cm_scen2_20_v3","cm_scen2_30_v3")
# - Requires that IPTi coverage has already been calculated and saved (IPTicov.csv) in appropriate format with columns for
#   - LGA, State, IPTyn, IPTicov
#   - including IPTi eligible as well as not eligible LGA's (relative reduction will be set to 1 regardless of coverage), to facilitate merging in the IPTp scaling afterwards.
# - Requires the HBHI simulation output files for each of the scenarios to have been generated
#   by the HBHI analyzers and saved in the appropriate simulation scenario folders ('U1_PfPR_ClinicalIncidence_severeTreatment.csv')
#
### R requirements
# - R version >= 4.0.2
# - `data.table`, `dplyr`, `plyr`
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
f_combineAndSave(exp_names, Uage = "U1", fnameOUT = "IPTi_adjustment_U1.csv")
f_combineAndSave(exp_names, Uage = "U5", fnameOUT = "IPTi_adjustment_U5csv")
f_combineAndSave(exp_names, Uage = "Uall", fnameOUT = "IPTi_adjustment_Uall.csv")
