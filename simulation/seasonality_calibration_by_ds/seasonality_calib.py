# Execute directly: 'python example_optimization.py'
# or via the calibtool.py script: 'calibtool run example_optimization.py'
import copy
import math
import os
import numpy as np
import pandas as pd

from scipy.special import gammaln

from calibtool.CalibManager import CalibManager
from calibtool.algorithms.OptimTool import OptimTool
from calibtool.plotters.SiteDataPlotter import SiteDataPlotter
from calibtool.plotters.LikelihoodPlotter import LikelihoodPlotter
from dtk.utils.core.DTKConfigBuilder import DTKConfigBuilder
from simtools.SetupParser import SetupParser

from dtk.vector.species import set_larval_habitat
from Helpers import get_spline_values
from malaria.reports.MalariaReport import add_filtered_report
from malaria.reports.MalariaReport import add_event_counter_report
from dtk.interventions.outbreakindividual import recurring_outbreak
from malaria.interventions.health_seeking import add_health_seeking
from dtk.interventions.mosquito_release import add_mosquito_release
from malaria.interventions.malaria_drug_campaigns import add_drug_campaign


from SeasonalityCalibSite import SeasonalityCalibSite

import sys
sys.path.append('../../')
from load_paths import load_box_paths
from simulation_setup_helpers import update_basic_params, set_input_files, add_hfca_hs, load_master_csv

datapath, projectpath = load_box_paths()


# Which simtools.ini block to use for this calibration
SetupParser.default_block = 'HPC'

# Start from a base MALARIA_SIM config builder
cb = DTKConfigBuilder.from_defaults('MALARIA_SIM')
datadir = './'

# duration of simulation in years, -1.
throwaway = 29

# specify DS name here
province = 'Owan East'
# to scale the DS pop so that simulated population is ~200-500 people. if pop_scale
mdf = load_master_csv()
pop_scale  = 300/2000

expname = '%sSeasonalityCalib NMFv2' % province
max_iterations = 1
samples_per_iteration = 50
sim_runs_per_param_set = 50

# only if you want to turn off calibration of specific months
static_params = ['Month1', 'Month2', 'Month3', 'Month4', 'Month5', 'Month6',
                 'Month7', 'Month8', 'Month9', 'Month10', 'Month11', 'Month12']

sites = [
    SeasonalityCalibSite(hfca=province,
                         throwaway=throwaway
                               )
        ]
plotters = [LikelihoodPlotter(combine_sites=True),
            SiteDataPlotter(num_to_plot=0, combine_sites=True)
]


#############################################################################################################
# helper files to specify relative abundance of vector species + initialization of monthly habitats
spline, fractions = get_spline_values(province)

# first 2 params under calibration:
# Constant: amount of habitat available all-year, independent of the monthly habitats
# MaxHab: maximum amount of monthly habitat

# turn this back on if you'd like to turn off sampling in the months listed under static_params
spline.loc[spline['Name'].isin(static_params), 'Dynamic'] = False
spline.loc[spline['Name'] == 'Constant', 'Max'] = 10
spline.loc[spline['Name'] == 'Constant', 'Min'] = 7
spline.loc[spline['Name'] == 'Constant', 'Guess'] = 8.7636648597644
spline.loc[spline['Name'] == 'Constant', 'Dynamic'] = False
spline.loc[spline['Name'] == 'MaxHab', 'Max'] = 14
spline.loc[spline['Name'] == 'MaxHab', 'Min'] = 10
spline.loc[spline['Name'] == 'MaxHab', 'Guess'] = 10.963382916256
spline.loc[spline['Name'] == 'MaxHab', 'Dynamic'] = True

params = []
# add months to list of params being sampled
for i, row in spline.iterrows():
    d = row.to_dict()
    params.append(d)

# overall format of monthly habitat to be specified
ls_hab_ref = { 'Capacity_Distribution_Number_Of_Years' : 1,
               'Capacity_Distribution_Over_Time' : {
                   'Times' : [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334],
                   'Values' : []
               },
               'Max_Larval_Capacity' : 800000000}


