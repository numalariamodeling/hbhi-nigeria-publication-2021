from simtools.Analysis.AnalyzeManager import AnalyzeManager
from simtools.SetupParser import SetupParser
import copy
import pandas as pd
import numpy as np
from simtools.Analysis.BaseAnalyzers import BaseAnalyzer
import datetime
import os
import sys
sys.path.append('../')
import matplotlib.pyplot as plt
import matplotlib as mpl
import calendar
mpl.rcParams['pdf.fonttype'] = 42

projectpath = r'C:\Users\dhano_5\Box\NU-malaria-team\projects\hbhi_nigeria'


class SeasonalityPlotter(BaseAnalyzer):

    @classmethod
    def monthparser(self, x):
        if x == 0:
            return 12
        else:
            return datetime.datetime.strptime(str(x), '%j').month

    def __init__(self, expt_name, sample, hfca, ax, sweep_variables=None, working_dir="."):
        super(SeasonalityPlotter, self).__init__(working_dir=working_dir,
                                                   filenames=['output/ReportEventCounter.json',
                                                              'output/ReportMalariaFiltered.json']
                                                   )
        self.sweep_variables = sweep_variables or ["Run_Number", '__sample_index__']
        self.expt_name = expt_name
        self.sample = sample
        self.hfca = hfca
        self.population_channel = 'Statistical Population'
        self.case_channel = 'Received_Treatment'
        self.prev_channel = 'PfHRP2 Prevalence'
        self.nmf_channel = 'Received_NMF_Treatment'
        self.comparison_channel = 'Treated Cases NMF Adjusted'
        ax = ax

    def filter(self, simulation):
        return simulation.tags['__sample_index__'] == self.sample

    def select_simulation_data(self, data, simulation):
        simdata = { self.case_channel : data[self.filenames[0]]['Channels'][self.case_channel]['Data'][-365:] }
        simdata[self.nmf_channel] = data[self.filenames[0]]['Channels'][self.nmf_channel]['Data'][-365:]
        simdata = pd.DataFrame(simdata)
        simdata[self.population_channel] = data[self.filenames[1]]['Channels'][self.population_channel]['Data']
        # inflate pop for undercounted denom
        simdata[self.population_channel] = simdata[self.population_channel]*1.2
        simdata[self.prev_channel] = data[self.filenames[1]]['Channels'][self.prev_channel]['Data']

        simdata[self.comparison_channel] = simdata[self.case_channel] + simdata[self.nmf_channel]
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
        adf.to_csv(os.path.join(self.working_dir, '%s_data.csv' % self.hfca))

# creating adf variable
def read_archetype_csv(ax, row):
    wdir = os.path.join(projectpath, 'simulation_output', 'seasonality')
    try:
        adf = pd.read_csv(os.path.join(wdir, '%s_data.csv' % row['archetype']))
    except IOError:
        print('running archetype', row['archetype'])
        analyzer = SeasonalityPlotter(expt_name='%s_seasonality_fit' % row['archetype'],
                                      ax=ax,
                                      sweep_variables=["Run_Number",
                                                       "__sample_index__"
                                                       ],
                                      sample=row['sample'],
                                      hfca=row['archetype'],
                                      working_dir=wdir)

        am = AnalyzeManager(row['expt_id'], analyzers=analyzer)
        am.analyze()
        adf = pd.read_csv(os.path.join(wdir, '%s_data.csv' % row['archetype']))
    return adf

# plotting all of the lines in the graphs
def plot_lines(r, row):
    reference_fname = os.path.join(projectpath, 'simulation_inputs', 'projection_csvs',
                                   'archetype_files', 'archetype_incidence_NGA_RIA_v5.csv')
    ref_df = pd.read_csv(reference_fname)
    ref_df = ref_df.rename(columns={'month': 'Month',
                                    'population': 'Trials'})
    ref_df['Observations'] = ref_df['incidence'] * ref_df['Trials'] / 1000

#    ref_df['Month'] = ref_df['Month'].apply(lambda x: calendar.month_abbr[x])
    ax = fig.add_subplot(6, 4, r + 1)
    adf = read_archetype_csv(ax, row)
    ax.set_xticks(np.arange(1, 13))
    ax.xaxis.set_ticklabels(['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'])
    xticks = ax.xaxis.get_major_ticks()
    for i in range(1, 7):
        xticks[2*i - 1].label1.set_visible(False)
 #   adf['Month'] = adf['Month'].apply(lambda x: calendar.month_abbr[x])
    rdf = copy.copy(ref_df[ref_df['seasonality'] == row['archetype']])
    rdf['incidence'] = rdf['Observations'] / rdf['Trials'] * 1000
    adf['incidence'] = adf['Observations'] / adf['Trials'] * 1000
    for s, plot_df in adf.groupby('Run_Number'):
        ax.plot(plot_df['Month'], plot_df['incidence'], '-', color='r', linewidth=0.5, alpha=0.3)
    plot_df = adf.groupby('Month').agg(np.mean).reset_index()
    plot_df['incidence'] = plot_df['Observations'] / plot_df['Trials'] * 1000
    scale = (rdf['incidence'].reset_index()['incidence']/plot_df['incidence']).mean()
    scaled_blue = rdf['incidence'].reset_index()['incidence']/scale
    ax.plot(plot_df['Month'], plot_df['incidence'], '-o', color='r', label='sim')
    # ax.plot(rdf['Month'], rdf['incidence'], '-o', color= '#383eb0', label='reference')
    ax.plot(rdf['Month'], scaled_blue, '-o', color='#383eb0', label='reference')
    y_lim = ax.get_ylim()
    y_diff = y_lim[1] - y_lim[0]
    plt.errorbar(rdf['Month'], scaled_blue, yerr=y_diff * 0.19)
    return ax

# plotting lines, and setting up titles, axes, and legend in graphs
def create_graphs():
    wdir = os.path.join(projectpath, 'simulation_output', 'seasonality')
    master_df = pd.read_csv(os.path.join(wdir, 'seasonality_calib_best_fits.csv'))
    for r, row in master_df.iterrows() :
        ax = plot_lines(r, row)
        set_titles_axes(ax, r, row, master_df)

# setting up titles and axes
def set_titles_axes(ax, r, row, master_df):
    ax.set_xlabel('Month')
    if r % 8 == 0:
        ax.set_ylabel('Treated Clinical Case incidence')
    ax.tick_params(axis="x", labelsize = 8)
    ax.set_ylim(0, )
    ax.set_title(row['archetype'])
    if r == len(master_df) - 1:
        ax.legend(bbox_to_anchor=(2, 0.5))

# save plots
def save_plots(fig):
    wdir = os.path.join(projectpath, 'simulation_output', 'seasonality')
    plt.subplots_adjust(bottom = 0.1, left = 0.05, right = 0.95, top = 0.95, wspace = 0.2, hspace = 0.7)
    fig.savefig(os.path.join(wdir, 'seasonality_calib_case_counts_comparison.png'))
    fig.savefig(os.path.join(wdir, 'seasonality_calib_case_counts_comparison.pdf'), format='PDF')

if __name__ == "__main__":
    SetupParser.init()
    fig = plt.figure(figsize=(14, 16))
    create_graphs()
    save_plots(fig)
    plt.show()