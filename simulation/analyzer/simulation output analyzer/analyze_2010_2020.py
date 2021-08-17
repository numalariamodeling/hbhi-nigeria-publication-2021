import pandas as pd
import numpy as np
from simtools.Analysis.BaseAnalyzers import BaseAnalyzer
import datetime
import os
import sys
sys.path.append('../')



class MonthlyPfPRAnalyzer(BaseAnalyzer):

    def __init__(self, expt_name, sweep_variables=None, working_dir=".", start_year=2010, end_year=2020):
        super(MonthlyPfPRAnalyzer, self).__init__(working_dir=working_dir,
                                                  filenames=["output/MalariaSummaryReport_Monthly%d.json" % x
                                                             for x in range(start_year, end_year)]
                                                  )
        self.sweep_variables = sweep_variables or ["Run_Number"]
        self.expt_name = expt_name
        self.start_year = start_year
        self.end_year = end_year
    # def filter(self, simulation):
    #     return simulation.tags["LGA"] == 'Alkaleri'
    #     return simulation.tags["LGA"] == 'Alkaleri'

    def select_simulation_data(self, data, simulation):

        adf = pd.DataFrame()
        for year, fname in zip(range(self.start_year, self.end_year), self.filenames):
            d = data[fname]['DataByTimeAndAgeBins']['PfPR by Age Bin'][:12]
            pfpr = [x[1] for x in d]
            d = data[fname]['DataByTimeAndAgeBins']['Annual Clinical Incidence by Age Bin'][:12]
            clinical_cases = [x[1] for x in d]
            d = data[fname]['DataByTimeAndAgeBins']['Annual Severe Incidence by Age Bin'][:12]
            severe_cases = [x[1] for x in d]
            d = data[fname]['DataByTimeAndAgeBins']['Average Population by Age Bin'][:12] # this add pop col in U5
            pop = [x[1] for x in d]
            simdata = pd.DataFrame( { 'month' : range(1,13),
                                      'PfPR U5' : pfpr,
                                      'Cases U5' : clinical_cases,
                                      'Severe cases U5': severe_cases,
                                      'Pop U5' : pop})
            simdata['year'] = year
            adf = pd.concat([adf, simdata])

        for sweep_var in self.sweep_variables:
            if sweep_var in simulation.tags.keys():
                adf[sweep_var] = simulation.tags[sweep_var]
        return adf

    def finalize(self, all_data):

        selected = [data for sim, data in all_data.items()]
        if len(selected) == 0:
            print("No data have been returned... Exiting...")
            return

        if not os.path.exists(os.path.join(self.working_dir, self.expt_name)):
            os.mkdir(os.path.join(self.working_dir, self.expt_name))

        adf = pd.concat(selected).reset_index(drop=True)
        adf.to_csv((os.path.join(self.working_dir, self.expt_name, 'U5_PfPR_ClinicalIncidence.csv')), index=False)


class MonthlyU1PfPRAnalyzer(BaseAnalyzer):

    def __init__(self, expt_name, sweep_variables=None, working_dir=".", start_year=2010, end_year=2020):
        super(MonthlyU1PfPRAnalyzer, self).__init__(working_dir=working_dir,
                                                  filenames=["output/MalariaSummaryReport_FineMonthly%d.json" % x
                                                             for x in range(start_year, end_year)]
                                                  )
        self.sweep_variables = sweep_variables or ["Run_Number"]
        self.expt_name = expt_name
        self.start_year = start_year
        self.end_year = end_year

    # def filter(self, simulation):
    #     return simulation.tags["LGA"] == 'Kissidougou'

    def select_simulation_data(self, data, simulation):

        adf = pd.DataFrame()
        for year, fname in zip(range(self.start_year, self.end_year), self.filenames):
            d = data[fname]['DataByTimeAndAgeBins']['PfPR by Age Bin'][:12]
            pfpr = [x[0] for x in d]
            d = data[fname]['DataByTimeAndAgeBins']['Annual Clinical Incidence by Age Bin'][:12]
            clinical_cases = [x[0] for x in d]
            d = data[fname]['DataByTimeAndAgeBins']['Annual Severe Incidence by Age Bin'][:12]
            severe_cases = [x[0] for x in d]
            d = data[fname]['DataByTimeAndAgeBins']['Average Population by Age Bin'][:12] # this add pop col in U1
            pop = [x[0] for x in d]
            simdata = pd.DataFrame( { 'month' : range(1,13),
                                      'PfPR U1' : pfpr,
                                      'Cases U1' : clinical_cases,
                                      'Severe cases U1': severe_cases,
                                      'Pop U1' : pop})
            simdata['year'] = year
            adf = pd.concat([adf, simdata])

        for sweep_var in self.sweep_variables:
            if sweep_var in simulation.tags.keys():
                adf[sweep_var] = simulation.tags[sweep_var]
        return adf

    def finalize(self, all_data):

        selected = [data for sim, data in all_data.items()]
        if len(selected) == 0:
            print("No data have been returned... Exiting...")
            return

        if not os.path.exists(os.path.join(self.working_dir, self.expt_name)):
            os.mkdir(os.path.join(self.working_dir, self.expt_name))

        adf = pd.concat(selected).reset_index(drop=True)
        adf.to_csv((os.path.join(self.working_dir, self.expt_name, 'U1_PfPR_ClinicalIncidence.csv')), index=False)


