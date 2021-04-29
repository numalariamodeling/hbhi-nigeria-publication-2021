#################################################################################################################################################
# comparison_incidence_DHIS2_sim.R
# HBHI - Nigeria. Script was originall written 
# contact: Ifeoma Nigeria 
# October 2020

# currently, we claim that our calibration and parameterization was successful because we can see that simulated DS trajectories often visually 
#    agree fairly well with survey/surveillance data. To look at this a bit more closely and to see how DS-specific this match is, create a 
#    series of plots that compare simulation and data, either for the same (matched) DS or for mismatched DS.
# main types of comparisons are:
#

#################################################################################################################################################


###########################################################################
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #
#                                setup
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #
###########################################################################
rm(list = ls())
list.of.packages <- c("tidyverse", "ggplot2", "purrr",  "stringr", "sp", "rgdal", "raster", "hablar", 
                      "lubridate", "RColorBrewer", "ggpubr", "gridExtra", "data.table",  "nngeo", "reshape2", "foreign", "ggthemes", "viridis", "lemon",
                      "egg", "grid", "boot")
lapply(list.of.packages, library, character.only = TRUE) #applying the library function to packages

###################################################################
#   read in and format data and simulation output
###################################################################
box_filepath = "C:/Users/ido0493/Box/NU-malaria-team/projects"
box_hbhi_filepath = paste0(box_filepath, '/hbhi_nigeria')
ifelse(!dir.exists(file.path(box_hbhi_filepath, "project_notes/publication/Hbhi modeling/validation/incidence")), 
       dir.create(file.path(box_hbhi_filepath, "project_notes/publication/Hbhi modeling/validation/incidence")), FALSE)
print_path <- file.path(box_hbhi_filepath, "project_notes/publication/Hbhi modeling/validation/incidence")
sim_input <- file.path(box_hbhi_filepath, "simulation_inputs/projection_csvs/archetype_files")

# - - - - - - - - - - - - - - - - - - - - - - #
# incidence from dhis2 and population data
# - - - - - - - - - - - - - - - - - - - - - - #

incidence_dhis2 <- read.csv(file.path(box_hbhi_filepath, "incidence", "RIA_by_LGA_and_rep_DS.csv")) %>% 
  mutate(incidence = (AllagesOutpatientMalariaC/geopode.pop) * 1000, date = as.Date(date), year = lubridate::year(date)) %>% 
  #filter(incidence < 3) %>% 
  mutate(LGA =gsub("/", "-", .$LGA))
glimpse(incidence_dhis2)
  


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
  summarise_all(mean) %>%  cbind(pfpr_case_all_2010 %>% group_by(date, LGA) %>% 
                                    summarise(max_RT = max(Received_Treatment), min_RT = min(Received_Treatment),
                                     max_NMF_RT = max(Received_NMF_Treatment), min_NMF_RT = min(Received_NMF_Treatment))) %>%  
  ungroup() 

colnames(pfpr_case_all_runMeans)[2]<- 'LGA'
# pfpr_case_u5_runMeans  <- pfpr_case_u5_2010 %>% group_by(date, LGA) %>%  
#   summarise_all(mean) %>% ungroup() 



###############################################################################
# merge DHIS2 and corresponding simulation values aand aggregate to state level
###############################################################################
# match the same DS from simulation and data
incidence_matched = merge(x=incidence_dhis2, y=pfpr_case_all_runMeans, by=c('LGA', 'year','month'), all.x=TRUE)

#incidence_matched$treatment_incidence_include_NMF = (incidence_matched$Received_Treatment + incidence_matched$Received_NMF_Treatment) / incidence_matched$`Statistical Population` * 1000


DS_arch_filename = file.path(box_hbhi_filepath, 'nigeria_LGA_pop.csv')

# add column with admin1 of each DS
admin1DS = fread(DS_arch_filename)
admin1DS = admin1DS[,c('LGA', 'State', 'Archetype')]


#aggregate and merge
incidence_matched_state = left_join(incidence_matched, admin1DS, by=c('LGA')) %>%
  dplyr::select(-c(LGA, Archetype, Run_Number, month, year, date...1, date...13, LGA...14, repDS)) %>%
  group_by(State, date) %>%  {left_join (summarise_at(., vars(-`Statistical Population`), sum),
                                           summarise_at(., vars(`Statistical Population`), mean))} 