# defines how parameters under sampling get consumed by EMOD
def map_sample_to_model_input(cb, sample):

    # set up some variables to hold the values we'll need to update the monthly habitat (hab)
    tags = {}
    sample = copy.deepcopy(sample)

    my_spline = []
    for month in range(1,13) :
        name = 'Month%d' %  month
        if name in sample:
            splinevalue = sample.pop(name)
            my_spline.append(splinevalue)
            tags.update({name: splinevalue})

    max_habitat_name = 'MaxHab'
    maxvalue = sample.pop(max_habitat_name)
    tags.update({max_habitat_name: maxvalue})

    name = 'Constant'
    const = sample.pop(name)
    tags.update({name: const})

    for (s, sp) in zip(fractions, ['arabiensis', 'funestus', 'gambiae']) :
        hab = copy.copy(ls_hab_ref)
        hab['Capacity_Distribution_Over_Time']['Values'] = my_spline
        hab['Max_Larval_Capacity'] = pow(10, maxvalue)*s
        # this function updates EMOD parameters to what is requested based on the calibration parameter sampling
        set_larval_habitat(cb, { sp : {'LINEAR_SPLINE' : hab,
                                       'CONSTANT' : pow(10, const)*s}})

    # set the simulation duration
    cb.set_param("Simulation_Duration", (throwaway+1)*365)

    # scale population down
    pop = mdf.at[province, 'population']/100
    scale_factor = 1/10000.

    cb.update_params({
        "x_Temporary_Larval_Habitat": pop*scale_factor*pop_scale,
        'Base_Population_Scale_Factor' : pop_scale,
        'x_Birth' : pop_scale,
        "Vector_Species_Names": ['arabiensis', 'funestus', 'gambiae'],
        'Enable_Default_Reporting' : 0,
        'Enable_Vector_Species_Report' : 0,
        'logLevel_VectorHabitat' : 'ERROR',
    })

    tags.update({'Pop_Scale' : pop_scale})

    return tags


# other EMOD setup
update_basic_params(cb)
set_input_files(cb, province)
# case management
recurring_outbreak(cb, start_day=182, outbreak_fraction=0.01, tsteps_btwn=365)
hs_df = pd.read_csv(os.path.join(projectpath, 'simulation_inputs',
                                 'arch_med_10.csv'))
# add_hfca_hs(cb, hs_df=hs_df, hfca=province)
add_health_seeking(cb, start_day=365*(throwaway-5),
                   targets=[{'trigger': 'NewClinicalCase', 'coverage': 0.5, 'agemin': 0, 'agemax': 5,
                             'seek': 1, 'rate': 0.3},
                            {'trigger': 'NewClinicalCase', 'coverage': 0.3, 'agemin': 5, 'agemax': 100,
                             'seek': 1, 'rate': 0.3},
                            ],
                   drug=['Artemether', 'Lumefantrine'], duration=-1)
add_health_seeking(cb, start_day=365*(throwaway-5),
                   targets=[{'trigger': 'NewSevereCase', 'coverage': 0.8, 'seek': 1, 'rate': 0.5}],
                   drug=['Artemether', 'Lumefantrine'], duration=-1,
                   broadcast_event_name='Received_Severe_Treatment')

for nmf_years in range(5) :
    add_drug_campaign(cb, 'MSAT', 'AL', start_days=[max([0+1000*nmf_years+1, 365*(throwaway-5) + 1000*nmf_years+1])],
                      coverage=0.0038,
                      repetitions=1000, tsteps_btwn_repetitions=1,
                      diagnostic_type='PF_HRP2', diagnostic_threshold=5,
                      receiving_drugs_event_name='Received_NMF_Treatment')

# request output files
add_filtered_report(cb, start=(throwaway)*365,
                    end=(throwaway+1)*365)
add_event_counter_report(cb, event_trigger_list=['Received_Treatment',
                                                 'Received_NMF_Treatment',
                                                 # 'Received_Severe_Treatment',
                                                 # 'Received_Self_Medication'
                                                 ],
                         duration=(throwaway+1)*365)

# calibtool setup
# Just for fun, let the numerical derivative baseline scale with the number of dimensions
volume_fraction = 0.01   # desired fraction of N-sphere area to unit cube area for numerical derivative (automatic radius scaling with N)
num_params = len([p for p in params if p['Dynamic']])
r = math.exp(1/float(num_params)*(math.log(volume_fraction) + gammaln(num_params/2.+1) - num_params/2.*math.log(math.pi)))
r *= 2

optimtool = OptimTool(params,
    mu_r = r,           # <-- radius for numerical derivatve.  CAREFUL not to go too small with integer parameters
    sigma_r = r/2.,    # <-- stdev of radius
    center_repeats=1, # <-- Number of times to replicate the center (current guess).  Nice to compare intrinsic to extrinsic noise
    samples_per_iteration=samples_per_iteration # was 32  # 32 # <-- Samples per iteration, includes center repeats.  Actual number of sims run is this number times number of sites.
)

calib_manager = CalibManager(name=expname,    # <-- Please customize this name
                             config_builder=cb,
                             map_sample_to_model_input_fn=map_sample_to_model_input,
                             sites=sites,
                             next_point=optimtool,
                             sim_runs_per_param_set=sim_runs_per_param_set,  # <-- Replicates
                             max_iterations=max_iterations,   # <-- Iterations
                             plotters=plotters)


run_calib_args = {
    "calib_manager":calib_manager
}

if __name__ == "__main__":

    if not SetupParser.initialized:
        SetupParser.init()
    cm = run_calib_args["calib_manager"]
    cm.run_calibration()
