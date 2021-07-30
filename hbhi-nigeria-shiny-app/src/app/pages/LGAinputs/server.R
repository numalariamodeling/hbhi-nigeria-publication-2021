##-----------------------------
## LGAinputs/server.R
##------------------------------

import::here('./functions.R', generateMap)
import::here('./ui_selection_data.R', interventions)


import::from(dplyr, rename,case_when, left_join,  '%>%' )
import::from(cowplot, ggdraw, plot_grid)
import::from(ggplot2, theme, margin, element_text)
import::from(rlang, quo)
import::from(ggiraph, girafe_options)
library(patchwork)


observe({
  updateSelectInput(session, "ITN_age", choices = interventions[interventions$interventions==input$varType, "age_group"])
  updateSelectInput(session, "SMC_access_type", choices = interventions[interventions$interventions==input$varType, "SMC_access"])
})





#--------------------------------------------------------  
###Map generation script  
#--------------------------------------------------------
data <- eventReactive(input$submit_loc,{
  data <- "../../data"
  
  #--------------------------------------------------------  
  ### Case management 
  #--------------------------------------------------------
  
  if(("Case management - uncomplicated" %in% input$varType)) {
    map<- reactive({
      
      if (input$scenarioInput == "Scenario 1 (Business as Usual)"){
        map=readRDS(file = paste0(data, "/CM/", 'CM_', input$scenarioInput, ".rds"))
        map$data$year = input$yearInput
        
      } else if (input$scenarioInput == "Scenario 4 (Budget-prioritized plan)") {
        map=readRDS(file = paste0(data, "/CM/", 'CM_', 'Scenario 3 (Budget-prioritized plan)', '_', as.character(input$yearInput), ".rds"))
      
      }else  {
      map=readRDS(file = paste0(data, "/CM/", 'CM_', input$scenarioInput, '_', as.character(input$yearInput), ".rds"))
      }
      
      #browser()
      map = map + ggplot2::labs(title = paste0("Year:", " ", max(map$data$year, na.rm=T)))+
        theme(plot.title=element_text(size = 12, color = "black",  hjust=0.5), legend.key.size = ggplot2::unit(1, 'cm'), legend.text = element_text(size=12))

      
    })
    return(map())
  } 
  


  #--------------------------------------------------------  
  ### Severe case management 
  #--------------------------------------------------------

  if(("Case management - severe" %in% input$varType)) {
    map<- reactive({
      
      if (input$scenarioInput == "Scenario 1 (Business as Usual)"){
        map=readRDS(file = paste0(data, "/Severe_CM/", 'Severe_CM_', input$scenarioInput, ".rds"))
        map$data$year = input$yearInput
        
      } else if (input$scenarioInput == "Scenario 4 (Budget-prioritized plan)") {
        map=readRDS(file = paste0(data, "/Severe_CM/", 'Severe_CM_', 'Scenario 3 (Budget-prioritized plan)', '_', as.character(input$yearInput), ".rds"))
      }
      else  {
        map=readRDS(file = paste0(data, "/Severe_CM/", 'Severe_CM_', input$scenarioInput, '_', as.character(input$yearInput), ".rds"))
      }
      
      map = map + ggplot2::labs(title = paste0("Year:", " ", max(map$data$year, na.rm=T)))+
        theme(plot.title=element_text(size = 12, color = "black",  hjust=0.5), legend.key.size = ggplot2::unit(1, 'cm'), legend.text = element_text(size=12))
      
    })
    return(map())
    
  } 
  
  
  
  #--------------------------------------------------------  
  ### ITN kill rate 
  #--------------------------------------------------------
  
  if("Insecticide treated net kill rate" %in% input$varType){
      map<- reactive({
        
        if (input$scenarioInput == "Scenario 4 (Budget-prioritized plan)"){
          
        map=readRDS(file = paste0(data, "/ITN_kill_rate/", 'ITN_kill_rate_', 'Scenario 3 (Budget-prioritized plan)', '_', as.character(input$yearInput), ".rds"))
        
        }else{
          
          map=readRDS(file = paste0(data, "/ITN_kill_rate/",'ITN_kill_rate_',input$scenarioInput, '_', as.character(input$yearInput), ".rds"))
        }
        map = generateMap(map, quo(kill_rate), "kill rate")
        map = map + ggplot2::labs(title = paste0("Year:", " ", max(map$data$year, na.rm=T))) +
          theme(plot.title=element_text(size = 12, color = "black",  hjust=0.5), legend.key.size = ggplot2::unit(1, 'cm'), legend.text = element_text(size=12))
        
      })
      
      return(map())
  }

  
  #--------------------------------------------------------  
  ### ITN block rate 
  #--------------------------------------------------------
  
  if("Insecticide treated net blocking rate" %in% input$varType){
    map<- reactive({
      
      if (input$scenarioInput == "Scenario 4 (Budget-prioritized plan)"){
        
        map=readRDS(file = paste0(data, "/ITN_block_rate/", 'ITN_block_rate_', 'Scenario 3 (Budget-prioritized plan)', '_', as.character(input$yearInput), ".rds"))
        
      }else{
        
        map=readRDS(file = paste0(data, "/ITN_block_rate/", 'ITN_block_rate_',input$scenarioInput, '_', as.character(input$yearInput), ".rds"))
      }
       map = generateMap(map, quo(block_rate), "blocking rate")
      map = map + ggplot2::labs(title = paste0("Year:", " ", max(map$data$year, na.rm=T)))+
        theme(plot.title=element_text(size = 12, color = "black",  hjust=0.5), legend.key.size = ggplot2::unit(1, 'cm'), legend.text = element_text(size=12))
      
    })
    
    return(map())
  }
  

  
  #--------------------------------------------------------  
  ### ITN coverage
  #--------------------------------------------------------
  
  if("Insecticide treated net coverage" %in% input$varType){
    map<- reactive({
      
      if (input$scenarioInput == "Scenario 4 (Budget-prioritized plan)"){
        
        map=readRDS(file = paste0(data, "/ITN_coverage/", 'ITN_coverage_', input$ITN_age, '_','Scenario 3 (Budget-prioritized plan)', '_', as.character(input$yearInput), ".rds"))
        
      }else{
        
        map=readRDS(file = paste0(data, "/ITN_coverage/", 'ITN_coverage_',input$ITN_age, '_',input$scenarioInput, '_', as.character(input$yearInput), ".rds"))
      }
      map = generateMap(map, quo(ITN_use), "ITN use")
      map = map + ggplot2::labs(title = paste0("Year:", " ", max(map$data$year, na.rm=T)))+
        theme(plot.title=element_text(size = 12, color = "black",  hjust=0.5), legend.key.size = ggplot2::unit(1, 'cm'), legend.text = element_text(size=12))
      
    })
    
    return(map())
  }
  
 
  #--------------------------------------------------------  
  ### SMC
  #-------------------------------------------------------- 
  
  if("Seasonal malaria chemoprevention" %in% input$varType){
    map<- reactive({
      
      if (input$scenarioInput == "Scenario 4 (Budget-prioritized plan)"){
        
        map=readRDS(file = paste0(data, "/ITN_coverage/", 'ITN_coverage_', input$ITN_age, '_','Scenario 3 (Budget-prioritized plan)', '_', as.character(input$yearInput), ".rds"))
        
      }else{
        map=readRDS(file = paste0(data, "/SMC/", 'SMC_',input$SMC_access_type, '_',input$scenarioInput, '_', as.character(input$yearInput), ".rds"))
      }
      
      
    })
    
    return(map())
  }
  
  

  
  
  
  
})


