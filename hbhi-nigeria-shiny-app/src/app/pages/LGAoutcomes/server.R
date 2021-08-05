##-----------------------------
## LGAoutcomes/server.R
##------------------------------


import::from('./ui_selection_data.R', admin)
import::from(ggplot2, theme, element_text, element_blank)
import::from(dplyr, mutate, '%>%')
import::from(stringr, str_wrap)

#Load admin unit description and names 
updateSelectInput(session, "admin_name", choices = admin[admin$admin==input$adminInput, "name"])


#--------------------------------------------------------  
###plot generation script  
#--------------------------------------------------------
proj <- eventReactive(input$submit_proj,{
  data <- "../../data"
  
  
  #--------------------------------------------------------  
  ### Prevalence 
  #--------------------------------------------------------
  
  if(("Trends" %in% input$statistic)) {
    plot<- reactive({
      #browser()
        plot=readRDS(file = paste0(data, "/Trends/",  input$Indicator, '_', input$adminInput, ".rds"))
        plot = plot + theme(legend.position = c(legend.position = c(0.23, 0.35)))
    })
    
    return(plot())
    
}
  
  
  
  if(("Relative change in 2025 compared to BAU in 2020" %in% input$statistic)) {
    plot<- reactive({
      #browser()
      plot=readRDS(file = paste0(data, "/Relative_change_2025/",  input$Indicator, '_', input$adminInput, ".rds"))
    })
    
    return(plot())
    
  }
  
  
  if(("Relative change in 2030 compared to BAU in 2020" %in% input$statistic)) {
    plot<- reactive({
      #browser()
      plot=readRDS(file = paste0(data, "/Relative_change_2030/",  input$Indicator, '_', input$adminInput, ".rds"))
    })
    
    return(plot())
    
  }
  
<<<<<<< HEAD
  
  if(("Relative change in 2025 compared to 2015 modeled estimate" %in% input$statistic)) {
    plot<- reactive({
      #browser()
      plot=readRDS(file = paste0(data, "/Relative_change_2025_2015_base/",  input$Indicator, '_', input$adminInput, ".rds"))
    })
    
    return(plot())
    
  }
  
  
  if(("Relative change in 2030 compared to 2015 modeled estimate" %in% input$statistic)) {
    plot<- reactive({
      #browser()
      plot=readRDS(file = paste0(data, "/Relative_change_2030_2015_base/",  input$Indicator, '_', input$adminInput, ".rds"))
    })
    
    return(plot())
    
  }
  
=======
>>>>>>> dffaf7d3b0f8681f63352613f2b36e07c8384abe
})


#--------------------------------------------------------  
###final plot, title and footnote generation script  
#--------------------------------------------------------
output$projections <-ggiraph::renderggiraph({
  
  ggiraph::girafe(code = print(proj()), width_svg = 9.5, height_svg = 4)
  
})

#----------------------------------
#download button for all ages
#----------------------------------

#Create button for downloading CSV; displayed only when submit button is clicked is computed
output$projdownUI <- shiny::renderUI({
  req(proj())
  do.call(shiny::downloadButton, list('downloadCSV_proj', 'Download all age projections as CSV'))
})

output$downloadCSV_proj <- shiny::downloadHandler(
  filename = paste0('all_age_projections_', input$adminInput,'_', input$Indicator, '_',input$statistic, '.csv'),
  content = function(file) {
    outputData <- proj()$data %>% dplyr::mutate(scenario = ifelse(scenario == 'NGA projection scenario 0', 'NGA historical projections', scenario))
    write.csv(outputData, file, row.names = FALSE)
  }
)




#--------------------------------------------------------  
###plot generation script U5 
#--------------------------------------------------------
proj_u5 <- eventReactive(input$submit_proj,{
  data <- "../../data"
  
  
  #--------------------------------------------------------  
  ### Prevalence 
  #--------------------------------------------------------
  
  if(("Trends" %in% input$statistic)) {
    plot<- reactive({
      #browser()
      plot=readRDS(file = paste0(data, "/Trends/",  input$Indicator, '_', input$adminInput, '_U5', ".rds"))
      plot = plot + theme(legend.position = c(legend.position = c(0.23, 0.33))) +  theme(plot.title = element_blank())
      
    })
    
    return(plot())
    
  }
  
  
  if(("Relative change in 2025 compared to BAU in 2020" %in% input$statistic)) {
    plot<- reactive({
      #browser()
      plot=readRDS(file = paste0(data, "/Relative_change_2025/",  input$Indicator, '_', input$adminInput, '_U5', ".rds"))
    })
    
    return(plot())
    
  }
  
  
  if(("Relative change in 2030 compared to BAU in 2020" %in% input$statistic)) {
    plot<- reactive({
      #browser()
      plot=readRDS(file = paste0(data, "/Relative_change_2030/",  input$Indicator, '_', input$adminInput, '_U5', ".rds"))
    })
    
    return(plot())
    
  }
<<<<<<< HEAD
  
  if(("Relative change in 2025 compared to 2015 modeled estimate" %in% input$statistic)) {
    plot<- reactive({
      #browser()
      plot=readRDS(file = paste0(data, "/Relative_change_2025_2015_base/",  input$Indicator, '_', input$adminInput,  '_U5',  ".rds"))
    })
    
    return(plot())
    
  }
  
  
  if(("Relative change in 2030 compared to 2015 modeled estimate" %in% input$statistic)) {
    plot<- reactive({
      #browser()
      plot=readRDS(file = paste0(data, "/Relative_change_2030_2015_base/",  input$Indicator, '_', input$adminInput,   '_U5',  ".rds"))
    })
    
    return(plot())
    
  }
=======
>>>>>>> dffaf7d3b0f8681f63352613f2b36e07c8384abe
  
})



#--------------------------------------------------------  
###final plot, title and footnote generation script  
#--------------------------------------------------------
output$projections_u5 <-ggiraph::renderggiraph({
  
  ggiraph::girafe(code = print(proj_u5()), width_svg = 9.5, height_svg = 4)
})


#----------------------------------
#download button for U5
#----------------------------------

#Create button for downloading CSV; displayed only when submit button is clicked is computed
output$proj_u5_downUI <- shiny::renderUI({
  req(proj_u5())
  do.call(shiny::downloadButton, list('downloadCSV_proj_u5', 'Download U5 projections as CSV'))
})

output$downloadCSV_proj_u5 <- shiny::downloadHandler(
  filename = paste0('projections_u5_', input$adminInput,'_', input$Indicator, '_',input$statistic, 'csv'),
  content = function(file) {
    outputData <- proj_u5()$data %>% dplyr::mutate(scenario = ifelse(scenario == 'NGA projection scenario 0', 'NGA historical projections', scenario))
    write.csv(outputData, file, row.names = FALSE)
  }
)
