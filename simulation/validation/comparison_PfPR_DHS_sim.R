#################################################################################################################################################
# comparison_PfPR_DHS_sim.R
# HBHI - Nigeria written by Monique Ambrose and repurposed by Ifeoma Ozodiegwu for Nigeria 
# contact: Ifeoma Ozodiegwu 
# December 2020

# currently, we claim that our calibration and parameterization was successful because we can see that simulated DS trajectories often visually 
#    agree fairly well with survey/surveillance data. To look at this a bit more closely and to see how DS-specific this match is, create a 
#    series of plots that compare simulation and data, either for the same (matched) DS or for mismatched DS.
# main types of comparisons are:
#    1) comparison of PfPR seasonality (plot the DHS PfPR according to month of survey, along with corresponding simulation values)
#    2) scatter plot comparisions of PfPR between observed DHS and corresponding simulation values
#    3) change between survey years (percent or absolute change within a DS or admin1 area in the aggregated PfPR in different survey years)
#    4) histograms of PfPR values, differences, and likelihoods

#################################################################################################################################################


###########################################################################
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #
#                                setup
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #
###########################################################################
rm(list = ls())
# library(ggplot2)
# library(ggpubr)
# library(gridExtra)
# library(data.table)
# library(RColorBrewer)
# library(tidyr)
# library(tibble)
# library(dplyr)
# library(reshape2)
# library(hablar)
# library(stringr)
# library(lubridate)

list.of.packages <- c("tidyverse", "ggplot2", "purrr",  "stringr", "sp", "rgdal", "raster", "hablar", 
                      "lubridate", "RColorBrewer", "ggpubr", "gridExtra", "data.table",  "nngeo", "reshape2")
lapply(list.of.packages, library, character.only = TRUE) #applying the library function to packages



###################################################################
#   read in and format data and simulation output
###################################################################


box_filepath = "C:/Users/ido0493/Box/NU-malaria-team/projects"
box_hbhi_filepath = paste0(box_filepath, '/hbhi_nigeria')
SrsDir = file.path(box_hbhi_filepath, 'DS DHS estimates', 'U5', 'pfpr', 'SRS') 
SvyDir = file.path(box_hbhi_filepath, 'DS DHS estimates', 'U5', 'pfpr', 'DHS.data_surveyd')
ifelse(!dir.exists(file.path(box_hbhi_filepath, "project_notes/publication/Hbhi modeling/validation/PfPR")), 
       dir.create(file.path(box_hbhi_filepath, "project_notes/publication/Hbhi modeling/validation/PfPR")), FALSE)
print_path <- file.path(box_hbhi_filepath, "project_notes/publication/Hbhi modeling/validation/PfPR")


# - - - - - - - - - - - - - - - - #
# DHS PfPR data
# - - - - - - - - - - - - - - - - #

#get svy adjusted estimates 
files <- list.files(path = SvyDir, pattern = "*_micro.csv", full.names = TRUE)
df <- sapply(files, read_csv, simplify = F)
colnames(df[[1]])[4:6] = c('p_test_mean',  'p_test_std.error', 'num_U5_sampled')
colnames(df[[2]])[4:6] = c('p_test_mean',  'p_test_std.error', 'num_U5_sampled')
colnames(df[[3]])[4:6] = c('p_test_mean',  'p_test_std.error', 'num_U5_sampled')
# combine dhs from multiple years and get U5 sampled with LGA 
df_Svyd <- plyr::ldply(df, rbind) %>%  dplyr::select(LGA, time2, num_U5_sampled) %>% 
  mutate(LGA = case_when(LGA == "kaita" ~ "Kaita",
                         LGA == "kiyawa" ~ "Kiyawa",
                         TRUE ~ as.character(LGA)))