class MonthlyPfPRAnalyzerByAge(BaseAnalyzer):

    def __init__(self, expt_name, sweep_variables=None,  working_dir=".", start_year=2010, end_year=2020):
        super(MonthlyPfPRAnalyzerByAge, self).__init__(working_dir=working_dir,
                                                       filenames=["output/MalariaSummaryReport_FineMonthly%d.json" % x
                                                                  for x in range(start_year, end_year)]  # ,2020
                                                       )
        self.sweep_variables = sweep_variables or ["Run_Number"]
        #        self.agebins = agebins or [0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2, 3, 4, 5, 15, 30, 50, 125]
        self.agebins = [1, 5, 120]

        # should be Annual Mild Anemia by Age Bin in new EMOD, but is Annual Mild Anemia in old EMOD
        self.anemia_channel_name = '' #' by Age Bin'
        self.expt_name = expt_name
        self.start_year = start_year
        self.end_year = end_year

    # def filter(self, simulation):
    #     return simulation.tags["LGA"] == 'Kissidougou'

    def select_simulation_data(self, data, simulation):

        adf = pd.DataFrame()
        for year, fname in zip(range(self.start_year, self.end_year), self.filenames):  # , 2020
            for age in list(range(0, len(self.agebins))):
                d = data[fname]['DataByTimeAndAgeBins']['PfPR by Age Bin'][:12]
                pfpr = [x[age] for x in d]
                d = data[fname]['DataByTimeAndAgeBins']['Annual Clinical Incidence by Age Bin'][:12]
                clinical_cases = [x[age] for x in d]
                d = data[fname]['DataByTimeAndAgeBins']['Annual Severe Incidence by Age Bin'][:12]
                severe_cases = [x[age] for x in d]
                d = data[fname]['DataByTimeAndAgeBins']['Average Population by Age Bin'][:12]  # this add pop col in U5
                pop = [x[age] for x in d]
                d = data[fname]['DataByTimeAndAgeBins']['Annual Mild Anemia%s' % self.anemia_channel_name][:12]
                mild_anemia = [x[age] for x in d]
                d = data[fname]['DataByTimeAndAgeBins']['Annual Moderate Anemia%s' % self.anemia_channel_name][:12]
                moderate_anemia = [x[age] for x in d]
                d = data[fname]['DataByTimeAndAgeBins']['Annual Severe Incidence by Anemia by Age Bin'][:12]
                severe_anemia = [x[age] for x in d]
                simdata = pd.DataFrame({'month': range(1, 13),
                                        'PfPR': pfpr,
                                        'Cases': clinical_cases,
                                        'Severe cases': severe_cases,
                                        'Pop': pop,
                                        'Mild anaemia': mild_anemia,
                                        'Moderate anaemia': moderate_anemia,
                                        'Severe anaemia': severe_anemia
                                        })
                simdata['year'] = year
                simdata['agebin'] = self.agebins[age]
                adf = pd.concat([adf, simdata])

        for sweep_var in self.sweep_variables:
            if sweep_var in simulation.tags.keys():
                adf[sweep_var] = simulation.tags[sweep_var]
        return adf

    def finalize(self, all_data):

        selected = [data for sim, data in all_data.items()]
        if len(selected) == 0:
            print("No data have been returned... Exiting...")
            return

        if not os.path.exists(os.path.join(self.working_dir, self.expt_name)):
            os.mkdir(os.path.join(self.working_dir, self.expt_name))

        adf = pd.concat(selected).reset_index(drop=True)
        adf.to_csv((os.path.join(self.working_dir, self.expt_name, 'Agebins_PfPR_ClinicalIncidenceAnemia.csv')),
                   index=False)

