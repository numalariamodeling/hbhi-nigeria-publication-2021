import pandas as pd
import numpy as np
from simtools.Analysis.BaseAnalyzers import BaseAnalyzer
import matplotlib.pyplot as plt
import datetime
import os
import sys
sys.path.append('../')
from load_paths import load_box_paths

datapath, projectpath = load_box_paths()


class DailyBitesAnalyzer(BaseAnalyzer):

    def __init__(self, expt_name, channels=None, rdf=pd.DataFrame(), sweep_variables=None, working_dir="."):
        super(DailyBitesAnalyzer, self).__init__(working_dir=working_dir,
                                                 filenames=["output/ReportMalariaFiltered.json"]
                                                   )
        self.sweep_variables = sweep_variables or ["LGA", "Run_Number"]
        self.channels = channels or ['Daily Bites per Human']
        self.rdf = rdf
        self.expt_name = expt_name

    def select_simulation_data(self, data, simulation):

        simdata = pd.DataFrame( { x : data[self.filenames[0]]['Channels'][x]['Data'] for x in self.channels })
        simdata = simdata[-365:]
        simdata['Time'] = simdata.index

        for sweep_var in self.sweep_variables:
            if sweep_var in simulation.tags.keys():
                simdata[sweep_var] = simulation.tags[sweep_var]
        return simdata

    def finalize(self, all_data):

        selected = [data for sim, data in all_data.items()]
        if len(selected) == 0:
            print("No data have been returned... Exiting...")
            return

        adf = pd.concat(selected).reset_index(drop=True)
        min_bites = 1
        max_bites = 200
        hdf = pd.DataFrame()
        for lga, lga_df in adf.groupby('LGA') :
            df = lga_df.groupby('Habitat_Multiplier')[self.channels[0]].agg(np.max).reset_index()
            df = df[(df[self.channels[0]] >= min_bites) & (df[self.channels[0]] <= max_bites)]
            sdf = pd.DataFrame( { 'LGA' : [lga],
                                  'min_hab' : [np.min(df['Habitat_Multiplier'])],
                                  'max_hab' : [np.max(df['Habitat_Multiplier'])],
                                  })
            hdf = pd.concat([hdf, sdf])
        hdf.to_csv(os.path.join(self.working_dir, 'min_max_hab_to_sample_for_archetype_pfpr.csv'), index=False)


if __name__ == "__main__":

    from simtools.Analysis.AnalyzeManager import AnalyzeManager
    from simtools.SetupParser import SetupParser

    SetupParser.default_block = 'HPC'
    SetupParser.init()

    analyzer = DailyBitesAnalyzer(expt_name='PfPR_daily_bites',
                                     sweep_variables=["Run_Number",
                                                      "LGA",
                                                      "Habitat_Multiplier"
                                                      ],
                                     working_dir=os.path.join(projectpath, 'simulation_output', 'prevalence'))

    am = AnalyzeManager('348eed28-ae21-ea11-a2c3-c4346bcb1551', analyzers=analyzer)
    am.analyze()