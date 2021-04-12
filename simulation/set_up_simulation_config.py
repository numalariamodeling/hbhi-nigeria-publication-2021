import os
import copy
import pandas as pd
import numpy as np
from malaria.interventions.health_seeking import add_health_seeking
from dtk.interventions.outbreakindividual import recurring_outbreak
from dtk.vector.species import update_species_param, set_species, get_species_param, set_larval_habitat
from dtk.vector.species import set_larval_habitat
from simtools.Utilities.Experiments import retrieve_experiment
from dtk.interventions.itn_age_season import add_ITN_age_season
from dtk.interventions.biting_risk import change_biting_risk
from dtk.interventions.irs import add_IRS
from malaria.interventions.malaria_drug_campaigns import add_drug_campaign, add_diagnostic_survey
from malaria.reports.MalariaReport import add_event_counter_report
from simulation.load_paths import load_box_paths
from simulation.update_drug_params import update_drugs




datapath, projectpath = load_box_paths()


def set_up_hfca(cb, hfca, archetype_hfca=None,
                pull_from_serialization=False,
                burnin_id='', ser_date=50*365,
                hdf=None, lhdf=None, from_arch=True,
                hab_multiplier=-1, run_number=-1,
                parser_default='HPC') :

    set_input_files(cb, hfca, archetype_hfca)
    if not archetype_hfca :
        archetype_hfca = hfca

    set_habitats(cb, hfca, hdf, lhdf, archetype_hfca, abs(hab_multiplier))

    if pull_from_serialization:
        if parser_default == 'HPC':
            from simtools.Utilities.COMPSUtilities import COMPS_login
            COMPS_login('https://comps.idmod.org')
        hab_scale_factor_param_name = 'Habitat_Multiplier'

        # serialization
        expt = retrieve_experiment(burnin_id)
        # creating data with all the simulation tags
        ser_df = pd.DataFrame([x.tags for x in expt.simulations])
        if from_arch :
            ser_df = ser_df[ser_df['LGA'] == archetype_hfca]
        else :
            ser_df = ser_df[ser_df['LGA'] == hfca]
        # getting paths for all the sims
        ser_df["outpath"] = pd.Series([sim.get_path() for sim in expt.simulations])
        if hab_multiplier >= 0 and run_number >= 0 :
            ser_df[hab_scale_factor_param_name] = ser_df[hab_scale_factor_param_name].apply(lambda x : np.round(x, 5))
            sdf = ser_df[(ser_df[hab_scale_factor_param_name] == np.round(hab_multiplier, 5)) &
                         (ser_df['Run_Number'] == run_number)]
            cb.update_params({
                hab_scale_factor_param_name: hab_multiplier
            })
            ser_path = sdf['outpath'].values[0]
        elif 'LGA' in ser_df.columns.values :
            ser_df = ser_df[ser_df['Run_Number'] == run_number]
            ser_df = ser_df.set_index('LGA')
            ser_path = ser_df.at[hfca, 'outpath']
        else :
            ser_path = ser_df['outpath'].values[0]

        cb.update_params( {
            'Serialized_Population_Path' : os.path.join(ser_path, 'output'),
            'Serialized_Population_Filenames' : ['state-%05d.dtk' % ser_date]
        })

    recurring_outbreak(cb, start_day=182, outbreak_fraction=0.01, tsteps_btwn=365)

    return {'LGA' : hfca,
            'archetype' : archetype_hfca}


