using DrWatson
@quickactivate "ens"

using Statistics
using Plots; gr()

include(srcdir("spike-tools.jl"))
include(srcdir("data-tools.jl"))
include(scriptsdir("load-data.jl"))

low, high = -0.7, 1.6

n = slice(data.t, data.lift, convolution=true, normalization=true, average=true, around=[-500, 500], over=[-5000, 5000])

idx = active_neurons(n, low, high)

active = n[:, idx]
x = -size(active, 1) ÷ 2:size(active, 1) ÷ 2 - 1
y = 1:sum(idx)
heatmap(x, y, active', clim=(low, high), size=(800, 600), colorbar_title="Normalized firing rate")
xaxis!("Time (ms)", (x[1], x[end]+1), [x[1], 0, x[end]+1], showaxis = false)
yaxis!("Neurons", (y[1], y[end]), [y[1],  y[end]])
