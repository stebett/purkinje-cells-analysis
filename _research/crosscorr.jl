using DrWatson
@quickactivate "ens"

include(scriptsdir("load-data.jl")) 
include(srcdir("spike-tools.jl"))

n2 = slice(data.t[2], data.lift[2][1], (-100, 100))
n3 = slice(data.t[3], data.lift[3][1], (-100, 100))

r = hcat(n2, n3)
heatmap(r', legend=false, color=:grays)

bar(sum(r, dims=2)[:, 1])
