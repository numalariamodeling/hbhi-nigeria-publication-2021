import os
import pandas as pd
from simulation.load_paths import load_box_paths

datapath, projectpath = load_box_paths()




wdir = os.path.join(projectpath, 'simulation_inputs', 'projection_csvs', 'projection_v4')

while True :

    scenario_fname = os.path.join(wdir, 'Intervention_scenarios_nigeria_v4.csv')
    df = pd.read_csv(scenario_fname)

    if len(df[df['status'] == 'run']) == 0 :
        break

    os.system('python ./run_LGA_2020_forward.py')

    i = df[df['status'] == 'run'].index[0]
    df.loc[i, 'status'] = 'queued'
    df.to_csv(scenario_fname, index=False)
#add to setup of scenarios
