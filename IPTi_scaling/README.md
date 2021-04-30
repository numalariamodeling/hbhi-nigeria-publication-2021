
## Estimating IPTi coverage per LGA 

The effect of IPTi was estimated by combining coverage with efficacy parameter and applying these to the outcome predictions in infants. The reduction in malaria positives, cases, severe cases, anemic infants and deaths in infants due to IPTi was subtracted from the respective outcomes in children under the age of five and the total population. The adjustment was applied on the simulated number of events per outcome in the population. The adjustment was applied for each LGA, each run number and each intervention scenario per year. The parameters varying per LGA were the outcome predictions, the coverage and the population of infants. 

The script (2_IPTieffectivenessNigeria.R,) generates two adjustment tables that include the relative reductions due to IPTi in the U5 and Uall population
Outcomes that are scaled: malaria prevalence, uncomplicated cases, severe cases and deaths (can include anaemia if of interest).

Main assumptions: 
- IPTi only has an effect on infants up to an age of 12 months 
- IPTi adjustment was made at an annual level (averaging over the three doses)
- protective efficacy estimates from past clinical trials applicable to NGA setting today 
- IPTi coverage approximated by EPI vaccine coverage 

Planned improvements:
- IPTi adjustment per months 
- recalculate mortality reduction after scaling clinical cases by IPTi effectiveness

### [0_master.R](https://github.com/ManuelaRunge/hbhi-nigeria/blob/cherrypick/simulation/IPTi_scaling/0_master.R)  (wrapper for 1-3)
Uses source to run 1-3. 

### [1_IPTicoverageNigeria.R](https://github.com/ManuelaRunge/hbhi-nigeria/blob/cherrypick/simulation/IPTi_scaling/1_IPTicoverageNigeria.R)  (optional)
- input: DS_pen1_pre_18.csv,  DS_pen3_pre_18.csv and IPTI LGA.xlsx
- output: assumedIPTicov.csv (& Rdata) and figures

### [2_IPTieffectivenessNigeria.R](https://github.com/ManuelaRunge/hbhi-nigeria/blob/cherrypick/simulation/IPTi_scaling/2_IPTieffectivenessNigeria.R) (required)
- Input: Simulation output, population, CM coverage, IPTi coverage per LGA
-  Output: (1) Csv file with relative reductions in U1 for all outcomes measures, which
         can be applied to adjust the outcomes measures in U5 populations
        (2) Separate in-depth description of malaria outcomes in U1

### [3_combineIPTi_files.R](https://github.com/ManuelaRunge/hbhi-nigeria/blob/cherrypick/simulation/IPTi_scaling/3_combineIPTi_files.R) (required)
- Input:  simout_tbl_withCI per scenario saved in ~Box\NU-malaria-team\projects\hbhi_nigeria\simulation_output\<iteration><exp_name>
- Output:  simout_tbl_withCI for all scenarios combined in one file ~Box\NU-malaria-team\projects\hbhi_nigeria\simulation_output\<iteration>

### [4_IPTieffectivenessNigeria_descriptive.R](https://github.com/ManuelaRunge/hbhi-nigeria/blob/cherrypick/simulation/IPTi_scaling/4_IPTieffectivenessNigeria_descriptive.R) (optional) 
- Input: Simulation output scaled for IPTi at different aggregation levels
- Output: maps and figures saved in ~Box\NU-malaria-team\projects\hbhi_nigeria\IPTi\<iteration>

### [scalePredictionOutcomes_forIPTi.R](https://github.com/ManuelaRunge/hbhi-nigeria/blob/cherrypick/simulation/IPTi_scaling/scalePredictionOutcomes_forIPTi.R) (scaling template (not used))
- Simulation output: U5_PfPR_ClinicalIncidence_severeTreatment.csv, All_Age_Monthly_Cases.csv, 
- Input: IPTi adjustment tables: IPTi_adjustment.csv and  IPTi_adjustment.Uall.csv and simulation output csv files (overwritten with added columns !)
- Output:  Simulation output with scaled malaria event variables 

