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


function convolute(n::Array{Float64, 2}, around)
    z = [pdf(Normal(0, 10), i) for i in around[1]:around[2]]
    c = conv(n, z)
    replace!(c, Inf=>0.)
    replace!(c, NaN=>0.)
    c
end

function correlate(convolutions)
    C = cor(convolutions)
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
n = normalize(data.t, data.lift, around=around, over=around)
# convolutions = convolute(n, around)
# correlations = correlate(convolutions)

# lift_neigh = neighbor_correlation(correlations)
# lift_dist = distant_correlation(correlations)

lift_neigh = 0.15 ± 0.27
lift_dist = 0.03393 ± 0.0004

# n = normalize(data.t, data.cover, around=around, over=around)
# convolutions = convolute(n, around)
# correlations = correlate(convolutions)

# cover_neigh = neighbor_correlation(correlations)
# cover_dist = distant_correlation(correlations)

cover_neigh = 0.15 ± 0.26
cover_dist = 0.03178 ± 0.00049

# n = normalize(data.t, data.grasp, around=around, over=around)
# convolutions = convolute(n, around)
# correlations = correlate(convolutions)

# grasp_neigh = neighbor_correlation(correlations)
# grasp_dist = distant_correlation(correlations)

grasp_neigh = 0.17 ± 0.26
grasp_dist = 0.03526 ± 0.00066

l = @layout [ [ a; b; c] d ] 
# findall(.85 .< correlations .< .8501)
p1 = plot(-500:499, n[:, [558, 178]], lab=["neuron 1" "neuron 2"], legend=:topleft)
p1 = title!("Pair of highly correlated neurons")
p3 = xaxis!("", (-500, 500), [0])

# findall(.50 .< correlations .< .5001)
p2 = plot(-500:499, n[:, [183, 37]], lab=["neuron 1" "neuron 2"], legend=false)
p2 = title!("Pair of mildly correlated neurons")
p3 = xaxis!("Time (ms)", (-500, 500), [0])
p2 = yaxis!("Normalized firing rate")

# findall(.05 .< correlations .< .05001)
p3 = plot(-500:499, n[:, [556, 484]], lab=["neuron 1" "neuron 2"], legend=false)
p3 = title!("Pair of uncorrelated neurons")
p3 = xaxis!("", (-500, 500), [-500, 0, 500])

xs = ["lift", "cover", "grasp"]
p4 = groupedbar(xs, [[lift_neigh.val, cover_neigh.val, grasp_neigh.val] [lift_dist.val, cover_dist.val, grasp_dist.val]], lab=["neighbors neurons" "distant neurons"])
p4 = yaxis!("Correlation coefficient")
p4 = title!("Average time course of firing rate")

plot(p1, p2, p3, p4, layout=l, size=(800,800))