# scrap code 

# case_management <- fread("data/case_management.csv")
# # footnote_cm <-'The Demographic and Health surveys were used to parameterize CM coverage. \n
# #                   #The same coverage levels were used for both adults and children'
# 
# cm_scen1_df <- case_management[which(case_management$scenario =="Scenario 1(Business as Usual)"), ]
# cm_scen1_df <- merge(LGAsf, y=cm_scen1_df , by="LGA",all.x =TRUE)
# cm_scen1_map<-generateMap(cm_scen1_df, quo(U5_coverage))
#cm_scen1_titles <-title_function("Case Management (CM) Coverage", "Scenario 1 (Business as Usual)", footnote_cm)

#sum(is.na(cm_scen1_df$adult_coverage))

#cm_scen1_df <- merge(x = LGAsf, y = cm_scen1_df, by = "LGA", all.x = TRUE)
#scenario 1, 2020 - 2030 
# library(rbenchmark)
# 
# benchmark("base" = {
#   df <- case_management[which(case_management$scenario =="Scenario 1(Business as Usual)"), ]
# },
# 
# "dplyr" = {
#   df<- case_management %>% dplyr::filter(scenario =="Scenario 1(Business as Usual)")
# },
# 
# "DT" = {
#   df<- case_management[scenario =="Scenario 1(Business as Usual)"]
# }, 
# 
# replications = 1000,
# columns = c("test", "replications", "elapsed",
#             "relative", "user.self", "sys.self")
# )
# 
# 
# 
# benchmark("DT" = {
#   map_df <- merge(x = LGAsf, y = cm_scen1_df, by = "LGA", all.x = TRUE)
# },
# 
# "dplyr" = {
#   map_df <- dplyr::left_join(LGAsf, cm_scen1_df , by=("LGA")) 
# },
# replications = 10,
# columns = c("test", "replications", "elapsed",
#             "relative", "user.self", "sys.self")
# )
# 









#severe cases 

#scenario 2, 2020 (would need 2021 - 2030)
# 
# cm_scen2_df <- case_management[which(case_management$scenario =="Scenario 2(High effective coverage)" & year == 2020), ]
# 
# #cm_scen1_df <- case_management[which(case_management$scenario =="Scenario 1(Business as Usual)"), ]
# 
# 
# cm_scen2_list <- split(cm_scen2_df, by="simday")
# #cm_scen2_list <- tidyr::chop(cm_scen2_df, simday)
# # 
# # 
# # 
# cm_scen2<- purrr::map2(LGA_list,cm_scen2_list, left_join, by="LGA")
# 
# cols_list = list(quo(U5_coverage))
# # 
# cm_scen2_map <-purrr::map2(cm_scen2, cols_list, generateMap)
# # 
# gridded_cm_scen2 <- plot_grid(cm_scen2_map[[1]],cm_scen2_map[[2]], nrow = 1)

#cm_scen2_titles <-title_function("Case Management (CM) Coverage", "Scenario 2 (National strategic plan with high effective coverage)", footnote_cm)





#scenario 3, 2020-2030  

#cm_scen3_df <- case_management %>% dplyr::filter(scenario =="Scenario 3(Improved coverage)")

# cm_scen3_df <- case_management[which(case_management$scenario =="Scenario 3(Improved coverage)") , ]
# 
# cm_scen3_df <-  merge(LGAsf, cm_scen3_df , by="LGA", all.x =TRUE) 
# 
# cm_scen3_map<-generateMap(cm_scen3_df)

#cm_scen3_titles <-title_function("Case Management (CM) Coverage", "Scenario 3 (National strategic plan with Improved coverage)", footnote_cm)



#scenario 4, 2020-2030  

# cm_scen4_df <- case_management[which(case_management$scenario =="Scenario 4(Improved coverage)"), ]
# 
# cm_scen4_df <- merge(LGAsf, cm_scen4_df , by="LGA", all.x = TRUE) 
# 
# cm_scen4_map<-generateMap(cm_scen4_df)

#cm_scen4_titles <-title_function("Case Management (CM) Coverage", "Scenario 4 (National strategic plan with Improved coverage)", footnote_cm)


#scenario 5, 2020-2030  

# cm_scen5_df <- case_management %>% dplyr::filter(scenario =="Scenario 5(Improved coverage)")
# 
# cm_scen5_df <- dplyr::left_join(LGAsf, cm_scen5_df, by=("LGA")) 
# 
# cm_scen5_map<-generateMap(cm_scen5_df)

#cm_scen5_titles <-title_function("Case Management (CM) Coverage", "Scenario 5 (National strategic plan with Improved coverage)", footnote_cm)



#scenario 6, 2020  

# cm_scen6_df <- case_management[which(case_management$scenario =="Scenario 6(Considered for funding in the NSP)" & year == 2020), ]
# 
# cm_scen6_df <- dplyr::left_join(LGAsf, cm_scen6_df, by=("LGA")) 
# 
# cm_scen6_map<-generateMap(cm_scen6_df)

#cm_scen6_titles <-title_function("Case Management (CM) Coverage", "Scenario 6 (Prioritized plans submitted to the Global Fund)", footnote_cm)



#scenario 7, 2020  

