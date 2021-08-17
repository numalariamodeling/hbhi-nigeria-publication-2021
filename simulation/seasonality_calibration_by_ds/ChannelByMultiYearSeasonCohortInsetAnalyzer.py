import calendar
import datetime
import logging
import pandas as pd
import numpy as np
import os
import matplotlib.pyplot as plt

from calibtool import LL_calculators
from simtools.Analysis.BaseAnalyzers import BaseCalibrationAnalyzer


logger = logging.getLogger(__name__)


class ChannelByMultiYearSeasonCohortInsetAnalyzer(BaseCalibrationAnalyzer):
    """
    Base class implementation for similar comparisons of age-binned reference data to simulation output.
    """

    @classmethod
    def monthparser(self, x):
        if x == 0:
            return 12
        else:
            return datetime.datetime.strptime(str(x), '%j').month

    def __init__(self, site, weight=1, compare_fn=LL_calculators.gamma_poisson_pandas, **kwargs):
        super().__init__(reference_data=site.get_reference_data('entomology_by_season'),
                         weight=weight,
                         filenames=['output/ReportEventCounter.json',
                                    'output/ReportMalariaFiltered.json'])

        self.population_channel = 'Statistical Population'
        self.case_channel = 'Received_Treatment'
        self.prev_channel = 'PfHRP2 Prevalence'
        self.nmf_channel = 'Received_NMF_Treatment'
        self.comparison_channel = 'Treated Cases NMF Adjusted'
        self.compare_fn = compare_fn
        self.site_name = site.name

    def select_simulation_data(self, data, simulation):
        """
        Extract data from output data and accumulate in same bins as reference.
        """

        # Load data from simulation
        simdata = { self.case_channel : data[self.filenames[0]]['Channels'][self.case_channel]['Data'][-365:] }
        simdata[self.nmf_channel] = data[self.filenames[0]]['Channels'][self.nmf_channel]['Data'][-365:]

        simdata = pd.DataFrame(simdata)
        simdata[self.population_channel] = data[self.filenames[1]]['Channels'][self.population_channel]['Data']
        # inflate pop for undercounted denom
        simdata[self.population_channel] = simdata[self.population_channel]*1.2
        simdata[self.prev_channel] = data[self.filenames[1]]['Channels'][self.prev_channel]['Data']

        simdata[self.comparison_channel] = simdata[self.case_channel] + simdata[self.nmf_channel]
        # simdata[self.comparison_channel] = NMF_correction_dalrymple19(simdata[self.case_channel],
        #                                                               simdata[self.prev_channel])

        simdata = simdata[-365:].reset_index(drop=True)
        simdata['Time'] = simdata.index
        simdata['Day'] = simdata['Time'] % 365
        simdata['Month'] = simdata['Day'].apply(lambda x: self.monthparser((x+1) % 365))

        simdata = simdata.rename(columns={ self.population_channel : 'Trials',
                                           self.comparison_channel : 'Observations'})

        s1 = simdata.groupby('Month')['Trials'].agg(np.mean).reset_index()
        s2 = simdata.groupby('Month')['Observations'].agg(np.sum).reset_index()
        simdata = pd.merge(left=s1, right=s2, on='Month')
        simdata = simdata[['Month', 'Trials', 'Observations']]
        simdata = simdata.set_index(['Month'])

        return simdata

    @staticmethod
    def join_reference(sim, ref):
        sim.columns = sim.columns.droplevel(0)  # drop sim 'sample' to match ref levels
        return pd.concat({'sim': sim, 'ref': ref}, axis=1).dropna()

    def compare(self, sample):
        """
        Assess the result per sample, in this case the likelihood
        comparison between simulation and reference data.
        """
        return self.compare_fn(self.join_reference(sample, self.reference_data))

    def finalize(self, all_data):
        """
        Calculate the output result for each sample.
        """
        selected = list(all_data.values())

        # Stack selected_data from each parser, adding unique (sim_id) and shared (sample) levels to MultiIndex
        combine_levels = ['sample', 'sim_id', 'Counts']
        combined = pd.concat(selected, axis=1,
                             keys=[(s.tags.get('__sample_index__'), s.id) for s in all_data.keys()],
                             names=combine_levels)

        data = combined.groupby(level=['sample', 'Counts'], axis=1).mean()
        compare_results = data.groupby(level='sample', axis=1).apply(self.compare)

        head, tail = os.path.split(self.working_dir)
        iteration = int(tail.split('r')[-1])
        sample_index = [s.tags.get('__sample_index__') for s in all_data.keys()]

        ref = self.reference_data
        ref['incidence'] = ref['Observations']/ref['Trials']*1000

        for sample in list(set(sample_index)) :
            selected_index = [i for i, s in enumerate(all_data.keys()) if s.tags.get('__sample_index__') == sample]

            fig = plt.figure()
            ax = fig.gca()

            for n in selected_index:
                plot_df = selected[n].reset_index()
                plot_df['incidence'] = plot_df['Observations'] / plot_df['Trials']*1000
                ax.plot(plot_df['Month'], plot_df['incidence'], '-', color='r', linewidth=0.5, alpha=0.3)

            adf = pd.concat([selected[i].reset_index() for i in selected_index])
            plot_df = adf.groupby('Month').agg(np.mean).reset_index()
            plot_df['incidence'] = plot_df['Observations'] / plot_df['Trials']*1000
            ax.plot(plot_df['Month'], plot_df['incidence'],  '-o', color='r',
                    label='iter %d sample %d' % (iteration, sample))
            ax.plot(ref['Month'], ref['incidence'],
                    '-o', color='#7AC4CD', label='reference')
            ax.set_xlabel('Month')
            ax.set_ylabel('Treated Clinical Case incidence with NMF')
            # ax.set_ylim(-0.02, 8.02)
            ax.legend()

            fig.savefig(os.path.join(self.working_dir, '%s_sample_%d.png' % (self.site_name, sample_index[n])))
            plt.close(fig)

        return compare_results
