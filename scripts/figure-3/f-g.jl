using DrWatson
@quickactivate :ens

#%
using Statistics
using Plots; gr()

#%
σ = 1

n = cut(data.t, data[:, landmark], [-500., 500.])
n = bin(n, 1000, 1.0)
n = convolve(n, 10.)
n = average(n, data)

neigh = couple(data, :n);
relative!(neigh, data);
cors = [cor(n[i]...) for i in neigh]

r_sim = findall(cors .> 0.2)
r_diff = findall(cors .<= 0.2)

neigh_sim = absolute(neigh[r_sim], data)
active_sim = get_active_couples(neigh_sim, active_ranges)

sim = crosscor_c(tmp, neigh_sim, active_sim, binsize) |> drop
folded_sim = reverse(sim[1:40, :], dims=1) .+ sim[41:end-1, :]

folded_sim_mean = convolve(mean(folded_sim, dims=2)[:], Float64(σ))
folded_sim_sem = sem(sim, dims=2)


neigh_diff = absolute(neigh[r_diff], data)
active_diff = get_active_couples(neigh_diff, active_ranges)

different = crosscor_c(tmp, neigh_diff, active_diff, binsize) |> drop
folded_diff = reverse(different[1:40, :], dims=1) .+ different[41:end-1, :]

folded_diff_mean = convolve(mean(folded_diff, dims=2)[:], Float64(σ))
folded_diff_sem = sem(different, dims=2)

plot(folded_sim_mean, c=:black, ribbon=folded_sim_sem, fillalpha=0.3,  linewidth=3, label=false)
vline!([10], line = (1, :dash, :black), lab="")
hline!([0], line = (1, :dash, :black), lab="")
xticks!([0:4:40;], ["$i" for i = 0:2:20])
title!("Pairs of neighboring cells with similar firing time course")
ylabel!("Average mean ± sem deviation")
xlabel!("Time (ms)")
savefig(plotsdir("crosscor", "figure_3F"), "scripts/figure-3/f-g.jl")

plot(folded_diff_mean, c=:black, ribbon=folded_diff_sem, fillalpha=0.3,  linewidth=3, label=false)
vline!([10], line = (1, :dash, :black), lab="")
hline!([0], line = (1, :dash, :black), lab="")
xticks!([0:4:40;], ["$i" for i = 0:2:20])
title!("Pairs of neighboring cells with different firing time course")
ylabel!("Average mean ± sem deviation")
xlabel!("Time (ms)")
savefig(plotsdir("crosscor", "figure_3G"), "scripts/figure-3/f-g.jl")
