using DrWatson
@quickactivate :ens

using Spikes
using MultivariateStats
using Plots; plotlyjs()


data = load_data("data-v4.arrow");

function scatter_dynamics(around, title)
	N = section(data.t, data.lift, around, :conv, :norm, :avg) |> drop
	M = fit(PCA, hcat(N...), maxoutdim=2)
	scatter(M.proj[:, 1], M.proj[:, 2], zcolor=[1:size(M.proj, 1);], colorbar_title="Time bin", xaxis="First component", yaxis="Second component",  colorbar=true, legend=false, title=title, size =(800, 800))
end

theme(:default)
title1 = "Principal components for spike times around lift"
scatter_dynamics([-250., 250.], title1)
filename = "pca-500-lift-dark"
# savefig(plotsdir("pca", filename), "scripts/pca/pca.jl")

title2 = "Principal components for spike times 1 second before lift"
scatter_dynamics([-1500., -1000.], title2)
filename = "pca-500-before-lift-dark"
# savefig(plotsdir("pca", filename), "scripts/pca/pca.jl")
