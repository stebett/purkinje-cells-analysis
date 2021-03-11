using DrWatson
@quickactivate :ens

using JLD2 
using Clustering
using PyCall
using StatsBase
using Plots

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

p = map(1:n) do i
	plot(means[a .== i], label="")
	plot!(R.centers[:, i], l=(1.5, :black, :dash), label="centroid")
end
plot(p..., size=(900, 900))


# hierarchical

# D = pairwise(Euclidean(), X, dims=2)

function dtw_distance(means)
	D = zeros(length(means), length(means))

	map(eachindex(means)) do i
		map(eachindex(means)) do j
			D[i, j], _, _ = dtw(means[i], means[j])
		end
	end
	D
end

D = dtw_distance(means)
D_norm = dtw_distance(zscore.(means))

H = hclust(D)
ah = cutree(H, k=n)
p = [plot(means[ah .== i]) for i = 1:n]
plot(p..., size=(900, 900))

# Dynamic Time Warping Kmeans
pyclust = pyimport("tslearn.clustering")

n=8
X = hcat(means...)'
model = pyclust.TimeSeriesKMeans(n_clusters=n, metric="dtw", max_iter=100000)
model.fit(zscore.(means))
a = model.labels_
p = map(1:n) do i
	plot(means[a .== i+1], label="")
	plot!(model.cluster_centers_[i, :, 1], l=(1.5, :black, :dash), label="centroid")
end
plot(p..., size=(900, 900))
