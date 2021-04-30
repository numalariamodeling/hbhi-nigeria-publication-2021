import os
import copy
import pandas as pd
import numpy as np
from datetime import date
import matplotlib.pyplot as plt
from load_paths import load_box_paths
import pandas as pd
from scipy.special import expit
import matplotlib as mpl
datapath, projectpath = load_box_paths()

#read resistance file
df1 = pd.read_csv(os.path.join(projectpath, 'ento','insecticide_resistance_DS_means','Permethrin_mortality_DS_means.csv'))



# #read LLIN distribution data
# df2 = pd.read_csv(os.path.join(datapath, 'nigeria_who','Interventions','LLINs','LLIN_distribution_by_LGA_and_month.csv'))
#
# df4= df2[df2['year']< 2018]
#
#
# #to compare
# df1 = df1.set_index('DS')
# df4['mortality'] = df4.apply(lambda x: df1.at[x['adm2'], str(x['year'])], axis=1)
# df5 = df2[df2['year'] >= 2018]
# df5['mortality'] = df5.apply(lambda x: df1.at[x['adm2'], str('2017')], axis=1)


alpha1 = 0.63
alpha2 = 4
tau = 0.5
df2 = df1[['DS', '2010']].copy()
df3 = df1[['DS', '2013']].copy()
df4 = df1[['DS', '2015']].copy()
df5 = df1[['DS', '2017']].copy()
df2['kill_rate_10'] = df2['2010'].apply(lambda x:expit(alpha1+ alpha2*(x-tau))/1.212060606)
df3['kill_rate_13'] = df3['2013'].apply(lambda x:expit(alpha1+ alpha2*(x-tau))/1.212060606)
df4['kill_rate_15'] = df4['2015'].apply(lambda x:expit(alpha1+ alpha2*(x-tau))/1.212060606)
df5['kill_rate_18'] = df5['2017'].apply(lambda x:expit(alpha1+ alpha2*(x-tau))/1.212060606)
df2.to_csv(os.path.join(projectpath,'ITN_parameter','Killing_rate_nigeria_2010.csv'))
df3.to_csv(os.path.join(projectpath,'ITN_parameter','Killing_rate_nigeria_2013.csv'))
df4.to_csv(os.path.join(projectpath,'ITN_parameter','Killing_rate_nigeria_2015.csv'))
df5.to_csv(os.path.join(projectpath,'ITN_parameter','Killing_rate_nigeria_2017.csv'))
# df4['Kill_rate']=df4['mortality'].apply(lambda x:expit(alpha1+ alpha2*(x-tau))/1.212060606)
# df5['Kill_rate']=df5['mortality'].apply(lambda x:expit(alpha1+ alpha2*(x-tau))/1.212060606)
# #df4.to_csv(os.path.join(projectpath,'ITN_parameter','Killing_rate_nigeria1.csv'))
# #df5.to_csv(os.path.join(projectpath,'ITN_parameter','Killing_rate_nigeria2.csv'))
# df4A = df4[['adm1','adm2','mortality','Kill_rate']]
# df5A = df5[['adm1','adm2','mortality','Kill_rate']]
# df6=pd.concat([df4A,df5A])
# df6.to_csv(os.path.join(projectpath,'ITN_parameter','Killing_rate_nigeria_full.csv'))
# print(df2.head())
# print(df5.head())





































#for cdf,adf in df2.groupby('year'):
#    df1['mortality_new'] = df1.loc[adf['adm2'].isin(df1['DS']), cdf]
#if 'year'==2010:
 #   df1['mortality']
#data2.loc[data1['Stream'].isin(data2.columns.values.astype(int))]
#df1['killing'] = df2.loc[df1['mort'].isin(df2['mortality_data']), 'Killing rate']
#df1.loc['killing'] = df2.loc(df2['mortality_data'],'Killing rate')
# for b in B:
#    A=list.append([df2['adm2']==b][2013])

















# df4 = df1[df1['DS'].isin(df3['repDS'])]

#to find the resistance vs mortality figure
# mpl.rcParams['pdf.fonttype'] = 42
# mort = np.linspace(0,1,100)
# alpha1 = 0.63
# alpha2 = 4
# tau = 0.5
# prop_dead = expit(alpha1 + alpha2*(mort - tau))
# killing_rate = expit(alpha1 + alpha2*(mort - tau))/1.212060606
#
# fig = plt.figure()
# ax = fig.gca()
# ax.plot([x for x in mort], prop_dead, label = 'prop_dead')
# ax.plot([x for x in mort], killing_rate,label = 'killing_rate')


#       ax.set_ylim(0,1)
# ax.set_xlim(0,1)
# ax.set_ylabel("Killing Rate")
# ax.set_xlabel("Mortality")
# ax.set_xticks(np.arange(0, 1.1, step=0.2))
# ax.set_yticks(np.arange(0, 1.1, step=0.2))
# d = pd.DataFrame(data = mort)
# d.rename(columns={0: 'mortality'}, inplace=True)
# d['Proportion_dead'] = d['mortality'].apply(lambda x:expit(alpha1+ alpha2*(x-tau)))
# d['Killing rate'] = d['mortality'].apply(lambda x:expit(alpha1+ alpha2*(x-tau))/1.212060606)
# d.to_csv(r'C:\Users\anl8486\Box\NU-malaria-team\projects\hbhi_nigeria\ITN_parameter\Mortality_vs_Killing_rate.csv')
#read mortality vs killing
# df = pd.read_csv(os.path.join(projectpath,'ITN_parameter','Mortality_vs_Killing_rate.csv'))
# df3= df[['Killing rate','mortality']].copy()
# df3['mortality_data'] = df3['mortality'].apply(lambda x: np.round(x, 2))
#

