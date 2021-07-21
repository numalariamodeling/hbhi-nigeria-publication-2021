##-----------------------------
## LGAinputs/server.R
##------------------------------

import::here('./functions.R', LGAsf, LGA_list, generateMap, title_function)
import::here('./ui_selection_data.R', interventions)


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
  Drive <- file.path(gsub("[\\]", "/", gsub("Documents", "", Sys.getenv("HOME"))))
  repo <- file.path(Drive, 'Documents', 'hbhi-nigeria-publication-2021', 'hbhi-nigeria-shiny-app', 'data')
  
  
  #--------------------------------------------------------  
  ### Case management 
  #--------------------------------------------------------
  
  if(("Case management - uncomplicated" %in% input$varType)) {
    cm_map<- reactive({
      
      if (input$scenarioInput == "Scenario 1 (Business as Usual)"){
        cm_map=readRDS(file = paste0(repo, "/CM/", 'CM_', input$scenarioInput, ".rds"))
        cm_map$data$year = input$yearInput
        
      } else if (input$scenarioInput == "Scenario 4 (Budget-prioritized plan)") {
        cm_map=readRDS(file = paste0(repo, "/CM/", 'CM_', 'Scenario 3 (Budget-prioritized plan)', '_', as.character(input$yearInput), ".rds"))
      
      }else  {
      cm_map=readRDS(file = paste0(repo, "/CM/", 'CM_', input$scenarioInput, '_', as.character(input$yearInput), ".rds"))
      }
      
      cm_map = cm_map + ggplot2::labs(title = paste0("Simday:", " ", max(cm_map$data$simday, na.rm = T), ", Year:", " ", max(cm_map$data$year, na.rm=T)))
      
    })
    return(cm_map())
  } 
  


  #--------------------------------------------------------  
  ### Severe case management 
  #--------------------------------------------------------

  if(("Case management - severe" %in% input$varType)) {
    cm_map<- reactive({
      
      if (input$scenarioInput == "Scenario 1 (Business as Usual)"){
        cm_map=readRDS(file = paste0(repo, "/Severe_CM/", 'Severe_CM_', input$scenarioInput, ".rds"))
        cm_map$data$year = input$yearInput
        
      } else if (input$scenarioInput == "Scenario 4 (Budget-prioritized plan)") {
        cm_map=readRDS(file = paste0(repo, "/Severe_CM/", 'Severe_CM_', 'Scenario 3 (Budget-prioritized plan)', '_', as.character(input$yearInput), ".rds"))
      }
      else  {
        cm_map=readRDS(file = paste0(repo, "/Severe_CM/", 'Severe_CM_', input$scenarioInput, '_', as.character(input$yearInput), ".rds"))
      }
      
      cm_map = cm_map + ggplot2::labs(title = paste0("Simday:", " ", max(cm_map$data$simday, na.rm = T), ", Year:", " ", max(cm_map$data$year, na.rm=T)))
      
    })
    return(cm_map())
    
  } 
  
  
  
  #--------------------------------------------------------  
  ### ITN kill rate 
  #--------------------------------------------------------
  
  if("Insecticide treated net kill rate" %in% input$varType){
      kill_map<- reactive({
        
        if (input$scenarioInput == "Scenario 4 (Budget-prioritized plan)"){
          
        kill_map=readRDS(file = paste0(repo, "/ITN_kill_rate/", 'ITN_kill_rate_', 'Scenario 3 (Budget-prioritized plan)', '_', as.character(input$yearInput), ".rds"))
        
        }else{
          
          kill_map=readRDS(file = paste0(repo, "/ITN_kill_rate/", 'ITN_kill_rate_', input$scenarioInput, '_', as.character(input$yearInput), ".rds"))
        }
        kill_map = generateMap(kill_map, quo(kill_rate), "kill rate")
        kill_map = kill_map + ggplot2::labs(title = paste0("Simdays:", " ", min(kill_map$data$simday, na.rm = T), "-", max(kill_map$data$simday, na.rm = T),   ", Year:", " ", max(kill_map$data$year, na.rm=T)))
        
      })
      
      return(kill_map())
  }


  
  #--------------------------------------------------------  
  ### ITN coverage
  #--------------------------------------------------------
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


  
  
  
  
  
  
  
  #severe case management 
  if(("Case management - severe" %in% input$varType)) {
    cm_titles<-reactive({
      cm_titles <-title_function("Severe Case Management (CM) Coverage", input$scenarioInput, 'Severe case management at baseline was estimated based on literature and expert opinion')
    })
    return(cm_titles())} 
  
  
 
  
  
  
  
  
  
  
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



# Create button for downloading CSV; displayed only when submit button is clicked 
# is computed
output$downloadUI <- shiny::renderUI({
req(data())
do.call(shiny::downloadButton, list('downloadCSV', 'Download model input as CSV'))
})

output$downloadCSV <- shiny::downloadHandler(
filename = 'model_input.csv',
content = function(file) {
outputData <- data()$data %>%  sf::st_drop_geometry()
write.csv(outputData, file, row.names = FALSE)
}
)


