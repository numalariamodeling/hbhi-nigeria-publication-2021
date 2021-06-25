from dtk.utils.core.DTKConfigBuilder import DTKConfigBuilder
from simtools.ExperimentManager.ExperimentManagerFactory import ExperimentManagerFactory
from simtools.SetupParser import SetupParser
from simtools.ModBuilder import ModBuilder, ModFn
from malaria.reports.MalariaReport import add_filtered_report, add_summary_report
from load_paths import load_box_paths
from set_up_simulation_config import update_basic_params, set_up_hfca, load_master_csv, habitat_scales, add_all_interventions, update_drug_config
import os
from malaria.interventions.malaria_drug_campaigns import add_drug_campaign
import pandas as pd

SetupParser.default_block = 'HPC'

datapath, projectpath = load_box_paths(parser_default=SetupParser.default_block)

num_seeds = 5
years = 11
ser_date = 10*365
serialize = False
pull_from_serialization = False
sulf_C50 = 0.2

burnin_id = '2021_04_16_17_41_30_761008'

if __name__ == "__main__":

    scenario_fname = os.path.join(projectpath, 'simulation_inputs',
                                    'projection_csvs', 'projection_v3', 'Intervention_scenarios_nigeria_v3.csv')  # use script for loading all files for scenarios
    scen_df = pd.read_csv(scenario_fname)

    scen_index = scen_df[scen_df['status'] == 'run'].index[0]

    expname = 'NGA_projection_scenario_%d' % scen_df.at[scen_index, 'Scenario_no']

    cb = DTKConfigBuilder.from_defaults('MALARIA_SIM')
    cb.update_params({
        'Simulation_Duration': years * 365 + 1,
        "Vector_Species_Names": ['arabiensis', 'funestus', 'gambiae'],
        'Enable_Default_Reporting': 0,
        'Enable_Property_Output': 0,
        'Enable_Vector_Species_Report': 0,
        'Report_Detection_Threshold_Blood_Smear_Parasites': 50,
        "Parasite_Smear_Sensitivity": 0.02,  # 50/uL
        # 'Base_Population_Scale_Factor' : 0.01,
        'x_Temporary_Larval_Habitat' : 0.03/0.15,
        "Report_Event_Recorder" : 1,
        "Report_Event_Recorder_Individual_Properties" : [],
        "Report_Event_Recorder_Events" : ['Received_Severe_Treatment'],
        "Report_Event_Recorder_Ignore_Events_In_List" : 0,
        'Listed_Events' : ['Bednet_Got_New_One', 'Bednet_Using', 'Bednet_Discarded','Received_Severe_Treatment']
    })

    if serialize:
        cb.update_params({
            'Serialization_Time_Steps': [365 * years],
            'Serialization_Type': 'TIMESTEP',
            'Serialization_Mask_Node_Write': 0,
            'Serialization_Precision': 'REDUCED'
        })
    # BASIC SETUP
    update_basic_params(cb)

    # INTERVENTIONS
    # malaria testing prompted by NMF
    for nmf_years in range(years):
        add_drug_campaign(cb, 'MSAT', 'AL',
                          start_days=[1 + 365 * nmf_years],
                          coverage=0.0038,
                          repetitions=365, tsteps_btwn_repetitions=1,
                          diagnostic_type='PF_HRP2', diagnostic_threshold=5,
                          receiving_drugs_event_name='Received_NMF_Treatment')
    # health-seeking
    try:
        hs_df = pd.read_csv(os.path.join(projectpath, 'simulation_inputs','projection_csvs', 'projection_v3',
                                         '%s.csv' % scen_df.at[scen_index, 'CM_filename']))
    except IOError:
        hs_df = pd.DataFrame()

    # ITNs
    try :
        itn_df = pd.read_csv(os.path.join(projectpath, 'simulation_inputs','projection_csvs', 'projection_v3',
                                          '%s.csv' % scen_df.at[scen_index, 'ITN_filename']))
    except IOError :
        itn_df = pd.DataFrame()

    # ITN ANC
    try:
        itn_anc_df = pd.read_csv(os.path.join(projectpath, 'simulation_inputs',  'projection_csvs', 'projection_v3',
                                              '%s.csv' % scen_df.at[scen_index, 'ANC_filename']))
    except IOError:
        itn_anc_df = pd.DataFrame()

    # IRS
    try:
        irs_df = pd.read_csv(os.path.join(projectpath, 'simulation_inputs', 'projection_csvs', 'projection_v3',
                                          '%s.csv' % scen_df.at[scen_index, 'IRS_filename']))
    except IOError:
        irs_df = pd.DataFrame()

    # SMC
    try :
        smc_df = pd.read_csv(os.path.join(projectpath, 'simulation_inputs', 'projection_csvs', 'projection_v3',
                                          '%s.csv' % scen_df.at[scen_index, 'SMC_filename']))
    except IOError :
        smc_df = pd.DataFrame()


    # CUSTOM REPORTS
    add_filtered_report(cb, start=0, end=years * 365)
    for year in range(years):
        for year in range(years):
            add_summary_report(cb, start=365 * year,
                               age_bins= [0.25, 5, 15, 30,50, 125],
                               interval=30, duration_days=365,
                               description='Monthly%d' %(year + 2020), parasitemia_bins = [10, 50, 1e9])
            add_summary_report(cb, start=365 * year, age_bins=[1, 5, 120],
                               interval=30, duration_days=365,
                               description='FineMonthly%d' %(year + 2020), parasitemia_bins = [10, 50, 1e9])

    # FOR CONFIGURING LARVAL HABTIATS
    hab_scale_factor_fname = os.path.join(projectpath, 'simulation_inputs', 'larval_habitats',
                                          'larval_habitat_multipliers_v4.csv')
    hab_df = pd.read_csv(hab_scale_factor_fname)
    hab_df = hab_df.set_index('LGA')
    rel_abundance_df = habitat_scales()
    lhdf = pd.read_csv(os.path.join(projectpath, 'simulation_inputs', 'larval_habitats','monthly_habitatv2.csv'))
    df = load_master_csv()
    df.reset_index(inplace=True)
    df = df.set_index('LGA')
    my_ds_list = list(df.index.values)

    # BUILDER
    builder = ModBuilder.from_list([[ModFn(set_up_hfca, hfca=my_hfca,
                                           archetype_hfca=df.at[my_hfca, 'Archetype'],
                                           pull_from_serialization=pull_from_serialization,
                                           burnin_id=burnin_id,
                                           ser_date=ser_date,
                                           hdf=rel_abundance_df,
                                           lhdf=lhdf,
                                           from_arch=False,
                                           hab_multiplier=hab_df.at[df.at[my_hfca, 'Archetype'], 'Habitat_Multiplier'],
                                           run_number=0),

                                     ModFn(add_all_interventions,
                                           irs_df=irs_df,
                                           smc_df=smc_df,
                                           itn_df=itn_df,
                                           itn_anc_df=itn_anc_df,
                                           hs_df=hs_df,
                                           hfca=my_hfca),
                                     ModFn(update_drug_config,
                                           # note: this call updates all other drug params to the values specified in the update_drug_params.py file
                                           list_drug_param=['Sulfadoxine', 'Drug_PKPD_C50'],
                                           value=sulf_C50),
                                     ModFn(DTKConfigBuilder.set_param, 'Run_Number', x),
                                     ModFn(DTKConfigBuilder.set_param, 'Scenario_Number', scen_index),
                                     ModFn(DTKConfigBuilder.set_param, 'Habitat_Multiplier',
                                           hab_df.at[my_hfca, 'Habitat_Multiplier']),
                                     ]

                                    # for my_hfca in ['Silame']
                                    for my_hfca in df.index
                                    for x in range(num_seeds)
                                    ])

    run_sim_args = {
        'exp_name': expname,
        'config_builder': cb,
        'exp_builder': builder
    }

    SetupParser.init()
    exp_manager = ExperimentManagerFactory.init()
    exp_manager.run_simulations(**run_sim_args)