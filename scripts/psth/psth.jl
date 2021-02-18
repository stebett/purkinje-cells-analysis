using DrWatson
@quickactivate :ens

using Statistics
using Plots;


low, high = -0.7, 1.6

n = section(data.t, data.lift, [-5000, 5000], over=[-5000, -2000], :norm, :avg)


function sort_active(n)
	n = drop(n)
	half = size(n, 1) ÷ 2
	rates = mean(@view(n[half-250:half+250, :]), dims=1)
	p = sortperm(rates[:])
	ordered_n = n[:, p]
end


function plot_psth(n::Array{Array{Float64, 1}}, low::Float64, high::Float64, around=[])
	ordered_n = sort_active(hcat(n...))
	heatmap(ordered_n', clim=(low, high), size=(750, 1000), colorbar_title="Normalized firing rate", c=:viridis)
	l, h = size(ordered_n)
	x0, x1 = [0, l] .- l ÷ 2
	xticks!([0, l÷2, l-l/1000], ["$x0", "0", "$x1"])
	yticks!([1, h-1], ["1", "$h"])
	xaxis!("Time (ms)")
	yaxis!("Neuron #")
end


gr()
fig = plot_psth(n, low, high)
savefig(plotsdir("psth", "psth"), "scripts/psth/psth.jl")
