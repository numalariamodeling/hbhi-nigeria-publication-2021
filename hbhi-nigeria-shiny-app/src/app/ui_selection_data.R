INPUT_PARAM_DESCRIPTIONS <- list(
  ########### Model tab inputs
  scenarios = c( "", "Scenario 1 (Business as Usual)", "Scenario 2 (National malaria strategic plan)", "Scenario 3 (Budget-prioritized plan)", "Scenario 4 (Budget-prioritized plan)"),
  year = c("", 2020:2030),
  interventions = c("Case management - uncomplicated", 'Insecticide treated net kill rate', 'Insecticide treated net blocking rate', 'Insecticide treated net coverage', 'Seasonal malaria chemoprevention', 'Intermittent preventive treatment in pregnancy', 'Intermittent preventive treatment in infants', 'ALL'),
  admin = c("National", "State", "LGA"),
  indicator = c(" ", "Prevalence", "Incidence per 1000", "Deaths per 1000"),
  statistic = c(" ", "Trends", "Relative change in 2025 compared to BAU in 2020", "Relative change in 2030 compared to BAU in 2020", "Relative change in 2025 compared to 2015 modeled estimate", "Relative change in 2030 compared to 2015 modeled estimate")
)



admin<- readr::read_csv("../../data/other/admin.csv")
interventions<-read.csv("../../data/other/Interventions.csv")








