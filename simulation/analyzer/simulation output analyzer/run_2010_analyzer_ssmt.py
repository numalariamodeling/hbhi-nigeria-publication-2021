from simtools.Analysis.SSMTAnalysis import SSMTAnalysis
from simtools.SetupParser import SetupParser
from analyze_2010_2020 import MonthlyPfPRAnalyzer, MonthlyTreatedCasesAnalyzer, monthlySevereTreatedByAgeAnalyzer, MonthlyNewInfectionsAnalyzer, monthlyEventAnalyzer
from analyze_2010_2020 import MonthlyPfPRAnalyzerByAge, MonthlyU1PfPRAnalyzer

start_year = 2010
end_year = 2020
experiments = {
    'NGA 2010-20': '606a2551-46d9-eb11-a9ec-b88303911bc1'
}

working_dir = "."


if __name__ == "__main__":
    SetupParser.default_block = 'HPC'
    SetupParser.init()

    analyzers = [
        MonthlyPfPRAnalyzer,
        MonthlyU1PfPRAnalyzer,
        MonthlyTreatedCasesAnalyzer,
        monthlySevereTreatedByAgeAnalyzer,
        monthlyEventAnalyzer,
        MonthlyNewInfectionsAnalyzer
                 ]

    for expt_name, exp_id in experiments.items():
        wi_name = "ssmt_analyzer_%s" % expt_name

        args_each = {'expt_name': expt_name,
                     'sweep_variables': ["Run_Number", "LGA"],
                     'working_dir': working_dir,
                     'start_year': start_year,
                     'end_year': end_year}
        analysis = SSMTAnalysis(experiment_ids=[exp_id],
                                analyzers=analyzers,
                                analyzers_args=[args_each]*len(analyzers),
                                analysis_name=wi_name)

        analysis.analyze()

