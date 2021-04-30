### ==========================================================================================
### HBHI modelling - Nigeria: IPTi effectiveness estimation and scaling of simulation outputs
### August 2020, MR
### Updated April 2020, added CIs
### Helper functions
### ====================================================================================


f_loadCMdat <- function(scen, CMfilename) {
  library(dplyr)

  CMdat <- read_csv(file.path(cm_dir, paste0(CMfilename, ".csv")))
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
  ### Parasitol Res. 2018;117: 801–807. doi:10.1007/s00436-018-5754-5

  PEdat <- as.data.frame(read_csv(file.path(WorkingDir, "data/IPTi_effectiveness.csv")))
  PEdat <- subset(PEdat, Drug == "SP" & Author == "Esu" & Comparison == "IPTi versus placebo")

  PE_IPTi_clinical <- PEdat[PEdat$Outcome == "clinical malaria", c("effectsize", "low_ci", "up_ci")]
  PE_IPTi_severe <- PEdat[PEdat$Outcome == "severe malaria", c("effectsize", "low_ci", "up_ci")]
  PE_IPTi_allDeaths <- PEdat[PEdat$Outcome == "all-cause mortality", c("effectsize", "low_ci", "up_ci")]
  PE_IPTi_anaemia <- PEdat[PEdat$Outcome == "anaemia", c("effectsize", "low_ci", "up_ci")]
  PE_IPTi_pfpr <- PEdat[PEdat$Outcome == "parasitaemia", c("effectsize", "low_ci", "up_ci")]

  PEnames <- c("mean", "lowCI", "upCI")

  PEs <- list("PfPR" = PE_IPTi_pfpr, "Clinical" = PE_IPTi_clinical, "Severe" = PE_IPTi_severe, "Anaemia" = PE_IPTi_anaemia, "Deaths" = PE_IPTi_allDeaths)
  PEdat <- rbind("PfPR" = PE_IPTi_pfpr, "Clinical" = PE_IPTi_clinical, "Severe" = PE_IPTi_severe, "Anaemia" = PE_IPTi_anaemia, "Deaths" = PE_IPTi_allDeaths)

  return(PEdat)
}


f_aggrAge <- function(dataset, groupVARS, agebinUp, Uagename, aggrMonths = T) {
  #'  Aggregate predictions per age_bins for specific age groups
  #' @param dataset  dataset with rows per age_bins to aggregate
  #' @param groupVARS grouping variables that are not aggregated
  #' @param agebinUp upper age limit used to subset the dataframe assuming infants are inluced in U5 and U5 included in all ages
  #' @param Uagename name of age group that is attached to column names
  #' @param aggrMonths aggregates months (i.e. infants as one group without age in months)

  temp <- dataset %>%
    dplyr::filter(agebin <= agebinUp) %>%
    dplyr::group_by_(.dots = groupVARS) %>%
    dplyr::summarize(
      PfPR = mean(PfPR),
      Cases = sum(Cases),
      Severe.cases = sum(Severe_cases),
      Anaemia = sum(Anaemia),
      statisticalPop = sum(Pop)
    )

  if (aggrMonths) {
    groupVARS2 <- groupVARS[!(groupVARS %in% "month")]
    temp <- temp %>%
      dplyr::group_by_(.dots = groupVARS2) %>%
      dplyr::summarize(
        PfPR = mean(PfPR),
        Cases = sum(Cases),
        Severe.cases = sum(Severe.cases),
        Anaemia = sum(Anaemia),
        statisticalPop = mean(statisticalPop)
      )
  }

  colnames(temp)[!(colnames(temp) %in% groupVars)] <- paste0(colnames(temp)[!(colnames(temp) %in% groupVars)], Uagename)
  return(temp)
}

f_perPop <- function(dat, outVar, ageU) {
  #' Calculate predictions per LGA population from statistical population
  #' @param dat  dataset in wide format with predictions per age group
  #' @param outVar variable to scale per population
  #' @param ageU age group

  if (ageU == "U1") dat[, paste0(outVar, ".pop")] <- (dat[, outVar] / dat$statisticalPop.U1) * dat$geopode.pop.0.1
  if (ageU == "U5") dat[, paste0(outVar, ".pop")] <- (dat[, outVar] / dat$statisticalPop.U5) * dat$geopode.pop.0.4
  if (ageU == "Uall") dat[, paste0(outVar, ".pop")] <- (dat[, outVar] / dat$statisticalPop.Uall) * dat$geopode.pop

  ### correct order for scl and pop
  colnames(dat) <- gsub("_scl.pop", ".pop_scl", colnames(dat))

  return(dat)
}

f_outprops <- function(dat, ageU) {
  #' Calculate proportions
  #' @param dat  dataset in wide format with predictions per age group
  #' @param ageU age group

  dat[, paste0("PfPR", ageU)] <- (dat[, paste0("pos", ageU)] / dat[, paste0("statisticalPop", ageU)])
  dat[, paste0("incidence", ageU)] <- (dat[, paste0("Cases", ageU)] / dat[, paste0("statisticalPop", ageU)]) * 1000
  dat[, paste0("mortality", ageU)] <- (dat[, paste0("deaths", ageU)] / dat[, paste0("statisticalPop", ageU)]) * 1000

  dat[, paste0("PfPR", ageU, "_scl")] <- (dat[, paste0("pos", ageU, "_scl")] / dat[, paste0("statisticalPop", ageU)])
  dat[, paste0("incidence", ageU, "_scl")] <- (dat[, paste0("Cases", ageU, "_scl")] / dat[, paste0("statisticalPop", ageU)]) * 1000
  dat[, paste0("mortality", ageU, "_scl")] <- (dat[, paste0("deaths", ageU, "_scl")] / dat[, paste0("statisticalPop", ageU)]) * 1000

  return(dat)
}
