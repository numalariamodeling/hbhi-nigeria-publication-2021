from dtk.utils.core.DTKConfigBuilder import DTKConfigBuilder
from simtools.ExperimentManager.ExperimentManagerFactory import ExperimentManagerFactory
from simtools.SetupParser import SetupParser
from simtools.ModBuilder import ModBuilder, ModFn
import sys
sys.path.append('../../')
from simulation.set_up_simulation_config import update_basic_params, load_master_csv, setup_ds
import os
import pandas as pd
import numpy as np
from simulation.load_paths import load_box_paths

SetupParser.default_block = 'HPC'

datapath, projectpath = load_box_paths(parser_default=SetupParser.default_block)

expname = 'GN_archetype_biting_sweep_Nzerekore'
num_seeds = 1
years = 2

cb = DTKConfigBuilder.from_defaults('VECTOR_SIM')
cb.update_params( {
    'Simulation_Duration' : years*365+1,
    "Vector_Species_Names": ['arabiensis', 'funestus', 'gambiae'],
    'Enable_Vector_Species_Report' : 0,
})

# BASIC SETUP
update_basic_params(cb)

df = load_master_csv()
rel_abundance_fname = os.path.join(projectpath, 'simulation_inputs', 'DS_vector_rel_abundance.csv')
rel_abund_df = pd.read_csv(rel_abundance_fname)
rel_abund_df = rel_abund_df.set_index('DS_Name')
lhdf = pd.read_csv(os.path.join(projectpath, 'simulation_inputs', 'larval_habitats', 'monthly_habitats5.csv'))

sweepspace = { my_ds : np.concatenate((np.logspace(np.log10(0.6), np.log10(1), 20),
                                       np.logspace(np.log10(10000), np.log10(50000), 80))) for my_ds in lhdf['archetype'].values}

lhdf = lhdf.set_index('archetype')
lhdf = lhdf.reset_index()


# BUILDER
builder = ModBuilder.from_list([[ModFn(setup_ds, my_ds=my_ds, archetype_ds=my_ds,
                                       pull_from_serialization=False,
                                       rel_abund_df=rel_abund_df,
                                       lhdf=lhdf, hab_multiplier=hab_scale),
                                 ModFn(DTKConfigBuilder.set_param, 'Run_Number', x),
                                 ModFn(DTKConfigBuilder.set_param, 'Habitat_Multiplier', hab_scale),
                                 ModFn(DTKConfigBuilder.set_param, 'Enable_Default_Reporting', 1),
                                 ]
                                for my_ds in lhdf['archetype'].values
                                for x in range(num_seeds)
                                for hab_scale in sweepspace[my_ds]
                                ])

run_sim_args = {
    'exp_name': expname,
    'config_builder': cb,
    'exp_builder': builder
}


if __name__ == "__main__":
    SetupParser.init()
    exp_manager = ExperimentManagerFactory.init()
    exp_manager.run_simulations(**run_sim_args)