###############################################################################
# bootstrap to generate intervals on the sum 
###############################################################################

# #create list of dataframes
# ci_df = left_join(incidence_matched, admin1DS, by=c('LGA'))
# 
# ci_df$row_num <- 1:nrow(ci_df) #create unique row numbers
# 
# zero_cases_df = ci_df %>%
#   filter(State == "Yobe" & (date =="2014-06-01"|date =="2014-07-01"|date =="2014-10-01"))
# 
# `%notin%` <- Negate(`%in%`)
# 
# ci_df=subset(ci_df, row_num %notin% zero_cases_df$row_num)
# 
# ci_df = ci_df %>% dplyr::select(row_num, AllagesOutpatientMalariaC, State, date) %>%
#   group_by(State, date) %>%  group_split()
# 
# 
# 
# 
#sum function
sumfun <- function(data, i){
  d <- data[i, ]
  return(sum(d))
}


#bootstrap functions
boot_fun <- function(data, col){
  bo <- boot(data[, col, drop = FALSE], statistic=sumfun, R=10000)
  ci<- boot.ci(bo, conf=0.95, type="bca")

  df <- data.frame(sum_est = bo$t0, sum_l_ci = ci$bca[4], sum_u_ci = ci$bca[5])
}

# 
# 
# 
# #run bootstrap and bind dataframe of results
# sum_ci_df <- map(ci_df, boot_fun)
# fin_ci_df = do.call("rbind", sum_ci_df)
# 
# 
# #get state and dates
# ci_df_state = ci_df %>%  map(~dplyr::select(.x, c(State, date.x))) %>%  map(~distinct(.x))
# ci_df_state = do.call("rbind", ci_df_state)
# 
# 
# #cbind state, dates and intervals
# sum_ci_all = cbind(ci_df_state, fin_ci_df)
# 
# write.csv(sum_ci_all, file.path(box_hbhi_filepath, "incidence", "cases_by_state_with_CIs.csv"))
sum_ci_all= read.csv(file.path(box_hbhi_filepath, "incidence", "cases_by_state_with_CIs.csv")) %>% 
  dplyr::select(-X) %>% rename(date = date.x) %>%  mutate(date = as.Date(date))


###############################################################################
# bootstrap to generate archetype intervals 
###############################################################################
#first create the dataset by aggregating to LGA and month 

# cases_LGA = read.csv(file.path(box_hbhi_filepath, "incidence", "RIA_by_LGA_and_rep_DS.csv")) %>% 
#   mutate(year = lubridate::year(date), month = month(date))
# cases_sum = cases_LGA %>%  group_by(LGA, year, month) %>%  summarise(sum_cases = sum(AllagesOutpatientMalariaC)) 
# cases_average = cases_sum %>% group_by(LGA, month) %>%  summarise(mean_cases = mean(sum_cases))
# 
# #create repDS file 
# repDS = cases_LGA %>%  group_by(LGA, month) %>%  distinct(repDS)
# 
# #aggregate up repDS level 
# cases_repDS = left_join(cases_average, repDS , by = c('month', 'LGA'))
# fin_data =  cases_repDS  %>%  group_by(repDS, month) %>% summarise(sum_cases_archetype= sum(mean_cases))
# 
# 
# # create aggregate population by archetype 
# rep_DS_pop = cases_LGA %>%  distinct(LGA, repDS, geopode.pop) %>%  group_by(repDS) %>%  summarise(repDS_pop = sum(geopode.pop)) 
# 
# 
# #create incidence data to check 
# fin_arch_df = left_join(fin_data, rep_DS_pop) %>%  
#   mutate(incidence = (sum_cases_archetype/repDS_pop) *1000) %>%  filter(repDS =='Akinyele')
# 
# plot(fin_arch_df$month, fin_arch_df$incidence, type = "b", pch = 19)
# 
# 
# 
# #create dataset list for bootstrapping 
# 
# boot_data =  cases_repDS  %>%  group_by(repDS, month) %>%  group_split()
# 
# col = c('mean_cases')
# sum_ci_arch_df <- map2(boot_data,col, boot_fun)
# fin_ci_df = do.call("rbind", sum_ci_arch_df)
# 
# 
# # get archetype and dates
# ci_df_repDS = cbind(fin_data, fin_ci_df)
# write.csv(ci_df_repDS, file.path(box_hbhi_filepath, "incidence", "cases_by_repDS_with_CIs.csv"))
#write.csv(rep_DS_pop, file.path(box_hbhi_filepath, "incidence", "population_by_repDS.csv"))
ci_df_repDS= read.csv(file.path(box_hbhi_filepath, "incidence", "cases_by_repDS_with_CIs.csv"))
rep_DS_pop= read.csv(file.path(box_hbhi_filepath, "incidence", "population_by_repDS.csv"))

