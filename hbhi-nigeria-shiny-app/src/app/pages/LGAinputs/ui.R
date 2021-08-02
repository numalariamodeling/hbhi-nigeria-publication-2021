#LGAinput ui.r

import::from('../../ui_selection_data.R', INPUT_PARAM_DESCRIPTIONS, interventions)
import::from(tidyr, '%>%')



LGAModelUI <- function () {
  ui <- fluidPage(
    shiny::sidebarLayout(
      shiny::sidebarPanel(
        shiny::h3('Input data visualization', style='margin-top: 0;'),
        br(),
        shiny::selectInput(
          inputId = 'scenarioInput',
          label = "Scenarios",
          choices = INPUT_PARAM_DESCRIPTIONS[['scenarios']]
        ),
        shiny::selectInput(
          inputId = 'yearInput',
          label = "Year",
          choices = INPUT_PARAM_DESCRIPTIONS[['year']]
        ),
        shiny::selectInput(
          inputId = 'varType',
          label = 'Intervention Type',
          choices =  interventions$interventions,
        ),
        shiny::selectInput(
          inputId = 'ITN_age',
          label = 'Select age for ITN coverage',
          choices =  interventions$age_group,
        ),
        shiny::selectInput(
          inputId = 'SMC_access_type',
          label = 'Select access type for SMC',
          choices =  interventions$SMC_access,
        ),
        
        actionButton(
          inputId = "submit_loc",
          label = "Submit")
        
      ),
      
      
      shiny::mainPanel(tags$style(".col-sm-8 .well {background-color:#FFFFFF;}"), 
        shiny::wellPanel(ggiraph::girafeOutput('modelPlot', width = '100%', height = '780px') %>% shinycssloaders::withSpinner(),
        #shiny::br(),
        shiny::uiOutput('downloadUI'),
        tags$div(style="width:200px;height:300px"))
      )
    )
  )
}