#get SRS estimates 
files <- list.files(path = SrsDir, pattern = "*_micro.csv", full.names = TRUE)
df2 <- sapply(files, read.csv, simplify = F)
colnames(df2[[1]])[4:7] = c('p_test_mean',  'p_test_sd', 'p_test_std.error', 'num_U5_sampled')
colnames(df2[[2]])[4:7] = c('p_test_mean',  'p_test_sd', 'p_test_std.error', 'num_U5_sampled')
colnames(df2[[3]])[4:7] = c('p_test_mean', 'p_test_sd', 'p_test_std.error', 'num_U5_sampled')
#combine survey results 
df_SRS <- plyr::ldply(df, rbind) %>%  dplyr::select(-num_U5_sampled) %>%  
  mutate(LGA = case_when(LGA == "kaita" ~ "Kaita",
                         LGA == "kiyawa" ~ "Kiyawa",
                         TRUE ~ LGA)) %>%  
  left_join(df_Svyd) 

dhs_pfpr <- df_SRS %>%  drop_na() %>%  mutate(month = str_split(time2, "-", simplify = TRUE)[,1],
                                                year = str_split(time2, "-", simplify = TRUE)[,2],
                                                date = make_date(year, month))



# - - - - - - - - - - - - - - - - #
# simulation output
# - - - - - - - - - - - - - - - - #
sim_filepath_2010 = paste0(box_hbhi_filepath, '/simulation_output/2010_to_2020_v10/NGA 2010-20 burnin_hs+itn+smc')
pfpr_case_all_2010 = fread(paste0(sim_filepath_2010, '/All_Age_monthly_Cases.csv'))
pfpr_case_all_2010[,date:=as.Date(date)]
pfpr_case_all_2010$year = lubridate::year(pfpr_case_all_2010$date)
pfpr_case_all_2010$month = lubridate::month(pfpr_case_all_2010$date)
pfpr_case_u5_2010 = fread(paste0(sim_filepath_2010, '/U5_PfPR_ClinicalIncidence_severeTreatment.csv'))
pfpr_case_u5_2010[,date:=as.Date(paste0(year,"-",month,"-01"),format="%Y-%m-%d")]
# mean values across runs
pfpr_case_all_runMeans  <- pfpr_case_all_2010 %>% group_by(date, LGA) %>%  
  summarise_all(mean) %>% ungroup() 
pfpr_case_u5_runMeans  <- pfpr_case_u5_2010 %>% group_by(date, LGA) %>%  
  summarise_all(mean) %>% ungroup() 
#pfpr_case_u5_runMeans$LGA = toupper(pfpr_case_u5_runMeans$LGA)


# - - - - - - - - - - - - - - - - - #
# archetype and admin 1 for each DS
# - - - - - - - - - - - - - - - - - #
# create data tables specifying which DS belong to which archetype (and the rep DS for that archetype) and admin1
DS_arch_filename = file.path(box_hbhi_filepath, 'nigeria_LGA_pop.csv')

# add column with admin1 of each DS
admin1DS = fread(DS_arch_filename)
admin1DS = admin1DS[,c('LGA', 'State', 'Archetype')]
#admin1DS$LGA =toupper(admin1DS$LGA)
pfpr_matched = left_join(pfpr_case_u5_runMeans, admin1DS, by=c('LGA'))




###################################################################
# merge DHS and corresponding simulation values
###################################################################

# PfPR: match date from sim and data but shuffle DS
pfpr_matched_2 = pfpr_matched
LGAs = unique(pfpr_matched_2$LGA)
LGAs_shuffled = LGAs[c(2:length(LGAs), 1)]
pfpr_case_u5_runMeans_mis = pfpr_matched_2 
pfpr_case_u5_runMeans_mis$LGA = sapply(pfpr_case_u5_runMeans_mis$LGA, function(x) LGAs_shuffled[which(LGAs == x)])
pfpr_mismatched = left_join(dhs_pfpr, pfpr_case_u5_runMeans_mis, by=c('LGA','date'))



