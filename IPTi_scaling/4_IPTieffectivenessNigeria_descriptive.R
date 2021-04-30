### ==========================================================================================
### HBHI modelling - Nigeria: Visualise IPTi effectiveness estimation and scaling of simulation outputs
### August 2020, MR
###
### Input: Simulation output scaled for IPTi at different aggregation levels
### Output: basic descriptive plots
### ====================================================================================

### --------------------------------------------------------------------------------------------
#### Settings and custom objects
SAVE <- T
theme_set(theme_minimal())

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
  
  fut_start_year <- 2020
  fut_end_year <- 2030
  
  source("functions/setup.R")
  source(file.path("functions/f_scaleIPTi.R"))
  source(file.path("functions/helper_functions.R"))
}

outdir <- file.path(ProjectDir, "hbhi_nigeria/IPTi",sim_iteration)
if (!(dir.exists(outdir))) dir.create(outdir)

scencols <- c( "mediumvioletred",  "deepskyblue3", "tan2", "olivedrab3",  "mediumpurple4")
if(length(exp_names)>5) {
  library(RColorBrewer)
  scencols <- colorRampPalette(rev(brewer.pal(8, "Dark2")))
  scencols <- scencols(length(exp_names))
} 

if(file.exists(file.path(simoutDir,"U1Dat_scl.Rdata")))load(file.path(simoutDir, "U1Dat_scl.Rdata"))
if(!file.exists(file.path(simoutDir,"U1Dat_scl.Rdata"))){
  rfiles <- list.files(simoutDir, pattern = "U1Dat_scl.Rdata", recursive = T, full.names = T)
  for (rfile in rfiles) {
    load(rfile)
    if (!exists("dfAll")) dfAll <- U1Dat_scl
    if (exists("dfAll")) dfAll <- rbind(dfAll, U1Dat_scl)
    rm(U1Dat_scl)
  }
  U1Dat_scl <- dfAll
 #save(U1Dat_scl, file = file.path(simoutDir, "U1Dat_scl.Rdata"))
}


## Aggregate Run_Number 
U1Dat_scl <- U1Dat_scl %>%
  ungroup() %>%
  mutate(measure=ifelse(measure=="effectsize","mean", measure ),
         scenNr = gsub("NGA projection scenario ","", scenarioname)) %>%
  dplyr::select(-Run_Number, -CMcov_to_use) %>%
  dplyr::group_by(State, Archetype, LGA, year, month, measure, IPTyn, IPTicov.adj, IPTimap, scenarioname) %>%
  dplyr::summarize_all(.funs = "mean") %>%
  mutate(Run_Number = "aggregated mean") 

### Sum month
U1Dat_sclYr <- U1Dat_scl %>%
  ungroup() %>%
  dplyr::select(-month,-Run_Number) %>%
  dplyr::group_by(State, Archetype, LGA, year, measure, IPTyn, IPTicov.adj, IPTimap, scenarioname) %>%
  dplyr::summarize_all(.funs = "sum")


##-------------------------
#### Define plots
##-------------------------
#### Timeline plot at national level per scenario
f_timelinePlot_yr <- function(df, outcome, SAVE=TRUE){
  
  df <- as.data.frame(df)
  df$outvar <- df[,colnames(df)==outcome]
  df$outvar_scl <- df[,colnames(df)==paste0(outcome, "_scl")]
  
  pplot <- df %>% 
    dplyr::filter(IPTyn==1) %>%
    dplyr::group_by(year, measure,scenarioname) %>%
    dplyr::summarize(outvar = sum(outvar),
                     outvar_scl = sum(outvar_scl)) %>%
    pivot_wider(names_from='measure', values_from=c('outvar', 'outvar_scl')) %>%
    ggplot() + 
    geom_ribbon(aes(x=year, ymin=outvar_low_ci, ymax=outvar_up_ci , fill=scenarioname ), alpha=0.4)+
    geom_ribbon(aes(x=year, ymin=outvar_scl_low_ci, ymax=outvar_scl_up_ci , fill=scenarioname ), linetype="dashed", alpha=0.4)+
    geom_line(aes(x=year, y=outvar_mean , col=scenarioname ), size=1.3)+
    geom_line(aes(x=year, y=outvar_scl_mean , col=scenarioname ), linetype="dashed", size=1.3) +
    facet_wrap(~scenarioname) +
    scale_x_continuous(breaks=seq(fut_start_year, fut_end_year, 2), labels=seq(fut_start_year, fut_end_year, 2))+
    labs(x="", y=paste0("total ",outcome,"  in infants"),
         caption="dashed line = adjusted for IPTi\nshaded area confidence limits of protective efficacy estimates") +
    theme(legend.position = "none") +
    scale_color_manual(values=scencols) +
    scale_fill_manual(values=scencols) +
    customTheme
  
  if(SAVE)ggsave(paste0("timelinePlot_yr_",outcome,".png"), plot = pplot,path = outdir, width = 10, height = 8,  device = "png")

  return(pplot)
  
}

