using DrWatson
@quickactivate :ens

using Plots; 
using Spikes
using StatsBase

data = load_data("data-v2.arrow")

low, high = -0.7, 1.6
around = [-5000., 5000.]
over = [-5000., -2000.]


spikes = cut(data.t, data.lift, around)
baseline = cut(data.t, data.lift, over)

binned = bin.(spikes, 0, 10000)
binned_baseline = bin.(baseline, 0, 3000)

convolved = convolve(binned)
convolved_baseline = convolve(binned_baseline)

# normalized = normalize(binned, binned_baseline)
normalized = normalize(convolved, convolved_baseline)
averaged = average(normalized, data)
sorted = sort_active(averaged, 800)
X = hcat(sorted...) |> drop |> transpose

pyplot(size=(900, 1000), c=:viridis)
heatmap(X, clims=(low, high))
title!("Normalized firing rate around lift")
xticks!([0, 5000, 9950], ["-5000", "0", "5000"])
yticks!([1, 139], ["1", "139"])
xaxis!("Time (ms)")
yaxis!("Neuron #")

# savefig(plotsdir("presentation", "psth.png"), "scripts/psth/psth.jl")
