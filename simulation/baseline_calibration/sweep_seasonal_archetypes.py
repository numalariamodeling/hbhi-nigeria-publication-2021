from dtk.utils.core.DTKConfigBuilder import DTKConfigBuilder
from simtools.ExperimentManager.ExperimentManagerFactory import ExperimentManagerFactory
from simtools.SetupParser import SetupParser
from simtools.ModBuilder import ModBuilder, ModFn
from malaria.reports.MalariaReport import add_filtered_report, add_summary_report
from malaria.reports.MalariaReport import add_event_counter_report
import sys
sys.path.append('../../')
from simulation.set_up_simulation_config import update_basic_params, set_up_hfca, add_hfca_hs, load_master_csv, habitat_scales
from malaria.interventions.malaria_drug_campaigns import add_drug_campaign
import os
import pandas as pd
import numpy as np
from simulation.load_paths import load_box_paths


SetupParser.default_block = 'NUCLUSTER'

datapath, projectpath = load_box_paths(parser_default=SetupParser.default_block)


expname = 'NGA archetype PfPR sweep burnin new'
num_seeds = 1
years = 50
# burnin_expid = '125945e7-1ec4-e911-a2c1-c4346bcb1555' # regular rainfall
serialize = True
pull_from_serialization = False
read_limits_from_file = True

cb = DTKConfigBuilder.from_defaults('MALARIA_SIM')
cb.update_params( {
    'Simulation_Duration' : years*365+1,
    "Vector_Species_Names": ['arabiensis', 'funestus', 'gambiae'],
    'Enable_Default_Reporting' : 0,
    'Enable_Vector_Species_Report' : 0,
    'Report_Detection_Threshold_Blood_Smear_Parasites' : 20,
    "Parasite_Smear_Sensitivity": 0.05,  # 50/uL
    # 'Base_Population_Scale_Factor' : 0.01,
})

if serialize :
    cb.update_params( {
        'Serialization_Time_Steps': [365 * (years - 5), 365 * years],
        'Serialization_Type': 'TIMESTEP',
        'Serialization_Mask_Node_Write': 0,
        # 0 corresponds to the previous version default: the same larval habitat parameters will be used in the burnin and pickup (from the burnin config)
        'Serialization_Precision': 'REDUCED'
    })

# BASIC SETUP
update_basic_params(cb)

# INTERVENTIONS
hs_df = pd.read_csv(os.path.join(projectpath, 'simulation_inputs', 'projection_csvs', 'archetype_files',
                                 'arch_med_10_v2.csv'))

# for nmf_years in range(years - 5, years):
# CUSTOM REPORTS
add_filtered_report(cb, start=max([0, (years-1)*365]), end=years*365)

df = load_master_csv()

# hab_scale_factor_fname = os.path.join(projectpath, 'simulation_inputs', 'larval_habitats', 'larval_habitat_multipliers_v4.csv')
# hab_df = pd.read_csv(hab_scale_factor_fname)
# hab_df = hab_df.set_index('DS_Name')
rel_abundance_df = habitat_scales()
lhdf = pd.read_csv(os.path.join(projectpath, 'simulation_inputs', 'larval_habitats', 'monthly_habitatv2.csv'))

if read_limits_from_file :
    lim_df = pd.read_csv(os.path.join(projectpath, 'simulation_output', 'prevalence',
                                      'min_max_hab_to_sample_for_archetype_pfpr.csv'))
    sweepspace = { row['LGA'] : np.logspace(np.log10(row['min_hab']),
                                            np.log10(row['max_hab']),
                                            50) for r,row in lim_df.iterrows()}
else :
    sweepspace = { hfca : np.logspace(np.log10(0.05), np.log10(300), 200) for hfca in lhdf['archetype'].values}

lhdf = lhdf.set_index('archetype')
pop_scale = 0.15
# scale_factor = 1 / 10000. * (1 / pop_scale)
lhdf = lhdf.reset_index()

# BUILDER
builder = ModBuilder.from_list([[ModFn(set_up_hfca, hfca=my_hfca,
                                       archetype_hfca=my_hfca,
                                       pull_from_serialization=pull_from_serialization,
                                       burnin_id='',
                                       ser_date=0,
                                       hdf=rel_abundance_df,
                                       lhdf=lhdf,
                                       from_arch=True,
                                       hab_multiplier=hab_scale, #hab_df.at[my_hfca, 'x_Temporary_Larval_Habitat'],
                                       run_number=0),
                                 # ModFn(add_hfca_hs, hs_df=hs_df, hfca=my_hfca),
                                 ModFn(DTKConfigBuilder.set_param, 'Run_Number', x),
                                 ModFn(DTKConfigBuilder.set_param, 'x_Temporary_Larval_Habitat', 0.03/pop_scale),
                                 ModFn(DTKConfigBuilder.set_param, 'Habitat_Multiplier', hab_scale),
                                 ]
                                for my_hfca in sweepspace.keys()
                                for x in range(num_seeds)
                                for hab_scale in sweepspace[my_hfca]
                                ] )

run_sim_args = {
    'exp_name': expname,
    'config_builder': cb,
    'exp_builder': builder
}


if __name__ == "__main__":

    SetupParser.init()
    exp_manager = ExperimentManagerFactory.init()
    exp_manager.run_simulations(**run_sim_args)

