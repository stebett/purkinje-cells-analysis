using DrWatson
@quickactivate :ens

include(srcdir("plot", "cross-correlation.jl"))

a = vcat([1:3:100;]..., [401:3:500;]...)
b = [2:3:100;]

crosscor(a, b, false, binsize=1)
