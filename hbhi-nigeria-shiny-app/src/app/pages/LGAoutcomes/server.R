##-----------------------------
## LGAoutcomes/server.R
##------------------------------


import::here('./ui_selection_data.R', admin)
import::here('./functions.R', generateLine, generateLinePT, generateBar, str_wrap_factor, statesf)


#Load admin unit description and names, and add toggle for info button based on state input  
observeEvent(input$adminInput, updateSelectInput(session, "admin_name", choices = admin[admin$admin==input$adminInput, "name"]))

observeEvent(c(input$admin_name), {shinyBS::toggleModal(session, 'infoModal', toggle = "open")}, ignoreInit = T)

#--------------------------------------------------------  
###plot generation script  
#--------------------------------------------------------
map_all <- eventReactive(input$submit_proj,{
  
  if(grepl('State|LGA', input$adminInput)){
    map <- reactive({
      
      if(input$adminInput == 'State'){
        map = statesf%>% dplyr::mutate(interest = ifelse(NAME_1 == input$admin_name, input$admin_name, NA))
        tooltip = paste0(input$admin_name, ' State')
      
      
      }else{
        LGA_state = data.table::fread("./data/other/LGA_state.csv")
        #browser()
        State = LGA_state[LGA_state$LGA == input$admin_name, 'State']
        map = statesf%>% dplyr::mutate(interest = ifelse(NAME_1 == !!State[[1]], !!State[[1]], NA))
        tooltip = paste0(input$admin_name, ' is in ', State[[1]], ' State')
      }
      map = ggplot2::ggplot(map)+
        ggiraph::geom_sf_interactive(ggplot2::aes(fill = interest, tooltip = tooltip), color = 'white', size = 0.2)+
        ggplot2::theme(axis.text.x = ggplot2::element_blank(),
                       axis.text.y = ggplot2::element_blank(),
                       axis.ticks = ggplot2::element_blank(),
                       rect = ggplot2::element_blank(),
                       plot.background = ggplot2::element_rect(fill = "white", colour = NA),
                       legend.position = 'none')+
        ggplot2::scale_fill_manual(values = c('blue'),na.value = "lightgrey")
    })
    
    return(map())
    
  }
  
})


