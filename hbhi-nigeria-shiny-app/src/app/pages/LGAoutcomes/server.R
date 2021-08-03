##-----------------------------
## LGAoutcomes/server.R
##------------------------------


import::from('./functions.R', admin)
import::from(ggplot2, theme, element_text)

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
        plot=readRDS(file = paste0(data, "/Prevalence/",  input$Indicator, '_', input$adminInput, ".rds"))
        plot = plot + theme(legend.position = c(legend.position = c(0.28, 0.3)))
    })
    
    return(plot())
    
}
  
  
  
})




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



#--------------------------------------------------------  
###final plot, title and footnote generation script  
#--------------------------------------------------------
output$projections <-ggiraph::renderggiraph({
  
  ggiraph::girafe(code = print(proj()), width_svg = 9, height_svg = 5)
  
})



# Create button for downloading CSV; displayed only when submit button is clicked 
# is computed
# output$projdownUI <- shiny::renderUI({
#   req(data())
#   do.call(shiny::downloadButton, list('downloadCSV', 'Download model input as CSV'))
# })
# 
# output$downloadCSV <- shiny::downloadHandler(
#   filename = 'model_input.csv',
#   content = function(file) {
#     outputData <- data()$data %>%  sf::st_drop_geometry()
#     write.csv(outputData, file, row.names = FALSE)
#   }
# )




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
      plot=readRDS(file = paste0(data, "/Prevalence/",  input$Indicator, '_', input$adminInput, ".rds"))
      plot = plot + theme(legend.position = c(legend.position = c(0.28, 0.3)), plot.title = element_blank())
      
    })
    
    return(plot())
    
  }
  
  
  
})



#--------------------------------------------------------  
###final plot, title and footnote generation script  
#--------------------------------------------------------
output$projections_u5 <-ggiraph::renderggiraph({
  
  ggiraph::girafe(code = print(proj()), width_svg = 9, height_svg = 5)
})
