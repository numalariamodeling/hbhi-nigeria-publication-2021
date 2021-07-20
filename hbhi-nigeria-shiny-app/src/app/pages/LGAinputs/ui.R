#LGAinput ui.r

import::from('../../ui_selection_data.R', INPUT_PARAM_DESCRIPTIONS, interventions)
import::from(tidyr, '%>%')






LGAModelUI <- function () {
	ui <- shiny::fluidPage(
	      wellPanel(shiny::h3('Input Data Visualization', style='margin-top: 0;')),
	      ggiraph::ggiraphOutput('modelPlot') %>% shinycssloaders::withSpinner(),
	      shiny::br(),
	      shiny::uiOutput('downloadUI'),
	      
	      hr(),
				#shiny::tabsetPanel(
				fluidRow(
				  column(12, wellPanel(shiny::h3('LGA Intervention Inputs', style='margin-top: 0;')))),
				
				br(), 
				fluidRow(
				  column(width = 4,
				         shiny::selectInput(
				           inputId = 'scenarioInput',
				           label = "Scenarios",
				           choices = INPUT_PARAM_DESCRIPTIONS[['scenarios']])
				        
				  ),
				  
				  column(width = 4, shiny::selectInput(
				    inputId = 'yearInput',
				    label = "Year",
				    choices = INPUT_PARAM_DESCRIPTIONS[['year']])
				  ),
				  
				  
				  column(width = 4, shiny::selectInput(
				    inputId = 'varType',
				    label = 'Intervention Type',
				    choices =  interventions$interventions)
				  )
				),
				
				fluidRow(column(width = 4, shiny::selectInput(
				  inputId = 'ITN_age',
				  label = 'Select age for ITN coverage', 
				  choices = interventions$age_group)
				  )
			),
				
				actionButton(
				  inputId = "submit_loc",
				  label = "Submit")

)
	ui
}