#final dataset 
# fin_df_repDS = left_join(ci_df_repDS, rep_DS_pop) %>%  
#   mutate(incidence = (sum_cases_archetype/40000) *1000,
#          incidence_low = (sum_l_ci/40000) * 1000, 
#          incidence_high = (sum_u_ci/40000) * 1000,
#          population = 1000) %>%  
#   rename(cases = sum_cases_archetype, seasonality = repDS)
# 
# write.csv(fin_df_repDS, paste0(box_hbhi_filepath, '/', "incidence",  '/', Sys.Date(), "_archetype_incidence_NGA_RIA_v3.csv"))
# write.csv(fin_df_repDS, paste0(sim_input, '/',  "archetype_incidence_NGA_RIA_v5.csv"))
# ###############################################################################
# Calculate incidence for data  and simulation and scale data 
###############################################################################


# combine case data and computed sums 

incidence_matched_state = left_join(incidence_matched_state, sum_ci_all, by =c("State", "date")) 

# incidence calculations for simulation 
incidence_matched_state$treatment_incidence_include_NMF_state = 
  (incidence_matched_state$Received_Treatment + incidence_matched_state$Received_NMF_Treatment) / incidence_matched_state$`Statistical Population` * 30/365* 1000

incidence_matched_state$treatment_incidence_include_NMF_state_low = 
  (incidence_matched_state$min_RT + incidence_matched_state$min_NMF_RT)/ incidence_matched_state$`Statistical Population` * 30/365* 1000

incidence_matched_state$treatment_incidence_include_NMF_state_high = 
  (incidence_matched_state$max_RT + incidence_matched_state$max_NMF_RT)/ incidence_matched_state$`Statistical Population` * 30/365* 1000

#incidence calculations for data 
incidence_matched_state$incidence_state = 
  (incidence_matched_state$AllagesOutpatientMalariaC / incidence_matched_state$geopode.pop) * 1000

incidence_matched_state$incidence_state_low = 
  (incidence_matched_state$sum_l_ci / incidence_matched_state$geopode.pop) * 1000


incidence_matched_state$incidence_state_high = 
  (incidence_matched_state$sum_u_ci / incidence_matched_state$geopode.pop) * 1000



#continue here 
#calculate scaling params and add 
incidence_matched_df <- incidence_matched_state %>%  dplyr::select(State, date, treatment_incidence_include_NMF_state,
                                                                   treatment_incidence_include_NMF_state_low, 
                                                                   treatment_incidence_include_NMF_state_high, 
                                                                   incidence_state,incidence_state_low,incidence_state_high) %>%
  mutate(date = as.Date(date), year = lubridate::year(date), month= lubridate::month(date),
         scaling = treatment_incidence_include_NMF_state/incidence_state,
         scaling = ifelse(!is.finite(scaling), 1, scaling)) %>%  
  dplyr::select(-date) 

mean_scaling <- incidence_matched_df %>%  group_by(State, year) %>%  
  summarise(median_scale = median(scaling)) 




###############################################################################
# Prepare data set to make time series plot and ccf plot 
###############################################################################

incidence_matched_df  <- left_join(incidence_matched_df, mean_scaling, by=c("State", "year")) %>%
mutate(new_incidence_state = incidence_state *median_scale, 
       new_incidence_state_low = incidence_state_low * median_scale,
       new_incidence_state_high = incidence_state_high * median_scale, 
       State = ifelse(State == "Federal Capital Territory", "FCT", State))


incidence_matched_df_v2 <- incidence_matched_df %>% 
  dplyr::select(State, year, month, treatment_incidence_include_NMF_state,  new_incidence_state) %>%
  pivot_longer(cols = c("treatment_incidence_include_NMF_state", 
                        "new_incidence_state"), names_to = "type", values_to = "value") 

incidence_matched_df_v2$row_num <- 1:nrow(incidence_matched_df_v2)

