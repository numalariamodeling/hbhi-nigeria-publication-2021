#################################################################################################
# High burden, high impact 
# get_num_IPTp_doses.R
# Monique Ambrose
# February 2020
#
# 
# Calculate the number of IPTp doses used in each scenario in each year across entire country.
#
# Uses the simulation population sizes for each LGA & year, estimates of the true population 
#    sizes for each LGA & year, and the number of IPTp doses used in the simulated scenario.

# REQUIREMENTS:
# - Requires that the simAdjustments_mortality_MiP_IPTp_IPTi.R script has already been run
# - requires a population size csv file saved in the country's base box directory
#
#
#################################################################################################

# calculate the total number of IPTp doses distributed in the country in each year

library(data.table)
library(dplyr)


##### User-specified information on scenarios to use: #################### 
user = Sys.getenv("USERNAME")
user_path = file.path("C:/Users",user)

# set name of country to run
country_name = 'Nigeria'
# filepath for simulation output
box_hbhi_filepath = paste(user_path, '/Box/hbhi_nigeria', sep='')
sim_output_filepath = paste(box_hbhi_filepath, '/simulation_output/2020_to_2025/cache5', sep='')

##########################################################################

# get filenames and information for all of the scenarios currently being processed
scenario_adjusmtnet_info_filepath = paste(sim_output_filepath,  '/scenario_adjustment_info.csv', sep='')
scenario_adjustment_info = read.csv(scenario_adjusmtnet_info_filepath, as.is=TRUE)
run_nums=0:0

# population sizes and CHW coverages (for Burkina)
if(country_name =='Burkina'){
  # populations sizes for each DS
  ds_pop_size_filepath = paste(box_hbhi_filepath, '/burkina_DS_pop.csv', sep='')
}else if(country_name =='Nigeria'){
  # populations sizes for each DS
  ds_pop_size_filepath = paste(box_hbhi_filepath, '/nigeria_LGA_pop.csv', sep='')
}
# read in population sizes for each DS
ds_pop_size = fread(ds_pop_size_filepath) # assume constant population size through time
# reformat names to match LGA names from IPTp doses
# ds_pop_size$LGA = gsub(' ', '.', ds_pop_size$LGA)
# ds_pop_size$LGA = gsub('-', '.', ds_pop_size$LGA)
# ds_pop_size$LGA = gsub("'", '.', ds_pop_size$LGA)
# ds_pop_size$LGA[ds_pop_size$LGA=='Kiyawa'] = 'kiyawa'
# ds_pop_size$LGA[ds_pop_size$LGA=='Kaita'] = 'kaita'

for(i_scen in 1:length(scenario_adjustment_info$ScenarioName)){
  for(i_run in 1:length(run_nums)){
    cur_run = run_nums[i_run]
    # get filename and coverage information for this scenario
    scenarioName_cur = scenario_adjustment_info$ScenarioName[i_scen]
    scenarioName_IPTi = scenario_adjustment_info$IPTi_scenario_name[i_scen]
    sim_output_base_filepath = paste(sim_output_filepath, '/', scenarioName_cur, sep='')
    future_projection_flag = scenario_adjustment_info$future_projection_flag[i_scen]
    coverage_string = scenario_adjustment_info$IPTp_string[i_scen]
    
    # read in dose numbers for each ds and each month
    num_doses_IPTp_each_DS_month_filename = paste(sim_output_base_filepath, '/mortality_LBW/num_doses_IPTp_each_DS_month',coverage_string,'_run',cur_run, '.csv', sep='')
    num_doses_IPTp_each_DS_month = fread(num_doses_IPTp_each_DS_month_filename)
    
    # read in simulated population size numbers for each ds and each month
    sim_pop_sizes_filename = paste(sim_output_base_filepath, '/mortality_LBW/pop_size_run',cur_run, '.csv', sep='')
    sim_pop_size = fread(sim_pop_sizes_filename)
    colnames(sim_pop_size)[colnames(sim_pop_size)=='kiyawa'] = 'Kiyawa'
    colnames(sim_pop_size)[colnames(sim_pop_size)=='kaita'] = 'Kaita'
    
    
    # transform the simulation population size and IPTp dose data frames so that the rows are DS, the columns are years
    # aggregate to total doses each year, each ds
    sim_pop_size_year = aggregate(sim_pop_size, list(sim_pop_size$year), FUN=mean)
    sim_pop_size_year_t = t(sim_pop_size_year)
    colnames(sim_pop_size_year_t) = as.integer(sim_pop_size_year_t['Group.1',])
    sim_pop_size_year_t = sim_pop_size_year_t[-(1:3),]
    sim_pop_size_year_t = as.data.frame(sim_pop_size_year_t)
    sim_pop_size_year_t$LGA = colnames(sim_pop_size_year[,-(1:3)])
    
    # transform IPTp dose dataframe in the same way
    num_doses_IPTp_each_DS_year = aggregate(num_doses_IPTp_each_DS_month, list(num_doses_IPTp_each_DS_month$year), FUN=sum)
    num_doses_IPTp_each_DS_year_t = t(num_doses_IPTp_each_DS_year)
    colnames(num_doses_IPTp_each_DS_year_t) = as.integer(num_doses_IPTp_each_DS_year_t['Group.1',])
    num_doses_IPTp_each_DS_year_t = num_doses_IPTp_each_DS_year_t[-(1:3),]
    num_doses_IPTp_each_DS_year_t = as.data.frame(num_doses_IPTp_each_DS_year_t)
    num_doses_IPTp_each_DS_year_t$LGA = colnames(sim_pop_size_year[,-(1:3)])
    

    if((length(ds_pop_size$LGA[which(!(ds_pop_size$LGA %in% sim_pop_size_year_t$LGA))])==0)  && (length(sim_pop_size_year_t$LGA[which(!(sim_pop_size_year_t$LGA %in% ds_pop_size$LGA))])==0)){
      # merge with pop size dataframes based on DS name
      pop_size_sim_true = merge(sim_pop_size_year_t, ds_pop_size, by=c('LGA'), sort=FALSE)  # not sorting keeps in same order as num_doses data frame
      # get multiplier for IPTp doses (goal is to calculate number of doses for the full population using geopode.pop size): geopode.pop / simulation pop
      pop_size_multiplier = pop_size_sim_true$geopode.pop / pop_size_sim_true[,2:(2+dim(sim_pop_size_year)[1]-1)]
      pop_size_multiplier$LGA = pop_size_sim_true$LGA
      
      # multiply number of IPTp doses with rescaling factor
      num_doses_rescaled_each_LGA = num_doses_IPTp_each_DS_year_t[,1:dim(sim_pop_size_year)[1]] * pop_size_multiplier[,1:dim(sim_pop_size_year)[1]]
      num_doses_rescaled = apply(num_doses_rescaled_each_LGA, 2, sum)
      write.csv(num_doses_rescaled[2:length(num_doses_rescaled)], paste(sim_output_base_filepath, '/mortality_LBW/num_doses_IPTp_rescaled_full_pop',coverage_string,'_run',cur_run, '.csv', sep=''))

    }else warning('LGA names from pop size data frame not matched with IPTp dose data frame')
  }
}

