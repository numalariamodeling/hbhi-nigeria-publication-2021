import::here('./vm.R', LGAsf, LGA_list, generateMap, title_function)
import::here('./utils.R', interventions)


import::from(dplyr, rename,case_when, left_join,  '%>%' )
import::from(cowplot, ggdraw, plot_grid)
import::from(ggplot2, theme, margin)
import::from(rlang, quo)
import::from(ggiraph, girafe_options)


observe({
  updateSelectInput(session, "ITN_age", choices = interventions[interventions$interventions==input$varType, "age_group"])
})




#--------------------------------------------------------  
###Map generation script  
#--------------------------------------------------------
data <- eventReactive(input$submit_loc,{
  data_dir <- file.path(Sys.getenv("HOME"),"Box", "NU-malaria-team", "projects", "hbhi_nigeria_shiny_app_data")

  #--------------------------------------------------------  
  ### Case management 
  #--------------------------------------------------------
if("Case management - uncomplicated" %in% input$varType){
  case_management <- 
    data.table::fread(file.path(data_dir, "case_management.csv"))
  #browser()
}
  

  
  
  if(("Scenario 1 (Business as Usual)"%in% input$scenarioInput)  & ("Case management - uncomplicated" %in% input$varType)) {
    cm_map<- reactive({
    cm  = case_management[which(case_management$scenario ==input$scenarioInput), ]
    #browser()
    cm_df = merge(LGAsf, cm, by ="LGA", all.x =TRUE)
    cm_df$year = input$yearInput
    cm_map = generateMap(cm_df, quo(U5_coverage))
    })
    #browser()
    return(cm_map())
    
    } 
  
  
  if(("Scenario 2 (High effective coverage)" %in% input$scenarioInput) & ("Case management - uncomplicated" %in% input$varType)){
    cm_map<- reactive({
    
      
      if (input$yearInput > 2025) {
        cm = case_management[which(case_management$scenario == input$scenarioInput, year == 2025), ]
        #browser()
        cm_df = split(cm , by="simday")
        cm_df = merge(LGAsf, y=cm_df[[3]] , by="LGA",all.x =TRUE)
        cm_df$simday = "continuous"
        cm_df$year = input$yearInput
        cm_map = generateMap(cm_df, quo(U5_coverage)) 
      
      } 
      
      else  {
        
        cm = case_management[which(case_management$scenario ==input$scenarioInput & year == input$yearInput), ]
        cm_df  = split(cm , by="simday")
        cm_df = purrr::map2(LGA_list,cm_df, left_join, by="LGA")
        cols_list = list(quo(U5_coverage))
        cm_map <-purrr::map2(cm_df, cols_list, generateMap)
       
              
         if(length(cm_map) > 2){
            
           legend <- cowplot::get_legend(
             # create some space to the left of the legend
             cm_map[[1]] + theme(legend.box.margin = margin(0, 0, 0, 12))
           )
           cm_map =  plot_grid(cm_map[[1]]+ theme(legend.position="none"),cm_map[[2]] + theme(legend.position="none"), cm_map[[3]] + theme(legend.position="none"), nrow = 1)
         
           cm_map = plot_grid(cm_map, legend, rel_widths = c(3, .4))
         } 
        
           else {
             
             legend <- cowplot::get_legend(
               # create some space to the left of the legend
               cm_map[[1]] + theme(legend.box.margin = margin(0, 0, 0, 12))
             )
            
             cm_map <- plot_grid(cm_map[[1]] + theme(legend.position="none"),cm_map[[2]]+ theme(legend.position="none") , nrow = 1)
             
             cm_map = plot_grid(cm_map, legend, rel_widths = c(3, .4))
             
              }
             
          }
     
    

      })
    
  

          return(cm_map())
   
  }
  
  # Scenarios 3-7
   if("Case management - uncomplicated" %in% input$varType) {
     cm_map<- reactive({
       if(substr(input$scenarioInput, 10, 10) %in% c('6', '7')){
         cm = case_management[which(case_management$scenario ==input$scenarioInput & year == input$yearInput), ]
       } else {
         cm  = case_management[which(case_management$scenario ==input$scenarioInput), ]
       }
       
       cm_df <- merge(LGAsf, cm , by="LGA", all.x =TRUE)
       cm_df$year = input$yearInput
       cm_map = generateMap(cm_df, quo(U5_coverage))
    })

     return(cm_map())}

# 
# 
# 
#  if(("Scenario 3 (Improved coverage)" %in% input$scenarioInput) & ("Case management - uncomplicated" %in% input$varType)) {
#    cm_map<- reactive({
#      cm  = case_management[which(case_management$scenario ==input$scenarioInput), ]
#      cm_df <- merge(LGAsf, cm , by="LGA", all.x =TRUE)
#      cm_df$year = input$yearInput
#      cm_map = generateMap(cm_df, quo(U5_coverage))
#   })
# 
#   return(cm_map())}
# 
# 
#   if(("Scenario 4 (Improved coverage)" %in% input$scenarioInput) & ("Case management - uncomplicated" %in% input$varType)) {
#     cm_map<- reactive({
#       cm  = case_management[which(case_management$scenario ==input$scenarioInput), ]
#       cm_df <- merge(LGAsf, cm , by="LGA", all.x =TRUE)
#       cm_df$year = input$yearInput
#       cm_map = generateMap(cm_df, quo(U5_coverage))
#     })
#   return(cm_map())}
# 
# 
# if(("Scenario 5 (Improved coverage)" %in% input$scenarioInput) & ("Case management - uncomplicated" %in% input$varType)) {
#   cm_map<- reactive({
#     cm  = case_management[which(case_management$scenario ==input$scenarioInput), ]
#     cm_df <- merge(LGAsf, cm , by="LGA", all.x =TRUE)
#     cm_df$year = input$yearInput
#     cm_map = generateMap(cm_df, quo(U5_coverage))
#   })
#   return(cm_map())}
# 
# 
# if(("Scenario 6 (Considered for funding in the NSP)"  %in% input$scenarioInput) & ("Case management - uncomplicated" %in% input$varType)) {
# 
#   cm_map<- reactive({
#     cm  = case_management[which(case_management$scenario ==input$scenarioInput & year == input$yearInput), ]
#     cm_df <- merge(LGAsf, cm , by="LGA", all.x =TRUE)
#     cm_df$year = input$yearInput
#     cm_map = generateMap(cm_df, quo(U5_coverage))
#   })
#   return(cm_map())}
# 
# 
#   if(("Scenario 7 (Considered for funding in the NSP)" %in% input$scenarioInput) & ("Case management - uncomplicated" %in% input$varType)) {
#     cm_map<- reactive({
#       cm  = case_management[which(case_management$scenario ==input$scenarioInput & year == input$yearInput), ]
#       cm_df <- merge(LGAsf, cm , by="LGA", all.x =TRUE)
#       cm_df$year = input$yearInput
#       cm_map = generateMap(cm_df, quo(U5_coverage))
#     })
#     return(cm_map())}
# 
#   

  #--------------------------------------------------------  
  ### Severe case management 
  #--------------------------------------------------------
 
  if("Case management - severe" %in% input$varType){
    severe_cm <- 
      data.table::fread(file.path(data_dir, "severe_case_management.csv"))
    #browser()
  }
  
  
  
  if(("Scenario 1 (Business as Usual)" %in% input$scenarioInput) & ("Case management - severe" %in% input$varType)) {
    cm_map<- reactive({
      cm  = severe_cm[which(severe_cm$scenario ==input$scenarioInput), ]
      #browser()
      cm_df = merge(LGAsf, cm, by ="LGA", all.x =TRUE)
      cm_df$year = input$yearInput
      cm_map = generateMap(cm_df, quo(severe_cases))
    })
    return(cm_map())
    
  } 
  
  
  
  if(("Scenario 2 (High effective coverage)" %in% input$scenarioInput) & ("Case management - severe" %in% input$varType)){
    cm_map<- reactive({
      
      
      
      if (input$yearInput > 2025) {
        cm = severe_cm[which(severe_cm$scenario ==input$scenarioInput & year == 2025), ]
        cm_df = split(cm , by="simday")
        cm_df = merge(LGAsf, y=cm_df[[3]] , by="LGA",all.x =TRUE)
        cm_df$simday = "continuous"
        cm_df$year = input$yearInput
        cm_map = generateMap(cm_df, quo(severe_cases))
        
      } 
      
      else  {
        
        cm = severe_cm[which(severe_cm$scenario ==input$scenarioInput & year == input$yearInput), ]
        cm_df  = split(cm , by="simday")
        cm_df = purrr::map2(LGA_list,cm_df, left_join, by="LGA")
        cols_list = list(quo(severe_cases))
        cm_map <-purrr::map2(cm_df, cols_list, generateMap)
        
        
        if(length(cm_map) > 2){
          
          legend <- cowplot::get_legend(
            # create some space to the left of the legend
            cm_map[[1]] + theme(legend.box.margin = margin(0, 0, 0, 12))
          )
          cm_map =  plot_grid(cm_map[[1]]+ theme(legend.position="none"),cm_map[[2]] + theme(legend.position="none"), cm_map[[3]] + theme(legend.position="none"), nrow = 1)
          
          cm_map = plot_grid(cm_map, legend, rel_widths = c(3, .4))
        } 
        
        else {
          
          legend <- cowplot::get_legend(
            # create some space to the left of the legend
            cm_map[[1]] + theme(legend.box.margin = margin(0, 0, 0, 12))
          )
          
          cm_map <- plot_grid(cm_map[[1]] + theme(legend.position="none"),cm_map[[2]]+ theme(legend.position="none") , nrow = 1)
          
          cm_map = plot_grid(cm_map, legend, rel_widths = c(3, .4))
          
        }
        
      }
      
      
      
    })
    
    
    
    return(cm_map())
    
  }
  
  # Scenarios 3-7
  if("Case management - severe" %in% input$varType){
    cm_map <- reactive({
      if(substr(input$scenarioInput, 10, 10) %in% c('6', '7')){
        cm = severe_cm[which(severe_cm$scenario ==input$scenarioInput & year == input$yearInput), ]
      } else {
        cm  = severe_cm[which(severe_cm$scenario ==input$scenarioInput), ]
      }
      cm_df <- merge(LGAsf, cm, by="LGA", all.x = TRUE)
      cm_df$year = input$yearInput
      cm_map = generateMap(cm_df, quo(severe_cases))
    })

    return(cm_map())}
  

  # if(("Scenario 3 (Improved coverage)" %in% input$scenarioInput) & ("Case management - severe" %in% input$varType)) {
  #   cm_map<- reactive({
  #     cm  = severe_cm[which(severe_cm$scenario ==input$scenarioInput), ]
  #     cm_df <- merge(LGAsf, cm , by="LGA", all.x =TRUE)
  #     cm_df$year = input$yearInput
  #     cm_map = generateMap(cm_df, quo(severe_cases))
  #   })
  # 
  #   return(cm_map())}
  # 
  # 
  # if(("Scenario 4 (Improved coverage)" %in% input$scenarioInput) & ("Case management - severe" %in% input$varType)) {
  #   cm_map<- reactive({
  #     cm  = severe_cm[which(severe_cm$scenario ==input$scenarioInput), ]
  #     cm_df <- merge(LGAsf, cm , by="LGA", all.x =TRUE)
  #     cm_df$year = input$yearInput
  #     cm_map = generateMap(cm_df, quo(severe_cases))
  #   })
  #   return(cm_map())}
  # 
  # 
  # if(("Scenario 5 (Improved coverage)" %in% input$scenarioInput) & ("Case management - severe" %in% input$varType)) {
  #   cm_map<- reactive({
  #     cm  = severe_cm[which(severe_cm$scenario ==input$scenarioInput), ]
  #     cm_df <- merge(LGAsf, cm , by="LGA", all.x =TRUE)
  #     cm_df$year = input$yearInput
  #     cm_map = generateMap(cm_df, quo(severe_cases))
  #   })
  #   return(cm_map())}
  # 
  # 
  # if(("Scenario 6 (Considered for funding in the NSP)" %in% input$scenarioInput) & ("Case management - severe" %in% input$varType)) {
  # 
  #   cm_map<- reactive({
  #     cm  = severe_cm[which(severe_cm$scenario ==input$scenarioInput & year == input$yearInput), ]
  #     cm_df <- merge(LGAsf, cm , by="LGA", all.x =TRUE)
  #     cm_df$year = input$yearInput
  #     cm_map = generateMap(cm_df, quo(severe_cases))
  #   })
  #   return(cm_map())}
  # 
  # 
  # if(("Scenario 7 (Considered for funding in the NSP)" %in% input$scenarioInput) & ("Case management - severe" %in% input$varType)) {
  #   cm_map<- reactive({
  #     cm  = severe_cm[which(severe_cm$scenario ==input$scenarioInput& year == input$yearInput), ]
  #     cm_df <- merge(LGAsf, cm , by="LGA", all.x =TRUE)
  #     cm_df$year = input$yearInput
  #     cm_map = generateMap(cm_df, quo(severe_cases))
  #   })
  #   return(cm_map())}

  
  
  #--------------------------------------------------------  
  ### ITN kill rate 
  #--------------------------------------------------------
  # code is really similar, can likely be simplified greatly 
  if("Insecticide treated net kill rate" %in% input$varType){
      kill_map<- reactive({
        
        filename = paste0("kill_grid_scenario", substr(input$scenarioInput, 10, 10), "_", as.character(input$yearInput))
        #browser()
        kill_grid=readRDS(file = paste0("data/kill_rate_map_grids/", filename, ".rds"))
        
      })
      #browser()
      return(kill_map())
  }
  # 
  # 
  # if(("Insecticide treated net kill rate" %in% input$varType) &  ("Scenario 1 (Business as Usual)" %in% input$scenarioInput))
  # {
  #   kill_map<- reactive({
  #     filename = paste0("kill_grid_scenario1_", as.character(input$yearInput))
  #     #browser()
  #     kill_grid=readRDS(file = paste0("data/kill_rate_map_grids/", filename, ".rds"))
  #     
  #   })
  #   #browser()
  #   return(kill_map())
  #   
  # } 
  # 
  # 
  # 
  # if(("Insecticide treated net kill rate" %in% input$varType) &  ("Scenario 2 (High effective coverage)" %in% input$scenarioInput))
  #     {
  #   kill_map<- reactive({
  #   filename = paste0("kill_grid_scenario2_", as.character(input$yearInput))
  #   #browser()
  #   kill_grid=readRDS(file = paste0("data/kill_rate_map_grids/", filename, ".rds"))
  #   
  #   })
  #   #browser()
  #   return(kill_map())
  #   
  # } 
  # 
  # 
  # if(("Insecticide treated net kill rate" %in% input$varType) &  ("Scenario 3 (Improved coverage)"  %in% input$scenarioInput))
  # {
  #   kill_map<- reactive({
  #     filename = paste0("kill_grid_scenario3_", as.character(input$yearInput))
  #     #browser()
  #     kill_grid=readRDS(file = paste0("data/kill_rate_map_grids/", filename, ".rds"))
  #     
  #   })
  #   return(kill_map())
  #   
  # } 
  # 
  # 
  # 
  # if(("Insecticide treated net kill rate" %in% input$varType) &  ("Scenario 4 (Improved coverage)"  %in% input$scenarioInput))
  # {
  #   kill_map<- reactive({
  #     filename = paste0("kill_grid_scenario4_", as.character(input$yearInput))
  #     #browser()
  #     kill_grid=readRDS(file = paste0("data/kill_rate_map_grids/", filename, ".rds"))
  #     
  #   })
  #   return(kill_map())
  #   
  # } 
  # 
  # 
  # if(("Insecticide treated net kill rate" %in% input$varType) &  ("Scenario 4 (Improved coverage)"  %in% input$scenarioInput))
  # {
  #   kill_map<- reactive({
  #     filename = paste0("kill_grid_scenario4_", as.character(input$yearInput))
  #     #browser()
  #     kill_grid=readRDS(file = paste0("data/kill_rate_map_grids/", filename, ".rds"))
  #     
  #   })
  #   return(kill_map())
  #   
  # }
  # 
  # 
  # 
  # if(("Insecticide treated net kill rate" %in% input$varType) &  ("Scenario 5 (Improved coverage)"  %in% input$scenarioInput))
  # {
  #   kill_map<- reactive({
  #     filename = paste0("kill_grid_scenario5_", as.character(input$yearInput))
  #     #browser()
  #     kill_grid=readRDS(file = paste0("data/kill_rate_map_grids/", filename, ".rds"))
  #     
  #   })
  #   return(kill_map())
  #   
  # }
  # 
  # 
  # if(("Insecticide treated net kill rate" %in% input$varType) &  ("Scenario 6 (Considered for funding in the NSP)" %in% input$scenarioInput))
  # {
  #   kill_map<- reactive({
  #     filename = paste0("kill_grid_scenario6_", as.character(input$yearInput))
  #     #browser()
  #     kill_grid=readRDS(file = paste0("data/kill_rate_map_grids/", filename, ".rds"))
  #     
  #   })
  #   return(kill_map())
  #   
  # }
  # 
  # 
  # 
  # if(("Insecticide treated net kill rate" %in% input$varType) &  ("Scenario 7 (Considered for funding in the NSP)" %in% input$scenarioInput))
  # {
  #   kill_map<- reactive({
  #     filename = paste0("kill_grid_scenario6_", as.character(input$yearInput))
  #     #browser()
  #     kill_grid=readRDS(file = paste0("data/kill_rate_map_grids/", filename, ".rds"))
  #     
  #   })
  #   return(kill_map())
  #   
  # }
  # 
  
  #--------------------------------------------------------  
  ### ITN coverage
  #--------------------------------------------------------
  browser()
  if(("Insecticide treated net coverage" %in% input$varType) &  ("> 5 years" %in% input$ITN_age))
  {
    ITN_map<- reactive({
      filename = paste0(input$scenarioInput,  "_",  as.character(input$yearInput))
      RDS_file_path <- file.path(data_dir, "ITN_map_grid", "u5_scenario", filename)
      kill_grid=readRDS(file = paste0(RDS_file_path, ".rds"))
      
    })
    return(ITN_map())
    
  }
  
  
  
  
})


