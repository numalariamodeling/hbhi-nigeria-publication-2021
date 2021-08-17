import copy

import pandas as pd
import numpy as np
from simtools.Analysis.BaseAnalyzers import BaseAnalyzer
from calibtool import LL_calculators
import datetime
import calendar
import math
import os
import sys
sys.path.append('../')
import matplotlib.pyplot as plt
import matplotlib as mpl
import matplotlib.gridspec as gridspec
#from plotting.colors import load_color_palette

mpl.rcParams['pdf.fonttype'] = 42

projectpath = r'C:\Users\dhano_5\Box\NU-malaria-team\projects\hbhi_nigeria'


def load_ref_data() :
    dhs_pfpr_fname = os.path.join(projectpath, 'simulation_inputs', 'projection_csvs', 'archetype_files',
                                  'PfPr_archetype_10_v2.csv')
    dhs_df = pd.read_csv(dhs_pfpr_fname)
    dhs_df = dhs_df.dropna(subset=['PfPr_microscopy'])
    dhs_df['PfPr_microscopy'] /= 100
    dhs_df['ci_l_micro'] /= 100
    dhs_df['ci_u_micro'] /= 100

    return dhs_df


class MonthlyPfPRITNAnalyzer(BaseAnalyzer):

    def __init__(self, expt_name, sweep_variables=None, working_dir="."):
        super(MonthlyPfPRITNAnalyzer, self).__init__(working_dir=working_dir,
                                                   filenames=["output/MalariaSummaryReport_MonthlyU5.json",
                                                              'output/InsetChart.json']
                                                   )
        self.sweep_variables = sweep_variables or ["Run_Number"]
        self.expt_name = expt_name
        self.mult_param = 'Habitat_Multiplier'
    #
    # def filter(self, simulation):
    #     return simulation.tags["DS_Name_for_ITN"] in ('Taura')

    def select_simulation_data(self, data, simulation):

        d = data[self.filenames[0]]['DataByTimeAndAgeBins']['PfPR by Age Bin'][:12]
        pfpr = [x[1] for x in d]
        d = data[self.filenames[0]]['DataByTimeAndAgeBins']['Average Population by Age Bin'][:12]
        age_pops = [x[1] for x in d]
        simdata = pd.DataFrame( { 'month' : range(1,13),
                                  'PfPR U5' : pfpr,
                                  'Trials' : age_pops})

        for sweep_var in self.sweep_variables:
            if sweep_var in simulation.tags.keys():
                simdata[sweep_var] = simulation.tags[sweep_var]
        return simdata

    def finalize(self, all_data):

        selected = [data for sim, data in all_data.items()]
        if len(selected) == 0:
            print("No data have been returned... Exiting...")
            return

        if not os.path.exists(self.working_dir):
            os.mkdir(self.working_dir)

        all_df = pd.concat(selected).reset_index(drop=True)

        x_temp = all_df['x_Temporary_Larval_Habitat'].unique()[0]
        all_df = all_df.groupby([self.mult_param, 'month', 'DS_Name_for_ITN'])[['PfPR U5', 'Trials']].agg(np.mean).reset_index()
        all_df = all_df.sort_values(by=[self.mult_param, 'month', 'DS_Name_for_ITN'])

        all_dhs_df = load_ref_data()
        all_df['Observations'] = all_df['Trials'] * all_df['PfPR U5']
        all_df['Trials'] = all_df['Trials'].astype(int)
        all_df['Observations'] = all_df['Observations'].astype(int)
 #       fig, axes = plt.subplots(nrows=len(all_df.groupby('DS_Name_for_ITN')), ncols=2)
        all_df_grouped_data = all_df.groupby('DS_Name_for_ITN')
        fig1, axes1 = plt.subplots(nrows=6, ncols=5, gridspec_kw= {'width_ratios': [10, 10, 1, 10, 10]})
        fig2, axes2 = plt.subplots(nrows=5, ncols=5, gridspec_kw={'width_ratios': [10, 10, 1, 10, 10]})
        fig1.set_figheight(22)
        fig1.set_figwidth(15)
        fig2.set_figheight(22)
        fig2.set_figwidth(15)
        graphNo = 0
        row = 0
        col = 0
        for hfca, df in all_df_grouped_data:
            dhs_df, df, score_df = return_all_df_vars(self, all_dhs_df, hfca, df, x_temp)
            # determining whether or not they go in the first or second fig
            if graphNo < 24:
                fig1, axes1 = plot_graphs(self, score_df, df, dhs_df, fig1, axes1, row, col)
                set_axes_limits_titles(axes1, row, col, hfca)
            else:
                fig2, axes2 = plot_graphs(self, score_df, df, dhs_df, fig2, axes2, row, col)
                set_axes_limits_titles(axes2, row, col, hfca)
            graphNo += 2
            if col == 0:
                col += 3
            elif col == 3:
                col = 0
                row += 1
            if row == 6:
                row = 0

            plt.close()
       # fig1.tight_layout()
        # fig2.tight_layout()  22 + 22 = 44 graphs
        fig1.subplots_adjust(wspace=0.5, hspace = 0.5)
        fig2.subplots_adjust(wspace=0.5, hspace = 0.5)
        for rowNo in range(0, 5):
            axes1[rowNo, 2].set_visible(False)
            axes2[rowNo, 2].set_visible(False)
        axes1[5, 2].set_visible(False)
        save_plots(self, fig1, '1')
        save_plots(self, fig2, '2')

