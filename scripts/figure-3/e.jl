using DrWatson
@quickactivate :ens

#%
using Statistics
using Plots; gr()
#%
#
σ = 1

mean_neighbors = mean(neighbors, dims=2)
neighbors_unmod = mean(drop(crosscor_c(tmp, neigh, [-500., 500.], 0.5, true)), dims=2)

x = reverse(mean_neighbors[1:40, :], dims=1) .+ mean_neighbors[41:end-1, :]
xs = copy(x)[1+2σ:end-2σ]
x = convolve(x[:], Float64(σ))

y = reverse(neighbors_unmod[1:40, :], dims=1) .+ neighbors_unmod[41:end-1, :]
y = convolve(y[:], Float64(σ))

plot([2:length(x)+1;], x, lw=2.5, c=:red, xlims=(0, 25), label="during modulation (smoothed)")
plot!([2:length(y)+1;], y, lw=2.5, c=:black, label="during whole task")
scatter!(2:length(xs)+1, xs, c=:black, label="modulation")
vline!([10], line = (1, :dash, :black), lab="")
hline!([0], line = (1, :dash, :black), lab="")
xticks!([0:4:24;], ["$i" for i = 0:2:12])
title!("Pairs of neighboring cells")
ylabel!("Average normalized cross-correlogram")
xlabel!("Time (ms)")
#%

savefig(plotsdir("crosscor", "figure_3E"), "scripts/figure-3/e.jl")
