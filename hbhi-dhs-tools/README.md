
  <h1 align="center">Demographic and Health Survey Analysis Tools</h1>

  


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
      <a href="#getting-started-on-using-the-dhs-analysis-tools ">Getting started on using the DHS Analysis Tools Locally </a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#running-the-scripts">Running The Scripts</a></li>
      </ul>
    </li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgements">Acknowledgements</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## About The Project

We developed a set of tools for analyzing the Demographic and Health Surveys at the geopolitical, state, LGA-level and for  different epidemiological archetypes as described in our study entitled "Application of mathematical modeling to inform national malaria intervention planning in Nigeria". These tools are extendable in that the same script can be used for different indicators with very little modifications.   


Acronyms used within the script:
* Epidemiological Archetypes/Representative District (repDS)
* Geopolitical zone (GPZ) 



### Built With

All scripts were written using R programming language 


<!-- GETTING STARTED -->
## Getting started on using the DHS Analysis Tools 

### Prerequisites

Download R and R studio following the instructions [here](https://rstudio-education.github.io/hopr/starting.html)

Clone this repo to the folder you would like to place the file in, either using the terminal (mac users), SourceTree or by simply downloading the zip file in the [main page](https://github.com/numalariamodeling/hbhi-nigeria-publication-2021).  

* terminal (mac users) 
  ```sh
  cd Documents 
  git clone https://github.com/numalariamodeling/hbhi-nigeria-publication-2021/tree/main/hbhi-nigeria-shiny-app
  ```

### Running The Scripts

1. Open up the master script [here](https://github.com/numalariamodeling/hbhi-nigeria-publication-2021/blob/main/hbhi-dhs-tools/0_master.R). Ensure that file paths correspond to the file paths that links to your personal data directory for the DHS and the generic functions directories [here](https://github.com/numalariamodeling/hbhi-nigeria-publication-2021/tree/main/hbhi-dhs-tools/1_variables_scripts/generic_functions). Also supply links to the shapefiles [here] (https://github.com/numalariamodeling/hbhi-nigeria-publication-2021/tree/main/hbhi-dhs-tools/LGA_shapefiles/Nigeria_LGAs_shapefile_191016) and [here](https://github.com/numalariamodeling/hbhi-nigeria-publication-2021/tree/main/hbhi-nigeria-shiny-app/src/app/data/shapefiles/gadm36_NGA_shp)and the repDS file [here](https://github.com/numalariamodeling/hbhi-nigeria-publication-2021/blob/main/simulation_inputs/LGA_and_respective_archetype.csv). 


2. Navigate to [analysis_variables_requirements_manuscript_manuscript.csv](https://github.com/numalariamodeling/hbhi-nigeria-publication-2021/blob/main/hbhi-dhs-tools/analysis_variables_requirements.csv) if you would like to replicate manuscript figures and simulation inputs based on the DHS or this [csv](https://github.com/numalariamodeling/hbhi-nigeria-publication-2021/blob/main/hbhi-dhs-tools/analysis_variables_requirements.csv) if you want additional DHS estimates. Ensure that all functions and indicators files are correctly linked.  


3. Highlight the master script and click run to generate output 





<!-- CONTACT -->
## Contact

Ifeoma Ozodiegwu [Research Assistant Professor, Northwestern University (NU).](https://www.feinberg.northwestern.edu/faculty-profiles/az/profile.html?xid=52373)
 Email - ifeoma.ozodiegwu@northwestern.edu 

Project Link: [https://github.com/numalariamodeling/hbhi-nigeria-publication-2021/tree/main/hbhi-dhs-tools](https://github.com/numalariamodeling/hbhi-nigeria-publication-2021/tree/main/hbhi-dhs-tools)



<!-- ACKNOWLEDGEMENTS -->
## Acknowledgements
* [Perpetua Uhomoibhi @National Malaria Elimination Programme](https://nmcp.gov.ng/)
* [Ibrahim Maikore @ World Health Organization, Regional Office for Africa](https://www.afro.who.int/)
* [Abdisalan Noor and Bea Galatas @World Health Organization Global Malaria Programme](https://www.who.int/teams/global-malaria-programme)
* [Jaline Gerardin - Principal Investigator @NU Malaria Modeling Team](https://www.feinberg.northwestern.edu/faculty-profiles/az/profile.html?xid=44305)
* [All NU Malaria Modeling Team members](https://www.numalariamodeling.org/team.html)
* [Monique Ambrose and Caitlin Bever @Institute for Disease Modeling](https://www.idmod.org/team)



