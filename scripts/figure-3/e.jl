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
xs = copy(x)[1+2σ:end-2σ]
x = convolve(x[:], Float64(σ))

y = reverse(neighbors_unmod[1:40, :], dims=1) .+ neighbors_unmod[41:end-1, :]

y = convolve(y[:], Float64(σ))

fig_e = plot([2:length(x)+1;], x, lw=2.5, c=:red, xlims=(0, 25), label="during modulation (smoothed)")
fig_e = plot!([2:length(y)+1;], y, lw=2.5, c=:black, label="during whole task")
fig_e = scatter!(2:length(xs)+1, xs, c=:black, label="modulation")
fig_e = vline!([10], line = (1, :dash, :black), lab="")
fig_e = hline!([0], line = (1, :dash, :black), lab="")
fig_e = xticks!([0:4:24;], ["$i" for i = 0:2:12])
fig_e = title!("Pairs of neighboring cells")
fig_e = ylabel!("Average normalized cross-correlogram")
fig_e = xlabel!("Time (ms)")
#%

savefig(plotsdir("logbook", "04-03", "fig_e_z"), "scripts/figure-3/e.jl")
# savefig(plotsdir("crosscor", "figure_3E"), "scripts/figure-3/e.jl")