#--------------------------------------------------------  
###title and footnote generation script  
#--------------------------------------------------------
title <- eventReactive(input$submit_loc,{
  
  #case management 
  if("Case management - uncomplicated" %in% input$varType){
    footnote_cm <- 'The Demographic and Health surveys were used to parameterize CM coverage at baseline. \n
                  The same coverage levels were used for both adults and children'
  }
  
  
  if(("Case management - uncomplicated" %in% input$varType)) {
    cm_titles<-reactive({
    cm_titles <-title_function("Case Management (CM) Coverage", input$scenarioInput, footnote_cm)
    })
    return(cm_titles())} 
  
  # if(("Scenario 2 (High effective coverage)" %in% input$scenarioInput) & ("Case management - uncomplicated" %in% input$varType)){
  #   cm_titles <-reactive({title_function("Case Management (CM) Coverage", "Scenario 2 (National strategic plan with high effective coverage)", footnote_cm)
  #   })
  #   return(cm_titles())}
  # 
  # if(("Scenario 3 (Improved coverage)" %in% input$scenarioInput) & ("Case management - uncomplicated" %in% input$varType)) {
  #    cm_titles <-reactive({title_function("Case Management (CM) Coverage", "Scenario 3 (National strategic plan with Improved coverage)", footnote_cm)
  #     })
  #    return(cm_titles())} 
  # 
  # 
  #  if(("Scenario 4 (Improved coverage)" %in% input$scenarioInput) & ("Case management - uncomplicated" %in% input$varType)) {
  #    cm_titles <-reactive({title_function("Case Management (CM) Coverage", "Scenario 4 (National strategic plan with Improved coverage)", footnote_cm)
  #    })
  #   return(cm_titles())}
  #   
  #   if(("Scenario 5 (Improved coverage)" %in% input$scenarioInput) & ("Case management - uncomplicated" %in% input$varType)) {
  #     cm_titles <-reactive({title_function("Case Management (CM) Coverage", "Scenario 5 (National strategic plan with Improved coverage)", footnote_cm)
  #     })
  #     return(cm_titles())}
  # 
  # 
  #  if(("Scenario 6 (Considered for funding in the NSP)" %in% input$scenarioInput) & ("Case management - uncomplicated" %in% input$varType)) {
  #   cm_titles <-reactive({title_function("Case Management (CM) Coverage", "Scenario 6 (Prioritized plans submitted to the Global Fund)", footnote_cm)
  #    })
  #    return(cm_titles())}
  # 
  #  if(("Scenario 7 (Considered for funding in the NSP)" %in% input$scenarioInput) & ("Case management - uncomplicated" %in% input$varType)) {
  #    cm_titles <-reactive({title_function("Case Management (CM) Coverage", "Scenario 7 (Prioritized plans submitted to the Global Fund)", footnote_cm)
  #    })
  #    return(cm_titles())}
  # 
  
  
  
  
  
  
  
  #severe case management 
  if(("Case management - severe" %in% input$varType)) {
    cm_titles<-reactive({
      cm_titles <-title_function("Severe Case Management (CM) Coverage", input$scenarioInput, 'Severe case management at baseline was estimated based on literature and expert opinion')
    })
    return(cm_titles())} 
  
  
  # if(("Scenario 2 (High effective coverage)" %in% input$scenarioInput) & ("Case management - severe" %in% input$varType)) {
  #   cm_titles<-reactive({
  #     cm_titles <-title_function(" Severe Case Management (CM) Coverage", "Scenario 2 (National strategic plan with high effective coverage)", 'Severe case management at baseline was estimated based on literature and expert opinion')
  #   })
  #   return(cm_titles())} 
  # 
  # 
  # if(("Scenario 3 (Improved coverage)" %in% input$scenarioInput) & ("Case management - severe" %in% input$varType)) {
  #   cm_titles <-reactive({title_function("Case Management (CM) Coverage", "Scenario 3 (National strategic plan with Improved coverage)", 'Severe case management at baseline was estimated based on literature and expert opinion')
  #   })
  #   return(cm_titles())} 
  # 
  # 
  # if(("Scenario 4 (Improved coverage)" %in% input$scenarioInput) & ("Case management - severe" %in% input$varType)) {
  #   cm_titles <-reactive({title_function("Case Management (CM) Coverage", "Scenario 4 (National strategic plan with Improved coverage)", 'Severe case management at baseline was estimated based on literature and expert opinion')
  #   })
  #   return(cm_titles())}
  # 
  # if(("Scenario 5 (Improved coverage)" %in% input$scenarioInput) & ("Case management - severe" %in% input$varType)) {
  #   cm_titles <-reactive({title_function("Case Management (CM) Coverage", "Scenario 5 (National strategic plan with Improved coverage)", 'Severe case management at baseline was estimated based on literature and expert opinion')
  #   })
  #   return(cm_titles())}
  # 
  # 
  # if(("Scenario 6 (Considered for funding in the NSP)" %in% input$scenarioInput) & ("Case management - severe" %in% input$varType)) {
  #   cm_titles <-reactive({title_function("Case Management (CM) Coverage", "Scenario 6 (Prioritized plans submitted to the Global Fund)", 'Severe case management at baseline was estimated based on literature and expert opinion')
  #   })
  #   return(cm_titles())}
  # 
  # if(("Scenario 7 (Considered for funding in the NSP)" %in% input$scenarioInput) & ("Case management - severe" %in% input$varType)) {
  #   cm_titles <-reactive({title_function("Case Management (CM) Coverage", "Scenario 7 (Prioritized plans submitted to the Global Fund)",  'Severe case management at baseline was estimated based on literature and expert opinion')
  #   })
  #   return(cm_titles())}
  # 
  
  
  
  
  
  
  
  
  
  #ITN kill rate  
  if("Insecticide treated net kill rate" %in% input$varType){
    footnote_itn <- "Kill rates were parameterized by constructing a relationship between mosquito mortality\n
                   in a bioassay and ITN kill rates in EMOD. ITNs will not be distributed in areas shaded in grey"
  }
  
  
  if(("Insecticide treated net kill rate" %in% input$varType)) {
    itn_titles<-reactive({
      itn_titles <-title_function("Insecticide Treated Net (ITN) Kill Rates", input$scenarioInput, footnote_itn)
    })
    return(itn_titles())} 
  
  
  
  #ITN coverage   
  if("Insecticide treated net coverage" %in% input$varType){
    footnote_itn <- "The Demographic and Health surveys were used to parameterize age-specific\n
                   ITN coverage. ITNs will not be distributed in areas shaded in grey"
  }
  
  
  if(("Insecticide treated net coverage" %in% input$varType)) {
    itn_titles<-reactive({
     itn_titles <-title_function(paste0("Insecticide Treated Net (ITN) Coverage", ",", input$ITN_age), input$scenarioInput, footnote_itn)
    })
    return(itn_titles())} 
  
  
  
})


