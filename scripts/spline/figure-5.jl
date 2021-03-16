using DrWatson
@quickactivate :ens

using JLD2 
using Spikes
using KernelDensity
using Distributions
using Measures
using StatsBase

include(srcdir("spline", "spline-plots.jl"))
include(srcdir("spline", "spline-analysis.jl"))
include(srcdir("spline", "spline-utils.jl"))

lift_dist = load(datadir("spline",   "lift-dist.jld2"));
lift_neigh = load(datadir("spline",  "lift-neigh.jld2"));
multi_dist = load(datadir("spline",  "multi-dist.jld2"));
multi_neigh = load(datadir("spline", "multi-neigh.jld2"));

#%

df_n = combine_analysis(multi_neigh)
df_d = combine_analysis(multi_dist)
df_n_lift = combine_analysis(lift_neigh)
df_d_lift = combine_analysis(lift_dist)


#% All interactions
function all_interactions(df)
	scatter(df.m, fill(-1.5, size(df, 1)), m=:vline, c=:black, label="Peak position")
	plot!(df.x, df.mean, label ="", xlims=(0, 100))
	ylabel!("η")
	xlabel!("Time (ms)")
	title!("Complex models interaction delays")
end

for row in eachrow(df_d)
	plot(row.x, row.mean)
	savefig(plotsdir("logbook", "15-03", "dist-complex-model", "$(row.idx)"))
end

all_interactions(df_n)
all_interactions(df_d)

#% Figure 5B
function figure_5B(df)
	k = kde(df.m, Normal(0, 0.2))
	plot(k, lw=1.5, lab="", xlims=(0, 30), ylims=(0, 1))
	scatter!(df.m, fill(0., size(df, 1)), m=:vline, c=:black, label="Peak position")
	ylabel!("Density")
	xlabel!("Time (ms)")
	title!("Peak cell interaction delay")
end

#% Figure 5C
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


#% Figure 5A
ll_n = load(datadir("spline", "neigh-likelihood.csv")) |> DataFrame
transform!(ll_n, [:simple1, :simple2, :complex1, :complex2] => 
		   ((s1, s2, c1, c2) -> (s1 .+ s2) .< (c1 .+ c2)) => :c_better)


A = bar([sum(ll_n.c_better), sum(.!ll_n.c_better)], lab="")
ylabel!("Counts")
xticks!([1, 2], ["Complex", "Simple"])
title!("Pairs of neighboring cells\n\nBest model")

#% Figure 5A
ll_d = load(datadir("spline", "dist-likelihood.csv")) |> DataFrame
transform!(ll_d, [:simple1, :simple2, :complex1, :complex2] => 
		   ((s1, s2, c1, c2) -> (s1 .+ s2) .< (c1 .+ c2)) => :c_better)

D = bar([sum(ll_d.c_better), sum(.!ll_d.c_better)], lab="")
ylabel!("Counts")
xticks!([1, 2], ["Complex", "Simple"])
title!("Pairs of distant cells\n\nBest model")

B = figure_5B(df_n)
E = figure_5B(df_d)
C = figure_5C(df_n)
F = figure_5C(df_d)
F5 = plot(A, D, B, E, C, F, size=(1200, 1600), layout=(3, 2), margin=7mm)

savefig(plotsdir("logbook", "16-03", "figure-5-complete"), "scripts/spline/figure-5.jl")