# match the same DS from simulation and data
dhs_pfpr <- dhs_pfpr %>%  mutate(LGA =gsub("/", "-", .$LGA))
pfpr_matched = left_join(dhs_pfpr, pfpr_matched, by=c('LGA','date'))


# relative and absolute differences - matched
pfpr_matched$error = (pfpr_matched$`PfPR U5` - pfpr_matched$p_test_mean) * -1
pfpr_matched$abs_error = abs(pfpr_matched$`PfPR U5` - pfpr_matched$p_test_mean)
pfpr_matched$rel_error = abs(pfpr_matched$`PfPR U5` - sapply(pfpr_matched$p_test_mean, max,0.0001))/sapply(pfpr_matched$p_test_mean, max,0.0001)
# relative and absolute differences -  mismatched
pfpr_mismatched$error = (pfpr_mismatched$`PfPR U5` - pfpr_mismatched$p_test_mean) * -1
pfpr_mismatched$abs_error = abs(pfpr_mismatched$`PfPR U5` - pfpr_mismatched$p_test_mean)
pfpr_mismatched$rel_error = abs(pfpr_mismatched$`PfPR U5` - sapply(pfpr_mismatched$p_test_mean, max,0.0001))/sapply(pfpr_mismatched$p_test_mean, max,0.0001)




#######################################################################
# calculate aggregated PfPR (to year and to admin1 level)
#######################################################################
# get annual averages for each DS
# matched DS
pfpr_matched$prod_dhs_pfpr_ss = pfpr_matched$p_test_mean * pfpr_matched$num_U5_sampled
pfpr_matched$prod_sim_pfpr_ss = pfpr_matched$`PfPR U5` * pfpr_matched$num_U5_sampled
pfpr_matched_annual = pfpr_matched[,c('LGA','year.y', 'prod_dhs_pfpr_ss','num_U5_sampled', 'prod_sim_pfpr_ss', 'Archetype')]  %>% group_by(year.y, LGA, Archetype) %>%  
  summarise_all(sum) %>% ungroup()
pfpr_annual_split = split(pfpr_matched_annual, pfpr_matched_annual$year.y)
pfpr_matched_annual = plyr::ldply(pfpr_annual_split, rbind)
pfpr_matched_annual$pfpr_dhs_mean = pfpr_matched_annual$prod_dhs_pfpr_ss/pfpr_matched_annual$num_U5_sampled
pfpr_matched_annual$pfpr_sim_mean = pfpr_matched_annual$prod_sim_pfpr_ss/pfpr_matched_annual$num_U5_sampled
# mismatched DS
pfpr_mismatched$prod_dhs_pfpr_ss = pfpr_mismatched$p_test_mean * pfpr_mismatched$num_U5_sampled
pfpr_mismatched$prod_sim_pfpr_ss = pfpr_mismatched$`PfPR U5` * pfpr_mismatched$num_U5_sampled
pfpr_mismatched_annual = pfpr_mismatched[,c('LGA','year.y', 'prod_dhs_pfpr_ss','num_U5_sampled', 'prod_sim_pfpr_ss', 'Archetype')]  %>% group_by(year.y, LGA, Archetype) %>%  
  summarise_all(sum) %>% ungroup() 
pfpr_mismatched_annual$pfpr_dhs_mean = pfpr_mismatched_annual$prod_dhs_pfpr_ss/pfpr_mismatched_annual$num_U5_sampled
pfpr_mismatched_annual$pfpr_sim_mean = pfpr_mismatched_annual$prod_sim_pfpr_ss/pfpr_mismatched_annual$num_U5_sampled

# get annual average for each admin 1 (instead of admin2=health district) - because DHS not powered at admin2
pfpr_matched_annual_admin1 = pfpr_matched[,c('State','year.y', 'prod_dhs_pfpr_ss','num_U5_sampled', 'prod_sim_pfpr_ss')]  %>% group_by(year.y, State) %>%  
  summarise_all(sum) %>% ungroup() 
