### ==========================================================================================
### HBHI modelling - Nigeria: IPTi effectiveness estimation and scaling of simulation outputs
### Feb 2020, MR
### Updated April 2020, separated aggregation of dataset from IPTi scaling per LGA
###
### Input: simout_tbl_withCI
### Output: aggregated datasets
### ====================================================================================


## Packages
pckg <- c("tidyverse", "plyr", "SDMTools", "gsubfn",  "readxl", "data.table")
lapply(pckg, require, character.only = TRUE)

table(tbl_U15.scl$scenario)
## ===============================
##### Aggregate
## ===============================
### Aggregate per archetype
tbl_U15.sclAggr <- tbl_U15.scl %>%
  dplyr::group_by(Archetype, scenario, scenarioNr, scenarioname, Scencov, year, Run_Number, IPTyn.f, measure) %>%
  dplyr::summarize(
    IPTicov.adj = mean(IPTicov.adj),
    #### U1
    pos.U1.pop = sum(pos.U1.pop),
    pos.U1.pop_scl = sum(pos.U1.pop_scl),
    Cases.U1.pop = sum(Cases.U1.pop),
    Cases.U1.pop_scl = sum(Cases.U1.pop_scl),
    Severe.cases.U1.pop = sum(Severe.cases.U1.pop),
    Severe.cases.U1.pop_scl = sum(Severe.cases.U1.pop_scl),
    Anaemia.U1.pop = sum(Anaemia.U1.pop),
    Anaemia.U1.pop_scl = sum(Anaemia.U1.pop_scl),
    deaths.U1.pop = sum(deaths.U1.pop),
    deaths.U1.pop_scl = sum(deaths.U1.pop_scl),
    
    #### U5
    pos.U5.pop = sum(pos.U5.pop),
    pos.U5.pop_scl = sum(pos.U5.pop_scl),
    Cases.U5.pop = sum(Cases.U5.pop),
    Cases.U5.pop_scl = sum(Cases.U5.pop_scl),
    Severe.cases.U5.pop = sum(Severe.cases.U5.pop),
    Severe.cases.U5.pop_scl = sum(Severe.cases.U5.pop_scl),
    Anaemia.U5.pop = sum(Anaemia.U5.pop),
    Anaemia.U5.pop_scl = sum(Anaemia.U5.pop_scl),
    deaths.U5.pop = sum(deaths.U5.pop),
    deaths.U5.pop_scl = sum(deaths.U5.pop_scl),
    
    #### Uall
    pos.Uall.pop = sum(pos.Uall.pop),
    pos.Uall.pop_scl = sum(pos.Uall.pop_scl),
    Cases.Uall.pop = sum(Cases.Uall.pop),
    Cases.Uall.pop_scl = sum(Cases.Uall.pop_scl),
    Severe.cases.Uall.pop = sum(Severe.cases.Uall.pop),
    Severe.cases.Uall.pop_scl = sum(Severe.cases.Uall.pop_scl),
    Anaemia.Uall.pop = sum(Anaemia.Uall.pop),
    Anaemia.Uall.pop_scl = sum(Anaemia.Uall.pop_scl),
    deaths.Uall.pop = sum(deaths.Uall.pop),
    deaths.Uall.pop_scl = sum(deaths.Uall.pop_scl),
    
    
    PfPR.U1_scl = wt.mean(PfPR.U1_scl, w = geopode.pop.0.1),
    incidence.U1_scl = wt.mean(incidence.U1_scl, w = geopode.pop.0.1),
    mortality.U1_scl = wt.mean(mortality.U1_scl, w = geopode.pop.0.1),
    
    PfPR.U1 = wt.mean(PfPR.U1, w = geopode.pop.0.1),
    incidence.U1 = wt.mean(incidence.U1, w = geopode.pop.0.1),
    mortality.U1 = wt.mean(mortality.U1, w = geopode.pop.0.1),
    
    PfPR.U5_scl = wt.mean(PfPR.U5_scl, w = geopode.pop.0.4),
    incidence.U5_scl = wt.mean(incidence.U5_scl, w = geopode.pop.0.4),
    mortality.U5_scl = wt.mean(mortality.U5_scl, w = geopode.pop.0.4),
    
    PfPR.U5 = wt.mean(PfPR.U5, w = geopode.pop.0.4),
    incidence.U5 = wt.mean(incidence.U5, w = geopode.pop.0.4),
    mortality.U5 = wt.mean(mortality.U5, w = geopode.pop.0.4),
    
    ### Uall
    PfPR.Uall_scl = wt.mean(PfPR.Uall_scl, w = geopode.pop),
    incidence.Uall_scl = wt.mean(incidence.Uall_scl, w = geopode.pop),
    mortality.Uall_scl = wt.mean(mortality.Uall_scl, w = geopode.pop),
    
    PfPR.Uall = wt.mean(PfPR.Uall, w = geopode.pop),
    incidence.Uall = wt.mean(incidence.Uall, w = geopode.pop),
    mortality.Uall = wt.mean(mortality.Uall, w = geopode.pop),
    
    ### Pop
    geopode.pop.0.1 = sum(geopode.pop.0.1),
    geopode.pop.0.4 = sum(geopode.pop.0.4),
    geopode.pop = sum(geopode.pop)
  ) %>%
  mutate(ArchetypeIPTIcov = paste0(Archetype, "\n (IPTi cov:", round_any(IPTicov.adj * 100, 10), ")"))

