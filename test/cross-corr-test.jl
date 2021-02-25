using DrWatson
@quickactivate :ens

include(srcdir("plot", "cross-correlation.jl"))

a = [1:3:100;]
b = [2:3:100;]

crosscor(a, b, false, binsize=1)