pfpr_matched_annual_admin1$pfpr_dhs_mean = pfpr_matched_annual_admin1$prod_dhs_pfpr_ss/pfpr_matched_annual_admin1$num_U5_sampled
pfpr_matched_annual_admin1$pfpr_sim_mean = pfpr_matched_annual_admin1$prod_sim_pfpr_ss/pfpr_matched_annual_admin1$num_U5_sampled




###########################################################################
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #
#                            plot comparisons
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #
###########################################################################

##################################################################
# compare seasonality patterns (plots of PfPR by month)
##################################################################
# save the mean and median absolute and relative differences for each month across all years and DS
median_dif_pfpr_monthly = rep(NA,12)
mean_abs_dif_pfpr_monthly = rep(NA,12)
median_abs_dif_pfpr_monthly = rep(NA,12)
mean_rel_dif_pfpr_monthly = rep(NA,12)
median_rel_dif_pfpr_monthly = rep(NA,12)
median_pfpr_dhs_monthly = rep(NA, 12)
median_pfpr_sim_monthly = rep(NA,12)
for(mm in 1:12){
  median_dif_pfpr_monthly[mm] = median(pfpr_matched$error[pfpr_matched$month.x == mm], na.rm=TRUE)
  mean_abs_dif_pfpr_monthly[mm] = mean(pfpr_matched$abs_error[pfpr_matched$month.x == mm], na.rm=TRUE)
  median_abs_dif_pfpr_monthly[mm] = median(pfpr_matched$abs_error[pfpr_matched$month.x == mm], na.rm=TRUE)
  mean_rel_dif_pfpr_monthly[mm] = mean(pfpr_matched$rel_error[pfpr_matched$month.x == mm], na.rm=TRUE)
  median_rel_dif_pfpr_monthly[mm] = median(pfpr_matched$rel_error[pfpr_matched$month.x == mm], na.rm=TRUE)
  median_pfpr_dhs_monthly[mm] = median(pfpr_matched$p_test_mean[pfpr_matched$month.x == mm], na.rm=TRUE)
  median_pfpr_sim_monthly[mm] = median(pfpr_matched$`PfPR U5`[pfpr_matched$month.x == mm], na.rm=TRUE)
}

## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ##
# plot monthly values in DHS dataset and from corresponding times and locations in the simulation 
## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ##

pdf(file=paste0(print_path, "/", "monthly_PfPR_DHS_compared_to_monthly_simulation.pdf"))
par(mfrow=c(1,1), mar=c(5,4,4,2))
set.seed(1); jitter = runif(length(pfpr_matched$month.x), min=-0.15, max=0.15)
plot(NA, xlim=c(1,12), ylim=c(0,1.1), type='b', bty='L', ylab='U5 PfPR', xlab='month')
pfpr_matched$month.x <-as.numeric(pfpr_matched$month.x)
points(pfpr_matched$month.x+jitter, pfpr_matched$p_test_mean, col=rgb(0.2,0.4,1), cex=0.5, pch=20)
points(pfpr_matched$month.x+jitter, pfpr_matched$`PfPR U5`, col=rgb(0.83,0,0.1), cex=0.5, pch=21)
lines(1:12, median_pfpr_dhs_monthly, col=rgb(0.2,0.4,1))
lines(1:12, median_pfpr_sim_monthly, col=rgb(0.83,0,0.1))
legend(x=0.7,y=0.99, c('DHS','simulation'), lty=1, col=c(rgb(0.2,0.4,1), rgb(0.83,0,0.1)), bty='n')
text(1:12, rep(1.1, 12), round(median_abs_dif_pfpr_monthly,2), col='grey')
dev.off()


## - - - - - - - - - - - - - - - - - - - - - - - - - - ##
# plot error in each month
## - - - - - - - - - - - - - - - - - - - - - - - - - - ##

