using DrWatson
@quickactivate :ens

#%
using Spikes
using Statistics
using LinearAlgebra
using Plots; gr()
import StatsBase.sem

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
	# savefig(plotsdir("crosscor", "figure_3C"), "scripts/figure-3/c-d.jl")
end
 
function plot_crosscor_distant(distant::Matrix)
	mean_distant = mean(distant, dims=2)[:]
	sem_distant = sem(distant, dims=2)[:]

	plot(mean_distant, c=:black, ribbon=sem_distant, fillalpha=0.3,  linewidth=3, label=false)
	xticks!([1:10:81;],["$i" for i =-20:5:20])
	title!("Pairs of distant cells")
	xlabel!("Time (ms)")
	ylabel!("Mean ± sem deviation")
	# savefig(plotsdir("crosscor", "figure_3D"), "scripts/figure-3/c-d.jl")
end
#%

tmp = load_data("data-v5.arrow");

pad = 500
n = 2
b1 = 100
binsize=.5
thr = 1.5

mpsth, ranges = section_trial(tmp, pad, n, b1);

active_trials = get_active_trials(mpsth, ranges, thr);
active_ranges = merge_trials(tmp, active_trials);


#% Merge neighbors active ranges
neigh = ens.couple(tmp, :n);
active_neigh = get_active_couples(neigh, active_ranges);
neighbors = crosscor_c(tmp, neigh, active_neigh, binsize) |> drop;

#% Merge distant active ranges
dist = ens.couple(tmp, :d);
active_dist = get_active_couples(dist, active_ranges);
distant = crosscor_c(tmp, dist, active_dist, binsize) |> drop;

#%
plot_crosscor_neigh(neighbors)

plot_crosscor_distant(distant)