incidence_matched_df_low <- incidence_matched_df %>% 
  dplyr::select(State, year, month, treatment_incidence_include_NMF_state_low,  new_incidence_state_low) %>% 
  pivot_longer(cols = c("treatment_incidence_include_NMF_state_low", 
                        "new_incidence_state_low"), names_to = "ci_low", values_to = "lower_limit") 

incidence_matched_df_low$row_num <- 1:nrow(incidence_matched_df_low)

incidence_matched_df_high <- incidence_matched_df %>% 
  dplyr::select(State, year, month, treatment_incidence_include_NMF_state_high,  new_incidence_state_high) %>% 
  pivot_longer(cols = c("treatment_incidence_include_NMF_state_high", 
                        "new_incidence_state_high"), names_to = "ci_high", values_to = "upper_limit") 

incidence_matched_df_high$row_num <- 1:nrow(incidence_matched_df_high) 



#join all three dfs 

incidence_matched_df_v2 = left_join(incidence_matched_df_v2, incidence_matched_df_low, by = 'row_num') %>% 
  left_join(incidence_matched_df_high, by= 'row_num')
  

incidence_matched_df_v2$State <- paste0(incidence_matched_df_v2$State, " ",  "(", as.character(incidence_matched_df_v2$year), ")")

incidence_matched_df_split = split(incidence_matched_df_v2, incidence_matched_df_v2$year)



###############################################################################
# Plotting functions 
###############################################################################

#incidence 

plot_ <-function(data){
  pd <- position_dodge(0.25)
  p<-ggplot(data, aes(x =month, y =value, group = type, color=type)) +
    geom_errorbar(aes(ymin = lower_limit, ymax = upper_limit), width =.2, position=pd)+
    geom_line(position=pd) + 
    geom_point(position=pd, size=0.8, shape=21, fill="white")+
    #scale_color_viridis(discrete = TRUE) +
    facet_wrap(~State, scales = "free")+
    scale_color_manual(labels = c("health facility data (rescaled)", "simulation (includes RDT + non-malarial fevers)"), values = c("darkorchid4", "deepskyblue2")) +
    scale_x_continuous(labels = function(x) month.abb[x], breaks = c(1, 4, 7, 10))+
    theme_minimal() + 
    theme(legend.direction = "vertical", legend.title = element_blank(),
          panel.border = element_rect(colour = "black", fill=NA, size=0.5),
          axis.ticks.x = element_line(size = 0.5, colour = "black"),
          axis.ticks.y = element_line(size = 0.5, colour = "black"),
          strip.text.x = element_text(size = 7.5, colour = "black", face = "bold"))+ 
    ylab("monthly all age treated cases of uncomplicated malaria (per 1000)")+
    xlab(unique(data$year))

    
}
  
shift_legend2 <- function(p) {
  # ...
  # to grob
  gp <- ggplotGrob(p)
  facet.panels <- grep("^panel", gp[["layout"]][["name"]])
  empty.facet.panels <- sapply(facet.panels, function(i) "zeroGrob" %in% class(gp[["grobs"]][[i]]))
  empty.facet.panels <- facet.panels[empty.facet.panels]
  
  # establish name of empty panels
  empty.facet.panels <- gp[["layout"]][empty.facet.panels, ]
  names <- empty.facet.panels$name
  # example of names:
  #[1] "panel-3-2" "panel-3-3"
  
  # now we just need a simple call to reposition the legend
 reposition_legend(p, 'center', panel=names)

}


#cross-correlation functions 

x <- ("new_incidence_state")
y <- list("treatment_incidence_include_NMF_state")


xcf_plot <- function(df){
  State <- unique(df$State)
  year <- unique(df$year)
  title<- paste0(State, " ", "(", year, ")")
  x <- df$new_incidence_state
  y<- df$treatment_incidence_include_NMF_state
  df_x <- eval(substitute(x),df)
  df_y <- eval(substitute(y),df)
  ccf.object <- ccf(df_x,df_y,plot=FALSE)
  output_table <-
    cbind(lag=ccf.object$lag, x.corr=ccf.object$acf) %>%
    as_tibble() %>%
    mutate(cat=ifelse(x.corr>0,"CCF > 0","CCF < 0"))
  output_table %>%
    ggplot(aes(x=lag,y=x.corr)) +
    geom_bar(stat="identity",aes(fill=cat))+
    scale_fill_manual(values=c("#E69F00", "#56B4E9"))+
    ylab("")+
    xlab("lag (months)")+
    scale_y_continuous(limits=c(-1,1))+
    theme_minimal()+
    theme(legend.position= "none",plot.title=element_text(size=8, color = "black", face = "bold", hjust=0.5),
          panel.border = element_rect(colour = "black", fill=NA, size=0.5),
          axis.ticks.x = element_line(size = 0.5, colour = "black"),
          axis.ticks.y = element_line(size = 0.5, colour = "black"))+
    labs(title = title)
}






