
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
      <a href="#getting-started-with-the-modeling-framework">Getting Started With The Simulation Modeling Framework</a></li>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#running-the-app">Running The App </a></li>
      </ul>
    </li>
    <li><a href="#troubleshooting-the-shiny-app">Troubleshooting The Shiny App</a></li>    
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgements">Acknowledgements</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## About The Project

The Nigerian Malaria Elimination Program (NMEP) together with the World Health Organization developed a targeted response to intervention deployment at the local government-level to inform the development of the 2021-2025 National Malaria Strategic Plan, as part of the [High Burden to High Impact response](https://www.who.int/publications/i/item/WHO-CDS-GMP-2018.25). The [Northwestern University Malaria Modeling Team](https://www.numalariamodeling.org/team.html) were recruited to create a mathematical modeling framework for predicting the impact of four NMEP proposed strategies on malaria morbidity and mortality in each of Nigeria's 774 local government areas (LGA). This repository contains scripts and data for replicating the LGA-level models described in the associated manuscript entitled "Application of mathematical modeling to inform national malaria intervention planning in Nigeria" and the modeling outputs also present in the manuscript and related R Shiny Application. 



## Summary Of The Modeling Framework
A three-step process was used to generate LGA-level predictions of potential national strategic plans. At the outset, the goal was to capture the intrinsic potential of each LGA to support malaria transmission in a baseline period before 2010 when most interventions were not scaled up nationwide. Data and geospatial modeled surfaces from 2010 or before were used to group LGAs into epidemiological archetypes. For each archetype, baseline malaria transmission was calibrated to 2010 data. Next, Nigeria’s intervention history from 2010-20 at the LGA level was imposed on the baseline models to generate 774 LGA-level models up through 2020. Last, various future intervention strategies were applied to the LGA models and intervention impact on prevalence, incidence, and mortality was assessed
 
![alt text](https://github.com/numalariamodeling/hbhi-nigeria-publication-2021/blob/main/Figure_1_model_overview_210715.png)


### Built With

Models were developed within EMOD v2.20, [an agent-based model of *Plasmodium falciparum* Transmission](https://malariajournal.biomedcentral.com/articles/10.1186/1475-2875-10-303), a coupling of models of temperature-dependent vector lifecycle and vector population dynamics, human disease and immunity, and intervention effects. 

![alt text](https://github.com/numalariamodeling/hbhi-nigeria-publication-2021/blob/main/EMOD.png) 


<!-- GETTING STARTED -->
## Getting Started With The Simulation Modeling Framework

### Prerequisites

Install Python 3.6 and dtk-tools following the instructions [here](http://institutefordiseasemodeling.github.io/dtk-tools/gettingstarted.html. DTK-tools are a set of generic modules created for configuring disease and vector-related simulations, and intervention campaigns. 

DTK-tools malaria package is also required as it contains module specific for modeling malaria. Installation instructions can be found [here](https://github.com/aouedraogo/dtk-tools-malaria). 


### Seasonality Calibration

Four scripts are provided for replicating archetype-level seasonality calibrations 

1. [Helper.py] (https://github.com/numalariamodeling/hbhi-nigeria-publication-2021/blob/main/simulation/seasonality_calibration_by_ds/Helpers.py): Include a function for setting priors on monthly habitats and another function for importing and processing facility-level incidence data from the Rapid Impact Assessment (RIA) study conducted by the NMEP. Incidence data is used to compare simulated incidence 


2.[seasonality_calib.py](https://github.com/numalariamodeling/hbhi-nigeria-publication-2021/blob/main/simulation/seasonality_calibration_by_ds/seasonality_calib.py): Contains a functions and scripts for calibrating seasonality 

3. [grab_best_plots.py](https://github.com/numalariamodeling/hbhi-nigeria-publication-2021/blob/main/simulation/seasonality_calibration_by_ds/grab_best_plots.py): Function and script for obtaining the best fitting archetypal seasonality plots and their values. 

4. [replot_seasonality_best_fit.py](https://github.com/numalariamodeling/hbhi-nigeria-publication-2021/blob/main/simulation/seasonality_calibration_by_ds/replot_seasonality_best_fit.py): Classes and functions for plotting the best archetype seasonality fits, their corresponding incidence values, and 95% confidence intervals.  

Data inputs to the calibration - demographics and air temperature per LGA are provided here. RIA and LGA population data is available from the NMEP on request. 


3. Click on "Run App" and the application will launch resembling the online version [here](https://ifeomaozo.shinyapps.io/hbhi-nigeria/).

 	* Type in the username and password that you chose in #1 
	* Make desired queries and download corresponding outputs  



<!-- TROUBLESHOOT-->
## Troubleshooting The Shiny App 

Sometimes issues may arise within the Shiny app that require users to troubleshoot. One way to do this is to use the ``` browser() ``` call between the lines of code that you want to investigate and then step through the code in the console by running small snippets in the Console until the bug is identified.  

_For more information on debugging shiny applications, please refer to the [Documentation](https://shiny.rstudio.com/articles/debugging.html)_





<!-- CONTACT -->
## Contact

Ifeoma Ozodiegwu [Research Assistant Professor, Northwestern University (NU).](https://www.feinberg.northwestern.edu/faculty-profiles/az/profile.html?xid=52373)
 Email - ifeoma.ozodiegwu@northwestern.edu 

Project Link: [https://ifeomaozo.shinyapps.io/hbhi-nigeria/](https://ifeomaozo.shinyapps.io/hbhi-nigeria/)



<!-- ACKNOWLEDGEMENTS -->
## Acknowledgements
* [Perpetua Uhomoibhi @Nigerian Malaria Elimination Programme](https://nmcp.gov.ng/)
* [Ibrahim Maikore @ World Health Organization, Regional Office for Africa](https://www.afro.who.int/)
* [Abdisalan Noor and Bea Galatas @World Health Organization Global Malaria Programme](https://www.who.int/teams/global-malaria-programme)
* [Jaline Gerardin - Principal Investigator @NU Malaria Modeling Team](https://www.feinberg.northwestern.edu/faculty-profiles/az/profile.html?xid=44305)
* [Neena Parveen Dhanoa @NU Malaria modeling Team ](https://www.linkedin.com/in/neena-parveen-dhanoa-3686b11b3/)
* [All NU Malaria Modeling Team members](https://www.numalariamodeling.org/team.html)
* [Monique Ambrose and Caitlin Bever @Institute for Disease Modeling](https://www.idmod.org/team)