# cm_scen7_df <- case_management[which(case_management$scenario =="Scenario 7(Considered for funding in the NSP)"& year == 2020), ]
# 
# cm_scen7_df <- merge(LGAsf, cm_scen7_df, by="LGA", all.x=TRUE) 
# 
# cm_scen7_map<-generateMap(cm_scen7_df)

# cm_scen7_titles <-title_function("Case Management (CM) Coverage", "Scenario 7 (Prioritized plans submitted to the Global Fund)", footnote_cm)



# 2021 


# cm_scen21_df <- case_management[which(case_management$scenario =="Scenario 2(High effective coverage)" & year == 2021), ]
# cm_scen21_list <- split(cm_scen21_df, cm_scen21_df$simday)

# 
# cm_scen21<- purrr::map2(LGA_list,cm_scen21_list, left_join, by="LGA")
# 
# cm_scen21_map <-purrr::map(cm_scen21, generateMap)
# 
# gridded_cm_scen21 <- plot_grid(cm_scen21_map[[1]],cm_scen21_map[[2]], nrow = 1)




# cm_scen21_titles <-title_function("Case Management (CM) Coverage", "Scenario 2 (National strategic plan with high effective coverage)", footnote_cm)


# 2022 


# cm_df <- case_management[which(case_management$scenario =="Scenario 2(High effective coverage)" & year == 2026), ]
# if(nrow(cm_df) == 0){
#   cm_df = case_management[which(case_management$scenario =="Scenario 2(High effective coverage)" & year == 2025), ]
#   cm_list = split(cm_df, cm_df$simday)
#   cm_ = merge(LGAsf, y=cm_list[[3]] , by="LGA",all.x =TRUE)
#   cm_$simday <- "continuous"
#   cm_$year <- 2026
#   cm_scen1_map<-generateMap(cm_)
# } else{
#   
#   cm_list <- split(cm_df, cm_df$simday)
#   cm_<- purrr::map2(LGA_list,cm_list, left_join, by="LGA")
#   cm_map <-purrr::map(cm_, generateMap)
#         if(length(cm_map) > 2){
#           gridded_cm_scen22 <- plot_grid(cm_map[[1]],cm_map[[2]], cm_map[[3]], nrow = 2)
#         }else {
#           gridded_cm_scen22 <- plot_grid(cm_map[[1]],cm_map[[2]], nrow = 1)
#         }
# }







# print(gridded_cm_scen22)
# 
# cm_scen21_titles <-title_function("Case Management (CM) Coverage", "Scenario 2 (National strategic plan with high effective coverage)", footnote_cm)






# generateModelPlot <- function(df,var){
#   fig <- plotly::plot_ly(df, split = ~LGA, 
#           color = var, 
#           showlegend = FALSE,
#           alpha = 1,
#           hoverinfo = 'text',
#           text = ~paste(LGA),
#           hoveron= "fill",
#           stroke = I("grey"))
#  fig <- fig %>%  layout(title = unique(df$scenario))
#  
#   fig
# }
# 
# generateModelPlot_cm <- function(df) {
# g <- ggplot2::ggplot(df) +
#   ggiraph::geom_polygon_interactive(
#     color='grey',
#     ggplot2::aes(long, lat, group=group, fill=U5_coverage,
#      tooltip=paste0(df$LGA, " ",  "is in", " ", df$State.x,  " ", "State"))) +
#   #hrbrthemes::theme_ipsum() +
#   colormap::scale_fill_colormap(
#     colormap=colormap::colormaps$viridis, reverse = T) +
#   ggplot2::labs(title='Case Management in Children (CM) under the age of five', subtitle=unique(df$scenario),
#        caption='The Demographic and Health surveys was used to parameterize CM coverage', fill = "")+ 
#   ggplot2::theme(axis.text.x = ggplot2::element_blank(),
#         axis.text.y = ggplot2::element_blank(),
#         axis.ticks = ggplot2::element_blank(),
#         rect = ggplot2::element_blank(),
#         plot.title = ggplot2::element_text(face="bold"),
#         plot.subtitle = ggplot2::element_text(face ="italic"),
#         plot.caption = ggplot2::element_text(size = 8, face = "italic"))+
#   ggplot2::xlab("")+
#   ggplot2::ylab("")
# 
# ggiraph::ggiraph(code = print(g))
# 
# #widgetframe::frameWidget(ggiraph::ggiraph(code=print(g)
# }




#test ITN maps 

# ITN_kill_rate <-
#   data.table::fread("data/ITN_killrate_scenario6.csv")
# year = c(2020:2030)
# 
# 
# 
# for (i in 1:length(year)){
# kill  = ITN_kill_rate[which(ITN_kill_rate$year == year[[i]]), ]
# kill$simday = sort(kill$simday)
# kill_df = split(kill , by="simday")
# kill_df = purrr::map2(LGA_list,kill_df, left_join, by="LGA")
# cols_list = list(quo(kill_rate))
# kill_map = purrr::map2(kill_df, cols_list, generateMap)
# 
# 
# legend <- cowplot::get_legend(
#   # create some space to the left of the legend
#   kill_map[[4]] + guides(color = guide_legend(nrow = 1)) +
#     theme(legend.position = "bottom")
# )
# 
# kill_grid = plot_grid(kill_map[[1]] + theme(legend.position="none"),kill_map[[2]] + theme(legend.position="none"),
#                        kill_map[[3]] + theme(legend.position="none"), kill_map[[4]] + theme(legend.position="none"),
#                        kill_map[[5]] + theme(legend.position="none"), kill_map[[6]] + theme(legend.position="none"), nrow = 2)
# 
# 
# kill_grid= plot_grid(kill_grid, legend, nrow = 2, rel_heights = c(1, .1))
# kill_grid
# saveRDS(kill_grid, paste0("data/kill_rate_map_grids/kill_grid_scenario6_", as.character(year[[i]]), ".rds"))
# }
# 