def set_habitats(cb, hfca, hdf, lhdf, archetype_hfca, hab_multiplier) :

    a = hdf.at[archetype_hfca, 'arabiensis_scale_factor']
    f = hdf.at[archetype_hfca, 'funestus_scale_factor']
    g = hdf.at[archetype_hfca, 'gambiae_scale_factor']
    tot = a + f + g
    a /= tot
    f /= tot
    g /= tot
    fraction = (a, f, g)

    ls_hab_ref = {'Capacity_Distribution_Number_Of_Years': 1,
                  'Capacity_Distribution_Over_Time': {
                      'Times': [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334],
                      'Values': []
                  },
                  'Max_Larval_Capacity': 800000000}

    my_spline, maxvalue, const, pop_scale = load_spline_and_scale_factors(lhdf, archetype_hfca)
    const_mult = 1 if hab_multiplier >=1 else hab_multiplier

    for (s, sp) in zip(fraction, ['arabiensis', 'funestus', 'gambiae']) :
        hab = copy.copy(ls_hab_ref)
        hab['Capacity_Distribution_Over_Time']['Values'] = my_spline
        hab['Max_Larval_Capacity'] = pow(10, maxvalue)*s*hab_multiplier
        # this function updates EMOD parameters to what is requested based on the calibration parameter sampling
        set_larval_habitat(cb, { sp : {'LINEAR_SPLINE' : hab,
                                       'CONSTANT' : pow(10, const)*s*const_mult}})


def load_spline_and_scale_factors(lhdf, archetype_hfca) :

    lhdf = lhdf.set_index('archetype')
    my_spline = [lhdf.at[archetype_hfca, 'Month%d' % x] for x in range(1, 13)]
    maxvalue = lhdf.at[archetype_hfca, 'MaxHab']
    const = lhdf.at[archetype_hfca, 'Constant']
    pop_scale = lhdf.at[archetype_hfca, 'pop_scale']

    return my_spline, maxvalue, const, pop_scale


def load_master_csv() :

    master_csv = os.path.join(projectpath, 'nigeria_LGA_pop.csv')
    df = pd.read_csv(master_csv, encoding='latin')
    df['LGA'] = df['LGA'].str.normalize('NFKD').str.encode('ascii', errors='ignore').str.decode('utf-8')
    df = df.set_index('LGA')
    return df


def load_pop_scale_factor(lhdf, archetype_hfca) :

    df = load_master_csv()
    my_spline, maxvalue, const, pop_scale = load_spline_and_scale_factors(lhdf, archetype_hfca)
    scale_factor = 1 / 10000. * (1 / pop_scale)
    pop = df.at[archetype_hfca, 'population']

    return pop, scale_factor


def set_input_files(cb, hfca, archetype_hfca) :

    cb.update_params( {
        'LGA' : hfca,
        'Archeype' : archetype_hfca,
        'Demographics_Filenames' : [os.path.join(hfca, '%s_demographics_accessIP_wSMC_risk.json' % hfca)],
        "Air_Temperature_Filename": os.path.join(archetype_hfca, '%s_air_temperature_daily_2016.bin' % archetype_hfca),
        "Land_Temperature_Filename": os.path.join(archetype_hfca, '%s_air_temperature_daily_2016.bin' % archetype_hfca),
        "Rainfall_Filename": os.path.join(archetype_hfca, '%s_rainfall_daily_2016.bin' % archetype_hfca),
        "Relative_Humidity_Filename": os.path.join(archetype_hfca, '%s_relative_humidity_daily_2016.bin' % archetype_hfca)
    })

    return {'LGA' : hfca}


def update_basic_params(cb) :

    cb.update_params({
        "Birth_Rate_Dependence": "FIXED_BIRTH_RATE",
        "Age_Initialization_Distribution_Type": 'DISTRIBUTION_COMPLEX',
        'Disable_IP_Whitelist' : 1,
        'logLevel_JsonConfigurable' : 'ERROR',
        'logLevel_VectorHabitat' : 'ERROR',
        'logLevel_StandardEventCoordinator' : 'ERROR'
    })
    set_species(cb, ['arabiensis', 'funestus', 'gambiae'])
    update_species_param(cb, 'arabiensis', 'Anthropophily', 0.54, overwrite=True)
    update_species_param(cb, 'arabiensis', 'Indoor_Feeding_Fraction', 0.29, overwrite=True)
    update_species_param(cb, 'funestus', 'Anthropophily', 0.64, overwrite=True)
    update_species_param(cb, 'funestus', 'Indoor_Feeding_Fraction', 0.64, overwrite=True)
    update_species_param(cb, 'gambiae', 'Anthropophily', 0.54, overwrite=True)
    update_species_param(cb, 'gambiae', 'Indoor_Feeding_Fraction', 0.10, overwrite=True)

   # change_biting_risk(cb, risk_config={'Risk_Distribution_Type': 'EXPONENTIAL_DURATION',
                                       # 'Exponential_Mean': 1})


