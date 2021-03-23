using DrWatson
@quickactivate :ens

using JLD2 
using Spikes
using KernelDensity
using Distributions
using Measures
using StatsBase

include(srcdir("spline", "spline-plots.jl"))

df_n = load(datadir("spline", "batch-4-cluster", "multi-neigh-combined.csv"))
df_d = load(datadir("spline", "batch-4-cluster", "multi-dist-combined.csv"))
ll_n = load(datadir("spline", "batch-4-cluster", "likelihood-neigh.csv"))

#% Figure 5A
A = bar([sum(ll_n.c_better), sum(.!ll_n.c_better)], lab="")
ylabel!("Counts")
xticks!([1, 2], ["Complex", "Simple"])
title!("Pairs of neighboring cells\n\nBest model")

#% Figure 5D

D = bar([sum(ll_d.c_better), sum(.!ll_d.c_better)], lab="")
ylabel!("Counts")
xticks!([1, 2], ["Complex", "Simple"])
title!("Pairs of distant cells\n\nBest model")

#% Figure 5B
function figure_5B(df)
	k = kde(df.m, Normal(0, 0.2))
	plot(k, lw=1.5, lab="", xlims=(0, 30), ylims=(0, 1))
	scatter!(df.m, fill(0., size(df, 1)), m=:vline, c=:black, label="Peak position")
	ylabel!("Density")
	xlabel!("Time (ms)")
	title!("Peak cell interaction delay")
end

function figure_5C(df)
	binsize = 0.001
	tmax = 50.
	counts = zeros(Int(tmax/binsize))
	timerange = 0:binsize:tmax-binsize
	for (i, v) in enumerate(timerange)
		counts[i] = sum([r[1] .< v .< r[2] for r in vcat(df.ranges...)])
	end
	counts_perc = counts ./ size(df, 1) .* 100.
	plot(timerange, counts_perc, ylims=(0, 100), lab="")
	ylabel!("% of pairs with significant interactions")
	xlabel!("Time (ms)")
	title!("Ranges of significant\ncell interaction delays")
end

#%

B = figure_5B(df_n)
E = figure_5B(df_d)
C = figure_5C(df_n)
F = figure_5C(df_d)
F5 = plot(A, D, B, E, C, F, size=(1200, 1600), layout=(3, 2), margin=7mm)

savefig(plotsdir("logbook", "16-03", "figure-5-complete"), "scripts/spline/figure-5.jl")
