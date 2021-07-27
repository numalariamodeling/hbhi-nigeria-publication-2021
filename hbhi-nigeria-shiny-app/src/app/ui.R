
#----------------------------------------------------------------------
# ui.R - Main UI File
# - Develops main page and links to the other two pages in the app
#----------------------------------------------------------------------

import::from('./pages/LGAinputs/ui.R', LGAModelUI)
import::from('./pages/LGAoutcomes/ui.R', outcomesUI)

navbarPageWithInputs <- function(..., inputs) {
	navbar <- navbarPage(...)
	form <- tags$form(class = "navbar-form", inputs)
	navbar[[3]][[1]]$children[[1]] <- htmltools::tagAppendChild(
	navbar[[3]][[1]]$children[[1]], form)
	navbar
}

ui <- shiny::tagList(
	shinyjs::useShinyjs(),
	navbarPageWithInputs(
		id='navbar',
		theme='flatly.min.css',
		'Malaria intervention scenarios and outcomes: Nigeria impact modeling',
		shiny::tabPanel(
			value='Interventions',
			icon=shiny::icon('globe-africa'),
			'Interventions', 
			LGAModelUI()),
		shiny::tabPanel(
			value='Outcomes',
			icon=shiny::icon('chart-area'),
			'Outcomes', 
			outcomesUI()),
		inputs=
			list(
				shiny::actionButton(
					'infoButton',
					icon=shiny::icon('info'),
					'Info'
				),
				'-', # separator
				shiny::actionButton(
					'codeButton',
					icon=shiny::icon('github'),
					'Code',
					onclick='window.open(\'https://github.com/numalariamodeling/hbhi-NGA-interventions-outcome-data-viz\', \'_blank\')'
				)
			)
			
	),
	shinyBS::bsModal(
		id='infoModal', 
		title='Malaria Intervention Scenarios and Outcomes',
		trigger='infoButton',
		size='large',
		"This tool visualizes intervention packages and projected outcomes for four scenarios considered for funding 
		the Nigerian Malaria Elimination Program as part of the 
		World Health Organization's ", htmltools::tags$a(href ="https://www.who.int/malaria/publications/atoz/high-impact-response/en/", "High Burden to High Impact Initiative (HBHI)", target ="_blank"),
		"to develop targeted interventions for high-burden countries.", "LGA-level intervention packages were used 
		inputs in an agent-based model of malaria transmission as described in the manuscript entitled Application of 
		mathematical modeling to inform intervention planning in Nigeria.",
		br(), br(),
		"To use the agent-based model, visit the ", htmltools::tags$a(href ="https://github.com/numalariamodeling/hbhi-nigeria-publication-2021", "HBHI Github Repo", target ="_blank"),
		"for more details",
		br(), br(),
		"To view this message again, click on the ", htmltools::tags$b("Info"), " tab.",
		br(), br(),
		"If you have used this tool for your work, please consider
		citing it: [TBD - Citation]" #TODO: add citation
	),
	hr(),
	shiny::div(
		style='text-align: center',
		'Created by the Northwestern University Malaria Modeling Team: ',
		shiny::HTML('<a href=\'https://numalariamodeling.org/\' target=\'_blank\'>https://numalariamodeling.org//</a>')
	),
	br()
)