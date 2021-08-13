import pandas as pd
import numpy as np
import os
import sys
sys.path.append('../')
# from simulation_setup_helpers import load_master_csv
import matplotlib.pyplot as plt
import matplotlib as mpl
import matplotlib.colors as colors
import seaborn as sns
#from grab_smc_paar_core_states import get_smc_state_LGAs
from simulation.analyzers.calculation_statements import *


# CFR_treated_severe = 0.097
# CFR_untreated_severe = 0.539
includeIPTi = True
def load_previous_trend(projectpath):
    previous_trend_dir = os.path.join(projectpath, 'simulation_output', '2010_to_2020_v10',
                                      'NGA 2010-20 burnin_hs+itn+smc')
    df_past = pd.read_csv(os.path.join(previous_trend_dir, 'annual_indicators_2011_2020.csv'))
    for age_group in ['all_ages', 'U5'] :
        df_past['death_rate_mean_%s' % age_group] = (df_past['death_rate_1_%s' % age_group] + df_past['death_rate_2_%s' % age_group]) / 2
    return df_past

def calculate_df(sdir, simoutdir, funder, projectpath):
    burden_fname = os.path.join(simoutdir, sdir, 'malariaBurden_withAdjustments.csv')
    df = pd.read_csv(burden_fname)
    df = df[df['year'] < 2031]
    LGA_funder = os.path.join(projectpath, 'simulation_output', '2020_to_2025_v6', 'LGA_funder.csv')
    LGA_funder = pd.read_csv(LGA_funder)
    nga_pop = os.path.join(projectpath, 'nigeria_LGA_pop.csv')
    df_nga_pop = pd.read_csv(nga_pop)

    if funder:
        df_funder = LGA_funder[LGA_funder['funder'] == funder]['LGA'].values
    else:
        df_funder = LGA_funder['LGA'].values

    if 'Received_Severe_Treatment' not in df.columns.values:
        df['Received_Severe_Treatment'] = 0
    df = df.groupby(['month', 'year', 'LGA', 'Run_Number']).agg(np.mean).reset_index()
    df = df.groupby(['year', 'LGA', 'Run_Number']).agg({'Statistical_Population': np.mean,
                                                        'New_Clinical_Cases': np.sum,
                                                        'PfPR_MiP_adjusted': np.mean,
                                                        'mLBW_births': np.sum,
                                                        'MiP_stillbirths': np.sum,
                                                        'total_mortality_1': np.sum,
                                                        'total_mortality_2': np.sum,
                                                        'Pop_U5': np.mean,
                                                        'PfPR_U5': np.mean,
                                                        'New_clinical_cases_U5': np.sum,
                                                        'total_mortality_U5_1': np.sum,
                                                        'total_mortality_U5_2': np.sum}).reset_index()
    data_channels = ['Statistical_Population', 'New_Clinical_Cases', 'PfPR_MiP_adjusted', 'mLBW_births',
                     'MiP_stillbirths',
                     'total_mortality_1', 'total_mortality_2', 'Pop_U5', 'PfPR_U5', 'New_clinical_cases_U5',
                     'total_mortality_U5_1',
                     'total_mortality_U5_2']
    #df = df.query('Run_Number == 0')
    df = df.groupby(['year', 'LGA'])[data_channels].agg(np.mean).reset_index()
    df = pd.merge(left=df, right=df_nga_pop, on=['LGA'])
    # all age metrics - rescaled to full population
    df = rename_data_cols(df)
    df = df.rename(columns=({'geopode.pop': 'geopode.pop_all_ages'}))
    rescale_age_metrics(df, 'geopode.pop', U5=False)
    df['num_mLBW'] = df['mLBW_births'] * df['geopode.pop_all_ages'] / df['Population_all_ages']
    df['num_mStillbirths'] = df['MiP_stillbirths'] * df['geopode.pop_all_ages'] / df['Population_all_ages']
    # U5 metrics - rescaled to full population
    df['geopode.pop_U5'] = df['geopode.pop_all_ages'] * (df['Population_U5'] / df[
        'Population_all_ages'])  # assumes fraction of individual U5 in simulation is same as fraction in full population
    rescale_age_metrics(df, 'geopode.pop', U5=True)
    df = df[df['LGA'].isin(df_funder)]
    return df