class MonthlyTreatedCasesAnalyzer(BaseAnalyzer):

    @classmethod
    def monthparser(self, x):
        if x == 0:
            return 12
        else:
            return datetime.datetime.strptime(str(x), '%j').month

    def __init__(self, expt_name, channels=None, sweep_variables=None, working_dir=".", start_year=2010, end_year=2020):
        super(MonthlyTreatedCasesAnalyzer, self).__init__(working_dir=working_dir,
                                                          filenames=["output/ReportEventCounter.json",
                                                                     "output/ReportMalariaFiltered.json"]
                                                          )
        self.sweep_variables = sweep_variables or ["LGA", "Run_Number"]
        self.channels = channels or ['Received_Treatment', 'Received_Severe_Treatment', 'Received_NMF_Treatment']
        self.inset_channels = ['Statistical Population', 'New Clinical Cases', 'New Severe Cases', 'PfHRP2 Prevalence']
        self.expt_name = expt_name
        self.start_year = start_year
        self.end_year = end_year

    def select_simulation_data(self, data, simulation):
        simdata  = pd.DataFrame( { x : data[self.filenames[1]]['Channels'][x]['Data'] for x in self.inset_channels })
        simdata['Time'] = simdata.index
        if self.channels :
            d = pd.DataFrame( { x : data[self.filenames[0]]['Channels'][x]['Data'] for x in self.channels })
            d['Time'] = d.index
            simdata = pd.merge(left=simdata, right=d, on='Time')
        simdata['Day'] = simdata['Time'] % 365
        simdata['Month'] = simdata['Day'].apply(lambda x: self.monthparser((x+1) % 365))
        simdata['Year'] = simdata['Time'].apply(lambda x : int(x/365) + self.start_year)
        simdata['date'] = simdata.apply(lambda x: datetime.date(int(x['Year']), int(x['Month']), 1), axis=1)

        sum_channels = ['Received_Treatment', 'Received_Severe_Treatment', 'New Clinical Cases', 'New Severe Cases',
                        'Received_NMF_Treatment']
        for x in [y for y in sum_channels if y not in simdata.columns.values]:
            simdata[x] = 0
        mean_channels = ['Statistical Population', 'PfHRP2 Prevalence']

        df = simdata.groupby(['date'])[sum_channels].agg(np.sum).reset_index()
        pdf = simdata.groupby(['date'])[mean_channels].agg(np.mean).reset_index()

        simdata = pd.merge(left=pdf, right=df, on=['date'])

        for sweep_var in self.sweep_variables:
            if sweep_var in simulation.tags.keys():
                simdata[sweep_var] = simulation.tags[sweep_var]
        return simdata

    def finalize(self, all_data):

        selected = [data for sim, data in all_data.items()]
        if len(selected) == 0:
            print("No data have been returned... Exiting...")
            return

        if not os.path.exists(os.path.join(self.working_dir, self.expt_name)):
            os.mkdir(os.path.join(self.working_dir, self.expt_name))

        adf = pd.concat(selected).reset_index(drop=True)
        adf.to_csv(os.path.join(self.working_dir, self.expt_name, 'All_Age_Monthly_Cases.csv'), index=False)


