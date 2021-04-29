import pandas as pd
import numpy as np
import os
import sys
sys.path.append('../')
# from load_paths import load_box_paths
# from simulation_setup_helpers import load_master_csv
from simulation.load_paths import load_box_paths
import matplotlib.pyplot as plt
import matplotlib as mpl
import matplotlib.colors as colors
import seaborn as sns
from simulation.analyzers.calculation_statements import *

mpl.rcParams['pdf.fonttype'] = 42
# from plotting.colors import load_color_palette


datapath, projectpath = load_box_paths()
#projectpath = '/Users/pdhanoa/Box/NU-malaria-team/projects/hbhi_nigeria'
palette = [(166/255,206/255,227/255), (31/255,120/255,180/255), (178/255,223/255,138/255), (51/255,160/255,44/255),
           (251/255,154/255,153/255), (227/255,26/255,28/255), (253/255,191/255,111/255), (255/255,127/255,0/255),
           (202/255,178/255,214/255)]

includeIPTi = True

# all of these variables are the same as single state plots
baseline_year = 2020
comparison_year = 2030
baseline_scenario = '1'
comp_year_range = range(2020, 2031)
CFR_treated_severe = 0.097
CFR_untreated_severe = 0.539
nga_pop = os.path.join(projectpath, 'nigeria_LGA_pop.csv')
df_nga_pop = pd.read_csv(nga_pop)

split_index_legend = -1

# renaming data columns as needed
def rename_data_cols(df):
    return df.rename(columns=({'Statistical_Population': 'Population_all_ages',
                               'total_mortality_1': 'total_mortality_1_all_ages',
                               'total_mortality_2': 'total_mortality_2_all_ages',
                               'New_Clinical_Cases': 'New_clinical_cases_all_ages',
                               'Pop_U5': 'Population_U5',
                               'total_mortality_U5_1': 'total_mortality_1_U5',
                               'total_mortality_U5_2': 'total_mortality_2_U5',
                               'PfPR_MiP_adjusted': 'PfPR_all_ages'}))

def rename_cols_extended(df):
    df = rename_data_cols(df)
    return df.rename(columns=({'cases': 'cases_all_ages',
                               'positives': 'positives_all_ages',
                               'deaths_1': 'deaths_1_all_ages',
                               'deaths_2': 'deaths_2_all_ages',
                               'deaths_U5_1': 'deaths_1_U5',
                               'deaths_U5_2': 'deaths_2_U5',
                               'geopode.pop': 'geopode.pop_all_ages',
                               'PfPR': 'PfPR_all_ages',
                               'incidence': 'incidence_all_ages',
                               'death_rate_1': 'death_rate_1_all_ages',
                               'death_rate_2': 'death_rate_2_all_ages',
                               'U5_PfPR': 'PfPR_U5',
                               'U5_incidence': 'incidence_U5',
                               'U5_death_rate_1': 'death_rate_1_U5',
                               'U5_death_rate_2': 'death_rate_2_U5'}))


# Essentially the same as single_state_plots -- it's just that there's an Except clause now, in addition to the original
# try clause
def load_previous_trend(previous_trend_dir, state):

    state = '_'.join(state.split(' '))
    try :
        df_past = pd.read_csv(os.path.join(previous_trend_dir, 'annual_indicators_%s.csv' % state))
    except IOError :
        print('generating previous trend for %s' % state)
        LGAlist = get_LGAs_by_funder_or_state(state)
        df_past = load_cur_df(previous_trend_dir, '', state, LGAlist, maxyear=2020)
    df_past = df_past[df_past['year'] > 2010]
    df_past = rename_cols_extended(df_past)
    return df_past

# identical to df and sum_df functions in single state plots

