# SENSITIVITY ui.R

import::from('../../utils.R', INPUT_PARAM_DESCRIPTIONS, admin)
import::from(tidyr, '%>%')



outcomesUI <- function () {
	ui <- fluidPage(
		shiny::sidebarLayout(
			shiny::sidebarPanel(
				shiny::h3('Simulation results', style='margin-top: 0;'),
				br(),
				shiny::selectInput(
				  inputId = 'scenarioInput',
				  label = "Scenarios",
				  choices = INPUT_PARAM_DESCRIPTIONS[['scenarios']]
				),
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
				# shiny::selectInput(
				# 	inputId='parameterSelect',
				# 	label='parameter for plotting sensitivity analysis',
				# 	c(
				# 		INPUT_PARAM_DESCRIPTIONS[['seed_prop']],
				# 		INPUT_PARAM_DESCRIPTIONS[['prob_admit']],
				# 		INPUT_PARAM_DESCRIPTIONS[['drop_Reffective']],
				# 		INPUT_PARAM_DESCRIPTIONS[['dur_admitted']],
				# 		INPUT_PARAM_DESCRIPTIONS[['social_distancing']],
				# 		INPUT_PARAM_DESCRIPTIONS[['prob_test_max']],
				# 		INPUT_PARAM_DESCRIPTIONS[['R0']]
				# 	)
				# )
			),
			
			shiny::mainPanel(
				shiny::wellPanel(
					shiny::h3('Projection plots', style='margin-top: 0;'),
					br(),
					shiny::uiOutput('paramRangeUI'),
					plotly::plotlyOutput('hospSensitivityPlot') %>% shinycssloaders::withSpinner(),
					plotly::plotlyOutput('ICUSensitivityPlot') %>% shinycssloaders::withSpinner(),
				)
			)
		)
	)
}