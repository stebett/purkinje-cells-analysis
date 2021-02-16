using DrWatson
@quickactivate "ens"

include(srcdir("spike-tools.jl"))
include(srcdir("data-tools.jl"))
include(srcdir("utils.jl"))

include(scriptsdir("load-data.jl"))

using MultivariateStats
using Plots

function sort_active(n, thr=0.5)
	half = size(n, 1) ÷ 2
	rates = abs.(mean(n[half-10:half+10, :], dims=1))
	high_rates = rates .> thr
	n[:, high_rates[:]]
end

n = slice(data.t, data.lift, around=[-50, 5000], convolution=true, normalization=true, average=false)
n = dropnancols(n)
N = sort_active(n, 1.5)

plotlyjs()
M = fit(PCA, N, maxoutdim=2)
# M = fit(PPCA, N, maxoutdim=2)
scatter(M.proj[:, 1], M.proj[:, 2], zcolor=[1:size(M.proj, 1);], colorbar_title="Time bin", xaxis="First component", yaxis="Second component", colorbar=true, legend=false, title="Principal components for spike times around lift", size=(800,600), ms=8)

savefig(plotsdir("PCA-100.pdf"))

M = fit(PCA, N, maxoutdim=3)

scatter(M.proj[:, 1], M.proj[:, 2], M.proj[:, 3], zcolor=[1:size(M.proj, 1);], colorbar_title="Time bin", xaxis="First component", yaxis="Second component", zaxis="Third component", colorbar=true, legend=false, title="Principal components for spike times around lift", size =(800, 800))
# png(plotsdir("pca_lift"))
#
#
x = 50
n = slice(data.t, data.lift, around=[-x, x], convolution=true, normalization=true, average=false)
n = dropnancols(n)
N = sort_active(n, 1.8)
M = fit(PCA, N, maxoutdim=3)

scatter(M.proj[:, 1], M.proj[:, 2], M.proj[:, 3], zcolor=[1:size(M.proj, 1);], colorbar_title="Time bin", xaxis="First component", yaxis="Second component", zaxis="Third component", colorbar=true, legend=false, title="Principal components for spike times around lift", size =(800, 800))
