using DrWatson
@quickactivate :ens

using Spikes
using Statistics
using StatsBase
using Plots; gr()
import Base.diff

diff(x::Tuple) = x[2] - x[1]

data = load_data("data-v5.arrow");

#%
pad = 2500
num_bins = 12
b1 = 25

n, ranges = multi_psth(data, pad, num_bins, b1);

m = hcat([sum(x) ./ sum([diff.(y) for y in r]) for (x, r) in zip(n, ranges)]...)
sort_peaks!(m)
m = transpose(m)

baseline = m[:, 1:floor(Int, size(m, 2)/4)]
zscore!(m, mean(baseline, dims=2), std(baseline, dims=2))


l = size(m, 2)
low, high = -5, 5
closeall()
heatmap(m, c=:viridis, clim=(low, high), size=(1000, 1000), colorbar_title="Normalized firing rate", yflip=true)
xticks!([1, l÷4, l÷2-num_bins÷2, l÷2+num_bins÷2, l÷4*3, l], ["$(-round(pad/1000, digits=1))s before lift", "approach", "reach", "grasp", "retrieve", "$(round(pad/1000, digits=1))s after grasp"]) 
xaxis!("Landmarks")
yaxis!("Neuron #")
vline!([l÷2-num_bins, l÷2, l÷2+num_bins], line = (0.2, :dash, 0.6, :white), legend=false)


savefig(plotsdir("psth", "multi-psth"), "scripts/psth/multi-psth.jl")
