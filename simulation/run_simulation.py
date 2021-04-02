from dtk.utils.core.DTKConfigBuilder import DTKConfigBuilder
from simtools.ExperimentManager.ExperimentManagerFactory import ExperimentManagerFactory
from simtools.SetupParser import SetupParser
from simtools.ModBuilder import ModBuilder, ModFn
from malaria.reports.MalariaReport import add_filtered_report, add_summary_report, add_event_counter_report
from load_paths import load_box_paths
from simulation_setup_helpers import update_basic_params, set_up_hfca, hs_by_accessIP, add_hfca_hs
from simulation_setup_helpers import load_master_csv, habitat_scales
from dtk.interventions.property_change import change_individual_property_at_age
from malaria.interventions.malaria_drug_campaigns import add_drug_campaign
import os
import pandas as pd

datapath, projectpath = load_box_paths()


hfca = 'Alkaleri'
expname = 'HSB 2010 Nigeria'
num_seeds = 1
years = 50
ser_date = 50*365
burnin_ids = {
}
serialize = False
pull_from_serialization = False


if __name__ == "__main__":

    cb = DTKConfigBuilder.from_defaults('MALARIA_SIM')
    cb.update_params({
        'Simulation_Duration': years * 365 + 1,
        "Vector_Species_Names": ['arabiensis', 'funestus', 'gambiae'],
        'Enable_Default_Reporting': 0,
        'Enable_Vector_Species_Report': 0,
        'Report_Detection_Threshold_Blood_Smear_Parasites': 50,
        "Parasite_Smear_Sensitivity": 0.02,  # 50/uL
        "x_Temporary_Larval_Habitat": 5,
        # 'Enable_Property_Output' : 1,
        # 'Base_Population_Scale_Factor' : 0.01
    })

    if serialize:
        cb.update_params({
            'Serialization_Time_Steps': [365 * years]
        })

    # BASIC SETUP
    update_basic_params(cb)
    change_individual_property_at_age(cb, 'AgeGroup', '15to30', 15*365)
    change_individual_property_at_age(cb, 'AgeGroup', '30to50', 30*365)
    change_individual_property_at_age(cb, 'AgeGroup', '50plus', 50*365)

    # INTERVENTIONS
    # hs_by_accessIP(cb, start=max([0, 365*(years-5)]), duration=-1, free_care=False)
    # hs_by_accessIP(cb, start=6 * 365, free_care=True)

    hs_df = pd.read_csv(os.path.join(projectpath, 'simulation_inputs',
                                      'arch_med_10.csv'))
    for nmf_years in range(years-5,years):
        add_drug_campaign(cb, 'MSAT', 'AL',
                          start_days=[1 + 365 * nmf_years],
                          coverage=0.0038,
                          repetitions=365, tsteps_btwn_repetitions=1,
                          diagnostic_type='PF_HRP2', diagnostic_threshold=5,
                          receiving_drugs_event_name='Received_NMF_Treatment')
    # CUSTOM REPORTS

    add_filtered_report(cb, start=max([0, 365*(years-5)]), end=years * 365)
    # for year in range(years):
    #     add_summary_report(cb, start=365 * year, age_bins=[0.25, 5, 15, 50, 125], interval=30, duration_days=365,
    #                        description='Monthly%d' % (year + 2010), parasitemia_bins=[10, 50, 1e9])
    add_event_counter_report(cb, event_trigger_list= ['Received_Treatment', 'Received_Severe_Treatment',
                        'Received_NMF_Treatment'], duration=365 * years)
    # FOR CONFIGURING LARVAL HABTIATS
    # df = load_master_csv()
    # hab_scale_factor_fname = os.path.join(projectpath, 'simulation_inputs', 'larval_habitat_multipliers.csv')
    # hab_df = pd.read_csv(hab_scale_factor_fname)
    # hab_df = hab_df.set_index('DS_Name')
    rel_abundance_df = habitat_scales()
    # lhdf = pd.read_csv(os.path.join(projectpath, 'simulation_inputs', 'monthly_habitats.csv'))

    # BUILDER
    builder = ModBuilder.from_list([[ModFn(set_up_hfca, hfca=my_hfca,
                                           # archetype_hfca=df.at[my_hfca, 'seasonality_archetype'],
                                           pull_from_serialization=pull_from_serialization,
                                           # burnin_id=burnin_ids[df.at[my_hfca, 'seasonality_archetype']],
                                           # ser_date=ser_date,
                                           hdf=rel_abundance_df,
                                           # lhdf=lhdf,
                                           # pop=df.at[df.at[my_hfca, 'seasonality_archetype'], 'population'],
                                           # hab_multiplier=hab_df.at[my_hfca, 'x_Temporary_Larval_Habitat'],
                                           run_number=(x % 10)),
                                     ModFn(add_hfca_hs, hs_df=hs_df,  hfca=my_hfca),
                                     ModFn(DTKConfigBuilder.set_param, 'Run_Number', x),
                                     # ModFn(DTKConfigBuilder.set_param, 'x_Temporary_Larval_Habitat',
                                     #       hab_df.at[my_hfca, 'x_Temporary_Larval_Habitat']), # note that this is overwriting what set_up_hfca() is doing to x_Temp
                                     ]
                                    # for my_hfca in [hfca]
                                    for my_hfca in hs_df["Rep_DS"]
                                    for x in range(num_seeds)
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