def add_hfca_irs(cb, irs_df, hfca) :

    irs_df = irs_df[irs_df['LGA'] == hfca.upper()]
    for r, row in irs_df.iterrows() :
        add_IRS(cb, start=row['IRS_day'], coverage_by_ages=[{"coverage": row['coverage'], "min": 0, "max": 100}],
                killing_config={
                    "Initial_Effect": row['kill_rate'],
                    "Decay_Time_Constant": 1460,
                    "class": "WaningEffectExponential"},
                blocking_config={
                    "Initial_Effect": row['block_initial'],
                    "Decay_Time_Constant": 730,
                    "class": "WaningEffectExponential"})

    return len(irs_df)

def add_hfca_itns(cb, itn_df, itn_anc_df, hfca) : #itn_anc_df,
    if 'LGA' in itn_df.columns.values :
        df = itn_df[itn_df['LGA'] == hfca]
    else :
        df = itn_df[itn_df['repDS'] == hfca]
    nets = len(df)
    for r, row in df.iterrows() :
        add_itn_from_file(cb, row)
    if not itn_anc_df.empty :
        df = itn_anc_df[itn_anc_df['LGA'] == hfca]
        df = df.drop_duplicates()
        add_itn_anc(cb, df)
        nets += len(df)

    return nets


def add_itn_from_file(cb, row) :

    usages = [row[x] for x in row.keys() if 'ITN_use' in x]
    coverage_all = np.max(usages)
    if coverage_all == 0:
        coverage_all = 1
    usages = [x/coverage_all for x in usages]
    leak_factor = 0.9
    seasonal_values = [0.15, 0.13, 0.12, 0.11, 0.12, 0.13, 0.14, 0.29, 0.30, 0.36, 0.38]
    seasonal_months = [0, 32, 60, 91, 121, 152, 182, 213, 244, 274, 364]

    seasonal_scales = [x / max(seasonal_values) for x in seasonal_values]

    seasonal_offset = row['simday'] % 365
    seasonal_times = [(x + (365 - seasonal_offset)) % 365 for x in seasonal_months]

    zipped_lists = zip(seasonal_times, seasonal_scales)
    sorted_pairs = sorted(zipped_lists)
    tuples = zip(*sorted_pairs)
    seasonal_times, seasonal_scales = [list(tuple) for tuple in tuples]
    if seasonal_times[0] > 0:
        seasonal_times.insert(0, 0)
        seasonal_scales.insert(0, seasonal_scales[-1])

    add_ITN_age_season(cb, start=row['simday'], # update with row['simday']
                       demographic_coverage=coverage_all,
                       killing_config={
                           "Initial_Effect": row['kill_rate'],
                           "Decay_Time_Constant": 1460,
                           "class": "WaningEffectExponential"},
                       blocking_config={
                           "Initial_Effect": row['block_initial'],
                           "Decay_Time_Constant": 730,
                           "class": "WaningEffectExponential"}, # update with area-specific kill rate (row['kill_rate'])
                       discard_times={"Expiration_Period_Distribution": "DUAL_EXPONENTIAL_DISTRIBUTION",
                                      'Expiration_Period_Proportion_1' : 0.9,
                                 'Expiration_Period_Mean_1' :  365*2.2,
                                 'Expiration_Period_Mean_2' : 365*10},
                       age_dependence={"Times": [0, 5, 10, 18],
                                "Values": [x * leak_factor for x in usages]},
                       seasonal_dependence={"Times": seasonal_times, "Values": seasonal_scales}
                       )


