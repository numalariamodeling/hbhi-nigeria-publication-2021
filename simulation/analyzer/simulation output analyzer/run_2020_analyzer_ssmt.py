from simtools.Analysis.SSMTAnalysis import SSMTAnalysis
from simtools.SetupParser import SetupParser
from analyze_2010_2020 import MonthlyPfPRAnalyzer, MonthlyTreatedCasesAnalyzer, monthlySevereTreatedByAgeAnalyzer, MonthlyNewInfectionsAnalyzer, monthlyEventAnalyzer
from analyze_2010_2020 import MonthlyPfPRAnalyzerByAge, MonthlyU1PfPRAnalyzer, MonthlyBednetUsageAnalyzer





expt_ids = {
    #'NGA projection scenario 1': '66fe6ae0-53d9-eb11-a9ec-b88303911bc1',
    #'NGA projection scenario 2': 'f16c1814-58d9-eb11-a9ec-b88303911bc1',
#'NGA projection scenario 3': 'eeb8dadb-5ed9-eb11-a9ec-b88303911bc1',
#'NGA projection scenario 4': '93c9eda2-65d9-eb11-a9ec-b88303911bc1'
#'NGA projection scenario 5': '1f40875f-6cd9-eb11-a9ec-b88303911bc1',
#'NGA projection scenario 6': '87cc331d-73d9-eb11-a9ec-b88303911bc1',
#'NGA projection scenario 7': 'aa1680c6-78d9-eb11-a9ec-b88303911bc1'
}

working_dir = '.'
if __name__ == "__main__":
    SetupParser.default_block = 'HPC'
    SetupParser.init()

    start_year = 2020
    end_year = 2031

    analyzers = [
        MonthlyPfPRAnalyzer,
        MonthlyU1PfPRAnalyzer,
        monthlySevereTreatedByAgeAnalyzer,
        #MonthlyPfPRAnalyzerByAge,
        MonthlyTreatedCasesAnalyzer,
        #MonthlyBednetUsageAnalyzer,
        MonthlyNewInfectionsAnalyzer
       ]

    sweep_variables = ["Run_Number",
                       "LGA"
                       ]

    #output_dir = os.path.join(projectpath, 'simulation_output', '2020_to_2030_v5')
    #if not os.path.exists(output_dir):
        #os.mkdir(output_dir)

    start_year = 2020
    end_year = 2031

    for expt_name, exp_id in expt_ids.items():

        wi_name = "ssmt_analyzer_%s" % expt_name

        args_each = {'expt_name': expt_name,
                     'sweep_variables': sweep_variables,
                     'working_dir': working_dir,
                     'start_year': start_year,
                     'end_year': end_year
                     }
        analysis = SSMTAnalysis(experiment_ids=[exp_id],
                                analyzers=analyzers,
                                analyzers_args=[args_each]*len(analyzers),
                                analysis_name=wi_name)

        analysis.analyze()