pdf(file=paste0(print_path, "/", "monthly_PfPR_DHS_compared_to_monthly_simulation_with_error.pdf"))
par(mfrow=c(1,1), mar=c(5,4,4,2))
set.seed(1); jitter = runif(length(pfpr_matched$month.x), min=-0.15, max=0.15)
plot(1:12, median_abs_dif_pfpr_monthly, type='l', bty='L', ylab='U5 PfPR or difference in PfPR', xlab='month', ylim=c(0,1))
pfpr_matched$month.x <-as.numeric(pfpr_matched$month.x)
points(pfpr_matched$month.x+jitter, pfpr_matched$p_test_mean, col=rgb(0.2,0.4,1), cex=0.5, pch=20)
points(pfpr_matched$month.x+jitter, pfpr_matched$`PfPR U5`, col=rgb(0.83,0,0.1), cex=0.5, pch=21)
lines(1:12, median_pfpr_dhs_monthly, col=rgb(0.2,0.4,1))
lines(1:12, median_pfpr_sim_monthly, col=rgb(0.83,0,0.1))
lines(1:12, median_dif_pfpr_monthly, col='salmon')
legend(x=0.7,y=0.99, c('DHS','simulation', 'median difference', 'median absolute difference'), lty=1, col=c(rgb(0.2,0.4,1), rgb(0.83,0,0.1), 'salmon', 'black'), bty='n')
dev.off()

# plot(1:12, median_rel_dif_pfpr_monthly, type='b', ylim=c(0,1), bty='L', ylab='median relative difference between DHS and simulation PfPR', xlab='month')

## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ##
# zoom in on october and plot with DS names, colored by archetype
## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ##
october_pfpr_matched = pfpr_matched[which(pfpr_matched$month.x == 10),]
pdf(file=paste0(print_path, "/", "october_PfPR_DHS_compared_to_october_simulation.pdf"))
ggplot(october_pfpr_matched, aes(x = `PfPR U5`, y = p_test_mean,color = Archetype, label = LGA))+
  geom_point()+ 
  geom_abline(slope=1, intercept=c(0,0)) +
  geom_text(aes(label=LGA))+ 
  theme_classic()+ 
  xlab('simulation U5 PfPR')+ 
  ylab('DHS U5 PfPR')+ 
  ggtitle('Comparison of october simulation and DHS')+
  theme(plot.title = element_text(hjust = 0.5), legend.position = "bottom")
dev.off()







###################################################################
#   scatterplots of simulated and DHS PfPR for each DS
###################################################################