##### =====================================
### Aggregate national
##### =====================================
tbl_U15.sclAggrIPT <- tbl_U15.scl %>%
  dplyr::group_by(scenario, scenarioNr, scenarioname, Scencov, year, Run_Number, IPTyn.f, measure) %>%
  dplyr::summarize(
    IPTicov.adj = mean(IPTicov.adj),
    #### U1
    pos.U1.pop = sum(pos.U1.pop),
    pos.U1.pop_scl = sum(pos.U1.pop_scl),
    Cases.U1.pop = sum(Cases.U1.pop),
    Cases.U1.pop_scl = sum(Cases.U1.pop_scl),
    Severe.cases.U1.pop = sum(Severe.cases.U1.pop),
    Severe.cases.U1.pop_scl = sum(Severe.cases.U1.pop_scl),
    Anaemia.U1.pop = sum(Anaemia.U1.pop),
    Anaemia.U1.pop_scl = sum(Anaemia.U1.pop_scl),
    deaths.U1.pop = sum(deaths.U1.pop),
    deaths.U1.pop_scl = sum(deaths.U1.pop_scl),
    
    #### U5
    pos.U5.pop = sum(pos.U5.pop),
    pos.U5.pop_scl = sum(pos.U5.pop_scl),
    Cases.U5.pop = sum(Cases.U5.pop),
    Cases.U5.pop_scl = sum(Cases.U5.pop_scl),
    Severe.cases.U5.pop = sum(Severe.cases.U5.pop),
    Severe.cases.U5.pop_scl = sum(Severe.cases.U5.pop_scl),
    Anaemia.U5.pop = sum(Anaemia.U5.pop),
    Anaemia.U5.pop_scl = sum(Anaemia.U5.pop_scl),
    deaths.U5.pop = sum(deaths.U5.pop),
    deaths.U5.pop_scl = sum(deaths.U5.pop_scl),
    
    ### U1
    PfPR.U1_scl = wt.mean(PfPR.U1_scl, w = geopode.pop.0.1),
    incidence.U1_scl = wt.mean(incidence.U1_scl, w = geopode.pop.0.1),
    mortality.U1_scl = wt.mean(mortality.U1_scl, w = geopode.pop.0.1),
    
    PfPR.U1 = wt.mean(PfPR.U1, w = geopode.pop.0.1),
    incidence.U1 = wt.mean(incidence.U1, w = geopode.pop.0.1),
    mortality.U1 = wt.mean(mortality.U1, w = geopode.pop.0.1),
    
    ## U5
    PfPR.U5_scl = wt.mean(PfPR.U5_scl, w = geopode.pop.0.4),
    incidence.U5_scl = wt.mean(incidence.U5_scl, w = geopode.pop.0.4),
    mortality.U5_scl = wt.mean(mortality.U5_scl, w = geopode.pop.0.4),
    
    PfPR.U5 = wt.mean(PfPR.U5, w = geopode.pop.0.4),
    incidence.U5 = wt.mean(incidence.U5, w = geopode.pop.0.4),
    mortality.U5 = wt.mean(mortality.U5, w = geopode.pop.0.4),
    
    ### Uall
    PfPR.Uall_scl = wt.mean(PfPR.Uall_scl, w = geopode.pop),
    incidence.Uall_scl = wt.mean(incidence.Uall_scl, w = geopode.pop),
    mortality.Uall_scl = wt.mean(mortality.Uall_scl, w = geopode.pop),
    
    PfPR.Uall = wt.mean(PfPR.Uall, w = geopode.pop),
    incidence.Uall = wt.mean(incidence.Uall, w = geopode.pop),
    mortality.Uall = wt.mean(mortality.Uall, w = geopode.pop),
    
    ### Pop
    geopode.pop.0.1 = sum(geopode.pop.0.1),
    geopode.pop.0.4 = sum(geopode.pop.0.4),
    geopode.pop = sum(geopode.pop)
  )

