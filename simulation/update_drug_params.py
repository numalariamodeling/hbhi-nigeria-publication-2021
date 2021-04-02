import copy
sulf_C50 = 0.2
sulf_kill = 0.506  #[0.1, 0.3, 0.506, 0.8]  #  "Max_Drug_IRBC_Kill": 0.506
# Amodiaquine: "Drug_PKPD_C50": 35.5 ng/mL (equiv 88.75 nmol/L) and "Max_Drug_IRBC_Kill": 0.67089
amod_C50 = 35.5
amod_kill = 0.67089

Malaria_Drug_Params = {
    "Abstract": {
        "Bodyweight_Exponent": 1,
        "Drug_Adherence_Rate": 1.0,
        "Drug_Cmax": 100,
        "Drug_Decay_T1": 10,
        "Drug_Decay_T2": 10,
        "Drug_Dose_Interval": 1,
        "Drug_Fulltreatment_Doses": 3,
        "Drug_Gametocyte02_Killrate": 0.0,
        "Drug_Gametocyte34_Killrate": 0.0,
        "Drug_GametocyteM_Killrate": 0.0,
        "Drug_Hepatocyte_Killrate": 0.0,
        "Drug_PKPD_C50": 10,
        "Drug_Vd": 1,
        "Fractional_Dose_By_Upper_Age": [
            {
                "Fraction_Of_Adult_Dose": 0.25,
                "Upper_Age_In_Years": 3
            },
            {
                "Fraction_Of_Adult_Dose": 0.5,
                "Upper_Age_In_Years": 6
            },
            {
                "Fraction_Of_Adult_Dose": 0.75,
                "Upper_Age_In_Years": 10
            }
        ],
        "Max_Drug_IRBC_Kill": 4.8
    },
    "Amodiaquine": {
        "Bodyweight_Exponent": 1,
        "Drug_Adherence_Rate": 1.0,
        "Drug_Cmax": 1185,
        "Drug_Decay_T1": 0.12,
        "Drug_Decay_T2": 6.25,
        "Drug_Dose_Interval": 1,
        "Drug_Fulltreatment_Doses": 3,
        "Drug_Gametocyte02_Killrate": 0.0,
        "Drug_Gametocyte34_Killrate": 0.0,
        "Drug_GametocyteM_Killrate": 0.0,
        "Drug_Hepatocyte_Killrate": 0.0,
        "Drug_PKPD_C50": amod_C50,
        "Drug_Vd": 2.51,
        "Fractional_Dose_By_Upper_Age": [
            {
                "Fraction_Of_Adult_Dose": 0.22,
                "Upper_Age_In_Years": 1
            },
            {
                "Fraction_Of_Adult_Dose": 0.44,
                "Upper_Age_In_Years": 5
            }
        ],
        "Max_Drug_IRBC_Kill": amod_kill
    },
    "Amodiaquine_for_AS_combination": {
        "Bodyweight_Exponent": 1,
        "Drug_Adherence_Rate": 1.0,
        "Drug_Cmax": 537,
        "Drug_Decay_T1": 0.12,
        "Drug_Decay_T2": 6.25,
        "Drug_Dose_Interval": 1,
        "Drug_Fulltreatment_Doses": 3,
        "Drug_Gametocyte02_Killrate": 0.0,
        "Drug_Gametocyte34_Killrate": 0.0,
        "Drug_GametocyteM_Killrate": 0.0,
        "Drug_Hepatocyte_Killrate": 0.0,
        "Drug_PKPD_C50": 80,
        "Drug_Vd": 2.51,
        "Fractional_Dose_By_Upper_Age": [
            {
                "Fraction_Of_Adult_Dose": 0.22,
                "Upper_Age_In_Years": 1
            },
            {
                "Fraction_Of_Adult_Dose": 0.44,
                "Upper_Age_In_Years": 5
            }
        ],
        "Max_Drug_IRBC_Kill": 0.7089
    },
    "Artemether": {
        "Bodyweight_Exponent": 1,
        "Drug_Adherence_Rate": 1.0,
        "Drug_Cmax": 114,
        "Drug_Decay_T1": 0.12,
        "Drug_Decay_T2": 0.12,
        "Drug_Dose_Interval": 0.5,
        "Drug_Fulltreatment_Doses": 6,
        "Drug_Gametocyte02_Killrate": 2.5,
        "Drug_Gametocyte34_Killrate": 1.5,
        "Drug_GametocyteM_Killrate": 0.7,
        "Drug_Hepatocyte_Killrate": 0.0,
        "Drug_PKPD_C50": 0.6,
        "Drug_Vd": 1,
        "Fractional_Dose_By_Upper_Age": [
            {
                "Fraction_Of_Adult_Dose": 0.25,
                "Upper_Age_In_Years": 3
            },
            {
                "Fraction_Of_Adult_Dose": 0.5,
                "Upper_Age_In_Years": 6
            },
            {
                "Fraction_Of_Adult_Dose": 0.75,
                "Upper_Age_In_Years": 10
            }
        ],
        "Max_Drug_IRBC_Kill": 8.9
    },
    "Artesunate": {
        "Bodyweight_Exponent": 1,
        "Drug_Adherence_Rate": 1.0,
        "Drug_Cmax": 200,
        "Drug_Decay_T1": 0.12,
        "Drug_Decay_T2": 0.12,
        "Drug_Dose_Interval": 1,
        "Drug_Fulltreatment_Doses": 3,
        "Drug_Gametocyte02_Killrate": 2.5,
        "Drug_Gametocyte34_Killrate": 1.5,
        "Drug_GametocyteM_Killrate": 0.7,
        "Drug_Hepatocyte_Killrate": 0.0,
        "Drug_PKPD_C50": 0.03,
        "Drug_Vd": 1,
        "Fractional_Dose_By_Upper_Age": [
            {
                "Fraction_Of_Adult_Dose": 0.22,
                "Upper_Age_In_Years": 2
            },
            {
                "Fraction_Of_Adult_Dose": 0.44,
                "Upper_Age_In_Years": 5
            }
        ],
        "Max_Drug_IRBC_Kill": 4.2
    },
    "Chloroquine": {
        "Bodyweight_Exponent": 1,
        "Drug_Adherence_Rate": 1.0,
        "Drug_Cmax": 150,
        "Drug_Decay_T1": 8.9,
        "Drug_Decay_T2": 244,
        "Drug_Dose_Interval": 1,
        "Drug_Fulltreatment_Doses": 3,
        "Drug_Gametocyte02_Killrate": 0.0,
        "Drug_Gametocyte34_Killrate": 0.0,
        "Drug_GametocyteM_Killrate": 0.0,
        "Drug_Hepatocyte_Killrate": 0.0,
        "Drug_PKPD_C50": 150,
        "Drug_Vd": 3.9,
        "Fractional_Dose_By_Upper_Age": [
            {
                "Fraction_Of_Adult_Dose": 0.17,
                "Upper_Age_In_Years": 5
            },
            {
                "Fraction_Of_Adult_Dose": 0.33,
                "Upper_Age_In_Years": 9
            },
            {
                "Fraction_Of_Adult_Dose": 0.67,
                "Upper_Age_In_Years": 14
            }
        ],
        "Max_Drug_IRBC_Kill": 4.8
    },
    "DHA": {
        "Bodyweight_Exponent": 1,
        "Drug_Adherence_Rate": 1.0,
        "Drug_Cmax": 200,
        "Drug_Decay_T1": 0.12,
        "Drug_Decay_T2": 0.12,
        "Drug_Dose_Interval": 1,
        "Drug_Fulltreatment_Doses": 3,
        "Drug_Gametocyte02_Killrate": 2.5,
        "Drug_Gametocyte34_Killrate": 1.5,
        "Drug_GametocyteM_Killrate": 0.7,
        "Drug_Hepatocyte_Killrate": 0.0,
        "Drug_PKPD_C50": 0.6,
        "Drug_Vd": 1,
        "Fractional_Dose_By_Upper_Age": [
            {
                "Fraction_Of_Adult_Dose": 0.375,
                "Upper_Age_In_Years": 0.83
            },
            {
                "Fraction_Of_Adult_Dose": 0.5,
                "Upper_Age_In_Years": 2.83
            },
            {
                "Fraction_Of_Adult_Dose": 0.625,
                "Upper_Age_In_Years": 5.25
            },
            {
                "Fraction_Of_Adult_Dose": 0.75,
                "Upper_Age_In_Years": 7.33
            },
            {
                "Fraction_Of_Adult_Dose": 0.875,
                "Upper_Age_In_Years": 9.42
            }
        ],
        "Max_Drug_IRBC_Kill": 9.2
    },
    "Lumefantrine": {
        "Bodyweight_Exponent": 0.35,
        "Drug_Adherence_Rate": 1.0,
        "Drug_Cmax": 1017,
        "Drug_Decay_T1": 1.3,
        "Drug_Decay_T2": 2.0,
        "Drug_Dose_Interval": 0.5,
        "Drug_Fulltreatment_Doses": 6,
        "Drug_Gametocyte02_Killrate": 2.4,
        "Drug_Gametocyte34_Killrate": 0.0,
        "Drug_GametocyteM_Killrate": 0.0,
        "Drug_Hepatocyte_Killrate": 0.0,
        "Drug_PKPD_C50": 280,
        "Drug_Vd": 1.2,
        "Fractional_Dose_By_Upper_Age": [
            {
                "Fraction_Of_Adult_Dose": 0.25,
                "Upper_Age_In_Years": 3
            },
            {
                "Fraction_Of_Adult_Dose": 0.5,
                "Upper_Age_In_Years": 6
            },
            {
                "Fraction_Of_Adult_Dose": 0.75,
                "Upper_Age_In_Years": 10
            }
        ],
        "Max_Drug_IRBC_Kill": 4.8
    },
    "Piperaquine": {
        "Bodyweight_Exponent": 0,
        "Drug_Adherence_Rate": 1.0,
        "Drug_Cmax": 30,
        "Drug_Decay_T1": 0.17,
        "Drug_Decay_T2": 41,
        "Drug_Dose_Interval": 1,
        "Drug_Fulltreatment_Doses": 3,
        "Drug_Gametocyte02_Killrate": 2.3,
        "Drug_Gametocyte34_Killrate": 0.0,
        "Drug_GametocyteM_Killrate": 0.0,
        "Drug_Hepatocyte_Killrate": 0.0,
        "Drug_PKPD_C50": 5,
        "Drug_Vd": 49,
        "Fractional_Dose_By_Upper_Age": [
            {
                "Fraction_Of_Adult_Dose": 0.375,
                "Upper_Age_In_Years": 0.83
            },
            {
                "Fraction_Of_Adult_Dose": 0.5,
                "Upper_Age_In_Years": 2.83
            },
            {
                "Fraction_Of_Adult_Dose": 0.625,
                "Upper_Age_In_Years": 5.25
            },
            {
                "Fraction_Of_Adult_Dose": 0.75,
                "Upper_Age_In_Years": 7.33
            },
            {
                "Fraction_Of_Adult_Dose": 0.875,
                "Upper_Age_In_Years": 9.42
            }
        ],
        "Max_Drug_IRBC_Kill": 4.6
    },
    "Primaquine": {
        "Bodyweight_Exponent": 1,
        "Drug_Adherence_Rate": 1.0,
        "Drug_Cmax": 75,
        "Drug_Decay_T1": 0.36,
        "Drug_Decay_T2": 0.36,
        "Drug_Dose_Interval": 1,
        "Drug_Fulltreatment_Doses": 1,
        "Drug_Gametocyte02_Killrate": 2.0,
        "Drug_Gametocyte34_Killrate": 5.0,
        "Drug_GametocyteM_Killrate": 50.0,
        "Drug_Hepatocyte_Killrate": 0.1,
        "Drug_PKPD_C50": 15,
        "Drug_Vd": 1,
        "Fractional_Dose_By_Upper_Age": [
            {
                "Fraction_Of_Adult_Dose": 0.17,
                "Upper_Age_In_Years": 5
            },
            {
                "Fraction_Of_Adult_Dose": 0.33,
                "Upper_Age_In_Years": 9
            },
            {
                "Fraction_Of_Adult_Dose": 0.67,
                "Upper_Age_In_Years": 14
            }
        ],
        "Max_Drug_IRBC_Kill": 0.0
    },
    "Pyrimethamine": {
        "Bodyweight_Exponent": 1,
        "Drug_Adherence_Rate": 1.0,
        "Drug_Cmax": 354.1,
        "Drug_Decay_T1": 5.411,
        "Drug_Decay_T2": 5.411,
        "Drug_Dose_Interval": 1,
        "Drug_Fulltreatment_Doses": 1,
        "Drug_Gametocyte02_Killrate": 0.0,
        "Drug_Gametocyte34_Killrate": 0.0,
        "Drug_GametocyteM_Killrate": 0.0,
        "Drug_Hepatocyte_Killrate": 0.0,
        "Drug_PKPD_C50": 2,
        "Drug_Vd": 1,
        "Fractional_Dose_By_Upper_Age": [
            {
                "Fraction_Of_Adult_Dose": 0.167,
                "Upper_Age_In_Years": 2
            },
            {
                "Fraction_Of_Adult_Dose": 0.33,
                "Upper_Age_In_Years": 5
            }
        ],
        "Max_Drug_IRBC_Kill": 0.6
    },
    "Sulfadoxine": {
        "Bodyweight_Exponent": 1,
        "Drug_Adherence_Rate": 1.0,
        "Drug_Cmax": 105.8,
        "Drug_Decay_T1": 8.55,
        "Drug_Decay_T2": 8.55,
        "Drug_Dose_Interval": 1,
        "Drug_Fulltreatment_Doses": 1,
        "Drug_Gametocyte02_Killrate": 0.0,
        "Drug_Gametocyte34_Killrate": 0.0,
        "Drug_GametocyteM_Killrate": 0.0,
        "Drug_Hepatocyte_Killrate": 0.0,
        "Drug_PKPD_C50": sulf_C50,
        "Drug_Vd": 1,
        "Fractional_Dose_By_Upper_Age": [
            {
                "Fraction_Of_Adult_Dose": 0.167,
                "Upper_Age_In_Years": 2
            },
            {
                "Fraction_Of_Adult_Dose": 0.33,
                "Upper_Age_In_Years": 5
            }
        ],
        "Max_Drug_IRBC_Kill": sulf_kill
    },
    "Vehicle": {
        "Bodyweight_Exponent": 0,
        "Drug_Cmax": 10,
        "Drug_Decay_T1": 1,
        "Drug_Decay_T2": 1,
        "Drug_Dose_Interval": 1,
        "Drug_Fulltreatment_Doses": 1,
        "Drug_Gametocyte02_Killrate": 0.0,
        "Drug_Gametocyte34_Killrate": 0.0,
        "Drug_GametocyteM_Killrate": 0.0,
        "Drug_Hepatocyte_Killrate": 0.0,
        "Drug_PKPD_C50": 5,
        "Drug_Vd": 10,
        "Fractional_Dose_By_Upper_Age": [],
        "Max_Drug_IRBC_Kill": 0.0
    }
}


def update_drugs(list_drug_param, value, list_drug_param2=[], value2=0, malaria_drug_params=Malaria_Drug_Params):
    # list_drug_param takes arguments as a list of parameter fields and the values
    if len(list_drug_param) == 1:
        malaria_drug_params[list_drug_param[0]] = value
    elif len(list_drug_param) == 2:
        malaria_drug_params[list_drug_param[0]][list_drug_param[1]] = value
    elif len(list_drug_param) == 3:
        malaria_drug_params[list_drug_param[0]][list_drug_param[1]][list_drug_param[2]] = value

    if len(list_drug_param2) == 1:
        malaria_drug_params[list_drug_param2[0]] = value2
    elif len(list_drug_param2) == 2:
        malaria_drug_params[list_drug_param2[0]][list_drug_param2[1]] = value2
    elif len(list_drug_param2) == 3:
        malaria_drug_params[list_drug_param2[0]][list_drug_param2[1]][list_drug_param2[2]] = value2

    return malaria_drug_params
