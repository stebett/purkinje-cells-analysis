using DrWatson
@quickactivate :ens

using Statistics
using LinearAlgebra
using Plots; gr()
import StatsBase.sem

include(srcdir("cross-correlation.jl"))
include(scriptsdir("io", "load-full.jl"))

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

idx1, idx2 = 162, 163
for p in neigh
	idx1, idx2 = p

	closeall()
	cc_mod = crosscor(tmp_acorr, idx1, idx2, filt=true)
	cc_unmod = crosscor(tmp_acorr, idx1, idx2, around=[-400, 400], filt=false)
	cc_unmod_norm = (cc_unmod .- mean(cc_unmod)) ./ std(cc_unmod)
	cc_unmod_norm = (cc_unmod_norm .* std(cc_mod)) .+ mean(cc_mod)

	cc_mod[40:41] .= NaN
	cc_unmod_norm[40:41] .= NaN

	plot(cc_mod, lw=2, c=:orange, labels="during modulation", fill = min(drop(cc_mod)..., drop(cc_unmod_norm)...), fillalpha = 0.2, fillcolor=:grey)
	plot!(cc_unmod_norm, c=:black, lw=2, labels="during whole task", α=0.6)
	xticks!([1:10:81;],["$i" for i =-20:5:20])
	xlabel!("Time (ms)")
	ylabel!("Count")

	savefig(plotsdir("crosscor", "3b", "$idx1+$idx2"))
end

# 3C
tmp = data[acorrs .> 0.5, :];
size(tmp)

neigh = get_pairs(tmp, "n")
cc_n = mass_crosscor(tmp, neigh, around=[-400, 400])

cc_n_mean = mean(cc_n, dims=2)[:]
cc_n_sem = sem(cc_n, dims=2)[:]

cc_n_mean[40:41] .= NaN 
cc_n_sem[40:41] .= NaN 

closeall()
plot(cc_n_mean, c=:red, ribbon=cc_n_sem, fillalpha=0.3,  linewidth=3, label=false)
xticks!([1:10:81;],["$i" for i =-20:5:20])
title!("Pairs of neighboring cells")
xlabel!("Time (ms)")
ylabel!("Mean ± sem deviation")

# 3D
distant = get_pairs(tmp, "d")
cc_d = mass_crosscor(tmp, distant, around=[-400, 400])

cc_d_mean = mean(cc_d, dims=2)
cc_d_sem = sem(cc_d, dims=2)

closeall()
low = min(drop(cc_n_mean.- cc_n_sem)...)
high = max(drop(cc_n_mean.+ cc_n_sem)...)
plot(cc_d_mean, ylims=(low, high), c=:black, ribbon=cc_d_sem, fillalpha=0.3,  linewidth=3, label=false)
xticks!([1:10:81;],["$i" for i =-20:5:20])
title!("Pairs of distant cells")
xlabel!("Time (ms)")
ylabel!("Mean ± sem deviakion")

# 3E
cc_n_mod = mass_crosscor(tmp, neigh, filt=true) 
cc_n_unmod = mass_crosscor(tmp, neigh, filt=false) 

σ = 1
x = reverse(cc_n_mod[1:40, :], dims=1) .+ cc_n_mod[41:end, :]
# x = drop((x .- mean(x, dims=1)) ./ std(x, dims=1))
x = x .- mean(x, dims=1) 
x = mean(x, dims=2)
xs = copy(x)[1+2σ:end-2σ]
x = convolve(x[:], σ)

y = reverse(cc_n_unmod[1:40, :], dims=1) .+ cc_n_unmod[41:end, :]
# y = drop((y .- mean(y, dims=1)) ./ std(y, dims=1))
y = y .- mean(y, dims=1)
y = mean(y, dims=2)
y = convolve(y[:], σ)

closeall()
plot([2:length(x)+1;], x, xlims=(0, 24), label="during modulation (smoothed)")
plot!([2:length(y)+1;], y, label="during whole task")
scatter!(2:length(xs)+1, xs, c=:black, label="modulation")
vline!([10], line = (1, :dash, :black), lab="")
hline!([0], line = (1, :dash, :black), lab="")
xticks!([0:4:24;], ["$i" for i = 0:2:12])



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

cc_sim normalize |> x->x[42:70, :] |> x->mean(x, dims=2) |> plot
cc_diff |> normalize |> x->x[42:70, :] |> x->mean(x, dims=2) |> plot!