def load_cur_df(sdir, simoutdir, funder, projectpath):

    df = calculate_df(sdir, simoutdir, funder, projectpath)
    sum_df = df.groupby('year')[['Population_all_ages', 'cases_all_ages', 'positives_all_ages', 'deaths_1_all_ages',
                                 'deaths_2_all_ages', 'num_mLBW', 'num_mStillbirths', 'Population_U5', 'cases_U5',
                                 'positives_U5', 'deaths_1_U5', 'deaths_2_U5',
                                 'geopode.pop_all_ages', 'geopode.pop_U5']].agg(np.sum).reset_index()
    calc_ann_nation_indicators(sum_df, 'geopode.pop', U5=False)
    sum_df['death_rate_mean_all_ages'] = (sum_df['death_rate_1_all_ages'] + sum_df['death_rate_2_all_ages']) / 2
    calc_ann_nation_indicators(sum_df, 'geopode.pop', U5=True)
    sum_df['death_rate_mean_U5'] = (sum_df['death_rate_1_U5'] + sum_df['death_rate_2_U5']) / 2
    sum_df['num_mStillbirths'] = sum_df['num_mStillbirths'] / 1000  # thousands of stillbirths
    sum_df['num_mLBW'] = sum_df['num_mLBW'] / 1000  # thousands of mLBWs

    sum_df.to_csv(os.path.join(simoutdir, sdir, 'annual_indicators_2020_2030.csv'), index=False)
    return sum_df


def plot_trend_and_bars_separate_pdfs(plot_scenarios, scenario_dirs, funder, projectpath) :
    baseline = {
        'PfPR': -9,
        'incidence': -9,
        'death_rate_1': -9,
        'death_rate_2': -9,
        'num_mStillbirths': -9,
        'U5_PfPR': -9,
        'U5_incidence': -9,
        'U5_death_rate_1': -9,
        'U5_death_rate_2': -9
    }
    split_index_legend = -1
    baseline_year = 2020
    comparison_year = 2030
    comp_year_range = range(2020, 2031)
    print_reductions = True
    df_past = load_previous_trend(projectpath)

    plot_channels = ['PfPR_U5', 'incidence_U5', 'death_rate_mean_U5', 'num_mStillbirths', 'PfPR_all_ages', 'incidence_all_ages',
                 'death_rate_mean_all_ages', 'num_mLBW']
    plot_y_labels = ['U5 PfPR', 'U5 incidence', 'U5 death rate', 'stillbirths (1000s)', 'all age PfPR',
                     'all age incidence', 'all age death rate', 'mLBW (1000s)']

    sns.set_style('whitegrid', {'axes.linewidth': 0.5})

    figs = [plt.figure(figsize=(8,3)) for y in range(len(plot_channels))]
    axes = [[fig.add_subplot(1,2,x+1) for x in range(2)] for fig in figs]

    scenario_dirs_to_analyze = [sdir for sdir in scenario_dirs if sdir.split(' ')[split_index_legend] in plot_scenarios]

    for si, sdir in enumerate(scenario_dirs_to_analyze) :

        print(sdir)
        palette = [(166 / 255, 206 / 255, 227 / 255), (31 / 255, 120 / 255, 180 / 255),
                   (178 / 255, 223 / 255, 138 / 255), (51 / 255, 160 / 255, 44 / 255),
                   (251 / 255, 154 / 255, 153 / 255), (227 / 255, 26 / 255, 28 / 255),
                   (253 / 255, 191 / 255, 111 / 255), (255 / 255, 127 / 255, 0 / 255),
                   (202 / 255, 178 / 255, 214 / 255)]
        sum_df = load_cur_df(sdir, simoutdir, funder, projectpath)
       # df_all_years = load_LGA_df(sdir)
        sum_df_indexed = sum_df.set_index('year')
        for ai, channel in enumerate(plot_channels):
            if si == 1:
                axes[ai][0].plot(df_past['year'], df_past[channel], color='#58595B')
            plot_df = pd.concat([df_past[df_past['year'] == 2019], sum_df], sort=True)
            plot_df = plot_df.sort_values(by='year')
            axes[ai][0].plot(plot_df['year'], plot_df[channel], color=palette[si], label=sdir.split(' ')[split_index_legend])
            axes[ai][0].set_ylabel(plot_y_labels[ai])
            axes[ai][0].set_xlim(2010, 2031)
            axes[ai][0].set_xticks(range(2010, 2031, 5))  # was (2020, 2026, 2)
            for comp_year in comp_year_range:
                if (comp_year == baseline_year) and (baseline_scenario in sdir):
                    baseline[channel] = sum_df_indexed.at[comp_year, channel]
                burden_red = (sum_df_indexed.at[comp_year, channel] - baseline[channel])/baseline[channel]
                if comp_year == comparison_year :
                    axes[ai][1].bar([si], [burden_red], color=palette[si], label=sdir.split(' ')[split_index_legend])
            axes[ai][1].set_ylim(-0.9, 0.8)
            axes[ai][1].set_xticklabels([])
            axes[ai][1].set_ylabel('(change %d - 2020 BAU)/(2020 BAU)' % comparison_year)

    tail = ''
    if funder :
        tail = '_%s' % funder
    return figs, plot_channels, tail