class MonthlyBednetUsageAnalyzer(BaseAnalyzer):

    @classmethod
    def monthparser(self, x):
        if x == 0:
            return 12
        else:
            return datetime.datetime.strptime(str(x), '%j').month

    def __init__(self, expt_name, channels=None, sweep_variables=None, working_dir=".", start_year=2010, end_year=2020):
        super(MonthlyBednetUsageAnalyzer, self).__init__(working_dir=working_dir,
                                                          filenames=["output/ReportEventCounter.json",
                                                                     "output/ReportMalariaFiltered.json"]
                                                          )
        self.sweep_variables = sweep_variables or ["LGA", "Run_Number"]
        self.channels = channels or ['Bednet_Using', 'Bednet_Got_New_One']
        self.inset_channels = ['Statistical Population']
        self.expt_name = expt_name
        self.start_year = start_year
        self.end_year = end_year

    # def filter(self, simulation):
    #     return simulation.tags["LGA"] == 'Beyla'

    def select_simulation_data(self, data, simulation):

        simdata  = pd.DataFrame( { x : data[self.filenames[1]]['Channels'][x]['Data'] for x in self.inset_channels })
        simdata['Time'] = simdata.index
        if self.channels :
            d = pd.DataFrame( { x : data[self.filenames[0]]['Channels'][x]['Data'][:len(simdata)] for x in self.channels })
            d['Time'] = d.index
            simdata = pd.merge(left=simdata, right=d, on='Time')
        simdata['Day'] = simdata['Time'] % 365
        simdata['Month'] = simdata['Day'].apply(lambda x: self.monthparser((x+1) % 365))
        simdata['Year'] = simdata['Time'].apply(lambda x : int(x/365) + self.start_year)

        for sweep_var in self.sweep_variables:
            if sweep_var in simulation.tags.keys():
                simdata[sweep_var] = simulation.tags[sweep_var]
        return simdata

    def finalize(self, all_data):

        selected = [data for sim, data in all_data.items()]
        if len(selected) == 0:
            print("No data have been returned... Exiting...")
            return

        if not os.path.exists(os.path.join(self.working_dir, self.expt_name)):
            os.mkdir(os.path.join(self.working_dir, self.expt_name))

        adf = pd.concat(selected).reset_index(drop=True)
        adf['date'] = adf.apply(lambda x: datetime.date(x['Year'], x['Month'], 1), axis=1)

        sum_channels = ['Bednet_Got_New_One']
        for x in [y for y in sum_channels if y not in adf.columns.values] :
            adf[x] = 0
        mean_channels = ['Statistical Population', 'Bednet_Using']

        df = adf.groupby(['LGA', 'date', 'Run_Number'])[sum_channels].agg(np.sum).reset_index()
        pdf = adf.groupby(['LGA', 'date', 'Run_Number'])[mean_channels].agg(np.mean).reset_index()

        adf = pd.merge(left=pdf, right=df, on=['LGA', 'date', 'Run_Number'])
        adf['mean_usage'] = adf['Bednet_Using']/adf['Statistical Population']
        adf['new_net_coverage'] = adf['Bednet_Got_New_One']/adf['Statistical Population']
        adf.to_csv(os.path.join(self.working_dir, self.expt_name, 'All_Age_ITN_Usage.csv'), index=False)


