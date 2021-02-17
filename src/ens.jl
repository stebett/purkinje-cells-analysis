module ens

using DrWatson

include(srcdir("data-tools.jl"))
include(srcdir("slice.jl"))
include(scriptsdir("load-arrow.jl"))

export data
end

