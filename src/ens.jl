module ens
 
using DrWatson
using Combinatorics
using Reexport
@reexport using Statistics
@reexport using DataFrames
@reexport using Spikes

abstract type Analysis end

nbdir(args...) = projectdir("notebooks", args...)

include(srcdir("average.jl"))
include(srcdir("couple.jl"))
include(srcdir("load-data.jl"))
# include(srcdir("savefig.jl"))
include(srcdir("find.jl"))
include(srcdir("sem.jl"))
include(srcdir("minmax.jl"))
include(srcdir("parse.jl"))
export Analysis, average, load_data, find, sem, minmax_scale, parse, couple, nbdir, mean, sd
 
end