# filename<- paste0("kill_grid_", as.character(2020))
# kill_grid=readRDS(kill_grid, file = paste0("data/kill_rate_map_grids/", filename, ".rds"))



# generateModelPlot <- function (modelOut) {
# 	legend_x <- getLegendXPosition(modelOut)
# 
# 	fig <- plotly::plot_ly(modelOut, x=~time)
# 	fig <- fig %>% plotly::add_trace(
# 			y=~DailyED_total_hosp,
# 			name=PLOT_OUTPUT_DESCRIPTIONS[['DailyED_total_hosp']],
# 			mode='lines', 
# 			type='scatter'
# 		) %>% 
# 		plotly::add_trace(
# 			y=~I_ch_hosp,
# 			name=PLOT_OUTPUT_DESCRIPTIONS[['I_ch_hosp']], 
# 			mode='lines', 
# 			type='scatter'
# 		) %>% 
# 		plotly::add_trace(
# 			y=~I_cicu_hosp,
# 			name=PLOT_OUTPUT_DESCRIPTIONS[['I_cicu_hosp']],
# 			mode='lines', 
# 			type='scatter'
# 		) %>% 
# 		plotly::add_trace(
# 			y=~inpatient_bed_max,
# 			name=PLOT_OUTPUT_DESCRIPTIONS[['inpatient_bed_max']],
# 			mode='lines', 
# 			type='scatter', 
# 			line=list(dash='dash')
# 		) %>% 
# 		plotly::add_trace(
# 			y=~ICU_bed_max,
# 			name=PLOT_OUTPUT_DESCRIPTIONS[['ICU_bed_max']],
# 			mode='lines', 
# 			type='scatter', 
# 			line=list(dash='dash')
# 		) %>%
# 		# TODO: try to figure out optimal position of legend, based on
# 		# functions peaks?
# 		plotly::layout(
# 			xaxis=list(title=PLOT_OUTPUT_DESCRIPTIONS[['time']]),
# 			yaxis=list(title='Counts', hoverformat='.0f'),
# 			legend=list(
# 				orientation='v',
# 				x=legend_x,
# 				y=0.9
# 			),
# 			title='Healthcare surge in hospital catchment area',
# 			margin=list(t=45, b=45)
# 		)
# 
# 	fig
# }

# # Reads default parameter settings for sensitivity analysis
# readDefault <- function () {
# 	default <- read.csv('./data/default.csv')
# 	default
# }
# 
# readSensitivity <- function (selectedParameter, default) {
# 	# Figure out which column to import based on selectedParameter
# 	header <- read.csv('./data/oneway_sensitivity.csv.gz', nrows=1, header=FALSE)
# 	selectedIdx <- which(header == selectedParameter)[[1]]
# 	chIdx <- which(header == 'I_ch')[[1]]
# 	cicuIdx <- which(header == 'I_cicu')[[1]]
# 	timeIdx <- which(header == 'time')[[1]]
# 	colClasses <- rep('NULL', length(header))
# 
# 	colClasses[[selectedIdx]] <- NA
# 	colClasses[[chIdx]] <- NA
# 	colClasses[[cicuIdx]] <- NA
# 	colClasses[[timeIdx]] <- NA
# 
# 	# Read data, importing only necessary columns
# 	data <- tibble::tibble(read.csv('./data/oneway_sensitivity.csv.gz', colClasses=colClasses))
# 
# 	# Cut to 90 days, and remove default value of selectedParameter
# 	data <- data %>%
# 		dplyr::filter(time <= 90, data[[selectedParameter]] != unique(default[[selectedParameter]]))
# 
# 	data
# }
# 
# generateHospSensitivityPlot <- function (input, selectedParameter, data) {
# 	paramRange <- input$parameterRange
# 
# 	if (!is.null(paramRange)) {
# 		data <- data %>% dplyr::filter(dplyr::between(data[[selectedParameter]], paramRange[[1]], paramRange[[2]]))
# 	}
# 
# 	figHosp <- data %>%
# 		plotly::plot_ly(
# 			x=~time, 
# 			y=~I_ch * input$sens_catchment_hosp, 
# 			type='scatter',
# 			color=~data[[selectedParameter]],
# 			split=~data[[selectedParameter]],
# 			colors=c('yellow', 'red'), 
# 			mode='lines',
# 			showlegend=FALSE
# 		) %>%
# 		plotly::add_trace(
# 			y=~input$sens_inpatient_bed_max,
# 			name=INPUT_PARAM_DESCRIPTIONS[['sens_inpatient_bed_max']],
# 			mode='lines',
# 			type='scatter',
# 			line=list(dash='dash', color='black')
# 		) %>%
# 		plotly::colorbar(
# 			title=''
# 		) %>%
# 		plotly::layout(
# 			xaxis=list(title='Days since outbreak started\n(local transmission)'),
# 			yaxis=list(title='Number of non-ICU inpatients with COVID-19<br>in catchment area', hoverformat='.0f'),
# 			annotations=list(
# 				x=50,
# 				y=~input$sens_inpatient_bed_max,
# 				text=INPUT_PARAM_DESCRIPTIONS[['sens_inpatient_bed_max']],
# 				xref='x',
# 				yref='y',
# 				showarrow=FALSE,
# 				yanchor='bottom'
# 			)
# 		)
# 
# 	figHosp
# }
# 
# generateICUSensitivityPlot <- function (input, selectedParameter, data) {
# 	paramRange <- input$parameterRange
# 
# 	if (!is.null(paramRange)) {
# 		data <- data %>% dplyr::filter(dplyr::between(data[[selectedParameter]], paramRange[[1]], paramRange[[2]]))
# 	}
# 
# 	figICU <- data %>%
# 		plotly::plot_ly(
# 			x=~time, 
# 			y=~I_cicu * input$sens_catchment_ICU, 
# 			type='scatter',
# 			color=~data[[selectedParameter]],
# 			split=~data[[selectedParameter]],
# 			colors=c('yellow', 'red'), 
# 			mode='lines',
# 			showlegend=FALSE
# 		) %>%
# 		plotly::add_trace(
# 			y=~input$sens_ICU_bed_max,
# 			name=INPUT_PARAM_DESCRIPTIONS[['sens_ICU_bed_max']],
# 			mode='lines',
# 			type='scatter',
# 			line=list(dash='dash', color='black')
# 		) %>%
# 		plotly::colorbar(
# 			title=''
# 		) %>%
# 		plotly::layout(
# 			xaxis=list(title='Days since outbreak started\n(local transmission)'),
# 			yaxis=list(title='Number of ICU inpatients with COVID-19<br>in catchment area', hoverformat='.0f'),
# 			annotations=list(
# 				x=50,
# 				y=~input$sens_ICU_bed_max,
# 				text=INPUT_PARAM_DESCRIPTIONS[['sens_ICU_bed_max']],
# 				xref='x',
# 				yref='y',
# 				showarrow=FALSE,
# 				yanchor='bottom'
# 			)
# 		)
# 
# 	figICU
# }


