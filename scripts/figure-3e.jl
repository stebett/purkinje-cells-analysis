using DrWatson
@quickactivate :ens

#%
using Statistics
using LinearAlgebra
using Plots; gr()
import StatsBase.sem

include(srcdir("plot", "cross-correlation.jl"))

#%
cc_n_mod = drop(mass_crosscor(tmp, neigh, filt=true, around=[-200., 200.]))
cc_n_unmod = drop(mass_crosscor(tmp, neigh, filt=false, around=[-200., 200.]))

σ = 1
x = reverse(cc_n_mod[1:40, :], dims=1) .+ cc_n_mod[41:end-1, :]
# x = drop((x .- mean(x, dims=1)) ./ std(x, dims=1))
x = x ./ mean(x) 
x = mean(drop(x), dims=2)
xs = copy(x)[1+2σ:end-2σ]
x = convolve(x[:], σ)

y = reverse(cc_n_unmod[1:40, :], dims=1) .+ cc_n_unmod[41:end-1, :]
# y = drop((y .- mean(y, dims=1)) ./ std(y, dims=1))
y = y ./ mean(y)
y = mean(drop(y), dims=2)
y = convolve(y[:], σ)

plot([2:length(x)+1;], x, lw=2.5, c=:red, xlims=(0, 25), label="during modulation (smoothed)")
plot!([2:length(y)+1;], y, lw=2.5, c=:black, label="during whole task")
scatter!(2:length(xs)+1, xs, c=:black, label="modulation")
vline!([10], line = (1, :dash, :black), lab="")
hline!([1], line = (1, :dash, :black), lab="")
xticks!([0:4:24;], ["$i" for i = 0:2:12])
title!("Pairs of neighboring cells")
ylabel!("Average normalized cross-correlogram")
xlabel!("Time (ms)")
#%
#savefig(plotsdir("crosscor", "figure_3e"), "scripts/cross-correlogram.jl")
