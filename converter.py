import rpy2.robjects as robjects
import numpy as np
import pickle 

robjects.r['load']("/home/ginko/ens/GraspData/allgraspPsthStaUnionbehsPrange500.Rdata")

data = robjects.r['lcasegrasp2']

def convert(df):
    pydf = {}
    for rat_idx, rat in enumerate(list(df.names)):
        pydf[rat] = {}
        for site_idx, site in enumerate(list(df[rat_idx].names)):
            pydf[rat][site] = {}
            for tet_idx, tet in enumerate(list(df[rat_idx][site_idx].names)):
                pydf[rat][site][tet] = {}
                for neigh_idx, neigh in enumerate(list(df[rat_idx][site_idx][tet_idx].names)):
                    t = df[rat_idx][site_idx][tet_idx][neigh_idx][0]
                    neigh_id = f'neuron{neigh_idx + 1}'
                    pydf[rat][site][tet][neigh_id] = np.array(t)
    return pydf

df = convert(data)

df['R16']['13']['tet1'].keys()

with open('/home/ginko/ens/converted.pickle', 'wb') as f:
    data = pickle.dump(df, f, protocol=pickle.HIGHEST_PROTOCOL)