# if(("Scenario 1 (Business as Usual)"%in% input$scenarioInput)  & ("Case management - uncomplicated" %in% input$varType)) {
#   cm_map<- reactive({
#     cm_map=readRDS(file = paste0(repo, "/CM/CM_Scenario 1 (Business as Usual)", ".rds"))
#     cm_map$data$year = input$yearInput
#     cm_map = cm_map + ggplot2::labs(title = paste0("Simday:", " ", max(cm_map$data$simday, na.rm = T), ", Year:", " ", max(cm_map$data$year, na.rm=T)))
#   })
#   return(cm_map())
#   
# } 



# if(("Scenario 2 (High effective coverage)" %in% input$scenarioInput) & ("Case management - uncomplicated" %in% input$varType)){
#   cm_map<- reactive({
#   
#     
#     if (input$yearInput > 2025) {
#       cm = case_management[which(case_management$scenario == input$scenarioInput, year == 2025), ]
#       #browser()
#       cm_df = split(cm , by="simday")
#       cm_df = merge(LGAsf, y=cm_df[[3]] , by="LGA",all.x =TRUE)
#       cm_df$simday = "continuous"
#       cm_df$year = input$yearInput
#       cm_map = generateMap(cm_df, quo(U5_coverage)) 
#     
#     } 
#     
#     else  {
#       
#       cm = case_management[which(case_management$scenario ==input$scenarioInput & year == input$yearInput), ]
#       cm_df  = split(cm , by="simday")
#       cm_df = purrr::map2(LGA_list,cm_df, left_join, by="LGA")
#       cols_list = list(quo(U5_coverage))
#       cm_map <-purrr::map2(cm_df, cols_list, generateMap)
#      
#             
#        if(length(cm_map) > 2){
#           
#          legend <- cowplot::get_legend(
#            # create some space to the left of the legend
#            cm_map[[1]] + theme(legend.box.margin = margin(0, 0, 0, 12))
#          )
#          cm_map =  plot_grid(cm_map[[1]]+ theme(legend.position="none"),cm_map[[2]] + theme(legend.position="none"), cm_map[[3]] + theme(legend.position="none"), nrow = 1)
#        
#          cm_map = plot_grid(cm_map, legend, rel_widths = c(3, .4))
#        } 
#       
#          else {
#            
#            legend <- cowplot::get_legend(
#              # create some space to the left of the legend
#              cm_map[[1]] + theme(legend.box.margin = margin(0, 0, 0, 12))
#            )
#           
#            cm_map <- plot_grid(cm_map[[1]] + theme(legend.position="none"),cm_map[[2]]+ theme(legend.position="none") , nrow = 1)
#            
#            cm_map = plot_grid(cm_map, legend, rel_widths = c(3, .4))
#            
#             }
#            
#         }
#    
#   
# 
#     })
#   
# 
# 
#         return(cm_map())
#  
# }



