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

