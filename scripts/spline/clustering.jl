using DrWatson
@quickactivate :ens

using JLD2 
using Clustering
using PyCall
using StatsBase
using Plots

include(srcdir("spline", "spline-plots.jl"))
include(srcdir("spline", "spline-utils.jl"))


multi_all = load(datadir("spline", "multi-all.jld2"));
lift_all = load(datadir("spline", "lift-all.jld2"));

df = combine_simple_analysis(multi_all)
#%


idx = 1.5 .< df.x[1] .< 4.5
X = hcat(zscore.(getindex.(df.mean, Ref(idx)))...)
# kmeans
n = 9
R = kmeans(X, n, maxiter=20000, display=:iter)
a = assignments(R)
p = map(1:n) do i
	plot(getindex.(df.x[a .== i], Ref(idx)), getindex.(df.mean[a .== i], Ref(idx)), lab="")
	plot!(getindex(df.x[a .== i][1], idx), R.centers[:, i], l=(1.5, :black, :dash), label="center")
end
xticks!.(p, Ref([2, 3, 4]), Ref(["lift", "cover", "grasp"]))
plot(p..., size=(900, 900))


# Dynamic Time Warping Kmeans
pyclust = pyimport("tslearn.clustering")

n=8
idx = 1.5 .< df.x[1] .< 4.5
X = hcat(zscore.(getindex.(df.mean, Ref(idx)))...)'
model = pyclust.TimeSeriesKMeans(n_clusters=n, metric="dtw", max_iter=100000)
model.fit(X)
a = model.labels_
p = map(1:n) do i
	plot(getindex.(df.x[a .== i-1], Ref(idx)), getindex.(df.mean[a .== i-1], Ref(idx)), lab="")
	plot!(getindex(df.x[a .== i-1][1], idx), model.cluster_centers_[i, :, 1], l=(1.5, :black, :dash), label="centroid")
end
xticks!.(p, Ref([2, 3, 4]), Ref(["lift", "cover", "grasp"]))
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

