using DrWatson
@quickactivate :ens

using JLD2 
using MultivariateStats
using Clustering
using NPZ
using Plots
using Combinatorics
using PyCall
using Distances


pymetrics = pyimport("tslearn.metrics")


 
Xs = npzread(datadir("clustering", "spline.npy")) |> transpose
Ds = npzread(datadir("clustering", "dtw-spline.npy"))

Ds = pymetrics.cdist_dtw(Xₘ, global_constraint="sakoe_chiba", sakoe_chiba_radius=0.2)
P = classical_mds(Ds, 24)

for n in 2:30
	R = kmeans(P, n, maxiter=200, display=:none)
	a = assignments(R)
	ms = mean(silhouettes(R, Ds))
	print("mean for $n clusters: $ms\n")
end

n = 8
R = kmeans(P, n)
a = assignments(R)
perm = sortperm(a)

plotlyjs()
scatter(P[1, :], P[2, :], ms=5,  zcolor=a, size=(800, 800), c=:darktest)

gr()
heatmap(Ds[perm, perm], size=(2000, 1600))
xticks!([1:length(a);], string.(perm), xrotation=90, fontsize=6)
yticks!([1:length(a);], string.(perm), yrotation=0, fontsize=6)

gr()
p = map(1:n) do i
	heatmap(Xₘ[a .== i, :], lab="", yflip=true, colorbar=false)
	yticks!([1:sum(a.==i);], string.(findall(a .== i)))
	# xticks!([1:65:size(Xm, 1)+1;], ["-300", "lift", "cover", "grasp", "+300", "+600"])
end
plot(p..., size=(1800, 1200))
xlabel!("Timestep")
ylabel!("Neuron")


xm = minmax_scale.(xₛ)
p = map(1:n) do i
	plot(xm[a .== i], lab="", yflip=true, colorbar=false)
	yticks!([1:sum(a.==i);], string.(findall(a .== i)))
end
plot(p..., size=(1800, 1200))
xlabel!("Timestep")
ylabel!("Neuron")




savefig(plotsdir("logbook", "18-03", "mds-8-clusters-mpsth-filtered-0.2.png"))
