using DrWatson
@quickactivate :ens

using DataFrames
using JLD2 
using Clustering
using PyCall
using Spikes
using MultivariateStats
using Plots
using Distances

include(srcdir("spline", "spline-plots.jl"))
include(srcdir("spline", "spline-utils.jl"))
pymetrics = pyimport("tslearn.metrics")


multi_all = load(datadir("spline", "multi-all.jld2"));
lift_all = load(datadir("spline", "lift-all.jld2"));

df_spline = combine_simple_analysis(multi_all)
p = sortperm(parse.(Int, df_spline.idx))
df_spline = df_spline[p, :]

data = load_data("data-v6.arrow");
data = data[in.(data.index, Ref(parse.(Int, df_spline.idx))), :];
pad = 600
num_bins = 12
b1 = 30
xm, _ = multi_psth(data, pad, num_bins, b1);
baseline = getindex.(xm, Ref(1:ceil(Int, length(xm[1])÷3)))
xm = normalize(xm, baseline, :mad)
todrop = drop(xm, index=true)

xm = xm[.!todrop]
Xm = hcat(xm...)
Xm = hcat(minmax_scale.(xm)...)

df_spline = df_spline[.!todrop, :]
Xs = getindex.(df_spline.mean, Ref(60:length(df_spline.mean[1])-60))
Xs = minmax_scale.(Xs)
Xs = hcat(Xs...)

D = pymetrics.cdist_dtw(Xs', global_constraint="itakura", itakura_max_slope=2.)
R = hclust(D)
heatmap(Xs[:, R.order[34:42]]')
Dm = pymetrics.cdist_dtw(Xm')

M = fit(PCA, Xm′, maxoutdim=20)
P = MultivariateStats.transform(M, Xm′)


function minmax_scale(x::Vector)
	min, max = extrema(x)
	@. (x - min) / (max-min)
end


for n in 2:10
	R = kmeans(P, n, maxiter=200, display=:none)
	a = assignments(R)
	ms = mean(silhouettes(R, pairwise(Euclidean(), P)))
	print("mean for $n clusters: $ms\n")
end

n = 6
R = kmeans(P, n, maxiter=200, display=:none)
a = assignments(R)
scatter(P[1, :], P[2, :], zcolor=a)

p = map(1:n) do i
	plot(xm[a .== i], lab="")
end
p1 = plot(p..., size=(700, 700))

p = map(1:n) do i
	heatmap(sort_active(Xm[:, a .== i], 30)', lab="")
end
p2 = plot(p..., size=(700, 700))

p = map(1:n) do i
	plot(df_spline.x[a.==i], df_spline.mean[a .== i], lab="")
end
p3 = plot(p..., size=(700, 700))

p = map(1:n) do i
	heatmap(sort_peaks(Xs[:, a .== i])', lab="")
	title!("Cluster $i")
end
p4 = plot(p..., size=(1200, 700))
xlabel!("Timestep")
ylabel!("Neuron")

p = map(1:n) do i
	heatmap(sort_active(Xm′[:, a .== i], 10)', lab="")
	title!("Cluster $i")
end
p4 = plot(p..., size=(1200, 700))
xlabel!("Timestep")
ylabel!("Neuron")

plot(p1, p2, p3, p4, size=(1920, 1280))

savefig(plotsdir("logbook", "4clusters_heatmaps_mpsth"))

p=[]
for (i, j) in combinations([1:4;], 2)
	push!(p, scatter(P[i, :], P[j, :], zcolor=a, colorbar=false, ms=6, bcolor=a))
	@show i, j
end
plot(p..., size=(1400, 1400))

