import pandas as pd
import numpy as np
import os
import sys
sys.path.append('../')
from simulation.analyzers.calculation_statements import *
from simulation.load_paths import load_box_paths





def calculate_LGA(df, data_channels, df_nga_pop):
    df = df.groupby(['year', 'LGA'])[data_channels].agg(np.mean).reset_index()
    df = pd.merge(left=df, right=df_nga_pop, on=['LGA'])
    # all age metrics - rescaled to full population
    df = rename_data_cols(df)
    df = df.rename(columns=({'geopode.pop': 'geopode.pop_all_ages'}))
    df = rescale_age_metrics(df, 'geopode.pop', U5=False)
    df.loc[:, 'num_mLBW'] = df['mLBW_births'] * df['geopode.pop_all_ages'] / df['Population_all_ages']
    df.loc[:, 'num_mStillbirths'] = df['MiP_stillbirths'] * df['geopode.pop_all_ages'] / df['Population_all_ages']
    # U5 metrics - rescaled to full population
    df.loc[:, 'geopode.pop_U5'] = df['geopode.pop_all_ages'] * (df['Population_U5'] / df[
        'Population_all_ages'])  # assumes fraction of individual U5 in simulation is same as fraction in full population
    LGA_funder = os.path.join(projectpath, 'simulation_output', '2020_to_2025_v6', 'LGA_funder.csv')
    LGA_funder = pd.read_csv(LGA_funder)
    df = rescale_age_metrics(df, 'geopode.pop', U5=True)
    return df


def calculate_df(simoutdir,  projectpath):
    data_channels = ['Statistical_Population', 'New_Clinical_Cases', 'PfPR_MiP_adjusted', 'mLBW_births',
                     'MiP_stillbirths',
                     'total_mortality_1', 'total_mortality_2', 'Pop_U5', 'PfPR_U5', 'New_clinical_cases_U5',
                     'total_mortality_U5_1',
                     'total_mortality_U5_2']
    nga_pop = os.path.join(projectpath, 'nigeria_LGA_pop.csv')
    df_nga_pop = pd.read_csv(nga_pop)

    run_number = [0, 1, 2, 3, 4]
    for i in run_number:
        burden_fname = os.path.join(simoutdir, 'malariaBurden_withAdjustments.csv')
        df = pd.read_csv(burden_fname)
        df = df[df['year'] < 2031]
        if 'Received_Severe_Treatment' not in df.columns.values:
            df.loc[:, 'Received_Severe_Treatment'] = 0
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

        df = df.query(f'Run_Number == {i}')
        df= calculate_LGA(df, data_channels, df_nga_pop)
        df = df[['year', 'LGA', 'Population_all_ages', 'cases_all_ages', 'positives_all_ages', 'deaths_1_all_ages',
                 'deaths_2_all_ages', 'num_mLBW', 'num_mStillbirths', 'Population_U5', 'cases_U5',
                 'positives_U5', 'deaths_1_U5', 'deaths_2_U5',
                 'geopode.pop_all_ages', 'geopode.pop_U5']]
        df = calc_ann_nation_indicators(df, 'geopode.pop', U5=False)
        df.loc[:, 'death_rate_mean_all_ages'] = (df['death_rate_1_all_ages'] + df['death_rate_2_all_ages']) / 2
        df = calc_ann_nation_indicators(df, 'geopode.pop', U5=True)
        df.loc[:, 'death_rate_mean_U5'] = (df['death_rate_1_U5'] + df['death_rate_2_U5']) / 2
        df.to_csv(simoutdir + '\\' + '\\' + 'annual_indicators_each_LGA_' + str(i) + '.csv', index=False)

    burden_fname = os.path.join(simoutdir, 'malariaBurden_withAdjustments.csv')
    df = pd.read_csv(burden_fname)
    df = df[df['year'] < 2031]
    if 'Received_Severe_Treatment' not in df.columns.values:
        df.loc[:, 'Received_Severe_Treatment'] = 0
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
    df_mean = calculate_LGA(df, data_channels, df_nga_pop)
    df = df_mean[['year', 'LGA', 'Population_all_ages', 'cases_all_ages', 'positives_all_ages', 'deaths_1_all_ages',
             'deaths_2_all_ages', 'num_mLBW', 'num_mStillbirths', 'Population_U5', 'cases_U5',
             'positives_U5', 'deaths_1_U5', 'deaths_2_U5',
             'geopode.pop_all_ages', 'geopode.pop_U5']]
    df = calc_ann_nation_indicators(df, 'geopode.pop', U5=False)
    df.loc[:, 'death_rate_mean_all_ages'] = (df['death_rate_1_all_ages'] + df['death_rate_2_all_ages']) / 2
    df = calc_ann_nation_indicators(df, 'geopode.pop', U5=True)
    df.loc[:, 'death_rate_mean_U5'] = (df['death_rate_1_U5'] + df['death_rate_2_U5']) / 2
    df.to_csv(simoutdir + '\\'  + '\\' + 'annual_indicators_each_LGA_mean.csv', index=False)
    return df_mean

