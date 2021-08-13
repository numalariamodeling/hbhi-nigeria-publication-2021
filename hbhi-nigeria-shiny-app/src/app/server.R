# data.frame with credentials info. User can create credentials as needed 
credentials <- data.frame(
  user = c("3"),
  password = c("3"),
  # comment = c("alsace", "auvergne", "bretagne"), %>% 
  stringsAsFactors = FALSE
)

server <- function (input, output, session) {
	shinyBS::toggleModal(session, 'infoModal', toggle='open')

	shiny::observe({
		# Run each page's server code
		source('./pages/LGAinputs/server.R', local=TRUE)
		source('./pages/LGAoutcomes/server.R', local=TRUE)
	})
	
	result_auth <- secure_server(check_credentials = check_credentials(credentials))
	
	output$res_auth <- renderPrint({
	  reactiveValuesToList(result_auth)
	})
}