# # Scenarios 3-7
#  if("Case management - uncomplicated" %in% input$varType) {
#    cm_map<- reactive({
#      if(substr(input$scenarioInput, 10, 10) %in% c('6', '7')){
#        cm = case_management[which(case_management$scenario ==input$scenarioInput & year == input$yearInput), ]
#      } else {
#        cm  = case_management[which(case_management$scenario ==input$scenarioInput), ]
#      }
#      
#      cm_df <- merge(LGAsf, cm , by="LGA", all.x =TRUE)
#      cm_df$year = input$yearInput
#      cm_map = generateMap(cm_df, quo(U5_coverage))
#   })
# 
#    return(cm_map())}

# ITN$U5_ITN_use = ITN$U5_ITN_use*100
# ITN$simday = sort(ITN$simday)
# ITN_df = split(ITN , by="simday")
# ITN_df = purrr::map2(LGA_list,ITN_df, left_join, by="LGA")
# cols_list = list(quo(U5_ITN_use))
# ITN_map = purrr::map2(ITN_df, cols_list, generateMap)
# #ITN_map[[2]]



# 
# legend <- cowplot::get_legend(
#     # create some space to the left of the legend
#     ITN_map[[4]] + guides(color = guide_legend(nrow = 1)) +
#       theme(legend.position = "bottom")
#   )
# 
#   ITN_grid = plot_grid(ITN_map[[1]] + theme(legend.position="none"),ITN_map[[2]] + theme(legend.position="none"),
#                          ITN_map[[3]] + theme(legend.position="none"), ITN_map[[4]] + theme(legend.position="none"),
#                          ITN_map[[5]] + theme(legend.position="none"), ITN_map[[6]] + theme(legend.position="none"), nrow = 2)
# 
# 
#   ITN_grid= plot_grid(ITN_grid, legend, nrow = 2, rel_heights = c(1, .1))
#   ITN_grid
#   saveRDS(ITN_grid,
#           paste0("data/ITN_map_grid/u5_scenario/", "Scenario 7 (Considered for funding in the NSP)", "_", as.character(year[[i]]),  ".rds"))
# }


# filename = paste0("Scenario 1 (Business as Usual)", "_", "2020")
# #browser()
# kill_grid=readRDS(file = paste0("data/ITN_map_grid/u5_scenario1/", filename, ".rds"))



# case_management <- fread("data/severe_case_management.csv")
# footnote_cm <-'The Demographic and Health surveys were used to parameterize CM coverage. \n
#                   #The same coverage levels were used for both adults and children'
# 
# cm_scen1_df <- case_management[which(case_management$scenario =="Scenario 1(Business as Usual)"), ]
# cm_scen1_df <- merge(LGAsf, y=cm_scen1_df , by="LGA",all.x =TRUE)
# cm_scen1_map<-generateMap(cm_scen1_df, quo(severe_cases))
# cm_scen1_titles <-title_function("Case Management (CM) Coverage", "Scenario 1 (Business as Usual)", footnote_cm)








#CM map scripts

# 

#inputs <- file.path(repo, 'simulation_inputs', 'CM')
#outputs <- file.path(data, 'Severe_CM')
# cm = data.table::fread(file.path(inputs, "cm_scenario1_BAU_2020_2030.csv"))
# cm_df = merge(LGAsf, cm, by ="LGA", all.x =TRUE)
# cm_df$severe_cases = round(cm_df$severe_cases * 100, 1)
# cm_map = generateMap(cm_df, quo(severe_cases))
# saveRDS(cm_map, paste0(outputs, '/', "Severe_CM_", "Scenario 1 (Business as Usual)", ".rds"))
# 
# cm_map$data$year = '2021'
# cm_map = cm_map + ggplot2::labs(title = paste0("Simday:", " ", max(cm_map$data$simday, na.rm = T), ", Year:", " ", max(cm_map$data$year, na.rm=T)))
# 
# 


#cm_map=readRDS(file = paste0(repo, "/CM/CM_Scenario 1 (Business as Usual)", ".rds"))
#cm_map$data$year = input$yearInput


# year = c(2020:2030)
# 
# 
# for (i in 1:length(year)){
# cm = data.table::fread(file.path(inputs, "cm_scenario3_4_funded_2020_2030.csv"))
# cm  = cm[which(cm$year ==as.character(year[[i]])), ]
# cm_df = merge(LGAsf, cm, by ="LGA", all.x =TRUE)
# cm_df$severe_cases = round(cm_df$severe_cases * 100, 1)
# cm_map = generateMap(cm_df, quo(severe_cases))
# saveRDS(cm_map, paste0(outputs, '/', "Severe_CM_", "Scenario 3 (Budget-prioritized plan)", "_", as.character(year[[i]]),  ".rds"))
# }
# 
# 
# repo <- file.path(Drive, 'Documents', 'hbhi-nigeria-publication-2021', 'hbhi-nigeria-shiny-app', 'data')
# scenarioInput = 'Scenario 3 (Budget-prioritized plan)'
# yearInput = '2025'
# cm_map=readRDS(file = paste0(repo, "/CM/", 'CM_', scenarioInput, '_', as.character(yearInput), ".rds"))


