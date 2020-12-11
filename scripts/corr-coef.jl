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
include(scriptsdir("load-data.jl"))

# julia> for i = unique(get_neighbors(data, [1:593;], true))
#        push!(slices, newSlice(data[i, "t"], data[i, "lift"]))
#        end


function correlate(n)
    C = cor(n)
    replace!(C, Inf=>0.)
    replace!(C, NaN=>0.)
    replace!(C, 1.0=>0.)
    C
end


function neighbor_correlation(correlations)
    total_mean = []
    for x in 1:size(data, 1)
        tmp = Float64[]
        for (i, j) in combinations(get_neighbors(data, x), 2)
            push!(tmp, correlations[i, j])
        end
        push!(total_mean, mean(tmp))
    end
    mean(skipnan(total_mean)) ± std(skipnan(total_mean))
end

function distant_correlation(correlations)
    total_mean = []
    for x in 1:size(data, 1)
        tmp = []
        neurons = [1:1:size(data,1);]
        deleteat!(neurons, get_neighbors(data, x))
        for (i, j) in combinations(neurons, 2)
            push!(tmp, correlations[i, j])
        end
        push!(total_mean, mean(tmp))
    end
    mean(skipnan(total_mean)) ± std(skipnan(total_mean))
end

around = (-500, 500)



n = normalize(data.t, data.cover, around, around)
correlations = correlate(n)

cover_neigh = neighbor_correlation(correlations)
cover_dist = distant_correlation(correlations)



n = normalize(data.t, data.grasp, around, around)
correlations = correlate(n)

grasp_neigh = neighbor_correlation(correlations)
grasp_dist = distant_correlation(correlations)

n = normalize(data.t, data.lift, around, around)
correlations = correlate(n)

lift_neigh = neighbor_correlation(correlations)
lift_dist = distant_correlation(correlations)


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
