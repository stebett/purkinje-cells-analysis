using DrWatson
@quickactivate "ens"

include(srcdir("spike-tools.jl"))
include(srcdir("data-tools.jl"))
include(srcdir("utils.jl"))

include(scriptsdir("load-data.jl"))

using MultivariateStats
using Plots


function scatter_dynamics(around, title)
	N = slice(data.t, data.lift, convolution=true, normalization=true, average=true, around=around)
	N = dropnancols(N)
	N = dropinfcols(N)
	N = dropoutliercols(N)
	M = fit(PCA, N, maxoutdim=2)
	scatter(M.proj[:, 1], M.proj[:, 2], zcolor=[1:size(M.proj, 1);], colorbar_title="Time bin", xaxis="First component", yaxis="Second component",  colorbar=true, legend=false, title=title, size =(800, 800))
end


title1 = "

filename = "pca-500-lift.pdf"
savefig(plotsdir(filename))