#   g <- ggplot2::ggplot(data()) +
#     ggiraph::geom_polygon_interactive(
#       color='grey',
#       ggplot2::aes(long, lat, group=group, fill=U5_coverage,
#                    tooltip=paste0(LGA, " ",  "is in", " ", State.x,  " ", "State"))) +
#     colormap::scale_fill_colormap(
#       colormap=colormap::colormaps$viridis, reverse = T) +
#     ggplot2::labs(title='Case Management (CM) Coverage', subtitle=unique(data()$scenario),
#                   caption='The Demographic and Health surveys were used to parameterize CM coverage. \n
#                   The same coverage levels were used for both adults and children', fill = "")+
#     ggplot2::theme(axis.text.x = ggplot2::element_blank(),
#                    axis.text.y = ggplot2::element_blank(),
#                    axis.ticks = ggplot2::element_blank(),
#                    rect = ggplot2::element_blank(),
#                    plot.title = ggplot2::element_text(face="bold", hjust = 0.5),
#                    plot.subtitle = ggplot2::element_text(face ="italic", hjust = 0.5),
#                    plot.caption = ggplot2::element_text(size = 8, face = "italic"))+
#     ggplot2::xlab("")+ 
#     ggplot2::ylab("")
# 
#   
#   ggiraph::ggiraph(code = print(g))
# })



generateMap <-function(data, column, tooltip_name){
  
  g <- ggplot2::ggplot(data) +
    ggiraph::geom_sf_interactive(
      color='grey', size =0.03, 
      ggplot2::aes(fill=!!column,
                   tooltip=paste0(LGA, " ",  "is in", " ", State,  " ", "State ", " with ", round(!!column, 1), "%", " ", tooltip_name,
                                  ",", "\n",
                                  "Simday:", " ", simday))) +
    viridis::scale_fill_viridis(direction = -1, na.value = 'grey', limits = c(0, 90)) +
    # colormap::scale_fill_colormap(
    #   colormap=colormap::colormaps$viridis, reverse = T) +
    #ggplot2::labs(title = paste0("Simday:", " ", max(data$simday, na.rm = T), ", Year:", " ", max(data$year, na.rm=T)))+
    ggplot2::theme(plot.title = ggplot2::element_text(face="italic", hjust = 0.5, size=8),
                   axis.text.x = ggplot2::element_blank(),
                   axis.text.y = ggplot2::element_blank(),
                   axis.ticks = ggplot2::element_blank(),
                   rect = ggplot2::element_blank(),
                   plot.background = ggplot2::element_rect(fill = "white", colour = NA),
                   legend.title = ggplot2::element_blank())+
    ggplot2::theme(plot.margin = ggplot2::margin(6, 0, 6, 0))+
    ggplot2::xlab("")+
    ggplot2::ylab("")
  return(g)
}




coverage_map = generateMap(LGA_shp, quo(coverage_high_access), "SMC coverage low access group")
coverage_map2 = generateMap(LGA_shp[[2]], quo(coverage_low_access), "SMC coverage low access group")
coverage_map3 = generateMap(LGA_shp[[3]], quo(coverage_low_access), "SMC coverage low access group")
coverage_map4 = generateMap(LGA_shp[[4]], quo(coverage_low_access), "SMC coverage low access group")

check_2 = coverage_map2$data %>%  na.omit()
print(coverage_map2)

LGA_dat1 <- LGA_shp$LGA
LGA_dat2 <- LGA_shp2$LGA

setdiff(LGA_dat1 ,LGA_dat2)

tm_shape(LGA_shp) +
  tm_polygons()


st_crs(LGAsf)

check = LGA_shp %>%  na.omit()


user <- Sys.getenv("USERNAME")
Drive <- file.path(gsub("[\\]", "/", gsub("Documents", "", Sys.getenv("HOME"))))
NuDir <- file.path(Drive, "Box", "NU-malaria-team")
ScriptDir <- file.path(NuDir,"data/nigeria_dhs/data_analysis/src/DHS/1_variables_scripts")
source(file.path(ScriptDir, "generic_functions", "DHS_fun.R"))

LGAsf2 <- sf::st_read("../../data/LGA_shp_2/gadm36_NGA_1.shp") 



#case management
# if("Case management - uncomplicated" %in% input$varType){
#   footnote_cm <- 'The Demographic and Health surveys were used to parameterize CM coverage at baseline. The same
#                          coverage levels were used for both adults and children. Values are percentages'
# }
# 
# if(("Case management - uncomplicated" %in% input$varType)) {
#   cm_titles<-reactive({
#   cm_titles <-title_function("Case Management (CM) Coverage", input$scenarioInput, footnote_cm)
#   })
#   return(cm_titles())}




theme_georgia <- function(...) {
  theme_gray(base_family = "Georgia", ...) + 
    theme(plot.title = element_text(face = "bold"))
}

draw_label_theme <- function(label, theme = NULL, element = "text", ...) {
  if (is.null(theme)) {
    theme <- ggplot2::theme_get()
  }
  if (!element %in% names(theme)) {
    stop("Element must be a valid ggplot theme element name")
  }
  
  elements <- ggplot2::calc_element(element, theme)
  
  cowplot::draw_label(label, 
                      fontfamily = elements$family,
                      #fontface = elements$face,
                      colour = elements$color,
                      size = 14,
                      ...
  )
}

