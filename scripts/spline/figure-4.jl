using DrWatson
@quickactivate :ens

using JLD2 
using Spikes
using KernelDensity
using StatsBase

include(srcdir("spline", "spline-plots.jl"))
include(srcdir("spline", "spline-analysis.jl"))
include(srcdir("spline", "spline-utils.jl"))

@load datadir("spline", "simple-complex.jld2") results

#%