def add_itn_anc(cb, itn_anc_df) :

    dry_ratio_may = 0.5
    leak_factor = 0.9

    for r, row in itn_anc_df.iterrows() :
        add_ITN_age_season(cb, start=row['simday'], demographic_coverage=row['coverage'],
                           killing_config={
                               "Initial_Effect": row['kill_rate'],
                               "Decay_Time_Constant": 1460,
                               "class": "WaningEffectExponential"},
                           blocking_config={
                               "Initial_Effect": row['block_initial'],
                               "Decay_Time_Constant": 730,
                               "class": "WaningEffectExponential"},
                           discard_times={"Expiration_Period_Distribution": "DUAL_EXPONENTIAL_DISTRIBUTION",
                                          'Expiration_Period_Proportion_1' : 0.9,
                                     'Expiration_Period_Mean_1' :  365*1.7,
                                     'Expiration_Period_Mean_2' : 365*10},
                           birth_triggered=True,
                           duration=row['duration'],
                           age_dependence={"Times": [0, 5],
                                    "Values": [leak_factor, leak_factor]},
                           seasonal_dependence={"Times": [0, 182], "Values":  [dry_ratio_may, 1]}
                           )


def add_hfca_hs(cb, hs_df, hfca) : #start_day_override=-1

    #df = hs_df[hs_df['repDS'] == hfca]
    if 'LGA' in hs_df.columns.values :
        df = hs_df[hs_df['LGA'] == hfca]
    else :
        df = hs_df[hs_df['repDS'] == hfca]
    for r, row in df.iterrows() :
        add_hs_from_file(cb, row) #start_day_override

    return len(df)


def add_hs_from_file(cb, row): #start_day_override

    hs_child = row['U5_coverage']
    hs_adult = row['adult_coverage']
    #start_day_override = row['start_day_override']
    start_day = row['simday'] #if start_day_override < 0 else start_day_override
    severe_cases = row['severe_cases']

    add_health_seeking(cb, start_day=start_day,
                       targets=[{'trigger': 'NewClinicalCase', 'coverage': hs_child, 'agemin': 0, 'agemax': 5,
                                 'seek': 1, 'rate': 0.3},
                                {'trigger': 'NewClinicalCase', 'coverage': hs_adult, 'agemin': 5, 'agemax': 100,
                                 'seek': 1, 'rate': 0.3},
                                ],
                       drug=['Artemether', 'Lumefantrine'], duration=row['duration'])
    add_health_seeking(cb, start_day=start_day,
                       targets=[{'trigger': 'NewSevereCase', 'coverage': severe_cases, 'seek': 1, 'rate': 0.5}], #change by adding column and reviewing literature
                       drug=['Artemether', 'Lumefantrine'], duration=row['duration'],
                       broadcast_event_name = 'Received_Severe_Treatment')


