"""Helper functions for parsing rdata.

Author: Romain Fayat

"""
import rpy2.robjects as robjects
from rpy2.robjects.vectors import DataFrame, FloatVector, IntVector,\
    StrVector, ListVector
from rpy2.robjects import pandas2ri
from collections import OrderedDict
import numpy as np
pandas2ri.activate()


def load_rdata(path, parse=True):
    "Load and optionally parse rdata."
    robjects.r['load'](path)
    data = robjects.r['lcasegrasp3']
    if parse:
        data = parse_rdata(data)

    return data


def parse_rdata(data):
    """Parse the complete structure of rdata to python types recursively.

    Notes
    -----
    From https://stackoverflow.com/a/24799752

    """
    rDictTypes = [DataFrame, ListVector]
    rArrayTypes = [FloatVector, IntVector]
    rListTypes = [StrVector]
    if type(data) in rDictTypes:
        return OrderedDict(zip(data.names,
                               [parse_rdata(elt) for elt in data]))
    elif type(data) in rListTypes:
        return [parse_rdata(elt) for elt in data]
    elif type(data) in rArrayTypes:
        return np.array(data)
    else:
        if hasattr(data, "rclass"):  # An unsupported r class
            raise KeyError(
                f"Could not proceed, type {type(data)} is not defined")
        else:
            return data  # We reached the end of recursion

data = load_rdata("data/RData/allgraspPsthStaUnionbehsPrange500.Rdata")