def load_cur_df(simoutdir, sdir, state, LGAlist, maxyear=2031):
    state = '_'.join(state.split(' '))
    # try :
    #     sum_df = pd.read_csv(os.path.join(simoutdir, sdir, 'annual_indicators_%s.csv' % state))
    #     sum_df = rename_cols_extended(sum_df)
    #     return sum_df
    # except IOError :
    burden_fname = os.path.join(simoutdir, sdir, 'malariaBurden_withAdjustments.csv')
    df = pd.read_csv(burden_fname)
    df = df[df['year'] < maxyear]
    df = df[df['LGA'].isin(LGAlist)]
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
    df = rename_data_cols(df)
    data_channels = ['Population_all_ages', 'New_clinical_cases_all_ages', 'PfPR_all_ages', 'mLBW_births',
                     'MiP_stillbirths', 'total_mortality_1_all_ages', 'total_mortality_2_all_ages', 'Population_U5',
                     'PfPR_U5', 'New_clinical_cases_U5', 'total_mortality_1_U5', 'total_mortality_2_U5']
    df = df.groupby(['year', 'LGA'])[data_channels].agg(np.mean).reset_index()
    df = pd.merge(left=df, right=df_nga_pop, on=['LGA'])
    # all age metrics - rescaled to full population
    df = df.rename(columns=({'geopode.pop': 'geopode.pop_all_ages'}))

    rescale_age_metrics(df, 'geopode.pop')
    # U5 metrics - rescaled to full population
    df['geopode.pop_U5'] = df['geopode.pop_all_ages'] * (df['Population_U5'] / df['Population_all_ages'])  # assumes fraction of individual U5 in simulation is same as fraction in full population
    rescale_age_metrics(df, 'geopode.pop', True)
    sum_df = df.groupby('year')[['Population_all_ages', 'cases_all_ages', 'positives_all_ages', 'deaths_1_all_ages',
                                 'deaths_2_all_ages', 'num_mLBW', 'num_mStillbirths', 'Population_U5', 'cases_U5',
                                 'positives_U5', 'deaths_1_U5', 'deaths_2_U5', 'geopode.pop_all_ages',
                                 'geopode.pop_U5']].agg(np.sum).reset_index()
    calc_ann_nation_indicators(sum_df, 'geopode.pop')
    calc_ann_nation_indicators(sum_df, 'geopode.pop', True)
    sum_df['num_mStillbirths'] = sum_df['num_mStillbirths'] / 1000  # thousands of stillbirths
    sum_df['num_mLBW'] = sum_df['num_mLBW'] / 1000  # thousands of mLBWs
    sum_df.to_csv(os.path.join(simoutdir, sdir, 'annual_indicators_%s.csv' % state), index=False)
    # print(sum_df)
    return sum_df



# completely different, not in original
def get_LGAs_by_funder_or_state(state):

    if 'funder' in state :
        state = state.split('_')[1]
        fname = 'LGA_funder.csv'
        colname = 'funder'
    else :
        fname = 'LGA_state.csv'
        colname = 'State'

    LGAdf = pd.read_csv(os.path.join(projectpath, 'simulation_output', '2020_to_2025_v6', fname))
    return LGAdf[LGAdf[colname] == state]['LGA'].values