#### Barchart cases averted  2020 - 2030 - total
f_barPlot_yr <- function(df, outcome, errorbars=TRUE, SAVE=TRUE){
  
  df <- as.data.frame(df)
  df$outvar <- df[,colnames(df)==outcome]
  df$outvar_scl <- df[,colnames(df)==paste0(outcome, "_scl")]
  
  pplot <- df %>% 
    dplyr::filter(IPTyn==1) %>%
    mutate(diff = outvar -outvar_scl) %>%
    dplyr::group_by(year, measure,scenarioname) %>%
    dplyr::summarize(diff = sum(diff)) %>%
    pivot_wider(names_from='measure', values_from=c('diff')) %>%
    ggplot() + 
    geom_bar(aes(x=year, y=mean , fill=scenarioname ), stat="identity", size=1.3)+
    facet_wrap(~scenarioname) +
    scale_x_continuous(breaks=seq(fut_start_year, fut_end_year, 2), labels=seq(fut_start_year, fut_end_year, 2))+
    labs(x="", 
         y=paste0("total ",outcome," averted in infants"),
         caption="") +
    theme(legend.position = "none")+
    scale_color_manual(values=scencols) +
    scale_fill_manual(values=scencols) +
    customTheme
  
  
  if(errorbars==TRUE)pplot <- pplot + geom_errorbar(aes(x=year, ymin=low_ci, ymax=up_ci , group=scenarioname ),col="black",width=0.5, alpha=0.4) 
  
  if(SAVE)ggsave(paste0("barPlot_yr_",outcome,".png"), plot = pplot,path = outdir,width = 10, height = 8,  device = "png")
  
  return(pplot)
  
}

f_barPlot <- function(df, outcome, errorbars=TRUE, annualAverage =TRUE, SAVE=TRUE){
  
  df <- as.data.frame(df)
  df$outvar <- df[,colnames(df)==outcome]
  df$outvar_scl <- df[,colnames(df)==paste0(outcome, "_scl")]
  
  plotdat <- df %>% 
    dplyr::filter(IPTyn==1) %>%
    mutate(diff = outvar -outvar_scl) %>%
    dplyr::group_by(year, measure,scenarioname) %>%
    dplyr::summarize(diff = sum(diff)) %>%
    dplyr::group_by( measure,scenarioname) %>%
    dplyr::summarize(annualAverage = mean(diff),
                     totalAverted = sum(diff)) %>%
    mutate(scenNr = gsub("NGA projection scenario ","", scenarioname))
  
  if(annualAverage) {
    ylabel = paste0("annual average ",outcome," averted in infants\n(" ,fut_start_year, " to ",fut_end_year, ")")
    plotdat <- plotdat %>%
    dplyr::select(-totalAverted) %>%
    pivot_wider(names_from='measure', values_from=c('annualAverage'))
  }
  if(annualAverage==FALSE) {
    ylabel = paste0("total ",outcome," averted in infants\n(" ,fut_start_year, " to ",fut_end_year, ")")
    plotdat <- plotdat %>%
      dplyr::select(-annualAverage) %>%
    pivot_wider(names_from='measure', values_from=c('totalAverted')) 
  }
    
    pplot <- plotdat %>%
    ggplot() + 
    geom_bar(aes(x=scenNr, y=mean , fill=scenarioname ), stat="identity", size=1.3)+
    labs(x="Scenario", 
         y=ylabel,
         caption="") +
    theme(legend.position = "none")+
      scale_color_manual(values=scencols) +
      scale_fill_manual(values=scencols) +
      customTheme
    
  
  if(errorbars==TRUE)pplot <- pplot + geom_errorbar(aes(x=scenNr, ymin=low_ci, ymax=up_ci , group=scenarioname ),col="black",width=0.5, alpha=0.4) 
  
  if(SAVE)ggsave(paste0("barPlot_",outcome,".png"), plot = pplot,path = outdir, width = 10, height = 8,  device = "png")
    
  return(pplot)
  
}

##-------------------------
#### Generate Plots
##-------------------------
colnames(U1Dat_sclYr)

#### Timeline plot at national level per scenario
f_timelinePlot_yr(U1Dat_sclYr, "pos")
f_timelinePlot_yr(U1Dat_sclYr, "Cases")
f_timelinePlot_yr(U1Dat_sclYr, "Severe_cases")
f_timelinePlot_yr(U1Dat_sclYr, "Anaemia")
f_timelinePlot_yr(U1Dat_sclYr, "deaths")

#### Barchart cases averted  per year
f_barPlot_yr(U1Dat_sclYr, "pos")
f_barPlot_yr(U1Dat_sclYr, "Cases")
f_barPlot_yr(U1Dat_sclYr, "Severe_cases", errorbars=FALSE)
f_barPlot_yr(U1Dat_sclYr, "Anaemia")
f_barPlot_yr(U1Dat_sclYr, "deaths", errorbars=FALSE)

#### Barchart cases averted  2020 - 2030 - total or annual average 
f_barPlot(U1Dat_sclYr, "pos")
f_barPlot(U1Dat_sclYr, "Cases")
f_barPlot(U1Dat_sclYr, "Severe_cases", errorbars=FALSE)
f_barPlot(U1Dat_sclYr, "Anaemia")
f_barPlot(U1Dat_sclYr, "deaths", errorbars=FALSE)