###############################################################################
# make plots 
###############################################################################

#apply functions and save incidence plots for all data 
p <-list()

for(i in 1:length(incidence_matched_df_split)){
  p[[i]]<- plot_(incidence_matched_df_split[[i]])  
}

p[[1]]

for (i in 1:length(p)) {
  ggsave(shift_legend2(p[[i]]), file=paste0(print_path, '/', unique(p[[i]]$data$year),'_incidence_sim_data_comparison.pdf'), width=13, height=13, onefile=FALSE)
}




# make dataset for ccf
df_split_ccf <- split(incidence_matched_df, incidence_matched_df[, c("State", "year")])



#plot for all the data 
cc_df <- map(df_split_ccf, xcf_plot)

first_37 <- cc_df[1:37]
n <- length(first_37)
p<-do.call("grid.arrange", c(first_37, ncol=7, left = "Cross-correlation function (CCF)"))

ggsave(paste0(print_path, '/', 'incidence_ccf_2014_nigeria.pdf'), p, width=13, height=13)



second_37 <- cc_df[38:74]
n <- length(second_37)
p<-do.call("grid.arrange", c(second_37, ncol=7, left = "Cross-correlation function (CCF)"))

ggsave(paste0(print_path, '/', 'incidence_ccf_2015_nigeria.pdf'),p, width=13, height=13)




third_37 <- cc_df[75:111]
n <- length(third_37)
p<-do.call("grid.arrange", c(third_37, ncol=7, left = "Cross-correlation function (CCF)"))

ggsave(paste0(print_path, '/', 'incidence_ccf_2016_nigeria.pdf'),p, width=13, height=13)


fourth_37 <- cc_df[112:148]
n <- length(fourth_37)
p<-do.call("grid.arrange", c(fourth_37, ncol=7, left = "Cross-correlation function (CCF)"))
ggsave(paste0(print_path, '/', 'incidence_ccf_2017_nigeria.pdf'),p, width=13, height=13)


fifth_37 <- cc_df[149:185]
n <- length(fifth_37)
p<-do.call("grid.arrange", c(fifth_37, ncol=7, left = "Cross-correlation function (CCF)"))
ggsave(paste0(print_path, '/', 'incidence_ccf_2018_nigeria.pdf'),p, width=13, height=13)



###############################################################################
# plot incidence and cross-correlation function for Abia and Adamawa 
###############################################################################

#incidence plot 
Abia_Adamawa <- incidence_matched_df_split[[5]] %>%  filter(str_detect(State, "Abia|Adamawa"))
gg_abia_adamawa <-plot_(Abia_Adamawa)
gg_abia_adamawa

pdf(paste0(print_path, '/', Sys.Date(), '_Abia_Adamawa_incidence_.pdf'),width=13, height=13)
gg_abia_adamawa
dev.off()

#ccf plot 
abia_ada <- incidence_matched_df %>% filter(str_detect(State, "Abia|Adamawa"), year == 2018)
abia_ada_ccf <- split(abia_ada, abia_ada[, c("State")])
cc_df <- map(abia_ada_ccf, xcf_plot)
cc_df


cc_plot <- grid.arrange(cc_df[[1]],cc_df[[2]], ncol =2)


g1 <- ggplotGrob(gg_abia_adamawa)
g2 <- ggplotGrob(cc_df[[1]])
g3 <- ggplotGrob(cc_df[[2]])

g2$grobs

fg2 <- gtable_frame(g2, debug = TRUE)
fg3 <- gtable_frame(g3, debug = TRUE)
fg23 <-
  gtable_frame(gtable_cbind(fg2, fg3))

fg1 <-
  gtable_frame(g1, debug = TRUE)

pdf(paste0(print_path, '/', 'Abia_Adamawa_incidence_validation_210119.pdf'),width=13, height=13)
grid.newpage()
combined <- gtable_rbind(fg1, fg23)
grid.draw(combined)
dev.off()















  


  
