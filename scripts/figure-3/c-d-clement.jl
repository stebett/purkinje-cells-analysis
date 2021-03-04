using DrWatson
@quickactivate :ens

#%
using Spikes
using Statistics
using Plots; gr()
using StatsBase
import StatsBase: sem

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

function merge_ranges(x::Vector{<:Tuple})
	a = x |> unique |> sort
	val, rep = vcat(collect.(a)...) |> sort |> rle
	b = val[rep .== 1]
	idx = BitArray(eachindex(b) .% 2)
	tuple.(b[idx], b[.!idx])
end

function filter_by_length(x::Vector{<:Tuple}, minlen::Int)
	idx = diff.(x) .< minlen
	if any(idx)
		@info "Removing $(sum(idx)) intervals"
		return x[.!idx]
	end
	x
end

function plot_crosscor_neigh(neighbors::Matrix)
	mean_neighbors = mean(neighbors, dims=2)[:]
	sem_neighbors = sem(neighbors, dims=2)[:]
	mean_neighbors[40:41] .= NaN 

	plot(mean_neighbors, c=:red, ribbon=sem_neighbors, fillalpha=0.3,  linewidth=3, label=false, ylim=(-1, 1))
	xticks!([1:10:81;],["$i" for i =-20:5:20])
	title!("Pairs of neighboring cells")
	xlabel!("Time (ms)")
	ylabel!("Mean ± sem deviation")
	# savefig(plotsdir("crosscor", "figure_3C"), "scripts/figure-3/c-d-clement.jl")
end
 
function plot_crosscor_distant(distant::Matrix)
	mean_distant = mean(distant, dims=2)[:]
	sem_distant = sem(distant, dims=2)[:]

	plot(mean_distant, c=:black, ribbon=sem_distant, fillalpha=0.3,  linewidth=3, label=false, ylim=(-1, 1))
	xticks!([1:10:81;],["$i" for i =-20:5:20])
	title!("Pairs of distant cells")
	xlabel!("Time (ms)")
	ylabel!("Mean ± sem deviation")
	# savefig(plotsdir("crosscor", "figure_3D"), "scripts/figure-3/c-d-clement.jl")
end


#%
tmp = load_data("data-v6.arrow");

pad = 500
num_bins = 2
b1 = 25
binsize=.5

m, ranges = multi_psth(tmp, pad, num_bins, b1);

baseline = getindex.(m, Ref(1:ceil(Int, length(m[1])÷3)))
m = normalize(m, baseline, :mad)

thr = quantile(drop(vcat(m...)), 0.90)
active_trials = get_active_from_merged(m, ranges, thr);
active_ranges = merge_trials(tmp, active_trials);


#% Merge neighbors active ranges
neigh = couple(tmp, :n);
active_neigh = get_active_couples(neigh, active_ranges);

for (key, val) in active_neigh
	active_neigh[key] = merge_ranges(val)
	active_neigh[key] = filter_by_length(val, 160)
end
neighbors = crosscor_c(tmp, neigh, active_neigh, binsize) |> drop;

#% Merge distant active ranges
dist = couple(tmp, :d);
active_dist = get_active_couples(dist, active_ranges);
for (key, val) in active_dist
	active_dist[key] = merge_ranges(val)
	active_dist[key] = filter_by_length(val, 160)
end
distant = crosscor_c(tmp, dist, active_dist, binsize) |> drop;

#%
fig_c = plot_crosscor_neigh(neighbors)

fig_d = plot_crosscor_distant(distant)
