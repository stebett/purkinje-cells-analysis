module ens
 
using DrWatson

include(srcdir("couple.jl"))
include(srcdir("load-data.jl"))
include(srcdir("savefig.jl"))
include(srcdir("find.jl"))
include(srcdir("sem.jl"))
include(srcdir("minmax.jl"))
include(srcdir("parse.jl"))
export load_data, savefig, find, sem, minmax_scale, parse, couple
 
end