class monthlySevereTreatedByAgeAnalyzer(BaseAnalyzer):
    @classmethod
    def monthparser(self, x):
        if x == 0:
            return 12
        else:
            return datetime.datetime.strptime(str(x), '%j').month

    def __init__(self, expt_name, event_name='Received_Severe_Treatment', agebins=None,
                 sweep_variables=None, working_dir=".", start_year=2010, end_year=2020):
        super(monthlySevereTreatedByAgeAnalyzer, self).__init__(working_dir=working_dir,
                                                                filenames=["output/ReportEventRecorder.csv"]
                                                                )
        self.sweep_variables = sweep_variables or ["LGA", "Run_Number"]
        self.event_name = event_name
        self.agebins = agebins or [1, 5, 200]
        self.expt_name = expt_name
        self.start_year = start_year
        self.end_year = end_year

    # def filter(self, simulation):
    #     return simulation.tags["LGA"] == 'Ushongo'

    def select_simulation_data(self, data, simulation):

        output_data = data[self.filenames[0]]
        output_data = output_data[output_data['Event_Name'] == self.event_name]

        simdata = pd.DataFrame()
        if len(output_data) > 0:  # there are events of this type
            output_data['Day'] = output_data['Time'] % 365
            output_data['month'] = output_data['Day'].apply(lambda x: self.monthparser((x + 1) % 365))
            output_data['year'] = output_data['Time'].apply(lambda x: int(x / 365) + self.start_year)
            output_data['age in years'] = output_data['Age'] / 365

            for agemax in self.agebins:
                if agemax < 200:
                    agelabel = 'U%d' % agemax
                else:
                    agelabel = 'all_ages'
                if agemax == 5:
                   agemin = 0.25
                else:
                    agemin = 0
                d = output_data[(output_data['age in years'] < agemax) & (output_data['age in years'] > agemin)]
                g = d.groupby(['year', 'month'])['Event_Name'].agg(len).reset_index()
                g = g.rename(columns={'Event_Name': 'Num_%s_Received_Severe_Treatment' % agelabel})
                if simdata.empty:
                    simdata = g
                else:
                    if not g.empty :
                        simdata = pd.merge(left=simdata, right=g, on=['year', 'month'], how='outer')
                        simdata = simdata.fillna(0)

            for sweep_var in self.sweep_variables:
                if sweep_var in simulation.tags.keys():
                    simdata[sweep_var] = simulation.tags[sweep_var]
        else:
            simdata = pd.DataFrame(columns=['year', 'month', 'Num_U5_Received_Severe_Treatment',
                                            'Num_U1_Received_Severe_Treatment',
                                            'Num_all_ages_Received_Severe_Treatment'] + self.sweep_variables)
        return simdata

    def finalize(self, all_data):

        selected = [data for sim, data in all_data.items()]
        if len(selected) == 0:
            print("No data have been returned... Exiting...")
            return

        if not os.path.exists(os.path.join(self.working_dir, self.expt_name)):
            os.mkdir(os.path.join(self.working_dir, self.expt_name))

        adf = pd.concat(selected).reset_index(drop=True)
        adf = adf.fillna(0)
        adf.to_csv(os.path.join(self.working_dir, self.expt_name, 'Treated_Severe_Monthly_Cases_By_Age.csv'),
                   index=False)

        for agelabel in ['U1', 'U5']:
            severe_treat_df = adf[
                ['year', 'month', 'Num_%s_Received_Severe_Treatment' % agelabel] + self.sweep_variables]
            # cast to int65 data type for merge with incidence df
            severe_treat_df = severe_treat_df.astype({'month': 'int64', 'year': 'int64', 'Run_Number': 'int64'})

            # combine with existing columns of the U5 clinical incidence and PfPR dataframe
            incidence_df = pd.read_csv(
                os.path.join(self.working_dir, self.expt_name, '%s_PfPR_ClinicalIncidence.csv' % agelabel))
            merged_df = pd.merge(left=incidence_df, right=severe_treat_df,
                                 on=['LGA', 'year', 'month', 'Run_Number'],
                                 how='left')
            merged_df = merged_df.fillna(0)

            # fix any excess treated cases!
            merged_df['num severe cases %s' % agelabel] = merged_df['Severe cases %s' % agelabel] * merged_df['Pop %s' % agelabel] * 30 / 365
            merged_df['excess sev treat %s' % agelabel] = merged_df['Num_%s_Received_Severe_Treatment' % agelabel] - merged_df['num severe cases %s' % agelabel]

            for (rn, lga), rdf in merged_df.groupby(['Run_Number', 'LGA']) :
                for r, row in rdf.iterrows() :
                    if row['excess sev treat %s' % agelabel] < 1 :
                        continue
                    # fix Jan 2020 (start of sim) excess treated severe cases
                    if row['year'] == self.start_year and row['month'] == 1 :
                        merged_df.loc[(merged_df['year'] == self.start_year) & (merged_df['month'] == 1) & (merged_df['Run_Number'] == rn) & (merged_df['LGA'] == lga),
                                'Num_%s_Received_Severe_Treatment' % agelabel] = np.sum(merged_df[(merged_df['year'] == self.start_year) &
                                                                                                  (merged_df['month'] == 1) &
                                                                                                  (merged_df['Run_Number'] == rn) &
                                                                                                  (merged_df['LGA'] == lga)]['num severe cases %s' % agelabel])
                    else :
                        # figure out which is previous month
                        newyear = row['year']
                        newmonth = row['month'] - 1
                        if newmonth < 1 :
                            newyear -= 1
                        excess = row['excess sev treat %s' % agelabel]
                        merged_df.loc[(merged_df['year'] == self.start_year) & (merged_df['month'] == 1) & (merged_df['Run_Number'] == rn) & (merged_df['LGA'] == lga), 'Num_%s_Received_Severe_Treatment' % agelabel] = \
                            merged_df.loc[(merged_df['year'] == self.start_year) & (merged_df['month'] == 1) & (merged_df['Run_Number'] == rn) & (merged_df['LGA'] == lga),
                                'Num_%s_Received_Severe_Treatment' % agelabel] - excess
                        merged_df.loc[(merged_df['year'] == self.start_year) & (merged_df['month'] == 1) & (merged_df['Run_Number'] == rn) & (merged_df['LGA'] == lga), 'Num_%s_Received_Severe_Treatment' % agelabel] = \
                            merged_df.loc[(merged_df['year'] == self.start_year) & (merged_df['month'] == 1) & (merged_df['Run_Number'] == rn) & (merged_df['LGA'] == lga),
                                'Num_%s_Received_Severe_Treatment' % agelabel] + excess
            merged_df['excess sev treat %s' % agelabel] = merged_df['Num_%s_Received_Severe_Treatment' % agelabel] - merged_df['num severe cases %s' % agelabel]
            merged_df.loc[merged_df['excess sev treat %s' % agelabel] > 0.5, 'Num_%s_Received_Severe_Treatment' % agelabel] = merged_df.loc[merged_df['excess sev treat %s' % agelabel] > 0.5, 'num severe cases %s' % agelabel]

            del merged_df['num severe cases %s' % agelabel]
            del merged_df['excess sev treat %s' % agelabel]
            merged_df.to_csv(os.path.join(self.working_dir, self.expt_name,
                                          '%s_PfPR_ClinicalIncidence_severeTreatment.csv' % agelabel), index=False)


