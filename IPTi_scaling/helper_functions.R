### ==========================================================================================
### HBHI modeling - NGA: Estimating IPTi impact
### Helper functions for  IPTieffectiveness.R
### ==========================================================================================

f_loadCMdat <- function(CMfilename) {
  library(dplyr)

  CMdat <- fread(file.path(cm_dir, paste0(CMfilename, ".csv")))
  CMdat <- CMdat %>%
    dplyr::select(LGA, year, U5_coverage, adult_coverage) %>%
    dplyr::group_by(LGA, year) %>%
    dplyr::summarize(
      U5_coverage = mean(U5_coverage),
      adult_coverage = mean(adult_coverage)
    )

  if (length(unique(CMdat$year)) <= 1) {
    CMdat <- CMdat %>%
      dplyr::select(-year) ## Cverage and CM stay constanct during

    futuretimeDat <- expand.grid(list(LGA = unique(CMdat$LGA), year = c(fut_start_year:fut_end_year)))
    CMdat <- left_join(CMdat, futuretimeDat, all = TRUE, by = "LGA")
  }

  ### If years in CMdat are less than the simulation years, keep latest coverage value for the other years
  if (max(CMdat$year) < fut_end_year) {
    df <- CMdat %>% filter(year == max(year))

    futuretimeDat <- expand.grid(list(
      LGA = unique(CMdat$LGA),
      year = c((unique(df$year) + 1):fut_end_year)
    ))

    futuretimeDat <- futuretimeDat %>%
      left_join(df[, c("LGA", "U5_coverage", "adult_coverage")], by = c("LGA"))

    CMdat <- rbind(CMdat, futuretimeDat) %>%
      arrange(LGA, year) %>%
      as.data.frame()
  }

  return(CMdat)
}


f_loadPEdat <- function() {
  ### Simple scaling of cases using protective efficacy estimates from Systematic Review
  ### 1. Esu E, Tacoli C, Gai P, Berens-Riha N, Pritsch M, Loescher T, et al.
  ### Prevalence of the Pfdhfr and Pfdhps mutations among asymptomatic pregnant women in Southeast Nigeria.
  ### Parasitol Res. 2018;117: 801�<U+0080><U+0093>807. doi:10.1007/s00436-018-5754-5

  clinical <- cbind("mean" = 0.79, "low_ci" = 0.74, "up_ci" = 0.85)
  row.names(clinical) <- "Clinical"
  severe <- cbind("mean" = 0.92, "low_ci" = 0.47, "up_ci" = 1.81)
  row.names(severe) <- "Severe"
  allDeaths <- cbind("mean" = 0.93, "low_ci" = 0.74, "up_ci" = 1.15)
  row.names(allDeaths) <- "Deaths"
  pfpr <- cbind("mean" = 0.66, "low_ci" = 0.56, "up_ci" = 0.79)
  row.names(pfpr) <- "PfPR"

  PEdat <- rbind(pfpr, clinical, severe, allDeaths)

  return(PEdat)
}


f_load_U1_df <- function(scenarioname, maxyear) {
  scenarioFile <- file.path(scenarioname, "U1_PfPR_ClinicalIncidence_severeTreatment.csv")
  df <- fread(file = file.path(simoutDir, scenarioFile)) %>%
    mutate(scenarioname = scenarioname) %>%
    as.data.frame()

  colnames(df) <- gsub(" ", "_", colnames(df))

  df <- df[df$year < maxyear, ]

  if (!("Num_U1_Received_Severe_Treatment" %in% colnames(df))) {
    df["Num_U1_Received_Severe_Treatment"] <- 0
  }

  df <- df %>%
    dplyr::group_by(year, LGA, Run_Number) %>%
    dplyr::summarize(
      PfPR_U1 = mean(PfPR_U1),
      Cases_U1 = sum(Cases_U1),
      Pop_U1 = mean(Pop_U1),
      Severe_cases_U1 = sum(Severe_cases_U1),
      Num_U1_Received_Severe_Treatment = sum(Num_U1_Received_Severe_Treatment, na.rm = TRUE)
    ) %>%
        dplyr::group_by(year, LGA) %>%
    dplyr::summarize(
      PfPR_U1 = mean(PfPR_U1),
      Cases_U1 = mean(Cases_U1),
      Pop_U1 = mean(Pop_U1),
      Severe_cases_U1 = mean(Severe_cases_U1),
      Num_U1_Received_Severe_Treatment = mean(Num_U1_Received_Severe_Treatment, na.rm = TRUE)
    ) %>%
    dplyr::group_by(year, LGA) %>%
    dplyr::mutate(
      pos_U1 = PfPR_U1 * Pop_U1,
      total_cases_U1 = Cases_U1 * Pop_U1 * 30 / 365,
      total_severe_cases_U1 = Severe_cases_U1 * Pop_U1 * 30 / 365,
      deaths_U1 = (total_severe_cases_U1 - Num_U1_Received_Severe_Treatment) * CFR_untreated_severe +
        (Num_U1_Received_Severe_Treatment * CFR_treated_severe)
    )

  return(df)
}


