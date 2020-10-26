import rpy2.robjects as robjects
import numpy as np
import pickle
import json

robjects.r['load']("/home/ginko/ens/RData/allgraspPsthStaUnionbehsPrange500.Rdata")

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
                    neigh_id = f'neuron{neigh_idx + 1}'
                    pydf[rat][site][tet][neigh_id] = {}


                    t = list(df[rat_idx][site_idx][tet_idx][neigh_idx][0])
                    grasp = list(df[rat_idx][site_idx][tet_idx][neigh_idx][17])
                    cover = list(df[rat_idx][site_idx][tet_idx][neigh_idx][18])
                    lift = list(df[rat_idx][site_idx][tet_idx][neigh_idx][19])

                    pydf[rat][site][tet][neigh_id]['t'] = t
                    pydf[rat][site][tet][neigh_id]['grasp'] = grasp
                    pydf[rat][site][tet][neigh_id]['cover'] = cover
                    pydf[rat][site][tet][neigh_id]['lift'] = lift

    return pydf

df = convert(data)


json.dump(df, open("data.json", "w"))