# set of scatterplots: four plots returned, all from the same scenario but from different years
#   include regression lines (lm weighted by survey size) and correlation values
create_PfPR_scatters = function(pfpr_df, x_col_name, x_lab, y_col_name, y_lab){
  # matched DS
  p_all = ggplot(pfpr_df, aes_string(x=x_col_name, y=y_col_name)) +
    geom_point(aes(size=num_U5_sampled, col=year.y), shape=20, alpha=0.5) + 
    geom_abline(slope=1, intercept=c(0,0)) +
    geom_smooth(method=lm, mapping = aes(weight = num_U5_sampled))+
    stat_cor(method = "pearson", col='darkred') +
    scale_size(limits = c(1,300), range = c(1, 8)) + 
    xlim(0, 1) + 
    ylim(0, 1) +
    xlab(x_lab) + 
    ylab(y_lab)+
    theme_classic() +
    theme(legend.position = "none")
  # look at each year separately
  p_2010 = ggplot(pfpr_df[pfpr_df$year.y==2010,], aes_string(x=x_col_name, y=y_col_name)) +
    geom_point(aes(size=num_U5_sampled), shape=20, alpha=0.5) + 
    geom_abline(slope=1, intercept=c(0,0)) +
    geom_smooth(method=lm, mapping = aes(weight = num_U5_sampled))+
    stat_cor(method = "pearson", col='darkred') +
    scale_size(limits = c(1,300), range = c(1, 8)) + 
    xlim(0, 1) + 
    ylim(0, 1) +
    xlab(x_lab) + 
    ylab(y_lab)+
    theme_classic() +
    theme(legend.position = "none")
  p_2015 = ggplot(pfpr_df[pfpr_df$year.y==2015,], aes_string(x=x_col_name, y=y_col_name)) +
    geom_point(aes(size=num_U5_sampled), shape=20, alpha=0.5) + 
    geom_abline(slope=1, intercept=c(0,0)) +
    geom_smooth(method=lm, mapping = aes(weight = num_U5_sampled))+
    stat_cor(method = "pearson", col='darkred') +
    scale_size(limits = c(1,300), range = c(1, 8)) + 
    xlim(0, 1) + 
    ylim(0, 1) +
    xlab(x_lab) + 
    ylab(y_lab)+
    theme_classic() +
    theme(legend.position = "none")
  p_2018_2018 = ggplot(pfpr_df[pfpr_df$year.y%in%c(2018,2018),], aes_string(x=x_col_name, y=y_col_name)) +
    geom_point(aes(size=num_U5_sampled), shape=20, alpha=0.5) + 
    geom_abline(slope=1, intercept=c(0,0)) +
    geom_smooth(method=lm, mapping = aes(weight = num_U5_sampled))+
    stat_cor(method = "pearson", col='darkred') +
    scale_size(limits = c(1,300), range = c(1, 8)) + 
    xlim(0, 1) + 
    ylim(0, 1) +
    xlab(x_lab) + 
    ylab(y_lab)+
    theme_classic() +
    theme(legend.position = "none")
  return(list(p_all, p_2010, p_2015, p_2018_2018))
}

create_PfPR_scatters_admin1 = function(pfpr_df, x_col_name, x_lab, y_col_name, y_lab){
  # matched DS
  p_all = ggplot(pfpr_df, aes_string(x=x_col_name, y=y_col_name)) +
    geom_point(size=5, shape=20, color = "skyblue2") + 
    geom_abline(slope=1, intercept=c(0,0)) +
    geom_smooth(method=lm)+
    stat_cor(method = "pearson", col='darkred') +
    scale_size(limits = c(1,300), range = c(1, 8)) + 
    xlim(0, 1) + 
    ylim(0, 1) +
    xlab(x_lab) + 
    ylab(y_lab)+
    theme_classic() +
    theme(legend.position = "none")
  # look at each year separately
  p_2010 = ggplot(pfpr_df[pfpr_df$year.y==2010,], aes_string(x=x_col_name, y=y_col_name)) +
    geom_point(size=5, shape=20, color = "skyblue2") + 
    geom_abline(slope=1, intercept=c(0,0)) +
    geom_smooth(method=lm)+
    stat_cor(method = "pearson", col='darkred') +
    scale_size(limits = c(1,300), range = c(1, 8)) + 
    xlim(0, 1) + 
    ylim(0, 1) +
    xlab(x_lab) + 
    ylab(y_lab)+
    theme_classic() +
    theme(legend.position = "none")
  p_2015 = ggplot(pfpr_df[pfpr_df$year.y==2015,], aes_string(x=x_col_name, y=y_col_name)) +
    geom_point(size=5, shape=20,color = "skyblue2") + 
    geom_abline(slope=1, intercept=c(0,0)) +
    geom_smooth(method=lm)+
    stat_cor(method = "pearson", col='darkred') +
    scale_size(limits = c(1,300), range = c(1, 8)) + 
    xlim(0, 1) + 
    ylim(0, 1) +
    xlab(x_lab) + 
    ylab(y_lab)+
    theme_classic() +
    theme(legend.position = "none")
  p_2018_2018 = ggplot(pfpr_df[pfpr_df$year.y%in%c(2018,2018),], aes_string(x=x_col_name, y=y_col_name)) +
    geom_point(size=5,shape=20,color = "skyblue2") + 
    geom_abline(slope=1, intercept=c(0,0)) +
    geom_smooth(method=lm)+
    stat_cor(method = "pearson", col='darkred') +
    scale_size(limits = c(1,300), range = c(1, 8)) + 
    xlim(0, 1) + 
    ylim(0, 1) +
    xlab(x_lab) + 
    ylab(y_lab)+
    theme_classic() +
    theme(legend.position = "none")
  return(list(p_all, p_2010, p_2015, p_2018_2018))
}

