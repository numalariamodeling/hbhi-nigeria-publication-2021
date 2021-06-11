# COVID-19 Healthcare Surge Model for Greater Toronto Area Hospitals

This folder contains the code and data used to run the model and generate
figures for the manuscript.

TODO: add citation

## Description of R code

### Generating parameter files

**Note: the necessary parameter files for running the model are already available in the data folder. See [the description of data files](#description-of-data) for more information.**

| File | Description |
| ---- | ----------- |
| [**`sample_parms.R`**](./code/sample_parms.R) | Starting point for creating parameter files. Reads in the data file of parameter ranges and value for sampling and calls the helper functions to output the parameter files: `ParmSet_Default.csv`, `OneWaySens_ParmList.csv`, `LHS_int_fix_drop_Reffective.csv`. |
| [`Full_LHS_fix.R`](./code/Full_LHS_fix.R) | Creates a matrix of parameter values using Latin hypercube sampling. |
| [`makeParmFile.R`](./code/makeParmFile.R) | Calculates the necessary parameters for the model and performs validity checks. Saves the final parameter file in the specified file. |

### Running the model

| File | Description |
| ---- | ----------- |
| [**`covid_modelphase1.R`**](./code/covid_modelphase1.R) | Starting point for running the model and generating outputs. Calls the other files to load in the correct parameter set. |
| [`covid_model_det.R`](./code/covid_model_det.R) | Defines the deterministic, compartmental surge model and defines the ODEs based on provided parameters. |
| [`epid.R`](./code/epid.R) | Defines the initial states of the model and calls the `deSolve` package to solve the ODEs. |
| [`RunParmsFile.R`](./code/RunParmsFile.R) | Reads in the provided parameters file and calls the `epid` function to perform the simulation. This file can run both the regular model and sensitivity analyses. |

### Creating the figures
| File | Description |
| ---- | ----------- |
| [`Figure 2 & 3.R`](./code/Figure%202%20&%203.R) | Creates: <li> **Figure 2:** Cumulative detected cases across simulated epidemic scenarios and observed data used for epidemic constraints. <li> **Figure 3:** Incident epidemic curves and health-care needs in the Greater Toronto Area (GTA) across three scenarios: default, fast/large, slow/small epidemics. |
| [`Figure 4 & 5.R`](./code/Figure%204%20&%205.R) | Creates: <li> **Figure 4:** Estimated surge and capacity for hospitalization at two acute care hospitals in the Greater Toronto Area. <li> **Figure 5:** Estimated surge and capacity for intensive care at two acute care hospitals in the Greater Toronto Area. <br> **Note: These figures require access to data from St. Michael's Hospital and St. Joseph's Health Centre.**  |
| [`Figure 6.R`](./code/Figure%206.R) | Creates: <li> **Figure 6:** One-way sensitivity analyses using default epidemic scenario for prevalence of non-ICU and ICU inpatients with COVID-19 at St. Michael’s Hospital. |

## Description of data

| File | Description | Type |
| ---- | ----------- | - |
| [`travel.csv`](./data/travel.csv) | Daily imported (travel-related) cases in Ontario, British Columbia and Toronto. <br> **Source:** [COVID-19 Canada Open Data Working Group](https://github.com/ishaberry/Covid19Canada) | Model Input |
| [`parametersForSampling`](./data/parametersForSampling.csv) | Parameter distributions, default values and ranges for sampling. Used to generate `ParmSet_Default.csv`, `OneWaySens_ParmList.csv`, `LHS_int_fix_drop_Reffective.csv`. | Model Input |
| [`ParmSet_Default.csv`](./data/ParmSet_Default.csv) | Parameter values for default epidemic scenario. | Model Input | 
| [`OneWaySens_ParmList.csv`](./data/OneWaySens_ParmList.csv) | Parameter values for one-way sensitivity analysis. Varies each parameter separately, while holding the other parameters fixed. | Model Input | 
| [`LHS_int_fix_drop_Reffective.csv`](./data/LHS_int_fix_drop_Reffective.csv) | Parameter values generated from Latin hypercube sampling (LHS). Holds `drop_Reffective` and fixed parameters constant while sampling the rest of the parameters using LHS. | Model Input |
| [`epidemic_f.csv`](./data/epidemic_f.csv) | Epidemic curves from Lombardy, Italy; Hong Kong, China; Signapore and Toronto, Canada. Used for creating a comparison figure between observed epidemics and simulated epidemic scenarios. <br> **Source:** <ol><li> [Johns Hopkins CSSE COVID-19 Data](https://github.com/CSSEGISandData/COVID-19) <li> [2020 coronavirus pandemic in Italy - Wikipedia](https://en.wikipedia.org/wiki/2020_coronavirus_pandemic_in_Italy) <li> [Confirmed COVID-19 cases in the Greater Toronto Area time series](./data/time_series_19-covid_GTA_clean_Mar25.xlsx) </ol> | External Data |
| [`time_series_19-covid_GTA_clean_Mar25.xlsx`](./data/time_series_19-covid_GTA_clean_Mar25.xlsx) | Time series data on confirmed COVID-19 cases in the Greater Toronto Area, broken down by region; as of March 25th. <br> **Sources:** <ol><li> [COVID-19 Canada Open Data Working Group](https://github.com/ishaberry/Covid19Canada) <li> [City of Toronto](https://www.toronto.ca/home/covid-19/media-room/moh-statements/) <li> [Province of Ontario](https://www.ontario.ca/page/2019-novel-coronavirus) <li> [Durham Region](https://www.durham.ca/en/health-and-wellness/novel-coronavirus-update.aspx#) <li> [York Region](https://www.york.ca/wps/portal/yorkhome/health/yr/infectiousdiseasesandprevention/covid19/covid19/!ut/p/z1/tVRNc4IwEP0tHjwyWT4q8YhoBRyx01aFXJwIUdNKUIha-usbnX6clOm05JBsMrtv814yDxEUISLoka-p5LmgW7WPSWfhO0Pf80YQTCzsggMTJzBsDIOujuaXBMOwOp7uQgDeBIN_bz_c9bGnw8hA5Hb9DBFEdglPUWximtrpkmnUMqlm6TjRaLrsaOYSIO1YGOs2PWcnQu7kBsVVsUhyIZmQbajy4lVtSsnl4XKwyTOmZka3ctMGLlYsUZQOZcpLRktWUpHuCnZUuYpoG5L8yFO9-x188rpx8TMvuDIcUPWkLiVWLeyrLR4NND9ydkJTkReZeoqnXyrl1XbQ_9ihBt5sFN6GZuGNZuH_R5zAB1d3FPzQHJjgGL6Le2aAw7BZ7cNmtQ-b1T5s9t_P_ipOUOeZypSNYuyO1wqWyo2m3C1HUY3HoejL2n4CFPOX_Z44ylPPRvomUdSoqe6yaYbNShPvvVAbukt8el5lt5Z5vzo5rdYHUF08-Q!!/dz/d5/L2dBISEvZ0FBIS9nQSEh/#.XnpqLohKhPa) <li> [Halton Region](https://www.halton.ca/For-Residents/Immunizations-Preventable-Disease/Diseases-Infections/New-Coronavirus) <li> [Peel Region](https://www.peelregion.ca/coronavirus/) </ol> | External Data |
