using DrWatson
@quickactivate :ens

#%
using Statistics
using Plots; gr()
#%
#
σ = 1

mean_neighbors = mean(neighbors, dims=2)
neighbors_unmod = mean(drop(crosscor_c(tmp, neigh, [-1000., 1000.], 0.5, true)), dims=2)

x = reverse(mean_neighbors[1:40, :], dims=1) .+ mean_neighbors[41:end-1, :]
scatter_mod = copy(x)[1+2σ:end-2σ]
folded_mod = convolve(x[:], Float64(σ))

y = reverse(neighbors_unmod[1:40, :], dims=1) .+ neighbors_unmod[41:end-1, :]

folded_unmod = convolve(y[:], Float64(σ))

function figure_E(x, xs, y; kwargs)
	plot([2:length(x)+1;], x; c=:red, xlims=(0, 25), label="during modulation (smoothed)", kwargs...)
	plot!([2:length(y)+1;], y; c=:black, label="during whole task", kwargs...)
	scatter!(2:length(xs)+1, xs, c=:black, label="modulation")
	vline!([10], line = (1, :dash, :black), lab="")
	hline!([0], line = (1, :dash, :black), lab="")
	xticks!([0:4:24;], ["$i" for i = 0:2:12])
	title!("Pairs of neighboring cells")
	ylabel!("Average normalized cross-correlogram")
	xlabel!("Time (ms)")
end
#%

savefig(plotsdir("logbook", "04-03", "fig_e_z"), "scripts/figure-3/e.jl")
# savefig(plotsdir("crosscor", "figure_3E"), "scripts/figure-3/e.jl")
