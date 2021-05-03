### ==========================================================================================
### HBHI modelling - NGA: Estimating IPTi impact
### Input: Simulation output csv files, CM coverage, IPTi coverage per LGA
### Output: Csv files per scenario and age bin (U1, U5, Uall) with relative reductions due to IPTi per outcome
### (`IPTi_adjustment_U1.csv`,`IPTi_adjustment_U5.csv`,`IPTi_adjustment_Uall.csv`)
### ====================================================================================

for (i in c(1:length(exp_names))) {

  scenarioname = exp_names[i]
  CMfilename = cm_names[i]
  ipti_cov_multiplier <- ipti_cov_multipliers[i]

  scen <- regmatches(scenarioname, gregexpr("[[:digit:]]+", scenarioname))
  scen <- as.numeric(unlist(scen))
  print(paste0("Running  ", scenarioname))

  ##  Case management to calculate mortality  (scenario specific)
  CMdat <- f_loadCMdat(scen, CMfilename)

  ## IPTi coverage  (scenario specific)
  ipti_cov_dat <- fread(file.path(wdir, "IPTicov.csv")) %>% as.data.frame()
  ipti_cov_dat <- ipti_cov_dat %>%
    dplyr::mutate(
      ipti_cov_multiplier = ipti_cov_multiplier,
      IPTicov.adj = ifelse(ipti_cov_multiplier == 0.80 & IPTicov < 0.80, ipti_cov_multiplier,
        ifelse(ipti_cov_multiplier >= 1.1 & ipti_cov_multiplier <= 1.3, pmin(IPTicov * ipti_cov_multiplier, 1), IPTicov)
      )
    ) %>%
    dplyr::mutate(
      LGA = gsub("/", "-", LGA),
      LGA = ifelse(LGA == "kaita", "Kaita", LGA),
      LGA = ifelse(LGA == "kiyawa", "Kiyawa", LGA)
    ) %>%
    left_join(CMdat, by = "LGA", keep = FALSE)

  ### CMdat includes different CM values per year
  length(unique(ipti_cov_dat$LGA))
  length(unique(ipti_cov_dat[ipti_cov_dat$IPTyn == 1, "LGA"]))

  ## Read in simualtions for U1, U5, Uall
  U1dat <- f_load_U1_df(scenarioname, fut_end_year) %>%
    left_join(ipti_cov_dat, by = c("LGA", "year"), all.x = TRUE) %>%
    mutate(IPTicov = ifelse(IPTyn == 1, IPTicov, 0))
  colnames(U1dat) <- gsub("_U1", "", colnames(U1dat))

  U5dat <- f_load_U5_df(scenarioname, fut_end_year) %>%
    left_join(ipti_cov_dat, by = c("LGA", "year"), all.x = TRUE) %>%
    mutate(IPTicov = ifelse(IPTyn == 1, IPTicov, 0))
  colnames(U5dat) <- gsub("_U5", "", colnames(U5dat))

  Ualldat <- f_load_Uall_df(scenarioname, fut_end_year) %>%
    left_join(ipti_cov_dat, by = c("LGA", "year"), all.x = TRUE) %>%
    mutate(IPTicov = ifelse(IPTyn == 1, IPTicov, 0))

  ## IPTi effectiveness adjustment for U1
  PEdat <- f_loadPEdat()
  outcomeIdentifier <- c("pos" = "PfPR", "total_cases" = "Clinical", "total_severe_cases" = "Severe", "deaths" = "Deaths")
  colsn <- c("pos", "total_cases", "total_severe_cases", "deaths")

  U1dat_scl <- d_scaleForIPTi(
    df = U1dat,
    outcomeVars = colsn,
    covVar = "IPTicov.adj",
    PEs = PEdat,
    outcomeIdentifier,
    measures = c("mean", "low_ci", "up_ci")
  )

  U1dat_scl <- U1dat_scl %>%
    mutate(
      pos_scl = ifelse(pos_scl < 0, 0, pos_scl),
      deaths_scl = ifelse(deaths_scl < 0, 0, deaths_scl),
      total_cases_scl = ifelse(total_cases_scl < 0, 0, total_cases_scl),
      total_severe_cases_scl = ifelse(total_severe_cases_scl < 0, 0, total_severe_cases_scl)
    )

  U1dat_scl_diff <- U1dat_scl %>%
    dplyr::mutate(
      pos_diff_U1 = pos - pos_scl,
      deaths_diff_U1 = deaths - deaths_scl,
      total_cases_diff_U1 = total_cases - total_cases_scl,
      total_severe_cases_diff_U1 = total_severe_cases - total_severe_cases_scl
    ) %>%
    dplyr::select(LGA, year, Run_Number, measure, pos_diff_U1, deaths_diff_U1, total_cases_diff_U1, total_severe_cases_diff_U1)

  ## Remove malaria events averted in U1 from U5 and Uall
  U5dat_list <- list()
  Ualldat_list <- list()
  for (i in unique(U1dat_scl_diff$measure)) {
    U1dat_scl_diff_i <- subset(U1dat_scl_diff, measure == i)

    U5dat_list[[length(U5dat_list) + 1]] <- U5dat %>%
      left_join(U1dat_scl_diff_i, by = c("LGA", "year", "Run_Number"), all.x = TRUE) %>%
      dplyr::mutate(
        pos_scl = pos - pos_diff_U1,
        deaths_scl = deaths - deaths_diff_U1,
        total_cases_scl = total_cases - total_cases_diff_U1,
        total_severe_cases_scl = total_severe_cases - total_severe_cases_diff_U1
      )

    Ualldat_list[[length(Ualldat_list) + 1]] <- Ualldat %>%
      left_join(U1dat_scl_diff_i, by = c("LGA", "year", "Run_Number"), all.x = TRUE) %>%
      dplyr::mutate(
        pos_scl = pos - pos_diff_U1,
        deaths_scl = deaths - deaths_diff_U1,
        total_cases_scl = total_cases - total_cases_diff_U1,
        total_severe_cases_scl = total_severe_cases - total_severe_cases_diff_U1
      )
  }

  U5dat_scl <- U5dat_list %>% bind_rows()
  Ualldat_scl <- Ualldat_list %>% bind_rows()

  ## Generate IPTi relative reductions table used for scaling
  U1dat_tbl <- f_getScalingTable(df = U1dat_scl) %>%
    mutate(scenarioname = scenarioname)

  U5dat_tbl <- f_getScalingTable(df = U5dat_scl) %>%
    mutate(scenarioname = scenarioname)

  Ualldat_tbl <- f_getScalingTable(df = Ualldat_scl) %>%
    mutate(scenarioname = scenarioname)

  if (nrow(U1dat_tbl) != nrow(U5dat_tbl) | nrow(U1dat_tbl) != nrow(Ualldat_tbl)) {
    stop("Number of rows are not the same")
  }

  ## Save outputs
  fwrite(U1dat_tbl, file = file.path(simoutDir, scenarioname, "IPTi_adjustment_U1.csv"), row.names = FALSE)
  fwrite(U5dat_tbl, file = file.path(simoutDir, scenarioname, "IPTi_adjustment_U5.csv"), row.names = FALSE)
  fwrite(Ualldat_tbl, file = file.path(simoutDir, scenarioname, "IPTi_adjustment_Uall.csv"), row.names = FALSE)

  if (file.exists(file.path(simoutDir, scenarioname, "IPTi_adjustment_U1.csv"))) {
    print(paste0("Output saved in ", scenarioname))
  }

  rm(scenarioname, U1dat_scl, U5dat_scl, U1dat_tbl, U5dat_tbl, Ualldat_scl, Ualldat_tbl, ipti_cov_dat)
}
