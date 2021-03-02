using DrWatson
@quickactivate :ens

#%
using Statistics
using LinearAlgebra
using Plots; gr()
import StatsBase.sem

include(srcdir("plot", "cross-correlation.jl"))

#%
n = section(tmp.t, tmp.lift, [-200, 200], :conv, :avg)
cors = [cor(n[findall(tmp.index .== x[1])[1]], n[findall(tmp.index .== x[2])[1]]) for x in neigh]

fr_sim = findall(cors .> 0.2)
fr_diff = findall(cors .<= 0.2)

cc_sim = mass_crosscor(tmp, neigh[fr_sim], thr=2.)
cc_diff = mass_crosscor(tmp, neigh[fr_diff], thr=2.)

σ = 1
x = reverse(cc_sim[1:40, :], dims=1) .+ cc_sim[41:end-1, :]
x = drop((x .- mean(x, dims=1)) ./ std(x, dims=1))
x = mean(drop(x), dims=2)
x = convolve(x[:], σ)
plot(x)

y = reverse(cc_diff[1:40, :], dims=1) .+ cc_diff[41:end-1, :]
y = drop((y .- mean(y, dims=1)) ./ std(y, dims=1))
y = mean(drop(y), dims=2)
y = convolve(y[:], σ)
plot!(y)
#%
