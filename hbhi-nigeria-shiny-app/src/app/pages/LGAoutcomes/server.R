##-----------------------------
## LGAoutcomes/server.R
##------------------------------


import::from('./ui_selection_data.R', admin)
import::from('./functions.R', generateLine, statesf)
import::from(ggplot2, theme, element_text, element_blank, element_line, element_blank, element_rect, unit, scale_y_continuous,
             margin, labs)
import::from(dplyr, mutate, '%>%')
import::from(stringr, str_wrap)
import::from(patchwork, plot_layout)

#Load admin unit description and names 
updateSelectInput(session, "admin_name", choices = admin[admin$admin==input$adminInput, "name"])


#--------------------------------------------------------  
###plot generation script  
#--------------------------------------------------------
proj <- eventReactive(input$submit_proj,{
  data <- "../../data"
  repo<- "../../../"
  inputs <- file.path(repo, 'simulation_outputs', 'indicators_noGTS_data')
  
  #--------------------------------------------------------  
  ### indicators 
  #--------------------------------------------------------
  
  if("Trends" %in% input$statistic) {
    plot<- reactive({
      
      if(input$adminInput == 'National'){
      #browser()
        plot=readRDS(file = paste0(data, "/Trends/",  input$Indicator, '_', input$adminInput, ".rds"))
        plot = plot + theme(legend.position = c(legend.position = c(0.23, 0.35))) +
          labs(title=paste0('Projected annual trends in all ages malaria ', tolower(input$Indicator), ', Nigeria'))
        
        }else if(input$adminInput == 'State'){
          #browser()
          line_df =data.table::fread(file.path(inputs, 'indicators_noGTS_state_new.csv')) 
          line_df = line_df[which(line_df$trend == input$Indicator & line_df$State == input$admin_name & line_df$age == 'all_ages'), ]
          plot=generateLine(line_df, line_df$count, paste0("all age ", tolower(input$Indicator), ', ', 'annual average'), title=paste0('Projected trends in all age malaria ', tolower(input$Indicator), ", ", input$admin_name), pin = pretty(line_df$count), limits = c(range(pretty(line_df$count))))
          plot = plot + theme(legend.position = c(legend.position = c(0.25, 0.25)))
          map = statesf%>% mutate(interest = ifelse(NAME_1 == input$admin_name, input$admin_name, NA))
          map = ggplot2::ggplot(map)+
            ggiraph::geom_sf_interactive(ggplot2::aes(fill = interest, tooltip = interest), color = 'white', size = 0.2)+
            ggplot2::theme(axis.text.x = ggplot2::element_blank(),
                           axis.text.y = ggplot2::element_blank(),
                           axis.ticks = ggplot2::element_blank(),
                           rect = ggplot2::element_blank(),
                           plot.background = ggplot2::element_rect(fill = "white", colour = NA),
                           legend.position = 'none')+
            ggplot2::scale_fill_manual(values = c('blue'),na.value = "lightgrey")
          plot = map + plot +  plot_layout(widths = c(0.5, 2))
          
          
        }else{
          plot=readRDS(file = paste0(data, "/Trends/",  input$Indicator, '_', input$adminInput, ".rds"))
          plot = plot + theme(legend.position = c(legend.position = c(0.23, 0.35)))
        }
    })
    
    return(plot())
    
}
  
  
  
  if(("Relative change in 2025 compared to BAU in 2020" %in% input$statistic)) {
    plot<- reactive({
      #browser()
      plot=readRDS(file = paste0(data, "/Relative_change_2025_2020_base/",  input$Indicator, '_', input$adminInput, ".rds"))
    })
    
    return(plot())
    
  }
  
  
  if(("Relative change in 2030 compared to BAU in 2020" %in% input$statistic)) {
    plot<- reactive({
      #browser()
      plot=readRDS(file = paste0(data, "/Relative_change_2030_2020_base/",  input$Indicator, '_', input$adminInput, ".rds"))
    })
    
    return(plot())
    
  }
  
  
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
  repo<- "../../../"
  inputs <- file.path(repo, 'simulation_outputs', 'indicators_noGTS_data')
  
  
  #--------------------------------------------------------  
  ### Prevalence 
  #--------------------------------------------------------
  
  if(("Trends" %in% input$statistic)) {
    plot<- reactive({
      if(input$adminInput == 'National'){
      #browser()
      plot=readRDS(file = paste0(data, "/Trends/",  input$Indicator, '_', input$adminInput, '_U5', ".rds"))
      plot = plot + theme(legend.position = c(legend.position = c(0.23, 0.33))) + 
        labs(title=paste0('Projected annual trends in U5 malaria ', tolower(input$Indicator), ', Nigeria'))
      
      
    }else if(input$adminInput == 'State'){
      
      #browser()
      line_df =data.table::fread(file.path(inputs, 'indicators_noGTS_state_new.csv')) 
      line_df = line_df[which(line_df$trend == input$Indicator & line_df$State == input$admin_name & line_df$age == 'U5'), ]
      plot=generateLine(line_df, line_df$count, paste0("U5 ", tolower(input$Indicator), ', ', 'annual average'), title=paste0('Projected trends in U5 malaria ', tolower(input$Indicator), ", ", input$admin_name), pin = pretty(line_df$count), limits = c(range(pretty(line_df$count))))
      plot = plot + theme(legend.position = c(legend.position = c(0.25, 0.25)))
      map = statesf%>% mutate(interest = ifelse(NAME_1 == input$admin_name, input$admin_name, NA))
      map = ggplot2::ggplot(map)+
        ggiraph::geom_sf_interactive(ggplot2::aes(fill = interest, tooltip = interest), color = 'white', size = 0.2)+
        ggplot2::theme(axis.text.x = ggplot2::element_blank(),
                       axis.text.y = ggplot2::element_blank(),
                       axis.ticks = ggplot2::element_blank(),
                       rect = ggplot2::element_blank(),
                       plot.background = ggplot2::element_rect(fill = "white", colour = NA),
                       legend.position = 'none')+
        ggplot2::scale_fill_manual(values = c('blue'),na.value = "lightgrey")
      plot = map + plot +  plot_layout(widths = c(0.5, 2))
        
      
      
    }else{
      plot=readRDS(file = paste0(data, "/Trends/",  input$Indicator, '_', input$adminInput, ".rds"))
      plot = plot + theme(legend.position = c(legend.position = c(0.23, 0.35)))+  theme(plot.title = element_blank())
    }
      
    })
    
    return(plot())
    
  }
  
  
  if(("Relative change in 2025 compared to BAU in 2020" %in% input$statistic)) {
    plot<- reactive({
      #browser()
      plot=readRDS(file = paste0(data, "/Relative_change_2025_2020_base/",  input$Indicator, '_', input$adminInput, '_U5', ".rds"))
    })
    
    return(plot())
    
  }
  
  
  if(("Relative change in 2030 compared to BAU in 2020" %in% input$statistic)) {
    plot<- reactive({
      #browser()
      plot=readRDS(file = paste0(data, "/Relative_change_2030_2020_base/",  input$Indicator, '_', input$adminInput, '_U5', ".rds"))
    })
    
    return(plot())
    
  }
  
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
  filename = paste0('projections_u5_', input$adminInput,'_', input$Indicator, '_',input$statistic, '.csv'),
  content = function(file) {
    outputData <- proj_u5()$data %>% dplyr::mutate(scenario = ifelse(scenario == 'NGA projection scenario 0', 'NGA historical projections', scenario))
    write.csv(outputData, file, row.names = FALSE)
  }
)
