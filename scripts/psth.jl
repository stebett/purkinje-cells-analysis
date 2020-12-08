using DrWatson
@quickactivate "ens"

using Statistics
using Plots; gr()

include(srcdir("spike-tools.jl"))
include(datadir("old-load-data.jl"))

function psth(spikerates, threshold)
    idx = falses(size(spikerates, 2))

    c = size(spikerates, 1) ÷ 2
    high = spikerates[c-200:c+200, :] .> threshold
    low = spikerates[c-200:c+200, :] .< -threshold

    for i in 1:size(spikerates, 2)
        if any(high[:, i]) | any(low[:, i])
            idx[i] = true
        end
    end

    active = spikerates[:, idx]
    x = -size(active, 1) ÷ 2:size(active, 1) ÷ 2 - 1
    y = 1:sum(idx)
    heatmap(x, y, active', clim=(-0.7, 1.6), size=(800, 600), colorbar_title="Normalized firing rate")
    xaxis!("Time (ms)", (x[1], x[end]+1), [x[1], 0, x[end]+1], showaxis = false)
    yaxis!("Neurons", (y[1], y[end]), [y[1],  y[end]])
end

spikerates = old_normalize(data.t, data.lift)
psth(spikerates, 2.5)
