using DrWatson
@quickactivate :ens

using Spikes
using Statistics
using StatsBase
using Plots; gr()

data = load_data("data-v6.arrow");

#%
pad = 5000
num_bins = 10
b1 = 100

n, ranges = multi_psth(data, pad, num_bins, b1);

baseline = getindex.(n, Ref(1:ceil(Int, length(n[1])÷3)))
n = normalize(n, baseline, :mad)
sort_agg_peaks!(n, 10)
m = hcat(n...) |> drop |> transpose 

l = size(m, 2)
low, high = -7, 7
closeall()
heatmap(m, c=:viridis, clim=(low, high), size=(1000, 1000), colorbar_title="Normalized firing rate", yflip=true)
xticks!([1, l÷4, l÷2-num_bins÷2, l÷2+num_bins÷2, l÷4*3, l], ["$(-round(pad/1000, digits=1))s before lift", "approach", "reach", "grasp", "retrieve", "$(round(pad/1000, digits=1))s after grasp"]) 
xaxis!("Landmarks")
yaxis!("Neuron #")
vline!([l÷2-num_bins, l÷2, l÷2+num_bins], line = (0.2, :dash, 0.6, :white), legend=false)


# savefig(plotsdir("psth", "multi-psth"), "scripts/psth/multi-psth.jl")
