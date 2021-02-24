using DrWatson
@quickactivate :ens

using Statistics
using Plots; gr()

include(srcdir("section-trial.jl"))
include(srcdir("plot", "psth.jl"))



pad = 1000.
num_bins = 6
b = 200

n, r = sectionTrial(data, num_bins, pad, b, :mad);

idx = drop(n, index=true)

active_bins = get_active_bins(n[.!idx])
ordered_n = sort_peaks(hcat(n[.!idx]...))

l = size(ordered_n, 1)
low, high = -5, 5
heatmap(ordered_n', c=:viridis, clim=(low, high), size=(750, 1000), colorbar_title="Normalized firing rate", yflip=true)
xticks!([1, l÷4, l÷2-bin_num÷2, l÷2+bin_num÷2, l÷4*3, l], ["$(pad÷1000)s before lift", "approach", "reach", "grasp", "retrieve", "$(pad÷1000)s after grasp"]) 
xaxis!("Landmarks")
yaxis!("Neuron #")


# savefig(plotsdir("psth", "psth-v2"), "scripts/psth/psth-v2.jl")
