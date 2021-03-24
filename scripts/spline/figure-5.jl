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

ll_n = load(datadir("analyses/spline/batch-4-cluster/postprocessed",
					"likelihood-neigh.csv")) |> DataFrame
ll_n.c_better = parse.(Bool, ll_n.c_better)
ll_d = load(datadir("analyses/spline/batch-4-cluster/postprocessed",
					"likelihood-dist.csv")) |> DataFrame
ll_d.c_better = parse.(Bool, ll_d.c_better)

n_better = df_n[in.(df_n.idx, Ref(ll_n[ll_n.c_better .== 1, :index])), :]
d_better = df_d[in.(df_d.idx, Ref(ll_d[ll_d.c_better .== 1, :index])), :]

function extract(data)
	df = DataFrame((idx=String[], t=Tuple[], m=Float64[], x=Vector[], mean=Vector[], ranges=Vector[]))
	for (k, r) in data
		x = r[:c_nearest]
		y = x[:est_mean] .> 0.
		indexes = rangeT(y)
		if length(indexes) > 0
			long_i = indexes[argmax(diff.(indexes))]
			t = x[:new_x][long_i[1]:long_i[2]]
			peak_m = t[argmax(x[:est_mean][long_i[1]:long_i[2]])]
			peak_t = extrema(t)
			push!(df, [k, 
					   peak_t,
					   peak_m,
					   x[:new_x], 
					   x[:est_mean],
					   all_ranges_above(x)])
		end
	end
	df
end

df_n = extract(r_neigh)
df_d = extract(r_dist)
n_better = df_n[in.(df_n.idx, Ref(ll_n[ll_n.c_better .== 1, :index])), :]
d_better = df_d[in.(df_d.idx, Ref(ll_d[ll_d.c_better .== 1, :index])), :]

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
	plot(k, lw=1.5, lab="", xlims=(0, 50), ylims=(0, 1))
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

B = figure_5B(n_better)
E = figure_5B(d_better)
C = figure_5C(n_better)
F = figure_5C(d_better)
F5 = plot(A, D, B, E, C, F, size=(1200, 1600), layout=(3, 2), margin=7mm)

savefig(plotsdir("logbook", "24-03", "figure-5-complete"), "scripts/spline/figure-5.jl")