title_function <-function(mainTitle, subTitle, footNote){
  title <- ggdraw() +
    draw_label_theme(mainTitle, 
                     theme = theme_georgia(), element = "plot.title",
                     hjust=0.5,  fontface ="bold")+ ggplot2::theme(plot.margin = ggplot2::unit(c(0, 0, 0, 0), "cm"))
  subtitle <- ggdraw() +
    draw_label_theme(subTitle,
                     theme = theme_georgia(), element = "plot.subtitle",
                     hjust=0.5, fontface="italic") + ggplot2::theme(plot.margin = ggplot2::unit(c(0, 0, 0, 0), "cm"))
  footnote<-ggdraw() +
    draw_label_theme(footNote,
                     theme = theme_georgia(), element = "plot.caption",
                     hjust=0.5,  fontface ="italic") + ggplot2::theme(plot.margin = ggplot2::unit(c(0, 0, 0, 0), "cm"))
  
  title_ls<-list(title, subtitle, footnote)
  return(title_ls)
}


# ggiraph::girafe(ggobj = cowplot::plot_grid(title()[[1]], NULL,  title()[[2]], data(),NULL, title()[[3]], ncol = 1, 
#                                            rel_heights = c(0.09, 0.02, 0.09, 3,-0.02, 0.3), align = 'none'), width_svg = 10, height_svg = 7, 
#                 options = list(ggiraph::opts_zoom(max = 5)))



# for (i in 1:length(val_year)){
# ITN <-data.table::fread(file.path(inputs, "itn_scenario3_4_funded_2020_2030.csv")) %>% dplyr::select(-c(six_nine_ITN_use,ten_eighteen_ITN_use,
#                                                                                                         over_eighteen_ITN_use, 'kill_rate', 'mortality', block_initial, 'LGA_old', mass_llins_fund))
# ITN= ITN[which(ITN$year == val_year[[i]]), ]
# ITN_df = merge(LGAsf, ITN, by ="LGA", all.x =TRUE)
# ITN_df$U5_ITN_use= round(ITN_df$U5_ITN_use* 100, 1)
# ITN_df = rename(ITN_df, ITN_use = U5_ITN_use)
# saveRDS(ITN_df, paste0(outputs, '/', "ITN_coverage", "_> 5 years_Scenario 3 (Budget-prioritized plan)", "_", as.character(val_year[[i]]), ".rds"), compress = FALSE)
#  }

# 
# 
# 
# coverage_map=readRDS(file = paste0(outputs, '/', "ITN_coverage_> 5 years_", "Scenario 1 (Business as Usual)", "_", '2021', ".rds"))
# coverage_map = generateMap(coverage_map, quo(ITN_use), "U5 ITN coverage")


# kill_map = kill_map + ggplot2::labs(title = paste0("Simdays:", " ", min(kill_map$data$simday, na.rm = T), "-", max(kill_map$data$simday, na.rm = T),   ", Year:", " ", max(kill_map$data$year, na.rm=T)))
# 
# data <- kill_map$data %>%  sf::st_drop_geometry
# class(data)

