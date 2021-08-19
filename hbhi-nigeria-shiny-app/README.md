
  <h1 align="center">Malaria intervention scenarios and projections for the 2021 - 2025 Nigerian National Malaria Strategic Plan: An R Shiny Application</h1>

  


<!-- TABLE OF CONTENTS -->
<details open="open">
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#running-the-shiny-application-locally">Running The Shiny Application Locally </a>
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

In partnership with the Nigerian Malaria Elimination Programme and the World Health Organization, we developed an [R Shiny Application](https://ifeomaozo.shinyapps.io/hbhi-nigeria/) to visualize data inputs and projections associated with the manuscript entitled "Application of mathematical modeling to inform national malaria intervention planning in Nigeria". Within the manuscript, we describe our approach for developing a mathematical model of malaria transmission for each of Nigeria's 774 districts for the period of 2010 - 2020. Using this model, we simulated four intervention scenarios, of interest to the Nigerian Malaria Elimination Program, from 2020 - 2030. This interactive Shiny application presents LGA-level intervention coverages and insecticide treated net efficacy inputs, and national, state and LGA-level projected trends and relative difference in malaria burden for the simulation period. This project was part of the WHO-initiated [High Burden to High Impact response](https://www.who.int/publications/i/item/WHO-CDS-GMP-2018.25) geared towards development of targeted strategies for intervention deployment in high burden malaria countries. 

![alt text](https://github.com/numalariamodeling/hbhi-nigeria-publication-2021/blob/main/hbhi-nigeria-shiny-app/input_data.PNG)


List of acronyms used within the app:
* Budget-prioritized plan (BPP)
* Business as Usual (BAU) 
* Case management (CM) 
* Demographic and Health Surveys (DHS) 
* High Burden to High Impact (HBHI) 
* Insecticide-treated nets (ITN)
* Intermittent Preventive Treatment in Infants (IPTi)
* Intermittent Preventive Treatement for Pregnant women (IPTp) 
* National Malaria Strategic Plan (NMSP)
* Seasonal Malaria Chemoprevention (SMC) 



### Built With

The app was developed using the [R Shiny package](https://shiny.rstudio.com/). Styling was based on the [Bootswatch Flatly theme](https://bootswatch.com/). A list of major R packages used in the app are listed in the [main ui page](https://github.com/numalariamodeling/hbhi-nigeria-publication-2021/blob/main/hbhi-nigeria-shiny-app/src/app/ui.R). 


<!-- GETTING STARTED -->
## Running The Shiny Application Locally 

To get a local copy up and running, follow these simple steps.

### Prerequisites

Download R and R studio following the instructions [here](https://rstudio-education.github.io/hopr/starting.html)

Clone this repo to the folder you would like to place the file in, either using the terminal (mac users), SourceTree or by simply downloading the zip file in the [main page](https://github.com/numalariamodeling/hbhi-nigeria-publication-2021).  

* terminal (mac users) 
  ```sh
  cd Documents 
  git clone https://github.com/numalariamodeling/hbhi-nigeria-publication-2021/tree/main/hbhi-nigeria-shiny-app
  ```

### Running The App 

1. Setup a password in the [server](https://github.com/numalariamodeling/hbhi-nigeria-publication-2021/blob/main/hbhi-nigeria-shiny-app/src/app/server.R). 

	* The current username and password is set as "3" but you can change it to whatever you like 

2. Navigate to the local [ui folder](https://github.com/numalariamodeling/hbhi-nigeria-publication-2021/blob/main/hbhi-nigeria-shiny-app/src/app/ui.R). 

	* Rstudio should prompt you to download all the required packages 


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
* [Perpetua Uhomoibhi @National Malaria Elimination Programme](https://nmcp.gov.ng/)
* [Ibrahim Maikore @ World Health Organization, Regional Office for Africa](https://www.afro.who.int/)
* [Abdisalan Noor and Bea Galatas @World Health Organization Global Malaria Programme](https://www.who.int/teams/global-malaria-programme)
* [Jaline Gerardin - Principal Investigator @NU Malaria Modeling Team](https://www.feinberg.northwestern.edu/faculty-profiles/az/profile.html?xid=44305)
* [Neena Parveen Dhanoa @NU Malaria modeling Team ](https://www.linkedin.com/in/neena-parveen-dhanoa-3686b11b3/)
* [All NU Malaria Modeling Team members](https://www.numalariamodeling.org/team.html)
* [Monique Ambrose and Caitlin Bever @Institute for Disease Modeling](https://www.idmod.org/team)



