using DrWatson
@quickactivate "ens"

using Statistics
using Plots; gr()

include(srcdir("spike-tools.jl"))
include(srcdir("data-tools.jl"))
include(scriptsdir("load-data.jl"))

low, high = -0.7, 1.6

n = bigSlice(data, 6, 4)




function drop_inactive(n, thresh=3)
	n = dropnancols(n)
	n = dropinfcols(n)
	n = n[2:end-1, :]
	idx = sum(abs.(n) .> thresh, dims=1) .> 0
	n[:, idx[:]]
end

function sort_peaks(n)
	peaks = map(x -> x[1][1], argmax(n, dims=1))
	p = sortperm(peaks[:])
	ordered_n = n[:, p]
end




function plot_psth(n, low, high, thresh)
	n = drop_inactive(n, thresh)
	ordered_n = sort_peaks(n)
	x = -size(ordered_n, 1) ÷ 2:size(ordered_n, 1) ÷ 2 - 1
	y = 1:size(ordered_n, 2)
	heatmap(x, y, ordered_n', clim=(low, high), size=(600, 600), colorbar_title="Normalized firing rate", c=:viridis, yflip=true)
	xaxis!("Time (ms)", (x[1], x[end]+1), [x[1], 0, x[end]+1], showaxis = true)
	yaxis!("Neurons", (y[1], y[end]), [y[1],  y[end]])
end


# gr()
# theme(:dark)
# fig = plot_psth(n, low, high)

# savefig(fig, plotsdir("psth-lime.svg"))

# savefig(fig, plotsdir("psth.pdf"))
