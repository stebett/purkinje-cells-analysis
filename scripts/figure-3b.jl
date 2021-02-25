using DrWatson
@quickactivate :ens

#%
using Statistics
using LinearAlgebra
using Plots; gr()
import StatsBase.sem

include(srcdir("plot", "cross-correlation.jl"))
include(srcdir("plot", "psth.jl"))

#%
tmp = data[data.p_acorr .< 0.2, :];
modulated = crosscor(tmp, [idx1, idx2], [-400., 400.], binsize=0.5, :filt, thr=2.)
unmodulated = crosscor(tmp, [idx1, idx2], [-2000., 2000.], binsize=0.5)
unmodulated ./= mean(unmodulated)
unmodulated .*= mean(modulated)


modulated[41] = NaN
unmodulated[41] = NaN

plot(modulated, lw=2, c=:orange, labels="during modulation", fill = -1, fillalpha = 0.2, fillcolor=:grey)
plot!(unmodulated, c=:black, lw=2, labels="during whole task", α=0.6)
xticks!([1:10:81;],["$i" for i =-20:5:20])
xlabel!("Time (ms)")
ylabel!("Count")
#%
# savefig(plotsdir("crosscor", "figure_3b"), "scripts/cross-correlogram.jl")