class MonthlyNewInfectionsAnalyzer(BaseAnalyzer):

    def __init__(self, expt_name, sweep_variables=None, working_dir=".", start_year=2010, end_year=2020):
        super(MonthlyNewInfectionsAnalyzer, self).__init__(working_dir=working_dir,
                                                           filenames=["output/MalariaSummaryReport_Monthly%d.json" % x
                                                                      for x in range(start_year, end_year)]
                                                           )
        self.sweep_variables = sweep_variables or ["Run_Number"]
        self.expt_name = expt_name
        self.start_year = start_year
        self.end_year = end_year

    def filter(self, simulation):
        return simulation.status.name == 'Succeeded'

    def select_simulation_data(self, data, simulation):

        adf = pd.DataFrame()
        for year, fname in zip(range(self.start_year, self.end_year), self.filenames):

            # from the 30 day reporting interval, imagine all months have 30 days, except December, which has 35
            days_in_month = [30]*11 + [35]

            # population size
            pop = data[fname]['DataByTimeAndAgeBins']['Average Population by Age Bin'][:12]  # remove final five days: assume final five days have same average as rest of month
            pop_Under15 = [sum(x[:3]) for x in pop]
            pop_15to30 = [x[3] for x in pop]
            pop_30to50 = [x[4] for x in pop]
            pop_50plus = [x[5] for x in pop]

            # new infections
            d = data[fname]['DataByTimeAndAgeBins']['New Infections by Age Bin'][:13]  # 'New Infections' on old EMOD, 'New Infections by Age Bin' on new EMOD
            d[11] = [sum(x) for x in zip(d[11], d[12])]  # add final five days to last month
            del d[-1]  # remove final five days
            new_infections_Under15 = [sum(x[:3]) for x in d]
            new_infections_15to30 = [x[3] for x in d]
            new_infections_30to50 = [x[4] for x in d]
            new_infections_50plus = [x[5] for x in d]

            # PfPR
            d = data[fname]['DataByTimeAndAgeBins']['PfPR by Age Bin'][:12]  # remove final five days: assume final five days have same average as rest of month
            # use weighted average for combined age groups
            pfpr_Under15 = [((d[yy][0] * pop[yy][0]) + (d[yy][1] * pop[yy][1]) + (d[yy][2] * pop[yy][2])) / (pop[yy][0] + pop[yy][1] + pop[yy][2]) for yy in range(12)]
            pfpr_15to30 = [x[3] for x in d]
            pfpr_30to50 = [x[4] for x in d]
            pfpr_50plus = [x[5] for x in d]

            # clinical cases
            d = data[fname]['DataByTimeAndAgeBins']['Annual Clinical Incidence by Age Bin'][:12]  # remove final five days: assume final five days have same average as rest of month
            # adjust the per-person annualized number (the reported value) to get the total number of clinical cases in that age group in a month
            clinical_cases_Under15 = [((d[yy][0] * pop[yy][0]) + (d[yy][1] * pop[yy][1]) + (d[yy][2] * pop[yy][2])) * days_in_month[yy] / 365 for yy in range(12)]
            clinical_cases_15to30 = [d[yy][3] * pop[yy][3] * days_in_month[yy] / 365 for yy in range(12)]
            clinical_cases_30to50 = [d[yy][4] * pop[yy][4] * days_in_month[yy] / 365 for yy in range(12)]
            clinical_cases_50plus = [d[yy][5] * pop[yy][5] * days_in_month[yy] / 365 for yy in range(12)]

            # severe cases
            d = data[fname]['DataByTimeAndAgeBins']['Annual Severe Incidence by Age Bin'][:12]  # remove final five days: assume final five days have same average as rest of month
            # adjust the per-person annualized number (the reported value) to get the total number of severe cases in that age group in a month
            severe_cases_Under15 = [((d[yy][0] * pop[yy][0]) + (d[yy][1] * pop[yy][1]) + (d[yy][2] * pop[yy][2])) * days_in_month[yy] / 365 for yy in range(12)]
            severe_cases_15to30 = [d[yy][3] * pop[yy][3] * days_in_month[yy] / 365 for yy in range(12)]
            severe_cases_30to50 = [d[yy][4] * pop[yy][4] * days_in_month[yy] / 365 for yy in range(12)]
            severe_cases_50plus = [d[yy][5] * pop[yy][5] * days_in_month[yy] / 365 for yy in range(12)]


            # order is [under 15, 15-30, 30-50, over 50]
            simdata = pd.DataFrame({'month': list(range(1, 13))*4,  # cycle through months for each age range
                                    'AgeGroup': np.repeat(['Under15', '15to30', '30to50', '50plus'], 12),
                                    'Pop': (pop_Under15 + pop_15to30 + pop_30to50 + pop_50plus),
                                    'New Infections': (new_infections_Under15 + new_infections_15to30 + new_infections_30to50 + new_infections_50plus),
                                    'PfPR': (pfpr_Under15 + pfpr_15to30 + pfpr_30to50 + pfpr_50plus),
                                    'Clinical cases':(clinical_cases_Under15 + clinical_cases_15to30 + clinical_cases_30to50 + clinical_cases_50plus),
                                    'Severe cases': (severe_cases_Under15 + severe_cases_15to30 + severe_cases_30to50 + severe_cases_50plus)
                                    })
            simdata['year'] = year
            adf = pd.concat([adf, simdata])

        for sweep_var in self.sweep_variables:
            if sweep_var in simulation.tags.keys():
                adf[sweep_var] = simulation.tags[sweep_var]
        return adf

    def finalize(self, all_data):

        selected = [data for sim, data in all_data.items()]
        if len(selected) == 0:
            print("No data have been returned... Exiting...")
            return

        if not os.path.exists(os.path.join(self.working_dir, self.expt_name)):
            os.mkdir(os.path.join(self.working_dir, self.expt_name))

        adf = pd.concat(selected).reset_index(drop=True)
        adf.to_csv((os.path.join(self.working_dir, self.expt_name, 'newInfections_PfPR_cases_monthly_byAgeGroup.csv')), index=False)


