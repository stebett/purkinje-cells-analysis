using DrWatson
@quickactivate :ens

using Statistics
using Plots; gr()
using Revise

includet(srcdir("slice-trial.jl"))
include(srcdir("plot", "psth.jl"))


# rate should be deviation from baseline
# baseline is first fourth of -5000:5000


low, high, thresh = -0.25, .25, 3

n = hcat(sectionTrial(data, 6, 100)...)
n = drop(n, outliers=true, threshold=thresh)
ordered_n = sort_peaks(n)
heatmap(ordered_n', c=:viridis, clim=(low, high), size=(750, 1000), colorbar_title="Normalized firing rate", yflip=true)
xaxis!("Time (ms)")
yaxis!("Neurons")


savefig(plotsdir("psth-v2.png"))

# savefig(fig, plotsdir("psth-lime.svg"))

# savefig(fig, plotsdir("psth.pdf"))
