using DrWatson
@quickactivate :ens

using JLD2 
using Clustering
using PyCall
using StatsBase
using Plots

include(srcdir("spline", "spline-plots.jl"))
include(srcdir("spline", "spline-utils.jl"))
pymetrics = pyimport("tslearn.metrics")


multi_all = load(datadir("spline", "multi-all.jld2"));
lift_all = load(datadir("spline", "lift-all.jld2"));
#%
function plot_kmeans(data::Matrix, n::Int, center::Bool)
	a = kmeans_assignments(data, n)
	p = map(1:n) do i
		plt = plot(data[:, a .== i], lab="")
		if center
			plt = plot!(R.centers[:, i], l=(1.5, :black, :dash), label="center")
		end
		if i == 2
			plt = title!("Kmeans clustering on firing rates")
		end
		plt
	end
	plot(p..., size=(900, 900))
end

function plot_kmeans(data::Matrix, X::Vector, n::Int)
	a = kmeans_assignments(data, n)
		p = map(1:n) do i
		plt = plot(X[a .== i], lab="")
		if i == 2
			plt = title!("Kmeans clustering on time-warped firing rates")
		end
		plt
	end
	plot(p..., size=(900, 900))
end

function plot_kmeans(data::Matrix, df::DataFrame, idx::AbstractVector, n::Int, dtw::Bool)
	a = kmeans_assignments(data, n)
	p = map(1:n) do i
		plt = plot(getindex.(df.x[a .== i], Ref(idx)), getindex.(df.mean[a .== i], Ref(idx)), lab="")
		if i == 2
			plt = title!("Kmeans clustering on spline fits")
		end
		if dtw
			plt = plot!(getindex(df.x[a .== i][1], idx), R.centers[:, i], l=(1.5, :black, :dash), label="center")
			if i == 2
				plt = title!("Kmeans clustering on time-warped spline fits")
			end
		end
		plt
	end
	xticks!.(p, Ref([2, 3, 4]), Ref(["lift", "cover", "grasp"]))
	plot(p..., size=(900, 900))
end

function plot_hclust(D::Matrix, X::Vector, n::Int)
	H = hclust(D, linkage=:average)
	a = cutree(H, k=n)

	p = map(1:n) do i
		plt = plot(X[a .== i], lab="")
		if i == 2
			plt = title!("Hierarchical clustering on firing rates")
		end
		plt
	end
	plot(p..., size=(900, 900))
end

function plot_hclust(D::Matrix, df::DataFrame, idx::AbstractVector, n::Int)
	a = hclust_assignements(D, n)

	p = map(1:n) do i
		plt = plot(getindex.(df.x[a .== i], Ref(idx)), getindex.(df.mean[a .== i], Ref(idx)), lab="")
		if i == 2
			plt = title!("Hierarchical clustering on spline fits")
		end
		plt
	end
	xticks!.(p, Ref([2, 3, 4]), Ref(["lift", "cover", "grasp"]))
	plot(p..., size=(900, 900))
end

function kmeans_assignements(data, n)
	R = kmeans(data, n, maxiter=20000, display=:iter)
	assignments(R)
end

function hclust_assignements(D, n)
	H = hclust(D, linkage=:average)
	cutree(H, k=n)
end
#%
data = load_data("data-v6.arrow");
data = data[in.(data.index, Ref(parse.(Int, df.idx))), :];
pad = 150
num_bins = 12
b1 = 5
σ = 5.
xn, _ = section_trial(data, pad, num_bins, b1);

Xm = hcat(Spikes.convolve([mean(i) for i in xn], σ)...)
todrop = drop(Xm, index=true)

#%
df = combine_simple_analysis(multi_all)
dfm = Spikes.convolve([mean(i) for i in xn][.!todrop], σ) 

X = hcat(zscore.(getindex.(df.mean, Ref(timerange)))...)
Xm = Xm[:, .!todrop]

D = pymetrics.cdist_dtw(X')
Dm = pymetrics.cdist_dtw(Xm')

timerange = 1.5 .< df.x[1] .< 4.5
n = 9

#%
k = kmeans_assignements(X, n)
km = kmeans_assignements(Xm, n)

k_dtw = kmeans_assignements(D, n)
km_dtw = kmeans_assignements(Dm, n)

h = hclust_assignements(D, n)
hm = hclust_assignements(Dm, n)

#%
plot_kmeans(X, df, timerange, n, true)
savefig(plotsdir("logbook", "15-03", "k-cluster"))
plot_kmeans(Xm, n, true)
savefig(plotsdir("logbook", "15-03", "k-cluster-fr"))

plot_kmeans(D, df, timerange, n, false)
savefig(plotsdir("logbook", "15-03", "k-dtw-cluster"))
plot_kmeans(Dm, dfm, n)
savefig(plotsdir("logbook", "15-03", "k-dtw-cluster-fr"))

plot_hclust(D, df, timerange, n)
savefig(plotsdir("logbook", "15-03", "h-cluster"))
plot_hclust(Dm, dfm, n)
savefig(plotsdir("logbook", "15-03", "h-cluster-fr"))
