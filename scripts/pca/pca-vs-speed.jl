using DrWatson
@quickactivate :ens

using Spikes
using Statistics
using MultivariateStats
using Plots; plotlyjs()


data = load_data("data-v5.arrow");

tmp = tmp[tmp.err .< 100, :];

around = [-500., 500.]
T = cut(tmp.t, tmp.cover, [around[1] - 20., around[2] + 20.]);
T = bin(T, Int(diff(around)...) + 40, 1.);
T = convolve(T, 10.)
M = fit(PCA, hcat(T...), maxoutdim=3)
plot(M.proj, lw=3) 


scatter(M.proj[:, 1], M.proj[:, 2],  zcolor=eachindex(M.proj[:, 1]), c=:delta, colorbar_title="Time bin", xaxis="First component", yaxis="Second component",  zaxis="Movement time (ms)", colorbar=true, legend=false, size =(800, 800))



P = hcat(transform.(Ref(M), T)...)

speed = [x for y=tmp.grasp for x=y] .- [x for y=tmp.lift for x=y]

speed_bin = copy(speed)
speed_bin[speed .< median(speed)] .= 0.
speed_bin[speed .>= median(speed)] .= 1.

scatter(P[1, :], P[2, :], zcolor=speed, clim=(50, 500), colorbar_title="Time bin", xaxis="First component", yaxis="Second component",  zaxis="Movement time (ms)", colorbar=true, legend=false, size =(800, 800))
