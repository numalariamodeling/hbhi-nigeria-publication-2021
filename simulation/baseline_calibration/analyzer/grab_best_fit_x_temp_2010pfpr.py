import pandas as pd
import numpy as np
import os
import sys
sys.path.append('../')
from load_paths import load_box_paths
from simulation_setup_helpers import load_master_csv

datapath, projectpath = load_box_paths()


if __name__ == '__main__' :

    wdir = os.path.join(projectpath, 'simulation_output', 'prevalence',
                        '2010_match_with_ITN_coverage_v4')
    mdf = load_master_csv()

    adf = pd.DataFrame()
    for DS in mdf.index :
        try :
            score_df = pd.read_csv(os.path.join(wdir, '%s_archetype.csv' % mdf.at[DS, 'Archetype']))
            max_score = np.max(score_df['score'])
            best_LH = score_df[score_df['score'] == max_score]['Habitat_Multiplier'].values[0]
            x_temp = score_df['x_Temporary_Larval_Habitat'].unique()[0]
            sdf = pd.DataFrame( { 'LGA' : [DS],
                                  'Archetype' : [mdf.at[DS, 'Archetype']],
                                  'Habitat_Multiplier' : [best_LH]})
            adf = pd.concat([adf, sdf])
        except FileNotFoundError :
            print(DS)
    adf.to_csv(os.path.join(projectpath, 'simulation_inputs', 'larval_habitats','larval_habitat_multipliers_v4.csv'),
               index=False)