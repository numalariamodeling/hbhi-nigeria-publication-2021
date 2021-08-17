import pandas as pd
import numpy as np
from simtools.Analysis.BaseAnalyzers import BaseAnalyzer
import datetime
import os
import sys
sys.path.append('../')



class VectorNumbersAnalyzer(BaseAnalyzer):

    @classmethod
    def monthparser(self, x):
        if x == 0:
            return 12
        else:
            return datetime.datetime.strptime(str(x), '%j').month

    def __init__(self, expt_name, sweep_variables=None, working_dir=".", start_year=2020, end_year=2026):
        super(VectorNumbersAnalyzer, self).__init__(working_dir=working_dir,
                                                    filenames=["output/ReportMalariaFiltered.json"])
        self.sweep_variables = sweep_variables or ["LGA", "Run_Number"]
        self.inset_channels = ['Adult Vectors']
        self.expt_name = expt_name
        self.start_year = start_year
        self.end_year = end_year

    # added to bypass failed cases
    # def filter(self, simulation):
    #     return simulation.status.name == 'Succeeded'

    def select_simulation_data(self, data, simulation):

        simdata = pd.DataFrame({x: data[self.filenames[0]]['Channels'][x]['Data'] for x in self.inset_channels})
        simdata['Time'] = simdata.index

        simdata['Day'] = simdata['Time'] % 365
        simdata['month'] = simdata['Day'].apply(lambda x: self.monthparser((x + 1) % 365))
        simdata['year'] = simdata['Time'].apply(lambda x: int(x / 365) + self.start_year)

        for sweep_var in self.sweep_variables:
            if sweep_var in simulation.tags.keys():
                simdata[sweep_var] = simulation.tags[sweep_var]
        return simdata

    def finalize(self, all_data):

        selected = [data for sim, data in all_data.items()]
        if len(selected) == 0:
            print("No data have been returned... Exiting...")
            return

        if not os.path.exists(os.path.join(self.working_dir, self.expt_name)):
            os.mkdir(os.path.join(self.working_dir, self.expt_name))

        adf = pd.concat(selected).reset_index(drop=True)
        adf['date'] = adf.apply(lambda x: datetime.date(x['year'], x['month'], 1), axis=1)


        mean_channels = ['Adult Vectors']

        adf = adf.groupby(['LGA', 'date', 'Run_Number'])[mean_channels].agg(np.mean).reset_index()
        adf.to_csv(os.path.join(self.working_dir, self.expt_name, 'vector_numbers_monthly.csv'), index=False)


if __name__ == "__main__":

    from simtools.Analysis.AnalyzeManager import AnalyzeManager
    from simtools.SetupParser import SetupParser
    from simulation.load_paths import load_box_paths

    datapath, projectpath = load_box_paths()
    SetupParser.default_block = 'HPC'
    SetupParser.init()

    analyzer = VectorNumbersAnalyzer(expt_name='NGA_funestus_TR',
                                     sweep_variables=["Run_Number",
                                                      "LGA"],
                                     working_dir=os.path.join(projectpath, 'simulation_output', 'seasonality'))

    am = AnalyzeManager('1af6a43e-9dca-e911-a2c1-c4346bcb1555', analyzers=analyzer)
    am.analyze()