def save_plots(figs, plot_channels, tail, simoutdir):
    plot_dir = os.path.join(simoutdir, '210308_national_level_plots')
    if not os.path.exists(plot_dir):
        os.mkdir(plot_dir)
    titles = ['U5 PfPR', 'U5 Incidence', 'U5 Death Rate', 'Stillbirths (1000s)', 'All Age PfPR',
                     'All Age Incidence', 'All Age Death Rate', 'mLBW (1000s)']
    for ff, fig in enumerate(figs):
        fig.suptitle("%s Trends and Relative Differences By Scenario \n \n" % titles[ff], y=0.97)
        fig.subplots_adjust(wspace=0.7)
        fig.savefig(os.path.join(plot_dir, 'trend_and_bars_by_year_%s%s.png' % (plot_channels[ff], tail)), dpi=200)
        fig.savefig(os.path.join(plot_dir, 'trend_and_bars_by_year_%s%s.pdf' % (plot_channels[ff], tail)), format='PDF')

if __name__ == '__main__' :
    projectpath = r'C:\Users\ido0493\Box\NU-malaria-team\projects\hbhi_nigeria'
    simoutdir = os.path.join(projectpath, 'simulation_output', '2020_to_2030_v3')

    stem = 'NGA projection scenario'
    baseline_scenario = '1'
    scenario_dirs = [x for x in os.listdir(simoutdir) if stem in x]
    scenario_dirs.insert(0, scenario_dirs.pop(scenario_dirs.index('%s %s' % (stem, baseline_scenario))))

    mpl.rcParams['pdf.fonttype'] = 42
    funder = ''

    # create plots

    if includeIPTi:
        plot_scenarios = [str(x) for x in [1, 2, 3, 4, 5, 6, 7]]
    else:
        plot_scenarios = [str(x) for x in [1, '2noIPTi', '3noIPTi', '4noIPTi', '5noIPTi', 6, 7, 8]]

    figs, plot_channels, tail = plot_trend_and_bars_separate_pdfs(plot_scenarios, scenario_dirs, funder, projectpath)
    save_plots(figs, plot_channels, tail, simoutdir)
    plt.show()
#