# library(patchwork)
# SMC = data.table::fread(file.path(inputs, "smc_scenario1_BAU_2020_2030.csv")) %>%  dplyr::select(-c(State))
# SMC = SMC %>%  dplyr::filter(year == 2020)
# SMC$coverage_high_access= round(SMC$coverage_high_access* 100, 1)
# SMC = split(SMC, SMC$round)
# LGA_shp <-map2(LGA_list, SMC, left_join, by ="LGA")
# val = list(quo(coverage_high_access))
# tooltip = list("SMC coverage high access group")
# maps <- pmap(list(LGA_shp, val,tooltip), generateMap)
# 
# legend <- cowplot::get_legend(
#     # create some space to the left of the legend
#     maps[[4]] + guides(color = guide_legend(nrow = 1)) +
#       theme(legend.position = "right")
#   )
# 
# all_maps =maps[[1]] + ggplot2::xlab(paste0('Round:', " ", unique(na.omit(maps[[1]]$data$round))))+
#   ggplot2::labs(title = paste0("Simdays:", " ", min(maps[[1]]$data$simday, na.rm = T), "-", max(maps[[1]]$data$simday, na.rm = T),   ", Year:", " ", max(maps[[1]]$data$year, na.rm=T))) +
#   theme(legend.position="none", plot.margin = unit(c(0, 0, 0, 0), "cm")) +
#   
#   
#   maps[[2]] +
#   ggplot2::xlab(paste0('Round:', " ", unique(na.omit(maps[[2]]$data$round))))+
#   ggplot2::labs(title = paste0("Simdays:", " ", min(maps[[2]]$data$simday, na.rm = T), "-", max(maps[[2]]$data$simday, na.rm = T),   ", Year:", " ", max(maps[[2]]$data$year, na.rm=T))) +
#   theme(legend.position="none", plot.margin = unit(c(0, 0, 0, 0), "cm")) +
#   
#   maps[[3]] + ggplot2::xlab(paste0('Round:', " ", unique(na.omit(maps[[3]]$data$round))))+
#   ggplot2::labs(title = paste0("Simdays:", " ", min(maps[[3]]$data$simday, na.rm = T), "-", max(maps[[3]]$data$simday, na.rm = T),   ", Year:", " ", max(maps[[3]]$data$year, na.rm=T))) +
# theme(legend.position="none", plot.margin = unit(c(0, 0, 0, 0), "cm")) +
#   
#   maps[[4]] + ggplot2::xlab(paste0('Round:', " ", unique(na.omit(maps[[4]]$data$round))))+
#   ggplot2::labs(title = paste0("Simdays:", " ", min(maps[[4]]$data$simday, na.rm = T), "-", max(maps[[4]]$data$simday, na.rm = T),   ", Year:", " ", max(maps[[4]]$data$year, na.rm=T)))+
# theme(plot.margin = unit(c(0, 0, 0, 0), "cm")) 
# 
# all_map = plot_grid(
#   maps[[1]] + ggplot2::xlab(paste0('Round:', " ", unique(na.omit(maps[[1]]$data$round))))+
#   ggplot2::labs(title = paste0("Simdays:", " ", min(maps[[1]]$data$simday, na.rm = T), "-", max(maps[[1]]$data$simday, na.rm = T),   ", Year:", " ", max(maps[[1]]$data$year, na.rm=T))) +
#     theme(legend.position="none", plot.margin = unit(c(0, 0, 0.1, 0), "cm")),
# 
#   maps[[2]] + ggplot2::xlab(paste0('Round:', " ", unique(na.omit(maps[[2]]$data$round))))+
#   ggplot2::labs(title = paste0("Simdays:", " ", min(maps[[2]]$data$simday, na.rm = T), "-", max(maps[[2]]$data$simday, na.rm = T),   ", Year:", " ", max(maps[[2]]$data$year, na.rm=T))) +
#     theme(legend.position="none", plot.margin = unit(c(0, 0, 0.1, 0), "cm")),
# 
#   maps[[3]] + ggplot2::xlab(paste0('Round:', " ", unique(na.omit(maps[[3]]$data$round))))+
#     ggplot2::labs(title = paste0("Simdays:", " ", min(maps[[3]]$data$simday, na.rm = T), "-", max(maps[[3]]$data$simday, na.rm = T),   ", Year:", " ", max(maps[[3]]$data$year, na.rm=T)))
#   + theme(legend.position="none", plot.margin = unit(c(0, 0, 0.1, 0), "cm")),
# 
#   maps[[4]] + ggplot2::xlab(paste0('Round:', " ", unique(na.omit(maps[[4]]$data$round))))+
#     ggplot2::labs(title = paste0("Simdays:", " ", min(maps[[4]]$data$simday, na.rm = T), "-", max(maps[[4]]$data$simday, na.rm = T),   ", Year:", " ", max(maps[[4]]$data$year, na.rm=T)))
#   + theme(legend.position="none", plot.margin = unit(c(0, 0, 0.1, 0), "cm")))
# 
# # 
# map_leg = plot_grid(all_map, legend, nrow = 2, rel_heights = c(1, .2))
# # 
# saveRDS(all_maps, paste0(outputs, '/', "SMC", "_high access children_Scenario 1 (Business as Usual)", "_", as.character(2020), ".rds"), compress = FALSE)
# 
# # 
# 

for (i in 1:length(val_year)){
  SMC = data.table::fread(file.path(inputs, "smc_scenario2_increase80_2020_2030.csv")) #%>%  dplyr::select(-c(State))
  SMC = SMC %>%  dplyr::filter(year == val_year[[i]])
  SMC$coverage_low_access= round(SMC$coverage_low_access* 100, 1)
  SMC = SMC %>%  group_by(LGA) %>%  summarise(average_coverage_per_round = mean(coverage_low_access))
  SMC$year = val_year[[i]]
  LGA_shp <- left_join(LGAsf, SMC, by ="LGA")
  saveRDS(LGA_shp, paste0(outputs, '/', "SMC_", "low access children_", "Scenario 2 (National malaria strategic plan)", "_", as.character(val_year[[i]]), ".rds"), compress = FALSE)
}


library(dplyr)
IPTi = data.table::fread(file.path(inputs, "assumedIPTicov.csv")) %>%  dplyr::select(-c(State)) %>%
  dplyr::mutate(LGA = stringr::str_replace_all(LGA, "/", "-"),LGA = dplyr::case_when(LGA == "kiyawa"~ "Kiyawa",
                                                                                     LGA == "kaita"~ "Kaita", TRUE ~ as.character(LGA)))
IPTi$ipti_cov_mean= round(IPTi$ipti_cov_mean* 0, 1)
IPTi$ipti_cov_cil = round(IPTi$ipti_cov_cil *0, 1)
IPTi$ipti_cov_ciu = round(IPTi$ipti_cov_ciu *0, 1)
LGA_shp <- left_join(LGAsf, IPTi, by ="LGA")
coverage_map = generateMap(LGA_shp, quo(ipti_cov_mean), "IPTi coverage")
saveRDS(coverage_map, paste0(outputs, '/', "IPTi_", "all_scenarios", ".rds"), compress = FALSE)

# #--------------------------------------------------------  
# ###title and footnote generation script  
# #--------------------------------------------------------
# proj_title <- eventReactive(input$submit_proj,{
#   
#   if(("Trends" %in% input$statistic)){
#     
#     title<-reactive({
#       #browser
#       title <- list(title = paste0('Projected', input$admin, input$statistic, 'in all age', input$Indicator ))
#       
#     })
#     
#     return(title())
#   }
#   
#   
# })