# correlation confidence interval 

df_2010 <- pfpr_matched_annual_admin1
cor.test(df_2010$pfpr_sim_mean, df_2010$pfpr_dhs_mean, method = "pearson", conf.level = 0.95)
## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ##
# compare matched DS versus mismatched DS
## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ##
# plot point for each DHS survey cluster (separate points in each month in a DS)
p_match_DHS_plots = create_PfPR_scatters(pfpr_df=pfpr_matched, y_col_name="p_test_mean", x_col_name="`PfPR U5`", x_lab="simulation U5 PfPR", y_lab="DHS U5 PfPR")
p_mismatch_DHS_plots = create_PfPR_scatters(pfpr_df=pfpr_mismatched, y_col_name="p_test_mean", x_col_name="`PfPR U5`", x_lab="simulation U5 PfPR", y_lab="DHS U5 PfPR")
gg = grid.arrange(p_match_DHS_plots[[1]], p_match_DHS_plots[[2]], p_match_DHS_plots[[3]], p_match_DHS_plots[[4]],
                  p_mismatch_DHS_plots[[1]], p_mismatch_DHS_plots[[2]], p_mismatch_DHS_plots[[3]], p_mismatch_DHS_plots[[4]],
                  nrow = 2)

ggsave(paste0(print_path, '/', 'match_PfPR_DHS_sim_mismatch_corr_plot.pdf'), gg, width=13, height=13)



# annual weighted average
#   (take weighted average of all DHS (and matching simulation) PfPR values within a year rather than one point per month sampled)
p_match_annual_DHS_plots = create_PfPR_scatters(pfpr_df=pfpr_matched_annual, x_col_name="pfpr_sim_mean", x_lab="simulation U5 PfPR", y_col_name="pfpr_dhs_mean", y_lab="DHS U5 PfPR")
p_mismatch_annual_DHS_plots = create_PfPR_scatters(pfpr_df=pfpr_mismatched_annual, x_col_name="pfpr_sim_mean", x_lab="simulation U5 PfPR", y_col_name="pfpr_dhs_mean", y_lab="DHS U5 PfPR")
gg = grid.arrange(p_match_annual_DHS_plots[[1]], p_match_annual_DHS_plots[[2]], p_match_annual_DHS_plots[[3]], p_match_annual_DHS_plots[[4]],
                  p_mismatch_annual_DHS_plots[[1]], p_mismatch_annual_DHS_plots[[2]], p_mismatch_annual_DHS_plots[[3]], p_mismatch_annual_DHS_plots[[4]],
                  nrow = 2)
ggsave(paste0(print_path, '/', 'match_PfPR_annual_PfPR_sim_DHS.pdf'), gg, width=13, height=13)


# scatter plot of DHS survey annual admin 1 estimates and simulation pfpr
p_match_DHS_plots_admin1 = create_PfPR_scatters_admin1(pfpr_df=pfpr_matched_annual_admin1, y_col_name="pfpr_dhs_mean", x_col_name="`pfpr_sim_mean`", x_lab="simulation U5 PfPR", y_lab="DHS U5 PfPR")
gg = grid.arrange(p_match_DHS_plots_admin1[[1]], p_match_DHS_plots_admin1[[2]], p_match_DHS_plots_admin1[[3]], p_match_DHS_plots_admin1[[4]], nrow = 1)
ggsave(paste0(print_path, '/', 'match_PfPR_DHS_sim_annual_admin1_corr_plot.pdf'), gg, width=13, height=13)