def hs_by_accessIP(cb, start=0, duration=-1, free_care=False) :

    HF_times = [0.5, 1, 2, 4, 7, 10]
    inpatient_times = [0.5, 1, 2, 4, 7, 10, 15, 20, 30]
    IP_names = ['HFWithin%.1fInpatientWithin%.1f' % (x,y) for x in HF_times for y in inpatient_times]

    if not free_care :
        hs_U5 = 0.6
        hs_O5 = 0.3
        inp = 0.8
        frac_self = 0
        HF_scale = [1, 1, 0.8, 0.6, 0.6, 0.6]
        inpatient_scale = [1, 1, 0.85, 0.75, 0.6, 0.6, 0.5, 0.5]
    else :
        hs_U5 = 0.8
        hs_O5 = 0.3
        inp = 0.9
        frac_self = 0
        HF_scale = [1, 0.94, 0.88, 0.85, 0.85, 0.85]
        inpatient_scale = [1, 1, 1, 0.85, 0.6, 0.6, 0.6, 0.6]

    uncomplicated_targets = [
        {"trigger":"NewClinicalCase","coverage": hs_U5,"agemin":0,"agemax":5,"seek":1,"rate":0.3},
        {"trigger": "NewClinicalCase", "coverage": hs_O5, "agemin": 5, "agemax": 200, "seek": 1, "rate": 0.3}
    ]
    severe_targets = [
        {"trigger": "NewSevereCase", "coverage": inp, "seek": 1, "rate": 0.5}
    ]

    for scale, time in zip(HF_scale, HF_times) :
        IPs = [x for x in IP_names if 'HFWithin%.1f' % time in x]
        targets = copy.deepcopy(uncomplicated_targets)
        for i in range(len(targets)) :
            targets[i]['coverage'] *= scale*(1-frac_self)
        add_health_seeking(cb, start_day=start, targets=targets,
                           ind_property_restrictions=[{ 'AccessToCare' : x,
                                                        'DrugStatus' : 'None'} for x in IPs],
                           drug_ineligibility_duration=14,
                           disqualifying_properties=['DrugStatus:RecentDrug'],
                           duration=duration)
        targets = copy.deepcopy(uncomplicated_targets)
        for i in range(len(targets)) :
            hs_rate = targets[i]['coverage'] * scale
            self_coverage = 1 - (1 - hs_rate)/(1 - (1 - frac_self)*hs_rate)
            targets[i]['coverage'] = self_coverage
        if frac_self > 0 :
            add_health_seeking(cb, drug=['Sulfadoxine', 'Pyrimethamine'],
                               start_day=start, targets=targets,
                               ind_property_restrictions=[{ 'AccessToCare' : x,
                                                            'DrugStatus' : 'None' } for x in IPs],
                               drug_ineligibility_duration=14,
                               disqualifying_properties=['DrugStatus:RecentDrug'],
                               duration=duration,
                               broadcast_event_name='Received_Self_Medication')

    # assume no self medication for severe treatment
    for scale, time in zip(inpatient_scale, inpatient_times) :
        IPs = [x for x in IP_names if 'InpatientWithin%.1f' % time in x]
        targets = copy.copy(severe_targets)
        for i in range(len(targets)) :
            targets[i]['coverage'] *= scale
        add_health_seeking(cb, start_day=start, targets=targets,
                           ind_property_restrictions=[{ 'AccessToCare' : x,
                                                        'DrugStatus' : 'None' } for x in IPs],
                           drug_ineligibility_duration=14,
                           disqualifying_properties=['DrugStatus:RecentDrug'],
                           duration=duration,
                           broadcast_event_name='Received_Severe_Treatment')


def habitat_scales() :

    rel_abundance_fname = os.path.join(projectpath, 'SpatialClustering', 'DS_vector_rel_abundance.csv')
    rdf = pd.read_csv(rel_abundance_fname)
    rdf['LGA'] = rdf['DS'].apply(lambda x : '-'.join(x.split('/')))
    rdf = rdf.rename(columns={'Anopheles_arabiensis' : 'arabiensis_scale_factor',
                              'Anopheles_coluzzii_gambiae' : 'gambiae_scale_factor',
                              'Anopheles_funestus_subgroup' : 'funestus_scale_factor'})
    rdf = rdf.set_index('LGA')
    return rdf


