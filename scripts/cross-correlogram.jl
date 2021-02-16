using DrWatson
@quickactivate "ens"

using Statistics
using LinearAlgebra
using Plots; gr()
using Revise

includet(srcdir("cross-correlation.jl"))
include(scriptsdir("load-data.jl"))
include(scriptsdir("load-full.jl"))

# 3B
acorrs = data_full[:, :p_acorr1000] 
tmp_acorr = data[findall(0.5 .< acorrs .< 1.), :];
get_pairs(tmp_acorr, "n")

idx1 = 30
idx2 = 34

plot(crosscor(tmp_acorr, idx1, idx2; thr=1.5, binsize=0.5, around=[-200, 200], filt=true))
plot!(crosscor(tmp_acorr, idx1, idx2; thr=1.5, binsize=0.5, around=[-200, 200], filt=false))

# 3C
tmp = data[acorrs .> 0.5, :];
size(tmp)

neigh = get_pairs(tmp, "n")
cc_n = mass_crosscor(tmp, neigh)

cc_n_mean = mean(cc_n, dims=2)
cc_n_std = std(cc_n, dims=2)
plot(cc_n_mean) #, ribbon=cc_n_std,fc=:blue,fa=0.3,label="neighbors", linewidth=3)

# 3D
distant = get_pairs(tmp, "d")
cc_d = mass_crosscor(tmp, distant)

cc_d_mean = mean(cc_d, dims=2)
cc_d_std = std(cc_d, dims=2)
plot!(cc_d_mean) #, ribbon=cc_d_std,fc=:blue,fa=0.3,label="distant", linewidth=3)

# 3E
cc_n_mod = mass_crosscor(tmp, neigh, filt=false) 
cc_n_unmod = mass_crosscor(tmp, neigh, filt=false) 

cc_n_mod |> dropnancols |> normalize |> x->x[42:70, :] |> x->mean(x, dims=2) |> plot
cc_n_unmod |> dropnancols |> normalize |> x->x[42:70, :] |> x->mean(x, dims=2) |> plot!


# 3F
n = slice(tmp.t, tmp.lift, around=[-200, 200], convolution=true, average=true)
cors = [cor(n[:, x[1]], n[:, x[2]]) for x in neigh]

fr_sim = findall(cors .> 0.2)
fr_diff = findall(cors .<= 0.2)

tmp_sim = tmp[fr_sim, :];
tmp_diff = tmp[fr_diff, :];

neigh_sim = get_pairs(tmp_sim, "n")
neigh_diff = get_pairs(tmp_diff, "n")

cc_sim = mass_crosscor(tmp_sim, neigh_sim)
cc_diff = mass_crosscor(tmp_diff, neigh_diff)

cc_sim |> normalize |> x->x[42:70, :] |> x->mean(x, dims=2) |> plot
cc_diff |> normalize |> x->x[42:70, :] |> x->mean(x, dims=2) |> plot!
