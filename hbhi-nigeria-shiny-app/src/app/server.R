

server <- function (input, output, session) {
	shinyBS::toggleModal(session, 'infoModal', toggle='open')

	shiny::observe({
		# Run each page's server code
		source('./pages/LGAinputs/server.R', local=TRUE)
		source('./pages/LGAoutcomes/server.R', local=TRUE)
	})
}