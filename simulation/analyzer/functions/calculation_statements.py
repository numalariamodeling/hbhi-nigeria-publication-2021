import pandas as pd
import numpy as np
def set_titles(axes, titles):
    count = 0
    for x in titles:
        axes[count].set_title(x)
        count += 1
def set_axes_limits(axes, limits):
    for count, x in enumerate(limits):
        axes[count].set_ylim(x[0], x[1])
def set_axes_titles(axes, axes_limits):
    return 0
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
                               #'geopode.pop': 'geopode.pop_all_ages',
                               'PfPR': 'PfPR_all_ages',
                               'incidence': 'incidence_all_ages',
                               'death_rate_1': 'death_rate_1_all_ages',
                               'death_rate_2': 'death_rate_2_all_ages',
                               'U5_PfPR': 'PfPR_U5',
                               'U5_incidence': 'incidence_U5',
                               'U5_death_rate_1': 'death_rate_1_U5',
                               'U5_death_rate_2': 'death_rate_2_U5'}))
def calculate_rate(data, numerator, denominator, perThousand = False):
    if perThousand is True:
        return data[numerator]/data[denominator]*1000
    else:
        return data[numerator]/data[denominator]
def calc_ann_nation_indicators(data, population, U5 = False):
    channel_suffix = ''
    if U5 == True:
     channel_suffix = '_U5'
    else:
     channel_suffix = '_all_ages'
    data = data.copy()
    data.loc[:, 'PfPR' + channel_suffix] = calculate_rate(data, 'positives' + channel_suffix, population + channel_suffix)
    data.loc[:, 'incidence' + channel_suffix] = calculate_rate(data, 'cases' + channel_suffix, population + channel_suffix, True)
    data.loc[:, 'death_rate_1' + channel_suffix] = calculate_rate(data, 'deaths_1' + channel_suffix, population + channel_suffix, True)
    data.loc[:, 'death_rate_2' + channel_suffix] = calculate_rate(data, 'deaths_2' + channel_suffix, population + channel_suffix, True)
    return data

def rescale_age_metrics(data, population, U5 = False):
    if U5 == True:
        channel_suffix = '_U5'
    else:
        channel_suffix = '_all_ages'
        data.loc[:, 'num_mLBW'] = data['mLBW_births'] * data[population + channel_suffix] / data['Population' + channel_suffix]
        data.loc[:, 'num_mStillbirths'] = data['MiP_stillbirths'] * data[population + channel_suffix] / data['Population' + channel_suffix]
    data = data.copy()
    data.loc[:, 'positives' + channel_suffix] = data['PfPR' + channel_suffix] * data[population + channel_suffix]
    data.loc[:, 'cases' + channel_suffix] = data['New_clinical_cases' + channel_suffix] * data[population + channel_suffix] / data['Population' + channel_suffix]
    data.loc[:, 'deaths_1' + channel_suffix] = data['total_mortality_1' + channel_suffix] * data[population + channel_suffix] / data['Population' + channel_suffix]
    data.loc[:, 'deaths_2' + channel_suffix] = data['total_mortality_2' + channel_suffix] * data[population + channel_suffix] / data['Population' + channel_suffix]
    return data