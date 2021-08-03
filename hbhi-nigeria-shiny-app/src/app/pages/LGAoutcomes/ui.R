# SENSITIVITY ui.R

import::from('../../ui_selection_data.R', INPUT_PARAM_DESCRIPTIONS, admin)
import::from(tidyr, '%>%')



outcomesUI <- function () {
	ui <- fluidPage(
		shiny::sidebarLayout(
			shiny::sidebarPanel(
				shiny::h3('Burden projections', style='margin-top: 0;'),
				br(),
				# shiny::selectInput(
				#   inputId = 'scenarioInput',
				#   label = "Scenarios",
				#   choices = INPUT_PARAM_DESCRIPTIONS[['scenarios']]
				#),
				shiny::selectInput(
				  inputId = 'adminInput',
				  label = "Administrative Unit",
				  choices = admin$admin
				),
				shiny::selectInput(
				  inputId = 'Indicator',
				  label = 'Indicator',
				  choices =  INPUT_PARAM_DESCRIPTIONS[['indicator']],
				),
				shiny::selectInput(
				  inputId = 'statistic',
				  label = 'Statistic',
				  choices =  INPUT_PARAM_DESCRIPTIONS[['statistic']],
				),
				shiny::selectInput(
				  inputId = 'admin_name',
				  label = 'Select State or LGA name (This option is only available if you selected "State", or "LGA" in the Administrative Unit Option',
				  choices =  admin$name,
				),
				
				actionButton(
				  inputId = "submit_proj",
				  label = "Submit")
	
			),
			
			shiny::mainPanel(
				shiny::wellPanel(
				  
				  ggiraph::girafeOutput('projections') %>% shinycssloaders::withSpinner(),
					                 #shiny::uiOutput('downloadUI'),
				  
				  ggiraph::girafeOutput('projections_u5') %>% shinycssloaders::withSpinner()
					#plotly::plotlyOutput('ICUSensitivityPlot') %>% shinycssloaders::withSpinner(),
					#shiny::uiOutput('downloadUI')
				)
			)
		)
	)
}