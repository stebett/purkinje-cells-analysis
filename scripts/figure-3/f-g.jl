using DrWatson
@quickactivate :ens

#%
using Statistics
using Plots; gr()

#%
σ = 1
data = load_data("data-v5.arrow");

n = cut(data.t, data[:, :cover], [-500., 500.])
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
#%

fig_f = plot(folded_sim_mean, c=:black, ribbon=folded_sim_sem, fillalpha=0.3,  linewidth=3, label=false)
fig_f = vline!([10], line = (1, :dash, :black), lab="")
fig_f = hline!([0], line = (1, :dash, :black), lab="")
fig_f = xticks!([0:4:40;], ["$i" for i = 0:2:20])
fig_f = title!("Pairs of neighboring cells with\n similar firing time course")
fig_f = ylabel!("Average mean ± sem deviation")
fig_f = xlabel!("Time (ms)")
# savefig(plotsdir("crosscor", "figure_3F"), "scripts/figure-3/f-g.jl")
#%

fig_g = plot(folded_diff_mean, c=:black, ribbon=folded_diff_sem, fillalpha=0.3,  linewidth=3, label=false)
fig_g = vline!([10], line = (1, :dash, :black), lab="")
fig_g = hline!([0], line = (1, :dash, :black), lab="")
fig_g = xticks!([0:4:40;], ["$i" for i = 0:2:20])
fig_g = title!("Pairs of neighboring cells with\ndifferent firing time course")
fig_g = ylabel!("Average mean ± sem deviation")
fig_g = xlabel!("Time (ms)")
# savefig(plotsdir("crosscor", "figure_3G"), "scripts/figure-3/f-g.jl")
