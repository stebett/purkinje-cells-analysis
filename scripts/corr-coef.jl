using DrWatson
@quickactivate "ens"

using DSP
using Plots; gr()
using StatsPlots
using Measurements
using Distributions
using Combinatorics

include(srcdir("spike-tools.jl"))
include(srcdir("data-tools.jl"))
include(srcdir("utils.jl"))
include(scriptsdir("load-data.jl"))


distant = get_distant(data, [1:593;], true)
neurons_idx = hcat(distant, ones(593)) |> DataFrame |> nonunique |> Array{Int, 1}
neuron_list = abs.(neurons_idx .- 1) .* [1:593;]
neuron_list = neuron_list[neuron_list .> 0]

neigh_list = unique(get_neighbors(data, [1:593;], true))
dist_list = unique(distant)

function neighbor_correlation(correlations, neigh_list)
    total_mean = []
    for neigh in neigh_list
        tmp = Float64[]
		
		if length(neigh) > 1
			for (i, j) in combinations(neigh, 2)
				push!(tmp, correlations[i, j])
			end
		end
        push!(total_mean, mean(tmp))
    end
    mean(skipnan(total_mean)) ± std(skipnan(total_mean))
end

function distant_correlation(correlations, dist_list, neuron_list)
    total_mean = []
	for (i, dist) in enumerate(dist_list)
        tmp = Float64[]
		if length(dist) > 0
			for d in dist
				push!(tmp, correlations[neuron_list[i], d])
			end
		end
        push!(total_mean, mean(tmp))
    end
    mean(skipnan(total_mean)) ± std(skipnan(total_mean))
end

r = (-500, 500)
n = slice(data.t, data.cover, around=r, convolution=true, normalization=true, over=r, average=true)

cover_neigh = neighbor_correlation(correlations, neigh_list)
cover_dist = distant_correlation(correlations, dist_list, neuron_list)


n = slice(data.t, data.grasp, around=r, convolution=true, normalization=true, over=r, average=true)
correlations = correlate(n)

grasp_neigh = neighbor_correlation(correlations, neigh_list)
grasp_dist = distant_correlation(correlations, dist_list, neuron_list)

n = slice(data.t, data.lift, around=r, convolution=true, normalization=true, over=r, average=true)
correlations = correlate(n)

lift_neigh = neighbor_correlation(correlations, neigh_list)
lift_dist = distant_correlation(correlations, dist_list, neuron_list)


l = @layout [ [ a; b; c] d ] 
findall(.90 .< correlations .< .91)
p1 = plot(-500:499, n[:, [396, 528]], lab=["neuron 1" "neuron 2"], legend=:topleft)
p1 = title!("Pair of highly correlated neurons")
p3 = xaxis!("", (-500, 500), [0])

findall(.50 .< correlations .< .5001)
p2 = plot(-500:499, n[:, [571, 54]], lab=["neuron 1" "neuron 2"], legend=false)
p2 = title!("Pair of mildly correlated neurons")
p3 = xaxis!("Time (ms)", (-500, 500), [0])
p2 = yaxis!("Normalized firing rate")

findall(.05 .< correlations .< .05001)
p3 = plot(-500:499, n[:, [563, 591]], lab=["neuron 1" "neuron 2"], legend=false)
p3 = title!("Pair of uncorrelated neurons")
p3 = xaxis!("", (-500, 500), [-500, 0, 500])

xs = ["lift", "cover", "grasp"]
p4 = groupedbar(xs, [[lift_neigh.val, cover_neigh.val, grasp_neigh.val] [lift_dist.val, cover_dist.val, grasp_dist.val]], lab=["neighbors neurons" "distant neurons"])
p4 = yaxis!("Correlation coefficient")
p4 = title!("Average time course of firing rate")

plot(p1, p2, p3, p4, layout=l, size=(800,800))
