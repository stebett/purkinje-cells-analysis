using DrWatson
@quickactivate :ens

using Statistics
using LinearAlgebra
using Plots; gr()
import StatsBase.sem

include(srcdir("cross-correlation.jl"))
include(scriptsdir("data", "load-full.jl"))

function sem(x::Matrix; dims=2)
	r = zeros(size(x, dims % 2 + 1)) 
	for i in 1 : length(r)
		r[i] = sem(x[i, :])
	end
	r
end


# 3B
acorrs = data_full[:, :p_acorr1000] 
tmp_acorr = data[findall(0.5 .< acorrs .< 1.), :];
neigh = get_pairs(tmp_acorr, "n")

for p in neigh
	idx1, idx2 = p

	cc_mod = crosscor(tmp_acorr, idx1, idx2, filt=true)
	cc_unmod = crosscor(tmp_acorr, idx1, idx2, filt=false)
	cc_unmod_norm = (cc_unmod .- mean(cc_unmod)) ./ std(cc_unmod)
	cc_unmod_norm = (cc_unmod_norm .* std(cc_mod)) .+ mean(cc_mod)

	plot(cc_mod, lw=2, c=:orange, labels="during modulation", fill = min(cc_mod..., cc_unmod_norm...), fillalpha = 0.3, fillcolor=:grey)
	plot!(cc_unmod_norm, c=:black, lw=2, labels="during whole task", α=0.6)

	savefig(plotsdir("crosscor", "3b", "$idx1+$idx2"))
end

# 3C
tmp = data[acorrs .> 0.5, :];
size(tmp)

neigh = get_pairs(tmp, "n")
cc_n = mass_crosscor(tmp, neigh, around=[-200, 200])

cc_n_mean = mean(cc_n, dims=2)
cc_n_sem = sem(cc_n, dims=2)

closeall()
plot(cc_n_mean, c=:red, ribbon=cc_n_sem, fillalpha=0.3,  linewidth=3, label=false)
xticks!([1:10:81;],["$i" for i =-20:5:20])
title!("Pairs of neighboring cells")
xlabel!("Time (ms)")
ylabel!("Mean ± sem deviation")

# 3D
distant = get_pairs(tmp, "d")
cc_d = mass_crosscor(tmp, distant, around=[-200, 200])

cc_d_mean = mean(cc_d, dims=2)
cc_d_sem = sem(cc_d, dims=2)

closeall()
low = min((cc_n_mean.- cc_n_sem)...)
high = max((cc_n_mean.+ cc_n_sem)...)
plot(cc_d_mean, ylims=(low, high), c=:black, ribbon=cc_d_sem, fillalpha=0.3,  linewidth=3, label=false)
xticks!([1:10:81;],["$i" for i =-20:5:20])
title!("Pairs of distant cells")
xlabel!("Time (ms)")
ylabel!("Mean ± sem deviation")

# 3E
cc_n_mod = mass_crosscor(tmp, neigh, filt=false) 
cc_n_unmod = mass_crosscor(tmp, neigh, filt=false) 

cc_n_mod |> dropnancols |> normalize |> x->x[42:70, :] |> x->mean(x, dims=2) |> plot
cc_n_unmod |> dropnancols |> normalize |> x->x[42:70, :] |> x->mean(x, dims=2) |> plot!


# 3F
n = slice(tmp.t, tmp.lift, [-200, 200], :conv, :avg)
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