def add_hfca_smc(cb, smc_df, hfca) :
    df = smc_df[smc_df['LGA'] == hfca]

    for r, row in df.iterrows() :
        cov_high = row['coverage_high_access']
        cov_low = row['coverage_low_access']
        max_smc_age = row['max_age']
        TAT = 0 # assume kids with fever don't get SMC at all and are also not referred

        add_diagnostic_survey(cb, start_day=row['simday'],
                              coverage=1,
                              target={"agemin": 0.25, "agemax": max_smc_age},
                              diagnostic_type='FEVER',
                              diagnostic_threshold=0.5,
                              negative_diagnosis_configs=[{
                                  "Broadcast_Event": "No_SMC_Fever",
                                  "class": "BroadcastEvent" }],
                              positive_diagnosis_configs=[{
                                  "Broadcast_Event": "Has_SMC_Fever",
                                  "class": "BroadcastEvent" }]
                              )
        add_drug_campaign(cb, 'SMC', 'SPA', start_days=[row['simday']],
                          coverage=cov_high, target_group={'agemin' : 0.25, 'agemax' : max_smc_age},
                          listening_duration=2,
                          trigger_condition_list=['No_SMC_Fever'],
                          ind_property_restrictions=[{'SMCAccess' : 'High'}])
        add_drug_campaign(cb, 'SMC', 'SPA', start_days=[row['simday']],
                          coverage=cov_low, target_group={'agemin' : 0.25, 'agemax' : max_smc_age},
                          listening_duration=2,
                          trigger_condition_list=['No_SMC_Fever'],
                          ind_property_restrictions=[{'SMCAccess' : 'Low'}])
        if TAT :
            add_drug_campaign(cb, 'MDA', drug_code='AL', start_days=[row['simday']],
                              coverage=cov_high,
                              target_group={'agemin': 0.25, 'agemax': 5},
                              listening_duration=2,
                              trigger_condition_list=['Has_SMC_Fever'],
                              ind_property_restrictions=[{'SMCAccess' : 'High'}],
                              receiving_drugs_event_name='Received_TAT_Treatment')
            add_drug_campaign(cb, 'MDA', drug_code='AL', start_days=[row['simday']],
                              coverage=cov_low,
                              target_group={'agemin': 0.25, 'agemax': 5},
                              listening_duration=2,
                              trigger_condition_list=['Has_SMC_Fever'],
                              ind_property_restrictions=[{'SMCAccess' : 'Low'}],
                              receiving_drugs_event_name='Received_TAT_Treatment')
    if len(df) > 0 :
        # leakage to over-5 groups
        add_drug_campaign(cb, 'SMC', 'SPA', start_days=df['simday'].values,
                          coverage= 0.058, target_group={'agemin' : max_smc_age, 'agemax' :10})
    return len(df)


def add_all_interventions(cb,smc_df, itn_df, hs_df, irs_df, itn_anc_df, hfca): # itn_anc_df, irs_df
    event_list =['Received_NMF_Treatment']

    if not irs_df.empty:
        has_irs = add_hfca_irs(cb, irs_df, hfca)
        if has_irs > 0:
            event_list.append('Received_IRS')

    if not smc_df.empty :
        has_smc = add_hfca_smc(cb, smc_df, hfca)
        if has_smc > 0:
            event_list.append('Received_Campaign_Drugs')

    if not (itn_df.empty and itn_anc_df.empty) : # and itn_anc_df.empty
        has_itn = add_hfca_itns(cb, itn_df, itn_anc_df, hfca) # itn_anc_df,

        if has_itn :
            event_list.append('Bednet_Got_New_One')
            event_list.append('Bednet_Using')
            event_list.append('Bednet_Discarded')

    if not hs_df.empty :
        has_cm = add_hfca_hs(cb, hs_df, hfca)
        if has_cm :
            event_list.append('Received_Treatment')
            event_list.append('Received_Severe_Treatment')

    add_event_counter_report(cb, event_trigger_list=event_list)
    return {}


def update_drug_config(cb, list_drug_param, value, list_drug_param2=[], value2=0):
    cb.update_params({
        "Malaria_Drug_Params": update_drugs(list_drug_param=list_drug_param, value=value, list_drug_param2=list_drug_param2, value2=value2)
    })
    return({'new drug value': value})


if __name__ == '__main__' :

    pass
