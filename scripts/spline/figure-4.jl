using DrWatson
@quickactivate :ens

using JLD2 
using Spikes
using KernelDensity
using StatsBase

include(srcdir("spline", "spline-plots.jl"))
include(srcdir("spline", "spline-utils.jl"))

#%

multi_neigh = load(datadir("spline", "multi-neigh.jld2"));
multi_all = load(datadir("spline", "multi-all.jld2"));
# TODO merge:
