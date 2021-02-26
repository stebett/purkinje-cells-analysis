using DrWatson
@quickactivate :ens

#%
using Statistics
using LinearAlgebra
using Plots; gr()
import StatsBase.sem

include(srcdir("filter-active.jl"))
include(srcdir("plot", "cross-correlation.jl"))
include(srcdir("plot", "psth.jl"))

function sem(x::Matrix; dims=2)
	r = zeros(size(x, dims % 2 + 1)) 
	for i in 1 : length(r)
		r[i] = sem(x[i, :])
	end
	r
end

function get_active_couples(couples, ranges)
	active_couples = Dict()
	for c in couples
		active_couples[c] = vcat(ranges[c[1]]..., ranges[c[2]])
	end
	active_couples
end

function plot_crosscor_neigh(neighbors::Matrix)
	mean_neighbors = mean(neighbors, dims=2)[:]
	sem_neighbors = sem(neighbors, dims=2)[:]
	mean_neighbors[40:41] .= NaN 

	plot(mean_neighbors, c=:red, ribbon=sem_neighbors, fillalpha=0.3,  linewidth=3, label=false)
	xticks!([1:10:81;],["$i" for i =-20:5:20])
	title!("Pairs of neighboring cells")
	xlabel!("Time (ms)")
	ylabel!("Mean ± sem deviation")
	savefig(plotsdir("crosscor", "figure_3c"), "scripts/figure-3c-correlogram.jl")
end
 
function plot_crosscor_distant(distant::Matrix)
	mean_distant = mean(distant, dims=2)[:]
	sem_distant = sem(distant, dims=2)[:]

	plot(mean_distant, c=:black, ribbon=sem_distant, fillalpha=0.3,  linewidth=3, label=false)
	xticks!([1:10:81;],["$i" for i =-20:5:20])
	title!("Pairs of distant cells")
	xlabel!("Time (ms)")
	ylabel!("Mean ± sem deviation")
	savefig(plotsdir("crosscor", "figure_3d"), "scripts/figure-3c.jl")
end
#%
tmp = data[data.p_acorr .< 0.2, :];

pad = 2500
n = 5
b1 = 50
binsize=.5
thr = 2.5

mpsth, ranges = sectionTrial(tmp, pad, n, b1);

active_trials = get_active_trials(mpsth, ranges, thr);
active_ranges = merge_trials(tmp, active_trials)


#% Merge neighbors active ranges
neigh = get_pairs(tmp, "n")
active_neigh = get_active_couples(neigh, active_ranges)
neighbors = crosscor_c(tmp, neigh, active_neigh, binsize) |> drop

#% Merge distant active ranges
dist = get_pairs(tmp, "d")
active_dist = get_active_couples(dist, active_ranges)
distant = crosscor_c(tmp, dist, active_dist, binsize) |> drop

#%
closeall()
plot_crosscor_neigh(neighbors)

plot_crosscor_distant(distant)
