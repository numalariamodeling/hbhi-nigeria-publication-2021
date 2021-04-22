
require(dplyr)
require(data.table)

### Directories
if (!exists("Drive")) {
  Drive <- file.path(gsub("[\\]", "/", gsub("Documents", "", Sys.getenv("HOME"))))
  NUDir <- file.path(Drive, "Box/NU-malaria-team")
  ProjectDir <- file.path(NUDir, "projects")
  WorkingDir <- file.path(ProjectDir, "IPTi")
  shpDir <- file.path(Drive, "Box/NU-malaria-team/data/nigeria_shapefiles")
  cm_dir <- file.path(ProjectDir, "hbhi_nigeria/simulation_inputs/projection_csvs/projection_v2")

  sim_iteration <- "2020_to_2030_v3"
  simoutDir <- file.path(ProjectDir, "hbhi_nigeria", "simulation_output", sim_iteration)
}

f_combineAndSave <- function(fname, Uage, fnameOUT) {
  fnameIN <- paste0(fname, Uage, ".csv")
  files <- file.path(simoutDir,exp_names,fnameIN)

  ## Check if files exist
  nfiles = sum(file.exists(files))
  files_not_exist <- gsub(simoutDir,'\n',files[which(!file.exists(files))])
  if(nfiles < length(exp_names) ){
    stop("\nNot all files found. Missing files",files_not_exist)
  }

  dat <- ldply(files, fread)

  dat <- dat %>%
    dplyr::mutate(
      scenario = scenarioname,
      IPTyn.f = IPTyn,
      IPTimap.f = IPTimap,
      scenarioNr = gsub("NGA projection scenario ", "", scenario),
      Scencov = scenarioNr,
      measure = ifelse(measure == "effectsize", "mean", measure)
    ) %>%
    dplyr::select(
      Archetype, LGA, scenario, scenarioNr, Scencov, year, IPTyn.f, IPTimap.f,
      measure, IPTiscl.pos, IPTiscl.cases, IPTiscl.Severe.cases, IPTiscl.deaths, IPTiscl.Anaemia
    )

  fwrite(dat, file = file.path(simoutDir, fnameOUT), row.names = FALSE)
  if(file.exists( file.path(simoutDir, fnameOUT))){
    return(paste0("File saved in ",file.path(simoutDir, fnameOUT)))
  }else{
    return(warning("File NOT found ",file.path(simoutDir, fnameOUT)))
  }
}


f_combineAndSave(fname = "IPTi_adjustment_", Uage = "U1", fnameOUT = "IPTi_adjustment.U1.csv")
f_combineAndSave(fname = "IPTi_adjustment_", Uage = "U5", fnameOUT = "IPTi_adjustment.csv")
f_combineAndSave(fname = "IPTi_adjustment_", Uage = "Uall", fnameOUT = "IPTi_adjustment.Uall.csv")