def load_cur_df(simoutdir, projectpath):
    sum_mean_df = calculate_df(simoutdir, projectpath)
    run_number = [0, 1, 2, 3, 4]
    for i in run_number:
        sum_df = pd.read_csv(simoutdir + '\\' + '\\' + 'annual_indicators_each_LGA_' + str(i) + '.csv')
        sum_df = sum_df.groupby('year')[['Population_all_ages', 'cases_all_ages', 'positives_all_ages', 'deaths_1_all_ages',
                                 'deaths_2_all_ages', 'num_mLBW', 'num_mStillbirths', 'Population_U5', 'cases_U5',
                                 'positives_U5', 'deaths_1_U5', 'deaths_2_U5',
                                 'geopode.pop_all_ages', 'geopode.pop_U5']].agg(np.sum).reset_index()
        sum_df = calc_ann_nation_indicators(sum_df, 'geopode.pop', U5=False)
        sum_df.loc[:, 'death_rate_mean_all_ages'] = (sum_df['death_rate_1_all_ages'] + sum_df['death_rate_2_all_ages']) / 2
        sum_df = calc_ann_nation_indicators(sum_df, 'geopode.pop', U5=True)
        sum_df.loc[:, 'death_rate_mean_U5'] = (sum_df['death_rate_1_U5'] + sum_df['death_rate_2_U5']) / 2
        sum_df.loc[:, 'num_mStillbirths'] = sum_df['num_mStillbirths'] / 1000  # thousands of stillbirths
        sum_df.loc[:, 'num_mLBW'] = sum_df['num_mLBW'] / 1000  # thousands of mLBWs
        sum_df.to_csv(simoutdir + '\\'  + '\\' + 'annual_indicators_2020_2030_' + str(i) + '.csv',
                             index=False)

    sum_mean_df = sum_mean_df.groupby('year')[
        ['Population_all_ages', 'cases_all_ages', 'positives_all_ages', 'deaths_1_all_ages',
         'deaths_2_all_ages', 'num_mLBW', 'num_mStillbirths', 'Population_U5', 'cases_U5',
         'positives_U5', 'deaths_1_U5', 'deaths_2_U5',
         'geopode.pop_all_ages', 'geopode.pop_U5']].agg(np.sum).reset_index()
    sum_mean_df = calc_ann_nation_indicators(sum_mean_df, 'geopode.pop', U5=False)
    sum_mean_df.loc[:, 'death_rate_mean_all_ages'] = (sum_mean_df['death_rate_1_all_ages'] + sum_mean_df['death_rate_2_all_ages']) / 2
    sum_mean_df = calc_ann_nation_indicators(sum_mean_df, 'geopode.pop', U5=True)
    sum_mean_df.loc[:, 'death_rate_mean_U5'] = (sum_mean_df['death_rate_1_U5'] + sum_mean_df['death_rate_2_U5']) / 2
    sum_mean_df.loc[:, 'num_mStillbirths'] = sum_mean_df['num_mStillbirths'] / 1000  # thousands of stillbirths
    sum_mean_df.loc[:, 'num_mLBW'] = sum_mean_df['num_mLBW'] / 1000  # thousands of mLBWs
    sum_mean_df.to_csv(simoutdir + '\\' + '\\' + 'annual_indicators_2020_2030_mean.csv',
                  index=False)
    return sum_mean_df






datapath, projectpath = load_box_paths()
simoutdir = os.path.join(projectpath, 'simulation_output', '2010_to_2020_v10', 'NGA 2010-20 burnin_hs+itn+smc')
calculate_df(simoutdir,  projectpath)


