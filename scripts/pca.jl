using DrWatson
@quickactivate "ens"

include(srcdir("spike-tools.jl"))
include(srcdir("data-tools.jl"))
include(scriptsdir("load-data.jl"))
include(srcdir("utils.jl"))

using MultivariateStats
using Plots

N = slice(data.t, data.lift, convolution=true, normalization=true, average=false)
N = dropnancols(N)
M = fit(PCA, N, maxoutdim=2)
scatter(M.proj[:, 1], M.proj[:, 2], zcolor=[1:size(M.proj, 1);], colorbar_title="Time bin", xaxis="First component", yaxis="Second component", colorbar=true, legend=false, title="Principal components for spike times around lift")
# png(plotsdir("pca_lift"))

N = slice(data.t, data.cover, convolution = true, normalization=true, average=true)
N, new_idx = dropnancols(N)
M = fit(PCA, N, maxoutdim=2)
scatter(M.proj[:, 1], M.proj[:, 2], zcolor=[1:size(M.proj, 1);], colorbar_title="Time bin", xaxis="First component", yaxis="Second component", colorbar=true, legend=false, title="Principal components for spike times around cover")
# png(plotsdir("pca_cover"))

N = slice(data.t, data.grasp, convolution = true, normalization=true, average=true)
N, new_idx = dropnancols(N)
M = fit(PCA, N, maxoutdim=2)
scatter(M.proj[:, 1], M.proj[:, 2], zcolor=[1:size(M.proj, 1);], colorbar_title="Time bin", xaxis="First component", yaxis="Second component", colorbar=true, legend=false, title="Principal components for spike times around grasp")
# png(plotsdir("pca_grasp"))


plotlyjs()
N = slice(data.t, data.lift, convolution = true, normalization=true, average=true)
N = dropnancols(N)
M = fit(PCA, N, maxoutdim=3)
scatter(M.proj[:, 1], M.proj[:, 2], M.proj[:, 3], zcolor=[1:size(M.proj, 1);], colorbar_title="Time bin", xaxis="First component", yaxis="Second component", zaxis="Third component", colorbar=true, legend=false, title="Principal components for spike times around lift", size =(800, 800))
# png(plotsdir("pca_lift"))

neigh = unique(get_neighbors(data, grouped=false))
N = slice(data.t, data[neigh, "lift"], convolution=true, normalization=true)
N = dropnancols(N)
M = fit(PCA, N, maxoutdim=3)
scatter(M.proj[:, 1], M.proj[:, 2], M.proj[:, 3], zcolor=[1:size(M.proj, 1);], colorbar_title="Time bin", xaxis="First component", yaxis="Second component", zaxis="Third component", colorbar=true, legend=false, title="Principal components for spike times around lift of neighboring neurons", size =(800, 800))
# png(plotsdir("pca_lift"))

function scatter_dynamics(around)
	N = slice(data.t, data.lift, convolution=true, normalization=false, around=around)
	N = dropnancols(N)
	M = fit(PCA, N, maxoutdim=3)
	scatter(M.proj[:, 1], M.proj[:, 2], M.proj[:, 3], zcolor=[1:size(M.proj, 1);], colorbar_title="Time bin", xaxis="First component", yaxis="Second component", zaxis="Third component", colorbar=true, legend=false, title="Principal components for spike times around lift", size =(800, 800))
end