#--------------------------------------------------------  
###final map, title and footnote generation script  
#--------------------------------------------------------
output$modelPlot <-ggiraph::renderggiraph({
  ggiraph::girafe(ggobj = cowplot::plot_grid(title()[[1]], title()[[2]], data(), title()[[3]], ncol = 1, 
                                             rel_heights = c(0.1, 0.1, 1, 0.3)), width_svg = 8, height_svg = 4, 
                  options = list(ggiraph::opts_zoom(max = 5)))

})

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

# Create button for downloading CSV; displayed only when submit button is clicked 
# is computed
output$downloadUI <- shiny::renderUI({
req(data())
do.call(shiny::downloadButton, list('downloadCSV', 'Download model input as CSV'))
})

output$downloadCSV <- shiny::downloadHandler(
filename = 'model_input.csv',
content = function(file) {
outputData <- data() %>%  dplyr::distinct(LGA, State.x, U5_coverage, Rep_DS, year, scenario) %>% dplyr::select(State = State.x, LGA, `Epidemiological Archetype` = Rep_DS, 
                                                                                                               `case management coverage (U5 or adults) ` =U5_coverage, 
                                                                                                               year, scenario) 
write.csv(outputData, file, row.names = FALSE)
}
)



# case_param<-shiny::reactive({(cm_scen1_df)})
# 
# 
# # case_param<-shiny::reactive({
# # 
# #   if ("Scenario 1 (Business as Usual)" %in% input$scenarioInput)
# #   return(cm_scen1_df)})
# 
# #join case_param to map and plot 
# 
# # plotData <- shiny::reactive({
# #   
# # })
# # 
# # output$modelPlot <- 
# 
# # Server functionality
# # inputParams <- shiny::reactive({
# # 	# Validate input
# # 	shiny::validate(
# # 		shiny::need(
# # 			input$scenarioInput != case_management$scenario, 
# # 			'Scenarios are not same in the option box and data'
# # 		),
# # 		shiny::need(
# # 			input$dur_incubation > input$dur_latent,
# # 			'Duration of incubation period must be greater than duration of latent period!'
# # 		)
# # 	)
# # 	setupParams(input)
# # })
# # modelOut <- shiny::reactive({runSimulation(inputParams())})
# # plotData <- shiny::reactive({generatePlotData(input, modelOut())})
# output$modelPlot <- plotly::renderPlotly(generateModelPlot(case_param(), ~U5_coverage))
# 
# # Create button for downloading CSV; displayed only when plotData
# # is computed
# # output$downloadUI <- shiny::renderUI({
# # 	req(plotData())
# # 	do.call(shiny::downloadButton, list('downloadCSV', 'Download model output as CSV'))
# # })
# # 
# # output$downloadCSV <- shiny::downloadHandler(
# # 	filename = 'model_results.csv',
# # 	content = function(file) {
# # 		outputData <- plotData() %>% rename(!!! swap_kv(OUTPUT_COLUMN_DESCRIPTIONS))
# # 		write.csv(outputData, file, row.names = FALSE)
# # 	}
# # )