using DrWatson
@quickactivate :ens

using Statistics
using Plots; gr()

include(srcdir("slice-trial.jl"))
include(srcdir("plot", "psth.jl"))


# rate should be deviation from baseline
# baseline is first fourth of -5000:5000


low, high = -10, 10

pad = 1000
bin_num = 8
n = sectionTrial(data, bin_num, pad)
n = hcat(drop(n)...)
ordered_n = sort_peaks(n)
l = size(ordered_n, 1)
heatmap(ordered_n', c=:viridis, clim=(low, high), size=(750, 1000), colorbar_title="Normalized firing rate", yflip=true)

xticks!([1, l÷4, l÷2-bin_num÷2, l÷2+bin_num÷2, l÷4*3, l], ["$(pad÷1000)s before lift", "approach", "reach", "grasp", "retrieve", "$(pad÷1000)s after grasp"]) 
xaxis!("Landmarks")
yaxis!("Neuron #")


savefig(plotsdir("psth-v2.png"))

# savefig(fig, plotsdir("psth-lime.svg"))

# savefig(fig, plotsdir("psth.pdf"))
