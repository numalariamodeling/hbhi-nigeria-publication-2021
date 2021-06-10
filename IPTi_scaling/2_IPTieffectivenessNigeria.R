### ==========================================================================================
### HBHI modelling - Nigeria: IPTi effectiveness estimation and scaling of simulation outputs
### Feb 2020, MR
### Updated March 2020, added CIs
### Note: script specific to cache4 simulations
###
### Input: Simulation output, population, CM coverage, IPTi coverage per LGA
### Output: (1) Csv file with relative reductions in U1 for all outcomes measures, which
###         can be applied to adjust the outcomes measures in U5 populations
###         (2) Separate in-depth description of malaria outcomes in U1
### ====================================================================================


### --------------------------------------------------------------------------------------------
#### Settings and custom objects
SAVE <- T

### Directories
if (!exists("Drive")) {
  Drive <- file.path(gsub("[\\]", "/", gsub("Documents", "", Sys.getenv("HOME"))))
  NUDir <- file.path(Drive, "Box/NU-malaria-team")
  ProjectDir <- file.path(NUDir, "projects")
  WorkingDir <- file.path(ProjectDir, "IPTi")
  shpDir <- file.path(Drive, "Box/NU-malaria-team/data/nigeria_shapefiles")
  cm_dir <- file.path(ProjectDir, "hbhi_nigeria/simulation_inputs/projection_csvs/projection_v2")

  cm_filenames <- scendat$CM_filename
  ipti_coverage_multiplers <- scendat$IPTi_cov_muliplier

  sim_iteration <- "2020_to_2030_v4"
  simoutDir <- file.path(ProjectDir, "hbhi_nigeria", "simulation_output", sim_iteration)

  fut_start_year <- 2020
  fut_end_year <- 2030

  source("functions/setup.R")
  source(file.path("functions/f_scaleIPTi.R"))
  source(file.path("functions/helper_functions.R"))
}


### Define fixed estimates
#### From relative reduction analyzer script
CFR_treated_severe <- 0.097
CFR_untreated_severe <- 0.539
#### Approximate the proportion of infants in the population
#### Assumed to be the same for all LGAs and constant over time
propU1_outTot <- 0.03474714994 ## From Ifakara, Tanzania demography (children U1) update when known for Nigeria
propU2_outTot <- 0.0927626506333018 ## From EMOD, proportion below 2 years
propU5_outTot <- 0.17709689
(propU1_outU5 <- propU1_outTot / propU5_outTot)