#--------------------------------------------------------  
###title and footnote generation script  
#--------------------------------------------------------
title <- eventReactive(input$submit_loc,{


  if(("Case management - uncomplicated" %in% input$varType)) {
    titles<-reactive({
      titles <-list(title = "Case Management (CM) Coverage", subtitle = input$scenarioInput, caption =
                         'The Demographic and Health surveys were used to parameterize CM coverage at baseline. The same
                           coverage levels were used for both adults and children. Values are percentages.')
    })
    return(titles())}

  
  if(("Case management - severe" %in% input$varType)) {
    titles<-reactive({
      titles <-list(title = "Severe Case Management (CM) Coverage", subtitle = input$scenarioInput, caption =
                         'Severe case management at baseline was estimated based on literature and expert opinion.')
    })
    return(titles())}


  if(("Insecticide treated net kill rate" %in% input$varType)) {
    titles<-reactive({
      titles <-list(title = "Insecticide Treated Net (ITN) Kill Rates", subtitle = input$scenarioInput, caption =
                      "Kill rates were parameterized by constructing a relationship between mosquito mortality\n
                   in a bioassay and ITN kill rates in EMOD. ITNs will not be distributed in areas shaded in grey.
                    Values are percentages.")
    })
    return(titles())}


  if(("Insecticide treated net blocking rate" %in% input$varType)) {
    titles<-reactive({
      titles <-list(title = "Insecticide Treated Net (ITN) Blocking Rates", subtitle = input$scenarioInput, caption =
                      "Blocking rates were parameterized based on a literature review. \n
    ITNs will not be distributed in areas shaded in grey. Values are percentages.")
    })
    return(titles())}



  if(("Insecticide treated net coverage" %in% input$varType)) {
    titles<-reactive({
    titles <-list(title = "Insecticide Treated Net (ITN) Coverage", subtitle = input$scenarioInput, caption =
                    "The Demographic and Health surveys were used to parameterize age-specific
                   ITN coverage. ITNs will not be distributed in areas shaded in grey. \nValues are percentages.")
    })
    return(titles())}



})


#--------------------------------------------------------  
###final map, title and footnote generation script  
#--------------------------------------------------------
output$modelPlot <-ggiraph::renderggiraph({
  
  ggiraph::girafe(code = print(data() + plot_annotation(title = title()[[1]], theme = theme(plot.title = element_text(face = 'bold', hjust = 0.5, size = 14), 
                                                                                            plot.subtitle = element_text(hjust = 0.5, size = 13)),
                                                              subtitle = title()[[2]],
                                                              caption = title()[[3]])), width_svg = 10, height_svg = 7)

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


