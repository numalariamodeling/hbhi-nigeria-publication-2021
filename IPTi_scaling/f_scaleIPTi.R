### ============================================================
### HBHI modeling - NGA: Estimating IPTi impact
### IPTi scaling function
## ============================================================

f_scaleForIPTi <- function(xU1, cov, PE) {
  #'  scale for IPTi using coverage and protective efficacy estimates - applied on a simple list of vector for one outcome
  #' @param xU1  predictions in infants
  #' @param cov coverage value (vector of same length as xU1)
  #' @param PE protective efficacy estimate (only takes a single value so far)

  x_scl <- xU1 - (xU1 * cov * (1 - PE))

  return(x_scl)
}


d_scaleForIPTi <- function(df, outcomeVars, covVar, PEs, outcomeIdentifier, measures = "effectsize") {
  #'  scale for IPTi using coverage and protective efficacy estimates applied on a dataframe and multiple outcomes
  #' @param df dataframe with predictions in long format (outcome.agegroup as variables per setting and scenario)
  #' @param outcomeVars names of the variable that contains the values to be scaled, should be absolute numbers and not rates or proportions (i.e. "pos")
  #' @param covVar  name of the variable that contains the coverage estimates (per setting and scenario)
  #' @param PEs list of PE values identified by outcome name
  #' @param outcomeIdentifier matches the outcome name used in the variable name with the outcome in the PEs list
  #' @param measures mean, min, max, etc, dataframe , additional rows will be generated for each effect size (long format)

  df <- as.data.frame(df)
  df$covVar_adj <- df[, covVar]

  dat_list <- list()
  for (measure in measures) {
    temp_dat <- as.data.frame(df)
    temp_dat$measure <- measure

    for (outcomeVar in outcomeVars) {
      PE <- as.numeric(PEs[rownames(PEs) == outcomeIdentifier[outcomeVar], measure])
      temp_dat[, paste0(outcomeVar, "_scl")] <- f_scaleForIPTi(xU1 = temp_dat[, outcomeVar], cov = temp_dat[, "covVar_adj"], PE = PE)
      rm(PE)
    }

    dat_list[[measure]] <- temp_dat
    rm(temp_dat)
  }

  dat.scl <- dat_list %>%
    bind_rows() %>%
    as.data.frame()

  return(dat.scl)
}