def plot_trend_and_point_comparison(simoutdir, previous_trend_dir, plot_scenarios, state, plot_dir) :
    # mostly the same, but taking state input into account
    print('running %s' % state)
    print_reductions = False
    df_past = load_previous_trend(previous_trend_dir, state)
    LGAlist = get_LGAs_by_funder_or_state(state)
    state = '_'.join(state.split(' '))

    sns.set_style('whitegrid', {'axes.linewidth': 0.5})

    fig = plt.figure(figsize=(14,6))
    axes = [fig.add_subplot(2,4,x+1) for x in range(8)]

    fig2 = plt.figure(figsize=(14,6))
    axes2 = [fig2.add_subplot(2,4,x+1) for x in range(8)]

    fig3 = plt.figure(figsize=(14,6))
    axes3 = [fig3.add_subplot(2,4,x+1) for x in range(8)]

    scenario_dirs_to_analyze = [sdir for sdir in scenario_dirs if sdir.split(' ')[-1] in plot_scenarios]

    for si, sdir in enumerate(scenario_dirs_to_analyze) :

        print(sdir)
        sum_df = load_cur_df(simoutdir, sdir, state, LGAlist)

        for ai, channel in enumerate(['PfPR_U5', 'incidence_U5', 'death_rate_1_U5', 'death_rate_2_U5',
                                       'PfPR_all_ages', 'incidence_all_ages', 'death_rate_1_all_ages',
                                      'death_rate_2_all_ages']) : #'num_mStillbirths',#'num_mLBW'
            if si == 0 :
                axes[ai].plot(df_past['year'], df_past[channel], color='#58595B')
            plot_df = pd.concat([df_past[df_past['year'] == 2019], sum_df], sort=True)
            plot_df = plot_df.sort_values(by='year')
            axes[ai].plot(plot_df['year'], plot_df[channel], color=palette[si], label=sdir.split(' ')[split_index_legend])

        sum_df = sum_df.set_index('year')
        # identical to original
        U5_pfpr_reds = []
        U5_inc_reds = []
        U5_death1_reds = []
        U5_death2_reds = []
        pfpr_reds = []
        inc_reds = []
        death1_reds = []
        death2_reds = []
        # still_reds = []
        # mLBW_reds = []
        for comp_year in comp_year_range :
            if (comp_year == baseline_year) and (baseline_scenario in sdir):
                baseline = {'PfPR_all_ages': sum_df.at[comp_year, 'PfPR_all_ages'],
                'incidence_all_ages': sum_df.at[comp_year, 'incidence_all_ages'],
                'death_rate_1_all_ages': sum_df.at[comp_year, 'death_rate_1_all_ages'],
                'death_rate_2_all_ages': sum_df.at[comp_year, 'death_rate_2_all_ages'],
                'PfPR_U5': sum_df.at[comp_year, 'PfPR_U5'],
                'incidence_U5': sum_df.at[comp_year, 'incidence_U5'],
                'death_rate_1_U5': sum_df.at[comp_year, 'death_rate_1_U5'],
                'death_rate_2_U5': sum_df.at[comp_year, 'death_rate_2_U5']
                            }
                # baseline['num_mStillbirths'] = sum_df.at[comp_year, 'num_mStillbirths']
                # baseline['num_mLBW'] = sum_df.at[comp_year, 'num_mLBW']
            # identical to original
            U5_pfpr_red = (sum_df.at[comp_year, 'PfPR_U5'] - baseline['PfPR_U5']) / baseline['PfPR_U5']
            U5_inc_red = (sum_df.at[comp_year, 'incidence_U5'] - baseline['incidence_U5']) / baseline['incidence_U5']
            U5_death1_red = (sum_df.at[comp_year, 'death_rate_1_U5'] - baseline['death_rate_1_U5']) / baseline[
                'death_rate_1_U5']
            U5_death2_red = (sum_df.at[comp_year, 'death_rate_2_U5'] - baseline['death_rate_2_U5']) / baseline[
                'death_rate_2_U5']
            pfpr_red = (sum_df.at[comp_year, 'PfPR_all_ages'] - baseline['PfPR_all_ages']) / baseline['PfPR_all_ages']
            inc_red = (sum_df.at[comp_year, 'incidence_all_ages'] - baseline['incidence_all_ages']) / baseline[
                'incidence_all_ages']
            death1_red = (sum_df.at[comp_year, 'death_rate_1_all_ages'] - baseline['death_rate_1_all_ages']) / baseline[
                'death_rate_1_all_ages']
            death2_red = (sum_df.at[comp_year, 'death_rate_2_all_ages'] - baseline['death_rate_2_all_ages']) / baseline[
                'death_rate_2_all_ages']
            # still_red = (sum_df.at[comp_year, 'num_mStillbirths'] - baseline['num_mStillbirths']) / baseline['num_mStillbirths']
            # mLBW_red = (sum_df.at[comp_year, 'num_mLBW'] - baseline['num_mLBW']) / baseline['num_mLBW']
            if comp_year == comparison_year :
                axes2[0].bar([si], [U5_pfpr_red], color=palette[si], label=sdir.split(' ')[split_index_legend])
                axes2[1].bar([si], [U5_inc_red], color=palette[si], label=sdir.split(' ')[split_index_legend])
                axes2[2].bar([si], [U5_death1_red], color=palette[si], label=sdir.split(' ')[split_index_legend])
                axes2[3].bar([si], [U5_death2_red], color=palette[si], label=sdir.split(' ')[split_index_legend])
                axes2[4].bar([si], [pfpr_red], color=palette[si], label=sdir.split(' ')[split_index_legend])
                axes2[5].bar([si], [inc_red], color=palette[si], label=sdir.split(' ')[split_index_legend])
                axes2[6].bar([si], [death1_red], color=palette[si], label=sdir.split(' ')[split_index_legend])
                axes2[7].bar([si], [death2_red], color=palette[si], label=sdir.split(' ')[split_index_legend])
                if print_reductions :
                    print('U5 PfPR:', U5_pfpr_red)
                    print('U5 incidence:', U5_inc_red)
                    print('U5 death rate 1:', U5_death1_red)
                    print('U5 death rate 2:', U5_death2_red)
                    print('All ages PfPR:', pfpr_red)
                    print('All ages incidence:', inc_red)
                    print('All ages death rate 1:', death1_red)
                    print('All ages death rate 2:', death2_red)
        # identical to original
            U5_pfpr_reds.append(U5_pfpr_red)
            U5_inc_reds.append(U5_inc_red)
            U5_death1_reds.append(U5_death1_red)
            U5_death2_reds.append(U5_death2_red)
            pfpr_reds.append(pfpr_red)
            inc_reds.append(inc_red)
            death1_reds.append(death1_red)
            death2_reds.append(death2_red)

        axes3[0].plot(comp_year_range, U5_pfpr_reds, color=palette[si], label=sdir.split(' ')[split_index_legend])
        axes3[1].plot(comp_year_range, U5_inc_reds, color=palette[si], label=sdir.split(' ')[split_index_legend])
        axes3[2].plot(comp_year_range, U5_death1_reds, color=palette[si], label=sdir.split(' ')[split_index_legend])
        axes3[3].plot(comp_year_range, U5_death2_reds, color=palette[si], label=sdir.split(' ')[split_index_legend])
        axes3[4].plot(comp_year_range, pfpr_reds, color=palette[si], label=sdir.split(' ')[split_index_legend])
        axes3[5].plot(comp_year_range, inc_reds, color=palette[si], label=sdir.split(' ')[split_index_legend])
        axes3[6].plot(comp_year_range, death1_reds, color=palette[si], label=sdir.split(' ')[split_index_legend])
        axes3[7].plot(comp_year_range, death2_reds, color=palette[si], label=sdir.split(' ')[split_index_legend])

        # axes3[4].plot(comp_year_range, still_reds, color=palette[si], label=sdir.split(' ')[split_index_legend])
        # axes3[9].plot(comp_year_range, mLBW_reds, color=palette[si], label=sdir.split(' ')[split_index_legend])
    # identical to original
    for ax in [axes, axes2, axes3] :
        ax[0].set_title('U5 PfPR')
        ax[1].set_title('U5 incidence')
        ax[2].set_title('U5 death rate 1')
        ax[3].set_title('U5 death rate 2')
        ax[4].set_title('all age PfPR')
        ax[5].set_title('all age incidence')
        ax[6].set_title('all age death rate 1')
        ax[7].set_title('all age death rate 2')
        # ax[4].set_title('stillbirths (1000s)')
        # ax[9].set_title('mLBW (1000s)')


    # axes[4].set_ylim(0,40)
    # axes[9].set_ylim(0, 300)

    for ax in axes :
        # ax.set_ylim(0,)
        ax.set_xlim(2010,2031)
        ax.set_xticks(range(2010, 2031, 5)) #was (2020, 2026, 2)
    for ax in axes2 :
        ax.set_ylim(-1, 1.5)
        ax.set_xticklabels([])

    axes2[0].set_ylabel('(change %d - 2020 BAU)/(2020 BAU)' % comparison_year)
    axes2[4].set_ylabel('(change %d - 2020 BAU)/(2020 BAU)' % comparison_year)
    axes3[0].set_ylabel('(change %d - 2020 BAU)/(2020 BAU)' % comparison_year)
    axes3[4].set_ylabel('(change %d - 2020 BAU)/(2020 BAU)' % comparison_year)
    axes[7].legend()
    # axes2[8].legend()
    # axes3[8].legend()

    fig.savefig(os.path.join(plot_dir, 'trend_by_year_%s.png' % state))
    fig2.savefig(os.path.join(plot_dir, 'compare_%d_to_%d_%s.png' % (baseline_year, comparison_year, state)))
    plt.close('all')


