# calculate relative malaria burden with different scenarios (relative to BAU)
user = Sys.getenv("USERNAME")
user_path = file.path("C:/Users",user)
box_hbhi_filepath = paste(user_path, '/Box/hbhi_burkina', sep='')
sim_output_filepath = paste(box_hbhi_filepath, '/simulation_output/2020_to_2022_covid', sep='')
simname_stem = 'BF projection scenario Covid new'
baseline_simname = 'BF projection scenario Covid new 15'
# scenario_fname = paste(box_hbhi_filepath, '/simulation_inputs', '/Intervention_scenarios_COV_v3.csv', sep='')

scenario_adjusmtnet_info_filepath = paste(sim_output_filepath,  '/scenario_adjustment_info.csv', sep='')
scenario_adjustment_info = read.csv(scenario_adjusmtnet_info_filepath, as.is=TRUE)
# check whether scenario name column already exists. if not, create it
if(!('ScenarioName' %in% colnames(scenario_adjustment_info))){
  scenario_adjustment_info$ScenarioName = paste(simname_stem, scenario_adjustment_info$Scenario_no)
}

order_column = 'plot_order_best_to_Worst'  # 'plot_order_best_to_Worst', 'plot_order_worst_to_best'
included_columns = c('PfPR',	'incidence',	'death_rate_1',	'death_rate_2',	
                     'U5_PfPR',	'U5_incidence',	'U5_death_rate_1',	'U5_death_rate_2', 
                     'num_mLBW',	'num_mStillbirths')

num_scenarios = length(scenario_adjustment_info$plot_order_worst_to_best)

relative_df = data.frame(matrix(NA,nrow=num_scenarios, ncol=(length(included_columns)+3)))
colnames(relative_df) = c('ScenarioName', 'CM_multiplier','SMC_maxAge', included_columns)


# read in annual indicator results for baseline
baseline_indicators = read.csv(paste(sim_output_filepath, '/', baseline_simname, '/annual_indicators.csv', sep=''))
col_index_orig = match(included_columns, colnames(baseline_indicators))

for (ii in 1:num_scenarios){
  new_row = scenario_adjustment_info[[order_column]][ii]
  relative_df$ScenarioName[new_row] = scenario_adjustment_info$ScenarioName[ii]
  relative_df$CM_multiplier[new_row] = scenario_adjustment_info$CM_multiplier[ii]
  relative_df$SMC_maxAge[new_row] = scenario_adjustment_info$SMC_maxAge[ii]

    # read in results for annual indicators in this scenario
  cur_indicators = read.csv(paste(sim_output_filepath, '/', scenario_adjustment_info$ScenarioName[ii], '/annual_indicators.csv', sep=''))
  relative_df[new_row, 4:length(colnames(relative_df))] = (cur_indicators[1, col_index_orig] - baseline_indicators[1, col_index_orig])#/baseline_indicators[1, col_index_orig]
}
View(relative_df)

# write.csv(relative_df, paste(sim_output_filepath, '/relative_difference_each_scenario.csv', sep=''))
# write.csv(relative_df, paste(sim_output_filepath, '/factor_each_scenario_divided_by_baseline.csv', sep=''))
write.csv(relative_df, paste(sim_output_filepath, '/difference_each_scenario.csv', sep=''))
rel_mat = as.matrix(relative_df[-dim(relative_df)[1],-c(1:3)])
image(rel_mat, col=terrain.colors(100), breaks=seq(min(rel_mat), max(rel_mat), length.out=101))








# U5 - unadjusted
included_columns = c('U5.PfPR',	'U5.incidence',	'U5.death.rate')

baseline_indicators = read.csv(paste(sim_output_filepath, '/', baseline_simname, '/U5_annual_indicators.csv', sep=''))
col_index_orig = match(included_columns, colnames(baseline_indicators))

relative_df = data.frame(matrix(NA,nrow=num_scenarios, ncol=(length(included_columns)+3)))
colnames(relative_df) = c('ScenarioName', 'CM_multiplier','SMC_maxAge', included_columns)

for (ii in 1:num_scenarios){
  new_row = scenario_adjustment_info[[order_column]][ii]
  relative_df$ScenarioName[new_row] = scenario_adjustment_info$ScenarioName[ii]
  relative_df$CM_multiplier[new_row] = scenario_adjustment_info$CM_multiplier[ii]
  relative_df$SMC_maxAge[new_row] = scenario_adjustment_info$SMC_maxAge[ii]
  
  # read in results for annual indicators in this scenario
  cur_indicators = read.csv(paste(sim_output_filepath, '/', scenario_adjustment_info$ScenarioName[ii], '/U5_annual_indicators.csv', sep=''))
  relative_df[new_row, 4:length(colnames(relative_df))] = (cur_indicators[1, col_index_orig] - baseline_indicators[1, col_index_orig])/baseline_indicators[1, col_index_orig]
}
View(relative_df)


write.csv(relative_df, paste(sim_output_filepath, '/relative_difference_each_scenario_U5_unadjusted.csv', sep=''))



# all age - unadjusted
included_columns = c('PfPR',	'incidence',	'death.rate')

baseline_indicators = read.csv(paste(sim_output_filepath, '/', baseline_simname, '/all_age_annual_indicators.csv', sep=''))
col_index_orig = match(included_columns, colnames(baseline_indicators))

relative_df = data.frame(matrix(NA,nrow=num_scenarios, ncol=(length(included_columns)+3)))
colnames(relative_df) = c('ScenarioName', 'CM_multiplier','SMC_maxAge', included_columns)

for (ii in 1:num_scenarios){
  new_row = scenario_adjustment_info[[order_column]][ii]
  relative_df$ScenarioName[new_row] = scenario_adjustment_info$ScenarioName[ii]
  relative_df$CM_multiplier[new_row] = scenario_adjustment_info$CM_multiplier[ii]
  relative_df$SMC_maxAge[new_row] = scenario_adjustment_info$SMC_maxAge[ii]
  
  # read in results for annual indicators in this scenario
  cur_indicators = read.csv(paste(sim_output_filepath, '/', scenario_adjustment_info$ScenarioName[ii], '/all_age_annual_indicators.csv', sep=''))
  relative_df[new_row, 4:length(colnames(relative_df))] = (cur_indicators[1, col_index_orig] - baseline_indicators[1, col_index_orig])/baseline_indicators[1, col_index_orig]
}
View(relative_df)

write.csv(relative_df, paste(sim_output_filepath, '/relative_difference_each_scenario_all_age_unadjusted.csv', sep=''))
