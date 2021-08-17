import pandas as pd
import os
import sys
from simtools.Utilities.Experiments import retrieve_experiment
from simtools.SetupParser import SetupParser
sys.path.append('../')
from load_paths import load_box_paths
from simulation_setup_helpers import load_master_csv, load_spline_and_scale_factors, habitat_scales

datapath, projectpath = load_box_paths()


def get_spline_values(hfca):

    hdf = habitat_scales()

    df = pd.DataFrame( { 'Name' : ['Month%d' % x for x in range(1,13)],
                         'Guess' : [0]*12})
    df = pd.concat([df, pd.DataFrame( { 'Name' : ['MaxHab'], 'Guess' : [12]}),
                    pd.DataFrame( { 'Name' : ['Constant'], 'Guess' : [8]})])

    df.loc[df['Name'] == 'Month1', 'Guess'] = 0
    df.loc[df['Name'] == 'Month2', 'Guess'] = 0
    df.loc[df['Name'] == 'Month3', 'Guess'] = 0
    df.loc[df['Name'] == 'Month4', 'Guess'] = 0
    df.loc[df['Name'] == 'Month5', 'Guess'] = 0.001
    df.loc[df['Name'] == 'Month6', 'Guess'] = 0.001
    df.loc[df['Name'] == 'Month7', 'Guess'] = 0.00775
    df.loc[df['Name'] == 'Month8', 'Guess'] = 0.0081
    df.loc[df['Name'] == 'Month9', 'Guess'] = 0.003
    df.loc[df['Name'] == 'Month10', 'Guess'] = 0.002
    df.loc[df['Name'] == 'Month11', 'Guess'] = 0
    df.loc[df['Name'] == 'Month12', 'Guess'] = 0

    df['Min'] = df['Guess'] * 0.1
    df['Max'] = df['Guess'] * 10
    df['Dynamic'] = True

    a = hdf.at[hfca, 'arabiensis_scale_factor']
    f = hdf.at[hfca, 'funestus_scale_factor']
    g = hdf.at[hfca, 'gambiae_scale_factor']
    tot = a + f + g
    a /= tot
    f /= tot
    g /= tot
    fraction = (a, f, g)

    return df, fraction


def get_cases(hfca) :

    reference_fname = os.path.join(projectpath, 'simulation_inputs', 'DHS', 'archetype_incidence_NGA_RIA_v3.csv')

    ref_df = pd.read_csv(reference_fname)
    ref_df = ref_df[ref_df['seasonality'] == hfca]
    ref_df = ref_df.rename(columns={'month': 'Month',
                                    'population' : 'Trials'})
    ref_df['Observations'] = ref_df['incidence'] * ref_df['Trials'] / 1000

    return ref_df[['Month', 'Trials', 'Observations']]
