from dtk.utils.core.DTKConfigBuilder import DTKConfigBuilder
from simtools.ExperimentManager.ExperimentManagerFactory import ExperimentManagerFactory
from simtools.SetupParser import SetupParser
from simtools.ModBuilder import ModBuilder, ModFn
from malaria.reports.MalariaReport import add_filtered_report, add_summary_report
from malaria.interventions.malaria_drug_campaigns import add_drug_campaign
import sys
sys.path.append('../../../')
from simulation.load_paths import load_box_paths
from simulation.simulation_setup_helpers import update_basic_params, set_up_hfca, load_pop_scale_factor,\
    load_master_csv, habitat_scales, add_all_interventions
import os
import pandas as pd
import numpy as np

datapath, projectpath = load_box_paths()


expname = 'NGA archetype PfPR ITN sweep_new'
num_seeds = 5
ser_date = 50*365
years = 1
burnin_id = 'cd61d557-3f92-eb11-a2ce-c4346bcb1550' #use sweep id from sweep_seasonal_archetypes : cd61d557-3f92-eb11-a2ce-c4346bcb1550
pull_from_serialization = True

if __name__ == "__main__":

    cb = DTKConfigBuilder.from_defaults('MALARIA_SIM')
    cb.update_params({
        'Simulation_Duration': years * 365,
        "Vector_Species_Names": ['arabiensis', 'funestus', 'gambiae'],
        'Enable_Default_Reporting': 1,
        'Enable_Vector_Species_Report': 0,
        'Report_Detection_Threshold_Blood_Smear_Parasites': 20,
        "Parasite_Smear_Sensitivity": 0.05,  # 50/uL
    })

    # BASIC SETUP
    update_basic_params(cb)

    # INTERVENTIONS
    hs_df = pd.read_csv(os.path.join(projectpath, 'simulation_inputs', 'projection_csvs', 'archetype_files',
                                 'arch_med_10_v2.csv'))
    for nmf_years in range(5):
        add_drug_campaign(cb, 'MSAT', 'AL',
                          start_days=[max([1 + 365 * nmf_years, 1 + 365 * (years - 5) + 365 * nmf_years])],
                          coverage=0.0038,
                          repetitions=365, tsteps_btwn_repetitions=1,
                          diagnostic_type='PF_HRP2', diagnostic_threshold=5,
                          receiving_drugs_event_name='Received_NMF_Treatment')
    itn_df = pd.read_csv(os.path.join(projectpath, 'simulation_inputs', 'projection_csvs', 'archetype_files',
                                      'ITN_archetype_10_v4.csv'))
    # itn_anc_df = pd.read_csv(os.path.join(projectpath, 'simulation_inputs', 'ITN_ANC_with_killing.csv'))

    # CUSTOM REPORTS
    # add_filtered_report(cb, start=(years-1)*365, end=years*365)
    add_summary_report(cb, start=0, age_bins=[0.25, 5, 15, 125], interval=30,
                       description='MonthlyU5', parasitemia_bins=[10, 50, 1e9])
    add_summary_report(cb, start=0, age_bins=[2, 10, 125], interval=365,
                       description='Annual2to10', parasitemia_bins=[10, 50, 1e9])

    df = load_master_csv()
    rel_abundance_df = habitat_scales()
    lhdf = pd.read_csv(os.path.join(projectpath, 'simulation_inputs', 'larval_habitats','monthly_habitatv2.csv'))
    lhdf = lhdf.set_index('archetype')

    lim_df = pd.read_csv(os.path.join(projectpath, 'simulation_output', 'prevalence',
                                      'min_max_hab_to_sample_for_archetype_pfpr.csv'))
    sweepspace = {row['LGA']: np.logspace(np.log10(row['min_hab']),
                                          np.log10(row['max_hab']),
                                          50) for r, row in lim_df.iterrows()}

    pop_scale = 0.15
    # scale_factor = 1 / 10000. * (1 / pop_scale)
    lhdf = lhdf.reset_index()

    # BUILDER
    builder = ModBuilder.from_list([[ModFn(set_up_hfca, hfca=my_hfca, archetype_hfca=my_hfca,
                                           pull_from_serialization=pull_from_serialization,
                                           burnin_id=burnin_id, ser_date=ser_date,
                                           hdf=rel_abundance_df,
                                           lhdf=lhdf,
                                           from_arch=True,
                                           hab_multiplier=hab_scale,
                                           run_number=0),
                                     ModFn(DTKConfigBuilder.set_param, 'Run_Number', x),
                                     ModFn(DTKConfigBuilder.set_param, 'x_Temporary_Larval_Habitat',
                                           0.03/pop_scale),
                                     ModFn(DTKConfigBuilder.set_param, 'Habitat_Multiplier', hab_scale),
                                     ModFn(add_all_interventions, smc_df=pd.DataFrame(), itn_df=itn_df, hs_df=hs_df,
                                           hfca=my_hfca, irs_df=pd.DataFrame(), itn_anc_df=pd.DataFrame()),
                                     ModFn(DTKConfigBuilder.set_param, 'DS_Name_for_ITN', my_hfca),
                                     ]
                                    for my_hfca in sweepspace.keys()
                                    for x in range(num_seeds)
                                    for hab_scale in sweepspace[my_hfca]
                                    ])

    run_sim_args = {
        'exp_name': expname,
        'config_builder': cb,
        'exp_builder': builder
    }

    SetupParser.default_block = 'HPC'
    SetupParser.init()
    exp_manager = ExperimentManagerFactory.init()
    exp_manager.run_simulations(**run_sim_args)