# finds dhs_df, df, score_df variables for finalize function
def return_all_df_vars(self, all_dhs_df, hfca, df, x_temp):
    dhs_df = copy.copy(all_dhs_df[all_dhs_df['repDS'] == hfca])

    dhs_df['month'] = dhs_df['time2'].apply(lambda x: list(calendar.month_abbr).index(x.split('1')[1].lower().capitalize()))

    dhs_df['Trials'] = dhs_df['Number of Kids_micro']
    dhs_df['Observations'] = dhs_df['Number of Kids_micro'] * dhs_df['PfPr_microscopy']
    dhs_df['Observations'] = dhs_df['Observations'].astype(int)
    dhs_df = dhs_df.sort_values(by='month')
    scores = []
    for var, sdf in df.groupby(self.mult_param):
        sdf = sdf[sdf['month'].isin(dhs_df['month'])]
        sdf = sdf.sort_values(by='month')
        score = np.sum(
            [LL_calculators.beta_binomial([x1], [x2], [x3], [x4]) for x1, x2, x3, x4 in zip(dhs_df['Trials'].values,
                                                                                            sdf['Trials'].values,
                                                                                            dhs_df['Observations'].values,
                                                                                            sdf['Observations'].values)])
        scores.append(score)
    score_df = pd.DataFrame({self.mult_param: [var for var, sdf in df.groupby(self.mult_param)],
                             'score': scores})
    if self.mult_param != 'x_Temporary_Larval_Habitat':
        score_df['x_Temporary_Larval_Habitat'] = x_temp
    score_df.to_csv(os.path.join(self.working_dir, '%s_archetype.csv' % hfca),
                    index=False)
    return dhs_df, df, score_df

# plots all of the graphs for every pair of graphs that represent a region
def plot_graphs(self, score_df, df, dhs_df, fig, axes, row, col):

    axes[row, col].plot(score_df[self.mult_param], score_df['score'], '-o')
    axes[row, col].set_xlabel(self.mult_param)
    axes[row, col].set_ylabel('log likelihood match to 2010 DHS U5 PfPR')
    axes[row, col].set_xscale('log')


    max_score = np.max(score_df['score'])
    best_LH = score_df[score_df['score'] == max_score][self.mult_param].values[0]
    axes[row, col].plot(best_LH, max_score, marker = 'o', markersize = 7, color = "red")

    for var, sdf in df.groupby(self.mult_param):
        if var == best_LH:
            continue
        axes[row, col + 1].plot(sdf['month'], sdf['PfPR U5'], '-r', linewidth=0.5, alpha=0.3)
    sdf = df[df[self.mult_param] == best_LH]
    axes[row, col + 1].plot(sdf['month'], sdf['PfPR U5'], '-r', label='sim')
    axes[row, col + 1].scatter(dhs_df['month'], dhs_df['PfPr_microscopy'], dhs_df['Number of Kids_micro'], 'k', label='DHS 2010')
    for r, rrow in dhs_df.iterrows():
        axes[row, col + 1].plot([rrow['month'], rrow['month']],
                [rrow['PfPr_microscopy'] - rrow['ci_l_micro'], rrow['PfPr_microscopy'] + rrow['ci_u_micro']],
                '-k',
                linewidth=0.5)
    return fig, axes

# sets axes, limits, and titles of graphs for every pair of graphs that represent a region
def set_axes_limits_titles(axes, row, col, hfca):
    log_graph = axes[row, col]
    plt.minorticks_off()
    U5_graph = axes[row, col + 1]
    legend = U5_graph.legend(loc='upper left')
    legend.legendHandles[1]._sizes = [30]
    U5_graph.set_ylim(0, 1)
    log_graph.set_xlabel('Habitat Multiplier')
    U5_graph.set_xlabel('Month')
    if row % 2 == 0:
        log_graph.set_ylabel('log likelihood match to 2010 DHS U5 PfPR')
    else:
        log_graph.set_ylabel('')
    U5_graph.set_ylabel('U5 PfPR')
    log_graph.title.set_text(hfca)
    U5_graph.title.set_text(hfca)

    U5_graph.set_xticks(np.arange(1, 13))
    U5_graph.xaxis.set_ticklabels(['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'])
    U5ticks = U5_graph.xaxis.get_major_ticks()
    for i in range(0, 4):
        U5ticks[3 * i + 1].set_visible(False)
        U5ticks[3 * i + 2].set_visible(False)

# saves plots
def save_plots(self, fig, half_number):
    fig.savefig(os.path.join(self.working_dir, 'total_archetype_%s.pdf' % half_number), bbox_inches = 'tight', format='PDF')


if __name__ == "__main__":
    from simtools.Analysis.AnalyzeManager import AnalyzeManager
    from simtools.SetupParser import SetupParser
    SetupParser.default_block = 'HPC'
    SetupParser.init()
    expt_id = 'e24c810a-37b6-ea11-a2c6-c4346bcb1557'
    analyzer = MonthlyPfPRITNAnalyzer(expt_name='archetype_U5_PfPR_ITN_match',
                                     sweep_variables=["Run_Number",
                                                      "x_Temporary_Larval_Habitat",
                                                      "Habitat_Multiplier",
                                                      "DS_Name_for_ITN"
                                                      ],
                                     working_dir=os.path.join(projectpath, 'simulation_output', 'prevalence',
                                                              '2010_match_with_ITN_coverage_v4'))
    am = AnalyzeManager(expt_id, analyzers=analyzer)
    am.analyze()