class monthlyEventAnalyzer(BaseAnalyzer):

    @classmethod
    def monthparser(self, x):
        if x == 0:
            return 12
        else:
            return datetime.datetime.strptime(str(x), '%j').month

    def __init__(self, expt_name, channels=None, sweep_variables=None, working_dir=".", start_year=2010, end_year=2020):
        super(monthlyEventAnalyzer, self).__init__(working_dir=working_dir,
                                                          filenames=["output/ReportEventCounter.json"]
                                                          )
        self.sweep_variables = sweep_variables or ["LGA", "Run_Number"]
        self.channels = channels or ['Received_Treatment',
                                     'Received_Severe_Treatment',
                                     'Received_NMF_Treatment']
        self.inset_channels = ['Statistical Population', 'New Clinical Cases', 'New Severe Cases', 'PfHRP2 Prevalence']
        self.expt_name = expt_name
        self.start_year = start_year
        self.end_year = end_year

    # def filter(self, simulation):
    #     return simulation.id == '877cbfbb-0028-ea11-a2c3-c4346bcb1551'

    def select_simulation_data(self, data, simulation):

        channels_in_expt = [x for x in self.channels if x in data[self.filenames[0]]['Channels'].keys()]

        simdata = pd.DataFrame( { x : data[self.filenames[0]]['Channels'][x]['Data'][:365*(self.end_year - self.start_year)] for x in channels_in_expt })
        simdata['Time'] = simdata.index

        simdata['Day'] = simdata['Time'] % 365
        simdata['month'] = simdata['Day'].apply(lambda x: self.monthparser((x+1) % 365))
        simdata['year'] = simdata['Time'].apply(lambda x : int(x/365) + self.start_year)

        for missing_channel in [x for x in self.channels if x not in channels_in_expt] :
            simdata[missing_channel] = 0

        for sweep_var in self.sweep_variables:
            if sweep_var in simulation.tags.keys():
                simdata[sweep_var] = simulation.tags[sweep_var]
        return simdata

    def finalize(self, all_data):

        selected = [data for sim, data in all_data.items()]
        if len(selected) == 0:
            print("No data have been returned... Exiting...")
            return

        if not os.path.exists(os.path.join(self.working_dir, self.expt_name)):
            os.mkdir(os.path.join(self.working_dir, self.expt_name))

        adf = pd.concat(selected, sort=True).reset_index(drop=True, )
        adf['date'] = adf.apply(lambda x: datetime.date(x['year'], x['month'], 1), axis=1)

        df = adf.groupby(['LGA', 'date', 'Run_Number'])[self.channels].agg(np.sum).reset_index()
        df.to_csv(os.path.join(self.working_dir, self.expt_name, 'monthly_Event_Count.csv'), index=False)
        

