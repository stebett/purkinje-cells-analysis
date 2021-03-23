using DrWatson
@quickactivate :ens

using JLD2 
using Spikes
using KernelDensity
using Distributions
using Measures
using StatsBase
using DataFrames 

include(srcdir("spline", "spline-plots.jl"))

r_neigh = load(datadir("analyses/spline/batch-4-cluster/postprocessed", "multi-neigh.jld2"))
r_dist = load(datadir("analyses/spline/batch-4-cluster/postprocessed", "multi-dist.jld2"))

df_n = combine_analysis(r_neigh)
df_d = combine_analysis(r_dist)

n_better = df_n[in.(df_n.idx, Ref(ll_n[ll_n.c_better .== 1, :index])), :]
d_better = df_d[in.(df_d.idx, Ref(ll_d[ll_d.c_better .== 1, :index])), :]

df_n = combine_analysis(n_better)
df_d = combine_analysis(d_better)

ll_n = load(datadir("analyses/spline/batch-4-cluster/postprocessed",
					"likelihood-neigh.csv")) |> DataFrame
ll_n.c_better = parse.(Bool, ll_n.c_better)

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
	k = kde(df.m, Normal(0, 0.5))
	plot(k, lw=1.5, lab="", xlims=(0, 15), ylims=(0, 1))
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
D = plot(framestyle=:none)
F5 = plot(A, D, B, E, C, F, size=(1200, 1600), layout=(3, 2), margin=7mm)

savefig(plotsdir("logbook", "16-03", "figure-5-complete"), "scripts/spline/figure-5.jl")
