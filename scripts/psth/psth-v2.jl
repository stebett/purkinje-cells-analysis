using DrWatson
@quickactivate :ens

using Statistics
using Plots; gr()

include(srcdir("slice-trial.jl"))

low, high, thresh = -2.5, 2.5, 1.5

n = bigSlice(data, 6, 4)

# rate should be deviation from baseline
# baseline is first fourth of -5000:5000



function drop_inactive(n, thresh=3)
	n = dropnancols(n)
	n = dropinfcols(n)
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
	# xaxis!("Time (ms)", (x[1], x[end]+1), [x[1], 0, x[end]+1], showaxis = true)
	xaxis!("Time (ms)", (x[1], x[end]+1), [x[1]:6:x[end];], showaxis = true)
	yaxis!("Neurons", (y[1], y[end]), [y[1],  y[end]])
end


plot_psth(n, low, high, thresh)
savefig(plotsdir("psth-v2.png"))

# savefig(fig, plotsdir("psth-lime.svg"))

# savefig(fig, plotsdir("psth.pdf"))
