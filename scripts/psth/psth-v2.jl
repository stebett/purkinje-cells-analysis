using DrWatson
@quickactivate :ens

using Spikes
using Statistics
using Plots; gr()

data = load_data("data-v6.arrow");

#%
pad = 600
num_bins = 12
b1 = 30

n, r = section_trial(data, pad, num_bins, b1);

ordered_n = sort_peaks(drop(hcat([mean(i) for i in n]...)))
Xm = drop([mean(i) for i in n])

l = size(ordered_n, 1)
low, high = -3, 3
closeall()
heatmap(ordered_n', c=:viridis, clim=(low, high), size=(1000, 1000), colorbar_title="Normalized firing rate", yflip=true)
xticks!([1, l÷4, l÷2-num_bins÷2, l÷2+num_bins÷2, l÷4*3, l], ["$(-round(pad/1000, digits=1))s before lift", "approach", "reach", "grasp", "retrieve", "$(round(pad/1000, digits=1))s after grasp"]) 
xaxis!("Landmarks")
yaxis!("Neuron #")
vline!([l÷2-num_bins, l÷2, l÷2+num_bins], line = (0.2, :dash, 0.6, :white), legend=false)


# savefig(plotsdir("psth", "psth-v2"), "scripts/psth/psth-v2.jl")