if __name__ == '__main__' :

    # create plots
    if includeIPTi:
        plot_scenarios = [str(x) for x in [1, 2, 3, 4, 5, 6,7]]
    else:
        plot_scenarios = [str(x) for x in [1, '2noIPTi', '3noIPTi', '4noIPTi', '5noIPTi', 6, 7, 8]]

    simoutdir = os.path.join(projectpath, 'simulation_output', '2020_to_2030_v3')
    stem = 'NGA projection scenario'
    scenario_dirs = [x for x in os.listdir(simoutdir) if stem in x]

    scenario_dirs.insert(0, scenario_dirs.pop(scenario_dirs.index('%s %s' % (stem, baseline_scenario))))

    previous_trend_dir = os.path.join(projectpath, 'simulation_output', '2010_to_2020_v10',
                                      'NGA 2010-20 burnin_hs+itn+smc')

    funders = ['funder_%s' % x for x in ['WB-IDB', 'PMI', 'Global Fund']]
    plot_dir = os.path.join(simoutdir, '210308_plots_funder')
    if not os.path.exists(plot_dir):
        os.mkdir(plot_dir)
    for funder in funders :
        plot_trend_and_point_comparison(simoutdir, previous_trend_dir,
                                        plot_scenarios, funder, plot_dir=plot_dir)

    state_df = pd.read_csv(os.path.join(projectpath, 'simulation_output', '2020_to_2025_v6', 'LGA_state.csv'))
    states = state_df['State'].unique()
    plot_dir = os.path.join(simoutdir, '210308_plots_States')
    if not os.path.exists(plot_dir):
        os.mkdir(plot_dir)
    for state in states :
        plot_trend_and_point_comparison(simoutdir, previous_trend_dir,
                                        plot_scenarios, state, plot_dir=plot_dir)