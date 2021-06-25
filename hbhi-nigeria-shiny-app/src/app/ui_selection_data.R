
INPUT_PARAM_DESCRIPTIONS <- list(
	########### Model tab inputs
	scenarios = c( "", "Scenario 1 (Business as Usual)", "Scenario 2 (High effective coverage)", "Scenario 3 (Improved coverage)", "Scenario 4 (Improved coverage)", "Scenario 5 (Improved coverage)", "Scenario 6 (Considered for funding in the NSP)", "Scenario 7 (Considered for funding in the NSP)"),
	year = c("", 2020:2030),
	interventions = c("Case management - uncomplicated", 'Insecticide treated net kill rate', 'Insecticide treated net coverage', 'Seasonal malaria chemoprevention', 'Intermittent preventive treatment in pregnancy', 'Intermittent preventive treatment in infants', 'ALL'),
	admin = c("National", "State", "LGA"),
	indicator = c(" ", "Prevalence", "Incidence", "Mortality"),
	statistic = c(" ", "Trends", "Relative change in 2030 compared to BAU in 2020", "Relative change in 2030 compared to projection in 2015")
)



Drive <- file.path(gsub("[\\]", "/", gsub("Documents", "", Sys.getenv("HOME"))))
data_dir <- file.path(Drive,"Box", "NU-malaria-team", "projects", "hbhi_nigeria_shiny_app_data")

admin<- readr::read_csv(file.path(data_dir, "admin.csv"))
interventions<-read.csv(file.path(data_dir, "Interventions.csv"))