#--------------------------------------------------------  
### indicators all ages
#--------------------------------------------------------
proj <- eventReactive(input$submit_proj,{
  data <- "./data"
  inputs <- file.path(data, 'simulation_outputs', 'indicators_noGTS_data')
  

  
  if("Trends" %in% input$statistic) {
    plot<- reactive({
      
      if(input$adminInput == 'National'){
      #browser()
        plot=readRDS(file = paste0(data, "/Trends/",  input$Indicator, '_', input$adminInput, ".rds"))
        plot = plot + theme(legend.text.align = 0, legend.position = c(legend.position = c(0.23, 0.35))) +
          labs(title=paste0('Projected annual trends in all ages malaria ', tolower(input$Indicator), ', Nigeria'),
                            y = paste('all ages annual ', tolower(input$Indicator)))
        
        }else {
          #browser()
          if(input$Indicator == 'Prevalence'){
          line_df =vroom::vroom(file.path(inputs, glue::glue('indicators_noGTS_{input$adminInput}_new.zip'))) 
          line_df = line_df[which(line_df$trend == input$Indicator & line_df[[input$adminInput]] == input$admin_name & line_df$age == 'all_ages'), ]
          plot=generateLine(line_df, line_df$count, paste0("all age ", tolower(input$Indicator), ', ', 'annual average'), title=paste0('Projected trends in all age malaria ', tolower(input$Indicator), ", ", input$admin_name), pin = pretty(line_df$count), limits = c(range(pretty(line_df$count))))
          plot = plot + theme(legend.position = c(legend.position = c(0.25, 0.25)))
          }else{
            inputs <- file.path(data, 'simulation_outputs', 'indicators_withGTS_data')
            df_gts =vroom::vroom(file.path(inputs, glue::glue('indicators_withGTS_{input$adminInput}_new.zip'))) 
            #browser()
            df_gts = df_gts[which(df_gts$trend == input$Indicator & df_gts[[input$adminInput]] == input$admin_name & df_gts$age == 'all_ages'), ]
            data_1 = dplyr::filter(df_gts, !(scenario %in% c('GTS targets based on 2015 modeled estimate')))
            data_2 = dplyr::filter(df_gts, scenario %in% c('GTS targets based on 2015 modeled estimate'))
            breaks = pretty(df_gts$count)
            limits = c(range(pretty(df_gts$count)))
            plot = generateLinePT(df_gts, data_1, data_2, breaks, limits)
            plot = plot + labs(y = paste0("all age ", tolower(input$Indicator), ', ', 'annual average'), title =paste0('Projected trends in all age malaria ', tolower(input$Indicator), ", ", input$admin_name))
            plot = plot + theme(legend.position = c(legend.position = c(0.25, 0.30)))
          }
          plot = map_all() + plot +  plot_layout(widths = c(0.5, 2))
          
        }
    })
    
    return(plot())
    
}
  
  
  
  if(grepl('Relative change', input$statistic)) {
    plot<- reactive({
      
      year = as.numeric(stringr::str_extract_all(input$statistic, "[0-9]+")[[1]])

      if(input$adminInput == 'National'){
      plot=readRDS(file = paste0(data, "/Relative_change_", year[[1]], "_", year[[2]], "_base/",  input$Indicator, '_', input$adminInput, ".rds"))+
        labs(title =paste0("Projected change in ", tolower(input$Indicator), ' in ', year[[1]], ' relative to ',  year[[2]]))
    
      } else {
        
        inputs <- paste0(data, '/simulation_outputs/', 'relative_change_', year[[2]],  '_base/')
    
        df<- vroom::vroom(paste0(inputs, glue::glue('relative_change_{year[[2]]}_base_{input$adminInput}_new.zip'))) 
        df <- df[which(df$year == year[[1]]& df[[input$adminInput]] == input$admin_name & df$trend == input$Indicator & df$age == 'all_ages'), ] 
        df$scenario <- factor(df$scenario, levels = c("Business as usual (Scenario 1)", "NMSP with ramping up to 80% coverage (Scenario 2)",
                                                      "Budget-prioritized plan with coverage increases at  historical rate & SMC in 235 LGAs (Scenario 3)",
                                                      "Budget-prioritized plan with coverage increases at  historical rate & SMC in 310 LGAs (Scenario 4)"))
      
        df$scenario = str_wrap_factor(df$scenario, width=20)
        
        plot = generateBar(df, scenario, df$count, paste0('% change in all age ', tolower(input$Indicator),  '\n in ', year[[1]], ' compared to ', year[[2]]),
                           paste0("Projected change in ", tolower(input$Indicator), ' in ', year[[1]], ' relative to ', year[[2]], ', ', input$admin_name)) 
        plot = map_all() + plot +  plot_layout(widths = c(0.5, 2))
        
      }
      
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
  data <- "./data"
  inputs <- file.path(data, 'simulation_outputs', 'indicators_noGTS_data')
  
  
  if("Trends" %in% input$statistic) {
    plot<- reactive({
      if(input$adminInput == 'National'){
   
      plot=readRDS(file = paste0(data, "/Trends/",  input$Indicator, '_', input$adminInput, '_U5', ".rds"))
      plot = plot + theme(legend.text.align = 0, legend.position = c(legend.position = c(0.23, 0.33)), 
                          plot.title = element_text(size=14, color = "black", face = "bold", hjust=0.5)) + 
        labs(title=paste0('Projected annual trends in U5 malaria ', tolower(input$Indicator), ', Nigeria'),
             y = paste('all ages annual ', tolower(input$Indicator)))
      
      
    }else {
      
     
      line_df =vroom::vroom(file.path(inputs, glue::glue('indicators_noGTS_{input$adminInput}_new.zip')))
      line_df = line_df[which(line_df$trend == input$Indicator & line_df[[input$adminInput]] == input$admin_name & line_df$age == 'U5'), ]
      plot=generateLine(line_df, line_df$count, paste0("U5 ", tolower(input$Indicator), ', ', 'annual average'), title=paste0('Projected trends in U5 malaria ', tolower(input$Indicator), ", ", input$admin_name), pin = pretty(line_df$count), limits = c(range(pretty(line_df$count))))
      plot = plot + theme(legend.position = c(legend.position = c(0.25, 0.25)))
      plot = map_all() + plot +  plot_layout(widths = c(0.5, 2))

    }
      
    })
    
    return(plot())
    
  }
  
  
  if(grepl('Relative change', input$statistic)) {
    year = as.numeric(stringr::str_extract_all(input$statistic, "[0-9]+")[[1]])
    
    plot<- reactive({
      
      if(input$adminInput == 'National'){
   
        
      plot=readRDS(file = paste0(data, "/Relative_change_", year[[1]], "_", year[[2]], "_base/",  input$Indicator, '_', input$adminInput, '_U5', ".rds"))
      plot = plot + theme(plot.title = element_text(size=14, color = "black", face = "bold", hjust=0.5))+ 
        labs(title =paste0("Projected change in ", tolower(input$Indicator), ' in ', year[[1]], ' relative to ',  year[[2]]))
      
      }else{
        inputs <- paste0(data, '/simulation_outputs/', 'relative_change_', year[[2]],  '_base/')
        
        df<- vroom::vroom(paste0(inputs, glue::glue('relative_change_{year[[2]]}_base_{input$adminInput}_new.zip'))) 
        df <- df[which(df$year == year[[1]]& df[[input$adminInput]] == input$admin_name & df$trend == input$Indicator & df$age == 'U5'), ] 
        df$scenario <- factor(df$scenario, levels = c("Business as usual (Scenario 1)", "NMSP with ramping up to 80% coverage (Scenario 2)",
                                                      "Budget-prioritized plan with coverage increases at  historical rate & SMC in 235 LGAs (Scenario 3)",
                                                      "Budget-prioritized plan with coverage increases at  historical rate & SMC in 310 LGAs (Scenario 4)"))
        
        df$scenario = str_wrap_factor(df$scenario, width=20)
        
        plot = generateBar(df, scenario, df$count, paste0('% change in U5 ', tolower(input$Indicator),  '\n in ', year[[1]], ' compared to ', year[[2]] ),
                           paste0("Projected change in ", tolower(input$Indicator), ' in ', year[[1]], ' relative to ',  year[[2]], ', ', input$admin_name)) 
        #browser()
        plot = map_all() + plot +  plot_layout(widths = c(0.5, 2))
        
      }
      
      
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