if __name__ == "__main__":

    from simtools.Analysis.AnalyzeManager import AnalyzeManager
    from simtools.SetupParser import SetupParser
    from load_paths import load_box_paths

    datapath, projectpath = load_box_paths()

    SetupParser.default_block = 'HPC'
    SetupParser.init()

    working_dir = os.path.join(projectpath, 'simulation_output', '2021_to_2026_v210510')
    if not os.path.exists(working_dir):
        os.mkdir(working_dir)

    start_year = 2020
    end_year = 2031
    expt_ids = {
        'NGA projection scenario 4': 'c081b9a7-357d-eb11-a2ce-c4346bcb1550',
        # 'NGA 2010-20 burnin_hs+itn+smc':'65ded2e3-7cde-ea11-a2c6-c4346bcb1557'
    }

    for expname, expid in expt_ids.items() :
        analyzers = [
            # MonthlyPfPRAnalyzer(expt_name=expname,
            #                     sweep_variables=["Run_Number", "LGA"],
            #                     working_dir=working_dir,
            #                     start_year=start_year,
            #                     end_year=end_year),
            # MonthlyU1PfPRAnalyzer(expt_name=expname,
            #                       sweep_variables=["Run_Number", "LGA"],
            #                       working_dir=working_dir,
            #                       start_year=start_year,
            #                       end_year=end_year),
            # MonthlyBednetUsageAnalyzer(expt_name=expname,
            #                            sweep_variables=["Run_Number", "LGA"],
            #                            working_dir=working_dir,
            #                            start_year=start_year,
            #                            end_year=end_year),
            # MonthlyTreatedCasesAnalyzer(expt_name=expname,
            #                             sweep_variables=["Run_Number", "LGA"],
            #                             # channels=['Bednet_Using'],
            #                             working_dir=working_dir,
            #                             start_year=start_year,
            #                             end_year=end_year),
            monthlySevereTreatedByAgeAnalyzer(expt_name=expname,
                                              sweep_variables=["Run_Number", "LGA"],
                                              working_dir=working_dir,
                                              start_year=start_year,
                                              end_year=end_year),
            # monthlyEventAnalyzer(expt_name=expname,
            #                      sweep_variables=["Run_Number", "LGA"],
            #                      working_dir=working_dir,
            #                      start_year=start_year,
            #                      end_year=end_year),
            # MonthlyNewInfectionsAnalyzer(expt_name=expname,
            #                              sweep_variables=["Run_Number", "LGA"],
            #                              working_dir=working_dir,
            #                              start_year=start_year,
            #                              end_year=end_year)
        ]
        am = AnalyzeManager(expid, analyzers=analyzers)
        am.analyze()
