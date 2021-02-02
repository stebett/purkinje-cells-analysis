using DrWatson
@quickactivate "ens"

using Statistics
using Plots; gr()

include(srcdir("spike-tools.jl"))
include(srcdir("data-tools.jl"))
include(scriptsdir("load-data.jl"))

low, high = -0.7, 1.6

n = slice(data.t, data.lift, convolution=true, normalization=true, average=true, around=[-5000, 5000], over=[-5000, -2000])


function sort_active(n)
	n = dropnancols(n)
	n = dropinfcols(n)
	half = size(n, 1) ÷ 2
	rates = mean(@view(n[half-250:half+250, :]), dims=1)
	p = sortperm(rates[:])
	ordered_n = n[:, p]
end


function plot_psth(n, low, high)
	ordered_n = sort_active(n)
	x = -size(ordered_n, 1) ÷ 2:size(ordered_n, 1) ÷ 2 - 1
	y = 1:size(ordered_n, 2)
	heatmap(x, y, ordered_n', clim=(low, high), size=(750, 1000), colorbar_title="Normalized firing rate", c=:viridis)
	xaxis!("Time (ms)", (x[1], x[end]+1), [x[1], 0, x[end]+1], showaxis = true)
	yaxis!("Neurons", (y[1], y[end]), [y[1],  y[end]])
end

plotlyjs()

gr()
theme(:dark)
fig = plot_psth(n, low, high)
savefig(fig, plotsdir("psth-lime.svg"))

savefig(fig, plotsdir("psth.pdf"))