for (scenarioname in exp_names) {
  # scenarioname = exp_names[2]

  print(scenarioname)
  scen <- as.numeric(gsub("NGA projection scenario ", "", scenarioname))


  ## ================================
  ### SUPPLEMENTARY DATA
  ## ================================
  ## 1 - Case management data
  ## 2 - IPTi coverage data
  ## 3 -  population data
  ## 4 -  protective efficacy estimates
  ## ================================

  ## 1 ================================
  ##  Case management to calculate mortality  (scenario specific)
  CMfilename <- scendat$CM_filename[scendat$Scenario_no == scen]
  CMdat <- f_loadCMdat(scen, CMfilename)

  ## 2 ================================
  ## Coverage  (scenario specific)
  ipti_cov_multiplier <- scendat$IPTi_cov_muliplier[scendat$Scenario_no == scen]
  load(file.path(ProjectDir, "hbhi_nigeria/IPTi/analysis", "assumedIPTicov.Rdata"))

  DSpenIPT <- DSpenIPT %>%
    dplyr::select(LGA, Scenario, IPTyn, IPTicov) %>%
    dplyr::mutate(
      ipti_cov_multiplier = ipti_cov_multiplier,
      IPTicov.adj = ifelse(ipti_cov_multiplier == 0.80 & IPTicov < 0.80, ipti_cov_multiplier,
        ifelse(ipti_cov_multiplier >= 1.1 & ipti_cov_multiplier <= 1.3, pmin(IPTicov * ipti_cov_multiplier, 1), IPTicov)
      )
    ) %>%
    dplyr::rename(IPTimap = Scenario) %>%
    dplyr::mutate(
      IPTimap = ifelse(is.na(IPTimap), "no IPTi", IPTimap)
    ) %>%
    dplyr::mutate(
      LGA = gsub("/", "-", LGA),
      LGA = ifelse(LGA == "kaita", "Kaita", LGA),
      LGA = ifelse(LGA == "kiyawa", "Kiyawa", LGA)
    )


  ## 3 ================================
  ### Population data: subset and calculate infant population
  LGApop <- fread(file.path(ProjectDir, "hbhi_nigeria/nigeria_LGA_pop.csv")) %>%
    dplyr::select(LGA, District_Code, State, Archetype, population, geopode.pop, geopode.pop.0.4) %>%
    dplyr::mutate(
      geopode.pop.0.1 = geopode.pop.0.4 * propU1_outU5,
      LGA = gsub("/", "-", LGA),
      LGA = ifelse(LGA == "kaita", "Kaita", LGA),
      LGA = ifelse(LGA == "kiyawa", "Kiyawa", LGA)
    )


  ## Combine 1-3 ================================
  #### case management data to reflect underlying changes in case management for each scenario
  additionalData <- DSpenIPT %>%
    left_join(LGApop, by = "LGA") %>%
    left_join(CMdat, by = "LGA")


  ## 4  ================================
  PEdat <- f_loadPEdat()

  ## ================================
  ### READ SIMULATIONS
  ## ================================
  ### Simulation output -  impact of IPTI in the Nigeria scenarios 4 to 8

  ### Read in simulations (due to computational limitations, read one at a time specified by the scenario number)
  # simdat <- sapply(scenarioFile, read_simout, simplify = FALSE) %>% bind_rows(.id = "id")


  scenarioFile <- paste0(scenarioname, "/Agebins_PfPR_ClinicalIncidenceAnemia.csv")

  simdat <- fread(file = file.path(simoutDir, scenarioFile)) %>% mutate(scenarioname = scenarioname)
  colnames(simdat) <- gsub(" ", "_", colnames(simdat))
  colnames(simdat) <- gsub("_U5", "", colnames(simdat))

  simdat$Anaemia <- simdat$Moderate_anaemia + simdat$Severe_anaemia

  ### Add population, coverage and CM, filter out LGAs that do not get IPTi
  simdat <- simdat %>%
    left_join(additionalData, by = c("LGA", "year"), all.x = TRUE) %>%
    mutate(IPTicov = ifelse(IPTyn == 1, IPTicov, 0))
    #filter(IPTyn == 1)

  ## Save agebins into separate dataframes
  # table(simdat$agebin)
  U1Dat <- simdat %>% filter(agebin == 1)
  U5Dat <- simdat %>% filter(agebin == 5)
  UallDat <- simdat %>% filter(agebin == 120)


  ## ==================================================
  #### Scale by IPTi effectiveness

  f_calculate_additionalVars <- function(df, adults = FALSE) {
    if (adults == FALSE) df$CMcov_to_use <- df$U5_coverage
    if (adults) df$CMcov_to_use <- df$adult_coverage

    df <- df %>%
      dplyr::mutate(
        pos = PfPR * Pop,
        treated_Severe_cases = Severe_cases * CMcov_to_use,
        deaths = ((Severe_cases - treated_Severe_cases) * CFR_untreated_severe) + (treated_Severe_cases * CFR_treated_severe),
      )

    return(df)
  }

  U1Dat <- f_calculate_additionalVars(U1Dat)
  U5Dat <- f_calculate_additionalVars(U5Dat)
  UallDat <- f_calculate_additionalVars(UallDat, adults = TRUE)

  outcomeIdentifier <- c("pos" = "PfPR", "Cases" = "Clinical", "Severe_cases" = "Severe", "Anaemia" = "Anaemia", "deaths" = "Deaths")
  colsn <- c("pos", "Cases", "Severe_cases", "Anaemia", "deaths")


  U1Dat_scl <- d_scaleForIPTi(
    df = U1Dat,
    outcomeVars = colsn,
    covVar = "IPTicov.adj",
    PEs = PEdat,
    outcomeIdentifier,
    measures = c(
      "effectsize",
      "low_ci",
      "up_ci"
    )
  )

  ## ============================
  ### SUBSTRACT 'SAVED' INFANTS FROM U5 and Uall
  ## ============================

  U1Dat_scl <- U1Dat_scl %>%
    mutate(
      pos_scl = ifelse(pos_scl < 0, 0, pos_scl),
      deaths_scl = ifelse(deaths_scl < 0, 0, deaths_scl),
      Cases_scl = ifelse(Cases_scl < 0, 0, Cases_scl),
      Severe_cases_scl = ifelse(Severe_cases_scl < 0, 0, Severe_cases_scl),
      Anaemia_scl = ifelse(Anaemia_scl < 0, 0, Anaemia_scl)
    )


  U1Dat_scl_diff <- U1Dat_scl %>%
    dplyr::mutate(
      pos_diff_U1 = pos - pos_scl,
      deaths_diff_U1 = deaths - deaths_scl,
      Cases_diff_U1 = Cases - Cases_scl,
      Severe_cases_diff_U1 = Severe_cases - Severe_cases_scl,
      Anaemia_diff_U1 = Anaemia - Anaemia_scl
    ) %>%
    dplyr::select(LGA, month, year, Run_Number, measure, pos_diff_U1, deaths_diff_U1, Cases_diff_U1, Severe_cases_diff_U1, Anaemia_diff_U1)

  U5Dat_list <- list()
  UallDat_list <- list()
  for (i in unique(U1Dat_scl_diff$measure)) {
    U1Dat_scl_diff_i <- subset(U1Dat_scl_diff, measure == i)

    U5Dat_list[[length(U5Dat_list) + 1]] <- U5Dat %>%
      left_join(U1Dat_scl_diff_i, by = c("LGA", "month", "year", "Run_Number"), all.x = TRUE) %>%
      dplyr::mutate(
        pos_scl = pos - pos_diff_U1,
        deaths_scl = deaths - deaths_diff_U1,
        Cases_scl = Cases - Cases_diff_U1,
        Severe_cases_scl = Severe_cases - Severe_cases_diff_U1,
        Anaemia_scl = Anaemia - Anaemia_diff_U1
      )


    UallDat_list[[length(UallDat_list) + 1]] <- UallDat %>%
      left_join(U1Dat_scl_diff_i, by = c("LGA", "month", "year", "Run_Number"), all.x = TRUE) %>%
      dplyr::mutate(
        pos_scl = pos - pos_diff_U1,
        deaths_scl = deaths - deaths_diff_U1,
        Cases_scl = Cases - Cases_diff_U1,
        Severe_cases_scl = Severe_cases - Severe_cases_diff_U1,
        Anaemia_scl = Anaemia - Anaemia_diff_U1
      )
  }

  U5Dat_scl <- U5Dat_list %>% bind_rows()
  UAlllDat_scl <- UallDat_list %>% bind_rows()


  U5Dat_scl <- U5Dat_scl %>%
    mutate(
      pos_scl = ifelse(pos_scl < 0, 0, pos_scl),
      deaths_scl = ifelse(deaths_scl < 0, 0, deaths_scl),
      Cases_scl = ifelse(Cases_scl < 0, 0, Cases_scl),
      Severe_cases_scl = ifelse(Severe_cases_scl < 0, 0, Severe_cases_scl),
      Anaemia_scl = ifelse(Anaemia_scl < 0, 0, Anaemia_scl)
    )


  UAlllDat_scl <- UAlllDat_scl %>%
    mutate(
      pos_scl = ifelse(pos_scl < 0, 0, pos_scl),
      deaths_scl = ifelse(deaths_scl < 0, 0, deaths_scl),
      Cases_scl = ifelse(Cases_scl < 0, 0, Cases_scl),
      Severe_cases_scl = ifelse(Severe_cases_scl < 0, 0, Severe_cases_scl),
      Anaemia_scl = ifelse(Anaemia_scl < 0, 0, Anaemia_scl)
    )


  ## ============================
  ### GENERATE SCALING TABLE
  ## ============================

  f_getScalingTable <- function(df, aggregateMonths = TRUE, aggregateRuns = TRUE) {
    groupVars <- c("Archetype", "LGA", "IPTicov", "IPTicov.adj", "scenarioname", "year", "month", "Run_Number", "IPTyn", "IPTimap", "measure")

    if (aggregateMonths & aggregateRuns == FALSE) {
      groupVars <- c("Archetype", "LGA", "IPTicov", "IPTicov.adj", "scenarioname", "year", "Run_Number", "IPTyn", "IPTimap", "measure")

      df <- df %>%
        dplyr::group_by_at(groupVars) %>%
        dplyr::summarize(
          pos_scl = sum(pos_scl),
          pos = sum(pos),
          Cases = sum(Cases),
          Cases_scl = sum(Cases_scl),
          Severe_cases = sum(Severe_cases),
          Severe_cases_scl = sum(Severe_cases_scl),
          Anaemia = sum(Anaemia),
          Anaemia_scl = sum(Anaemia_scl),
          deaths = sum(deaths),
          deaths_scl = sum(deaths_scl),
        )
    }
    if (aggregateRuns & aggregateMonths == FALSE) {
      groupVars <- c("Archetype", "LGA", "IPTicov", "IPTicov.adj", "scenarioname", "year", "month", "IPTyn", "IPTimap", "measure")

      ### If no IPTi planned, set relative reduction to 1
      df <- df %>%
        dplyr::group_by_at(groupVars) %>%
        dplyr::summarize(
          pos_scl = mean(pos_scl, na.rm = TRUE),
          pos = mean(pos, na.rm = TRUE),
          Cases = mean(Cases, na.rm = TRUE),
          Cases_scl = mean(Cases_scl, na.rm = TRUE),
          Severe_cases = mean(Severe_cases, na.rm = TRUE),
          Severe_cases_scl = mean(Severe_cases_scl, na.rm = TRUE),
          Anaemia = mean(Anaemia, na.rm = TRUE),
          Anaemia_scl = mean(Anaemia_scl, na.rm = TRUE),
          deaths = mean(deaths, na.rm = TRUE),
          deaths_scl = mean(deaths_scl, na.rm = TRUE)
        )
    }
    if (aggregateRuns & aggregateMonths) {
      groupVars1 <- c("Archetype", "LGA", "IPTicov", "IPTicov.adj", "scenarioname", "year", "Run_Number", "IPTyn", "IPTimap", "measure")
      groupVars <- c("Archetype", "LGA", "IPTicov", "IPTicov.adj", "scenarioname", "year", "IPTyn", "IPTimap", "measure")


      df <- df %>%
        dplyr::group_by_at(groupVars1) %>%
        dplyr::summarize(
          pos_scl = sum(pos_scl),
          pos = sum(pos),
          Cases = sum(Cases),
          Cases_scl = sum(Cases_scl),
          Severe_cases = sum(Severe_cases),
          Severe_cases_scl = sum(Severe_cases_scl),
          Anaemia = sum(Anaemia),
          Anaemia_scl = sum(Anaemia_scl),
          deaths = sum(deaths),
          deaths_scl = sum(deaths_scl),
        ) %>%
        dplyr::group_by_at(groupVars) %>%
        dplyr::summarize(
          pos_scl = mean(pos_scl),
          pos = mean(pos),
          Cases = mean(Cases),
          Cases_scl = mean(Cases_scl),
          Severe_cases = mean(Severe_cases),
          Severe_cases_scl = mean(Severe_cases_scl),
          Anaemia = mean(Anaemia),
          Anaemia_scl = mean(Anaemia_scl),
          deaths = mean(deaths),
          deaths_scl = mean(deaths_scl),
        )
    }

    df <- df %>%
      as.data.frame() %>%
      dplyr::group_by_at(groupVars) %>%
      dplyr::mutate(
        IPTiscl.pos = ifelse(pos != 0, pos_scl / pos, 1),
        IPTiscl.cases = ifelse(Cases != 0, Cases_scl / Cases, 1),
        IPTiscl.Severe.cases = ifelse(Severe_cases != 0, Severe_cases_scl / Severe_cases, 1),
        IPTiscl.deaths = ifelse(deaths != 0, deaths_scl / deaths, 1),
        IPTiscl.Anaemia = ifelse(Anaemia != 0, Anaemia_scl / Anaemia, 1),
      ) %>%
      as.data.frame()


    sclvars <- colnames(df)[grep("IPTiscl", colnames(df))]
    # tapply(df$IPTiscl.pos, df$IPTyn, summary)
    # sapply(df[, sclvars], summary)
    # sapply(df[U1Dat_scl$IPTyn == 1, sclvars], summary)
    # sapply(df[U1Dat_scl$IPTyn == 0, sclvars], summary)


    ### Ensure scaling is 1  if not an IPTi area
    df[df$IPTyn == 0, sclvars] <- 1

    return(df)
  }


  U1Dat_tbl <- f_getScalingTable(df = U1Dat_scl)
  U5Dat_tbl <- f_getScalingTable(df = U5Dat_scl)
  UAlllDat_tbl <- f_getScalingTable(df = UAlllDat_scl)

  ### Save outputs
  if (SAVE) {
    save(U1Dat_scl, file = file.path(simoutDir, scenarioname, "U1Dat_scl.Rdata"))
    fwrite(U1Dat_tbl, file = file.path(simoutDir, scenarioname, "IPTi_adjustment_U1.csv"), row.names = FALSE)
    fwrite(U5Dat_tbl, file = file.path(simoutDir, scenarioname, "IPTi_adjustment_U5.csv"), row.names = FALSE)
    fwrite(UAlllDat_tbl, file = file.path(simoutDir, scenarioname, "IPTi_adjustment_Uall.csv"), row.names = FALSE)

    if (file.exists(file.path(simoutDir, scenarioname, "simout_tbl_withCI.Rdata"))) {
      print(paste0("Output saved in", scenarioname))
    }
    ## Cleanup
    rm(scenarioname, simdat, U1Dat_scl, U5Dat_scl, UAlllDat_scl, U1Dat_tbl, U5Dat_tbl, UAlllDat_tbl, additionalData)
  }
}