tbl_U15.sclAggrNat <- tbl_U15.scl %>%
  dplyr::group_by(scenario, scenarioNr, scenarioname, Scencov, year, Run_Number, measure) %>%
  dplyr::summarize(
    IPTicov.adj = mean(IPTicov.adj),
    #### U1
    pos.U1.pop = sum(pos.U1.pop),
    pos.U1.pop_scl = sum(pos.U1.pop_scl),
    Cases.U1.pop = sum(Cases.U1.pop),
    Cases.U1.pop_scl = sum(Cases.U1.pop_scl),
    Severe.cases.U1.pop = sum(Severe.cases.U1.pop),
    Severe.cases.U1.pop_scl = sum(Severe.cases.U1.pop_scl),
    Anaemia.U1.pop = sum(Anaemia.U1.pop),
    Anaemia.U1.pop_scl = sum(Anaemia.U1.pop_scl),
    deaths.U1.pop = sum(deaths.U1.pop),
    deaths.U1.pop_scl = sum(deaths.U1.pop_scl),
    
    #### U5
    pos.U5.pop = sum(pos.U5.pop),
    pos.U5.pop_scl = sum(pos.U5.pop_scl),
    Cases.U5.pop = sum(Cases.U5.pop),
    Cases.U5.pop_scl = sum(Cases.U5.pop_scl),
    Severe.cases.U5.pop = sum(Severe.cases.U5.pop),
    Severe.cases.U5.pop_scl = sum(Severe.cases.U5.pop_scl),
    Anaemia.U5.pop = sum(Anaemia.U5.pop),
    Anaemia.U5.pop_scl = sum(Anaemia.U5.pop_scl),
    deaths.U5.pop = sum(deaths.U5.pop),
    deaths.U5.pop_scl = sum(deaths.U5.pop_scl),
    
    ### U1
    PfPR.U1_scl = wt.mean(PfPR.U1_scl, w = geopode.pop.0.1),
    incidence.U1_scl = wt.mean(incidence.U1_scl, w = geopode.pop.0.1),
    mortality.U1_scl = wt.mean(mortality.U1_scl, w = geopode.pop.0.1),
    
    PfPR.U1 = wt.mean(PfPR.U1, w = geopode.pop.0.1),
    incidence.U1 = wt.mean(incidence.U1, w = geopode.pop.0.1),
    mortality.U1 = wt.mean(mortality.U1, w = geopode.pop.0.1),
    
    ## U5
    PfPR.U5_scl = wt.mean(PfPR.U5_scl, w = geopode.pop.0.4),
    incidence.U5_scl = wt.mean(incidence.U5_scl, w = geopode.pop.0.4),
    mortality.U5_scl = wt.mean(mortality.U5_scl, w = geopode.pop.0.4),
    
    PfPR.U5 = wt.mean(PfPR.U5, w = geopode.pop.0.4),
    incidence.U5 = wt.mean(incidence.U5, w = geopode.pop.0.4),
    mortality.U5 = wt.mean(mortality.U5, w = geopode.pop.0.4),
    
    ### Uall
    PfPR.Uall_scl = wt.mean(PfPR.Uall_scl, w = geopode.pop),
    incidence.Uall_scl = wt.mean(incidence.Uall_scl, w = geopode.pop),
    mortality.Uall_scl = wt.mean(mortality.Uall_scl, w = geopode.pop),
    
    PfPR.Uall = wt.mean(PfPR.Uall, w = geopode.pop),
    incidence.Uall = wt.mean(incidence.Uall, w = geopode.pop),
    mortality.Uall = wt.mean(mortality.Uall, w = geopode.pop),
    
    ### Pop
    geopode.pop.0.1 = sum(geopode.pop.0.1),
    geopode.pop.0.4 = sum(geopode.pop.0.4),
    geopode.pop = sum(geopode.pop)
  )

## ============================
### Check population after aggregation 
## ============================
SelectedScenario = unique(tbl_U15.scl$scenario)[1]
SelectedRun_Number = unique(tbl_U15.scl$Run_Number)[1]

pop1 <- tbl_U15.scl %>%
  filter(year == 2020 & scenario == SelectedScenario & measure=="mean" & Run_Number==SelectedRun_Number) %>%
  group_by() %>%
  dplyr::select(geopode.pop, geopode.pop.0.4, geopode.pop.0.1) %>%
  summarize_all(.funs = "sum") %>%
  as.data.frame()
pop2 <- tbl_U15.sclAggr %>%
  filter(year == 2020 & scenario == SelectedScenario & measure=="mean" & Run_Number==SelectedRun_Number) %>%
  group_by() %>%
  dplyr::select(geopode.pop, geopode.pop.0.4, geopode.pop.0.1) %>%
  summarize_all(.funs = "sum") %>%
  as.data.frame()
pop3 <- tbl_U15.sclAggrNat %>%
  filter(year == 2020 & scenario == SelectedScenario & measure=="mean" & Run_Number==SelectedRun_Number) %>%
  group_by() %>%
  dplyr::select(geopode.pop, geopode.pop.0.4, geopode.pop.0.1) %>%
  summarize_all(.funs = "sum") %>%
  as.data.frame()

pop1 == pop2
pop1 == pop3
#print(pop1)
pop1$geopode.pop / sum(LGApop$geopode.pop)
pop1$geopode.pop.0.4 == sum(LGApop$geopode.pop.0.4)

if(pop1$geopode.pop == sum(LGApop$geopode.pop) & pop1$geopode.pop.0.4 == sum(LGApop$geopode.pop.0.4)) print("population matches")
if(pop1$geopode.pop != sum(LGApop$geopode.pop) | pop1$geopode.pop.0.4 != sum(LGApop$geopode.pop.0.4)) print("population does not match")
