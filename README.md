
  <h1 align="center">Application of Mathematical Modeling to Inform National Malaria Intervention Planning in Nigeria </h1>

  


<!-- TABLE OF CONTENTS -->
<details open="open">
  <summary>Table of Contents</summary>
  <ol>
    <li><a href="#about-the-project">About The Project</a> 
    <li><a href="#summary-of-the-modeling-framework">Summary Of The Modeling Framework </a></li>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started-with-the-simulation-modeling-framework">Getting Started With The Simulation Modeling Framework</a></li>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#seasonality-calibration">Seasonality Calibration</a></li>
        <li><a href="#baseline-calibration">Baseline Calibration</a</li>
	<li><a href="#historical-simulations">Historical Simulations</a></li>
	<li><a href="#future-projections">Future Projections</a></li>
      </ul>
    </li>
	<li>
	<a href="#Post-processing">Post processing</a></li> 
	<ul>	
        <li><a href="#IPTi">IPTi</a></li>
		<li><a href="#IPTp">IPTp</a></li>
	</ul>
	<li><a href="#analyzers">Analyzers</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgements">Acknowledgements</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## About the Project

The Nigerian Malaria Elimination Program (NMEP) together with the World Health Organization developed a targeted response to intervention deployment at the local government-level to inform the development of the 2021-2025 National Malaria Strategic Plan, as part of the [High Burden to High Impact response](https://www.who.int/publications/i/item/WHO-CDS-GMP-2018.25). The [Northwestern University Malaria Modeling Team](https://www.numalariamodeling.org/team.html) were recruited to create a mathematical modeling framework for predicting the impact of four NMEP proposed strategies on malaria morbidity and mortality in each of Nigeria's 774 local government areas (LGA). This repository contains scripts and data for replicating the LGA-level models described in the associated manuscript entitled "Application of mathematical modeling to inform national malaria intervention planning in Nigeria" and the modeling outputs also present in the manuscript and related [R Shiny Application](https://ifeomaozo.shinyapps.io/hbhi-nigeria/). 



## Summary of the Modeling Framework
A three-step process was used to generate LGA-level predictions of potential national strategic plans. At the outset, the goal was to capture the intrinsic potential of each LGA to support malaria transmission in a baseline period before 2010 when most interventions were not scaled up nationwide. Data and geospatial modeled surfaces from 2010 or before were used to group LGAs into epidemiological archetypes. For each archetype, baseline malaria transmission was calibrated to 2010 data. Next, Nigeria’s intervention history from 2010-20 at the LGA level was imposed on the baseline models to generate 774 LGA-level models up through 2020. Last, various future intervention strategies were applied to the LGA models and intervention impact on prevalence, incidence, and mortality was assessed
 
![alt text](https://github.com/numalariamodeling/hbhi-nigeria-publication-2021/blob/main/Figure_1_model_overview_210715.png)


### Built With

Models were developed within [EMOD](https://docs.idmod.org/projects/emod-malaria/en/latest/index.html) v2.20, [an agent-based model of *Plasmodium falciparum* Transmission](https://malariajournal.biomedcentral.com/articles/10.1186/1475-2875-10-303), a coupling of models of temperature-dependent vector lifecycle and vector population dynamics, human disease and immunity, and intervention effects. 

![alt text](https://github.com/numalariamodeling/hbhi-nigeria-publication-2021/blob/main/EMOD.png) 


<!-- GETTING STARTED -->
## Getting Started With The Simulation Modeling Framework

### Prerequisites
Install Python 3.6 and dtk-tools following the instructions [here](http://institutefordiseasemodeling.github.io/dtk-tools/gettingstarted.html). dtk-tools is a set of generic modules created for configuring disease and vector-related simulations, and intervention campaigns in EMOD, and is available upon request from the Institute for Disease Modeling.

The dtk-tools-malaria package is also required as it contains modules specific for modeling malaria. Installation instructions can be found [here](https://github.com/aouedraogo/dtk-tools-malaria) and requests for access should also be directed to the Institute for Disease Modeling.



### Seasonality Calibration

Five scripts are provided for replicating archetype-level seasonality calibrations 

1. [SeasonalityCalibSite.py](https://github.com/numalariamodeling/hbhi-nigeria-publication-2021/blob/main/simulation/seasonality_calibration_by_ds/SeasonalityCalibSite.py): Python module with class for getting reference incidence data per LGA and importing the [analyzer](https://github.com/numalariamodeling/hbhi-nigeria-publication-2021/blob/main/simulation/seasonality_calibration_by_ds/ChannelByMultiYearSeasonCohortInsetAnalyzer.py) script for comparing simulation and incidence data.  

2. [Helper.py](https://github.com/numalariamodeling/hbhi-nigeria-publication-2021/blob/main/simulation/seasonality_calibration_by_ds/Helpers.py): Includes a function for setting priors on monthly habitats and another function for importing and processing facility-level incidence data from the Rapid Impact Assessment (RIA) study conducted by the NMEP. Incidence data is used to compare simulated incidence 


3. [seasonality_calib.py](https://github.com/numalariamodeling/hbhi-nigeria-publication-2021/blob/main/simulation/seasonality_calibration_by_ds/seasonality_calib.py): Contains functions and scripts for calibrating seasonality 

4. [grab_best_plots.py](https://github.com/numalariamodeling/hbhi-nigeria-publication-2021/blob/main/simulation/seasonality_calibration_by_ds/grab_best_plots.py): Function and script for obtaining the best fitting archetypal seasonality plots and their values. 

5. [replot_seasonality_best_fit.py](https://github.com/numalariamodeling/hbhi-nigeria-publication-2021/blob/main/simulation/seasonality_calibration_by_ds/replot_seasonality_best_fit.py): Classes and functions for plotting the best archetype seasonality fits, their corresponding incidence values, and 95% confidence intervals.  

Data inputs to the seasonality calibration - demographics and climate per LGA are provided [here](https://github.com/numalariamodeling/hbhi-nigeria-publication-2021/tree/main/simulation_inputs/demographics_and%20climate_files). RIA and LGA population data are available from the NMEP on request. 


### Baseline Calibration

Five scripts are provided for setting baseline transmission intensity 

1. [sweep_biting_rates.py](https://github.com/numalariamodeling/hbhi-nigeria-publication-2021/blob/main/simulation/baseline_calibration/sweep_biting_rates.py): For running a sweep of simulations to sample monthly larval habitats using vector relative abundance values.  

2. [analyze_daily_bites_per_human.py](https://github.com/numalariamodeling/hbhi-nigeria-publication-2021/blob/main/simulation/baseline_calibration/analyze_daily_bites_per_human.py): Analyzes simulation results from #1 for daily mosquito bites between 1 and 200 to produce associated minimum and maximum larval habitats scale factors to sample when matching *Pf*PR in the simulation to the 2010 MIS. 

3. [sweep_seasonal_archetypes.py](https://github.com/numalariamodeling/hbhi-nigeria-publication-2021/blob/main/simulation/baseline_calibration/sweep_seasonal_archetypes.py): Comprises dtk related configuration builders and scripts for running 50 year burn-ins to establish population immunity (in the absence of ITN use) using larval habitat values, estimated from seasonality calibrations, and in the presence of 2010 archetype-level case management estimates from the Nigeria Malaria Indicator Survey (MIS). 

4. [sweep_2010_PfPR_with_ITN.py](https://github.com/numalariamodeling/hbhi-nigeria-publication-2021/blob/main/simulation/baseline_calibration/sweep_2010_PfPR_with_ITN.py): Script for applying a scaling factor on the monthly vector larval habitat availability to reproduce the 2010 MIS U5 *Pf*PR, in the presence of the observed 2010 ITN usage and case management (CM) coverage. 

5. [analyze_pfpr_itn_2010.py](https://github.com/numalariamodeling/hbhi-nigeria-publication-2021/blob/main/simulation/baseline_calibration/analyze_pfpr_itn_2010.py): Plots the output of sweeps showcasing the larval habitat scale factors and simulated U5 *Pf*PR match to the 2010 MIS  U5 *Pf*PR. 


Data inputs to the baseline calibration - 2010 MIS  archetype case management data is linked [here](https://github.com/numalariamodeling/hbhi-nigeria-publication-2021/blob/main/simulation_inputs/archetype/arch_med_10_v2.csv), 2010 MIS archetype ITN data is linked [here](https://github.com/numalariamodeling/hbhi-nigeria-publication-2021/blob/main/simulation_inputs/archetype/ITN_archetype_10_v4.csv), 2010 MIS archetype *Pf*PR data is linked [here](https://github.com/numalariamodeling/hbhi-nigeria-publication-2021/blob/main/simulation_inputs/archetype/PfPr_archetype_10_v2.csv) and relative vector abundance input files are [here](https://github.com/numalariamodeling/hbhi-nigeria-publication-2021/blob/main/simulation_inputs/DS_vector_rel_abundance.csv)

### Historical Simulations

1. [run_LGA_to_present.py](https://github.com/numalariamodeling/hbhi-nigeria-publication-2021/blob/main/simulation/run_LGA_to_present.py): Used for running 11 year historical simulations from 2010-2020. 

Intervention inputs files required for running the simulation - case management, insecticide treated net use and seasonal malaria chemoprevention (SMC) - can be found [here](https://github.com/numalariamodeling/hbhi-nigeria-publication-2021/tree/main/simulation_inputs/historical%20projections)


### Future Projections 

1. [run_LGA_2020_forward.py](https://github.com/numalariamodeling/hbhi-nigeria-publication-2021/blob/main/simulation/run_LGA_2020_forward.py): Used for running 11 year historical simulations from 2020-2030. 

Scenario files required for running the simulation - case management, insecticide treated net use, SMC, Intermittent preventive treatment in pregnancy (IPTp), intemittent preventive treatment in infants (IPTp) - can be found [here](https://github.com/numalariamodeling/hbhi-nigeria-publication-2021/tree/main/simulation_inputs/future%20projections)


<!-- POST-PROCESSING-->
## Post-processing 

Adjustment for the impact of IPTp and IPTi on burden projections are done outside the simulation. Adjustment for IPTi occurs before the IPTp adjustment in order to generate relative reduction tables per LGA, which are then used to adjust simulation outputs during the IPTp adjustment.The following scripts are used for post-postprocessing:

### IPTi

1. [master.R](https://github.com/numalariamodeling/hbhi-nigeria-publication-2021/blob/main/IPTi_scaling/master.R): This master script sources and runs associated adjustment scripts for specified scenarios. Included in the scripts are descriptions of assumptions, experiment steps, and prerequisites.   

Since IPTi is only applied in scenario 2, only the case management coverages for scenario 2 is required and it is available [here](https://github.com/numalariamodeling/hbhi-nigeria-publication-2021/blob/main/simulation_inputs/future%20projections/CM/cm_scenario2_increase80_2020_2030.csv). BecauseIPTi has never been historically implemented in Nigeria, Expanded Programme on Immunization coverages for the [first, second and third doses of pentavalent diphtheria, tetanus and pertussis vaccine](https://github.com/numalariamodeling/hbhi-nigeria-publication-2021/blob/main/simulation_inputs/future%20projections/IPTi/assumedIPTicov.csv) were extracted from the 2018 DHS and used to substitute for historical coverages as both interventions are expected to be rolled out simultaneously. 


### IPTp 

1. [simAdjustments_mortality_MiP_IPTp_IPTi.R](https://github.com/numalariamodeling/hbhi-nigeria-publication-2021/blob/main/IPTp_mortality_postprocessing/simAdjustments_mortality_MiP_IPTp_IPTi.R): This master script connects to functions and additional scripts for adjusting the simulation output for the impact of IPTp on malaria burden. A description is included on how to use the script as well as prerequisites. 

IPTp scenario coverages is located [here](https://github.com/numalariamodeling/hbhi-nigeria-publication-2021/tree/main/simulation_inputs/future%20projections/IPTp). Scenario adjustment information for IPTp is available [here](https://github.com/numalariamodeling/hbhi-nigeria-publication-2021/blob/main/IPTp_mortality_postprocessing/scenario_adjustment_info.csv). 



<!-- Analyzers-->
## Analyzers

Several simulation output analyzers, plotting scripts, and related functions for plotting projected trends, relative reductions and replicating the result tables within the manuscript are included in this repository [here](https://github.com/numalariamodeling/hbhi-nigeria-publication-2021/tree/main/simulation/analyzer). Additional plotting functions are available within the [R shiny Application](https://ifeomaozo.shinyapps.io/hbhi-nigeria/) used to visualize manuscript outputs [here](https://github.com/numalariamodeling/hbhi-nigeria-publication-2021/blob/main/hbhi-nigeria-shiny-app/src/app/functions.R).


<!-- CONTACT -->
## Contact

For IPTi-specific inquiries, contact Manuela Runge, [Postdoctoral Fellow, Northwestern University](https://www.numalariamodeling.org/team.html). Email - manuela.runge@northwestern.edu

For IPTp-specific questions, contact Monique Ambrose, [Senior Research Scientist, Institute for Disease Modeling](https://www.idmod.org/team). Email - mambrose@idmod.org

For all other inquiries, contact Ifeoma Ozodiegwu, [Research Assistant Professor, Northwestern University (NU).](https://www.feinberg.northwestern.edu/faculty-profiles/az/profile.html?xid=52373)
 Email - ifeoma.ozodiegwu@northwestern.edu 

Project Link: [https://github.com/numalariamodeling/hbhi-nigeria-publication-2021](https://github.com/numalariamodeling/hbhi-nigeria-publication-2021)



<!-- ACKNOWLEDGEMENTS -->
## Acknowledgements
* [Perpetua Uhomoibhi @National Malaria Elimination Programme](https://nmcp.gov.ng/)
* [Ibrahim Maikore @ World Health Organization, Regional Office for Africa](https://www.afro.who.int/)
* [Abdisalan Noor, Bea Galatas and Tamara Ehler @World Health Organization Global Malaria Programme](https://www.who.int/teams/global-malaria-programme)
* [Jaline Gerardin - Principal Investigator @NU Malaria Modeling Team](https://www.feinberg.northwestern.edu/faculty-profiles/az/profile.html?xid=44305)
* [All NU Malaria Modeling Team members](https://www.numalariamodeling.org/team.html)
* [Monique Ambrose and Caitlin Bever @Institute for Disease Modeling](https://www.idmod.org/team)



