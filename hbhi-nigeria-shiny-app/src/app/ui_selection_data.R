INPUT_PARAM_DESCRIPTIONS <- list(
  ########### Model tab inputs
  scenarios = c( "", "Scenario 1 (Business as Usual)", "Scenario 2 (National malaria strategic plan)", "Scenario 3 (Budget-prioritized plan)", "Scenario 4 (Budget-prioritized plan)"),
  year = c("", 2020:2030),
  interventions = c("Case management - uncomplicated", 'Insecticide treated net kill rate', 'Insecticide treated net coverage', 'Seasonal malaria chemoprevention', 'Intermittent preventive treatment in pregnancy', 'Intermittent preventive treatment in infants', 'ALL'),
  admin = c("National", "State", "LGA"),
  indicator = c(" ", "Prevalence", "Incidence", "Mortality"),
  statistic = c(" ", "Trends", "Relative change in 2030 compared to BAU in 2020", "Relative change in 2030 compared to projection in 2015")
)



Drive <- file.path(gsub("[\\]", "/", gsub("Documents", "", Sys.getenv("HOME"))))
data_dir <- file.path(Drive, 'Documents', 'hbhi-nigeria-publication-2021', 'hbhi-nigeria-shiny-app', 'data', 'other')

admin<- readr::read_csv(file.path(data_dir, "admin.csv"))
interventions<-read.csv(file.path(data_dir, "Interventions.csv"))








