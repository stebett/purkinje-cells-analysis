using DrWatson
@quickactivate "ens"

include(srcdir("spike-tools.jl"))
include(srcdir("data-tools.jl"))
include(scriptsdir("load-data.jl"))

using MultivariateStats
using Plots

N = normalize(data.t, data.lift, (-50, 50), (-500, 500))
N, new_idx = dropnancols(N)
M = fit(PCA, N, maxoutdim=2)
scatter(M.proj[:, 1], M.proj[:, 2], zcolor=[1:size(M.proj, 1);], colorbar_title="Time bin", xaxis="First component", yaxis="Second component", colorbar=true, legend=false, title="Principal components for spike times around lift")
# png(plotsdir("pca_lift"))

N = normalize(data.t, data.cover, (-50, 50), (-500, 500))
N, new_idx = dropnancols(N)
M = fit(PCA, N, maxoutdim=2)
scatter(M.proj[:, 1], M.proj[:, 2], zcolor=[1:size(M.proj, 1);], colorbar_title="Time bin", xaxis="First component", yaxis="Second component", colorbar=true, legend=false, title="Principal components for spike times around cover")
# png(plotsdir("pca_cover"))

N = normalize(data.t, data.grasp, (-50, 50), (-500, 500))
N, new_idx = dropnancols(N)
M = fit(PCA, N, maxoutdim=2)
scatter(M.proj[:, 1], M.proj[:, 2], zcolor=[1:size(M.proj, 1);], colorbar_title="Time bin", xaxis="First component", yaxis="Second component", colorbar=true, legend=false, title="Principal components for spike times around grasp")
# png(plotsdir("pca_grasp"))


plotlyjs()
N = normalize(data.t, data.lift, (-50, 50), (-500, 500))
N, new_idx = dropnancols(N)
M = fit(PCA, N, maxoutdim=3)
scatter(M.proj[:, 1], M.proj[:, 2], M.proj[:, 3], zcolor=[1:size(M.proj, 1);], colorbar_title="Time bin", xaxis="First component", yaxis="Second component", zaxis="Third component", colorbar=true, legend=false, title="Principal components for spike times around lift", size =(800, 800))
# png(plotsdir("pca_lift"))
