using DrWatson
@quickactivate :ens

using JLD2 
using Spikes
using KernelDensity
using StatsBase
using Clustering
using Distances

include(srcdir("spline", "spline-plots.jl"))
include(srcdir("spline", "spline-utils.jl"))

@load datadir("spline", "simple-complex.jld2") results

#%
allnewx = [r.simple_time[:new_x] for (_, r) in results]
allestmean = [r.simple_time[:est_mean] for (_, r) in results]

idx = [-300 .< a .< 300 for a in allnewx ]

means = [x[y] for (x, y) = zip(allestmean, idx)]
means = means[length.(means) .== 228]

X = hcat(zscore.(means)...)
# kmeans
n = 4
R = kmeans(X, n, maxiter=20000, display=:iter)
a = assignments(R)
p = [plot(means[a .== i]) for i = 1:n]
plot(p..., size=(900, 900))


# hierarchical

D = pairwise(Euclidean(), X, dims=2)
H = hclust(D)
ah = cutree(H, k=n)
p = [plot(means[ah .== i]) for i = 1:n]
plot(p..., size=(900, 900))


