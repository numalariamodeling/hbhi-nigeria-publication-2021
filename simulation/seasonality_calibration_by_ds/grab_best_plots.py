import os
import pandas as pd
import shutil


def move_top_plots(expname, hfca, num_plots=5) :

    working_dir = os.path.join('./', expname)
    plotdir = os.path.join(working_dir, '_plots')
    if not os.path.exists(plotdir) :
        os.mkdir(plotdir)

    df = pd.read_csv(os.path.join(plotdir, 'LL_all.csv'))
    analyzers = list(df.columns.values[2:])
    total_index = analyzers.index('total')
    analyzers = [x for x in analyzers[:total_index] if 'Analyzer' in x]

    for r, row in df.head(num_plots).iterrows() :
        iterdir = os.path.join(working_dir, 'iter%d' % row['iteration'])
        iterplots = [x for x in os.listdir(iterdir) if 'png' in x]
        for analyzer in analyzers :
            fname = os.path.join(plotdir, 'rank%d_%s.png' % (r, analyzer))
            plotfname = [x for x in iterplots if '%s_sample_%d.' % (hfca, row['sample']) in x]
            shutil.copy(os.path.join(iterdir, plotfname[0]), fname)


if __name__ == '__main__' :

    hfcas = ['Geidam']
    for hfca in hfcas :
        move_top_plots('%sSeasonalityCalib NMFv2' % hfca, hfca, 100)
