module ens

using DrWatson

include(srcdir("data-tools.jl"))
include(srcdir("slice.jl"))
include(srcdir("drop.jl"))
include(scriptsdir("data", "load-arrow.jl"))

export data
end

