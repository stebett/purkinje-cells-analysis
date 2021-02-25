using DrWatson
@quickactivate :ens

#%
using Statistics
using LinearAlgebra
using Plots; gr()
import StatsBase.sem

include(srcdir("plot", "cross-correlation.jl"))
#%

idx1, idx2 = 437, 438

x = section(tmp[(tmp.index .== idx1), "t"], tmp[findall(tmp.index .== idx1), "cover"], [-400., 400.], binsize=.5) 
c1 = sort_active(hcat(x...), 10)
heatmap(c1', c=:grays, cbar=false)
xticks!([0, 800, 1595], ["-400", "0", "400"])
title!("Spiketrain 437")
xlabel!("Time (ms)")
p1 = ylabel!("Trials")
x_fr = section(tmp[findall(tmp.index .== idx1), "t"], tmp[findall(tmp.index .== idx1), "cover"], [-400, 400], binsize=.5, :conv, :avg) 
plot(x_fr, legend=false)
ylabel!("Firing rate")
p2= xticks!([0, 800, 1595], ["-400", "0", "400"])



y = section(tmp[findall(tmp.index .== idx2), "t"], tmp[findall(tmp.index .== idx2), "cover"], [-400., 400.], binsize=.5) 
c2 = sort_active(hcat(y...), 10)
heatmap(c2', c=:grays, cbar=false)
xticks!([0, 800, 1595], ["-400", "0", "400"])
title!("Spiketrain 438")
p3 = xlabel!("Time (ms)")
y_fr = section(tmp[findall(tmp.index .== idx2), "t"], tmp[findall(tmp.index .== idx2), "cover"], [-400, 400], binsize=.5, :conv, :avg) 
plot(y_fr, legend=false)
p4= xticks!([0, 800, 1595], ["-400", "0", "400"])
plot(p1, p3, p2, p4, layout = @layout [ a b ; c d ])
#%
# savefig(plotsdir("crosscor", "Figure 3A"), "scripts/cross-correlogram.jl")
#%
cc = crosscor.(x, y, binsize=0.5, :norm)
cc = sort_active(hcat(cc...), 10)
heatmap(cc')
#%
#savefig(plotsdir("crosscor", "heatmap-couple"), "scripts/cross-correlogram.jl")