f_load_U5_df <- function(scenarioname, maxyear) {
  scenarioFile <- file.path(scenarioname, "U5_PfPR_ClinicalIncidence_severeTreatment.csv")
  df <- fread(file = file.path(simoutDir, scenarioFile)) %>%
    dplyr::mutate(scenarioname = scenarioname) %>%
    as.data.frame()
  colnames(df) <- gsub(" ", "_", colnames(df))


  df <- df[df$year < maxyear, ]

  if (!("Num_U5_Received_Severe_Treatment" %in% colnames(df))) {
    df["Num_U5_Received_Severe_Treatment"] <- 0
  }

  df <- df %>%
    dplyr::group_by(year, LGA, Run_Number) %>%
    dplyr::summarize(
      PfPR_U5 = mean(PfPR_U5),
      Cases_U5 = sum(Cases_U5),
      Pop_U5 = mean(Pop_U5),
      Severe_cases_U5 = sum(Severe_cases_U5),
      Num_U5_Received_Severe_Treatment = sum(Num_U5_Received_Severe_Treatment, na.rm = TRUE)
    ) %>%
     dplyr::group_by(year, LGA) %>%
    dplyr::summarize(
      PfPR_U5 = mean(PfPR_U5),
      Cases_U5 = mean(Cases_U5),
      Pop_U5 = mean(Pop_U5),
      Severe_cases_U5 = mean(Severe_cases_U5),
      Num_U5_Received_Severe_Treatment = mean(Num_U5_Received_Severe_Treatment, na.rm = TRUE)
    ) %>%
    dplyr::group_by(year, LGA) %>%
    dplyr::mutate(
      pos_U5 = PfPR_U5 * Pop_U5,
      total_cases_U5 = Cases_U5 * Pop_U5 * 30 / 365,
      total_severe_cases_U5 = Severe_cases_U5 * Pop_U5 * 30 / 365,
      deaths_U5 = (total_severe_cases_U5 - Num_U5_Received_Severe_Treatment) * CFR_untreated_severe +
        (Num_U5_Received_Severe_Treatment * CFR_treated_severe)
    )

  return(df)
}


f_load_Uall_df <- function(scenarioname, maxyear) {
  scenarioFile <- file.path(scenarioname, "All_Age_Monthly_Cases.csv")
  df <- fread(file = file.path(simoutDir, scenarioFile)) %>%
    dplyr::mutate(scenarioname = scenarioname) %>%
    as.data.frame()
  colnames(df) <- gsub(" ", "_", colnames(df))

  df$date <- as.Date(df$date)
  df$year <- year(df$date)
  df <- df[df$year < maxyear, ]

  if (!("Received_Severe_Treatment" %in% colnames(df))) {
    df["Received_Severe_Treatment"] <- 0
  }

  df <- df %>%
    dplyr::group_by(year, LGA, Run_Number) %>%
    dplyr::summarize(
      PfPR = mean(PfHRP2_Prevalence),
      Cases = sum(New_Clinical_Cases),
      Pop = mean(Statistical_Population),
      Severe_cases = sum(New_Severe_Cases),
      Received_Severe_Treatment = sum(Received_Severe_Treatment)
    ) %>%
   dplyr::group_by(year, LGA) %>%
    dplyr::summarize(
      PfPR = mean(PfPR),
      Cases = mean(Cases),
      Pop = mean(Pop),
      Severe_cases = mean(Severe_cases),
      Received_Severe_Treatment = mean(Received_Severe_Treatment)
    ) %>%
    dplyr::group_by(year, LGA) %>%
    dplyr::mutate(
      pos = PfPR * Pop,
      total_cases = Cases * Pop * 30 / 365,
      total_severe_cases = Severe_cases * Pop * 30 / 365,
      deaths = (total_severe_cases - Received_Severe_Treatment) * CFR_untreated_severe +
        (Received_Severe_Treatment * CFR_treated_severe)
    )

  return(df)
}


f_getScalingTable <- function(df) {

  df <- df %>%
    dplyr::mutate(
      IPTiscl.pos = ifelse(pos != 0, pos_scl / pos, 1),
      IPTiscl.cases = ifelse(total_cases != 0, total_cases_scl / total_cases, 1),
      IPTiscl.Severe.cases = ifelse(total_severe_cases != 0, total_severe_cases_scl / total_severe_cases, 1),
      IPTiscl.deaths = ifelse(deaths != 0, deaths_scl / deaths, 1)
    ) %>%
    dplyr::select(LGA ,IPTicov ,IPTicov.adj ,year ,IPTyn ,measure ,pos_scl ,pos ,
                  total_cases ,total_cases_scl ,total_severe_cases ,total_severe_cases_scl ,deaths ,deaths_scl ,
                  IPTiscl.pos ,IPTiscl.cases ,IPTiscl.Severe.cases ,IPTiscl.deaths ) %>%
    as.data.frame()

  sclvars <- colnames(df)[grep("IPTiscl", colnames(df))]
  ### Ensure scaling is 1  if not an IPTi area
  df[df$IPTyn == 0, sclvars] <- 1

  return(df)
}


f_combineAndSave <- function(exp_names, Uage, fnameOUT) {

  files <- file.path(simoutDir, exp_names, paste0("IPTi_adjustment_", Uage, ".csv"))

  ## Check if files exist
  nfiles <- sum(file.exists(files))
  files_not_exist <- gsub(simoutDir, "\n", files[which(!file.exists(files))])
  if (nfiles < length(exp_names)) {
    stop("\nNot all files found. Missing files", files_not_exist)
  }

  dat <- ldply(files, fread)

  dat <- dat %>%
    dplyr::mutate(
      scenario = scenarioname,
      scenarioNr = gsub("NGA projection scenario ", "", scenario),
      Scencov = scenarioNr
    ) %>%
    dplyr::select(
      LGA, scenario, scenarioNr, Scencov, year, IPTyn,
      measure, IPTiscl.pos, IPTiscl.cases, IPTiscl.Severe.cases, IPTiscl.deaths
    ) %>%
    dplyr::rename(IPTyn.f = IPTyn)

  fwrite(dat, file = file.path(simoutDir, fnameOUT), row.names = FALSE)
  if (file.exists(file.path(simoutDir, fnameOUT))) {
    return(paste0("File saved in ", file.path(simoutDir, fnameOUT)))
  } else {
    return(warning("File NOT found ", file.path(simoutDir, fnameOUT)))
  }
}

