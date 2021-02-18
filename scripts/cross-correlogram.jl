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

#<
acorrs = data_full[:, :p_acorr] 
tmp = data[acorrs .< 0.2, :];
neigh = get_pairs(tmp, "n")
distant = get_pairs(tmp, "d")

n = hcat(section(tmp.t, tmp.cover, [-50, 50], :norm, :avg)...)
findall(sum(n .> 1., dims=1) .> 1)
#>

#< Heatmap
idx1, idx2 = 29, 30

x = section(tmp[idx1, "t"], tmp[idx1, "cover"], [-400, 400], binsize=.5) 
y = section(tmp[idx2, "t"], tmp[idx2, "cover"], [-400, 400], binsize=.5) 

heatmap(hcat(crosscor_custom.(x, y)...)')
savefig(plotsdir("crosscor", "heatmap"), "scripts/cross-correlogram.jl")

#>

#< 3B

cc_mod = crosscor(tmp, idx1, idx2, filt=true)
cc_unmod = crosscor(tmp, idx1, idx2, around=[-800, 800], filt=false)
cc_unmod_norm = (cc_unmod ./ mean(cc_unmod)) .* mean(cc_mod)  # TODO

cc_mod[41] = NaN
cc_unmod_norm[41] = NaN

plot(cc_mod, lw=2, c=:orange, labels="during modulation", fill = min(drop(cc_mod)..., drop(cc_unmod_norm)...), fillalpha = 0.2, fillcolor=:grey)
plot!(cc_unmod_norm, c=:black, lw=2, labels="during whole task", α=0.6)
xticks!([1:10:81;],["$i" for i =-20:5:20])
xlabel!("Time (ms)")
ylabel!("Count")
savefig(plotsdir("crosscor", "figure_3b"), "scripts/cross-correlogram.jl")
#>
#< 3C

cc_n = mass_crosscor(tmp, neigh, around=[-200, 200], thr=2.)

cc_n_mean = mean(cc_n, dims=2)[:]
cc_n_sem = sem(cc_n, dims=2)[:]

cc_n_mean[40:41] .= NaN 
cc_n_sem[40:41] .= NaN 

cc_n_mean_norm = cc_n_mean .- mean(drop(cc_n_mean))

closeall()
plot(cc_n_mean_norm, c=:red, ribbon=cc_n_sem, fillalpha=0.3,  linewidth=3, label=false)
xticks!([1:10:81;],["$i" for i =-20:5:20])
title!("Pairs of neighboring cells")
xlabel!("Time (ms)")
ylabel!("Mean ± sem deviation")
savefig(plotsdir("crosscor", "figure_3c"), "scripts/cross-correlogram.jl")

#>
#< 3D

cc_d = mass_crosscor(tmp, distant, around=[-400, 400])

cc_d_mean = mean(cc_d, dims=2)
cc_d_mean_norm = cc_d_mean ./ mean(cc_d_mean)
cc_d_sem = sem(cc_d, dims=2)

low = min(drop(cc_n_mean.- cc_n_sem)...)
high = max(drop(cc_n_mean.+ cc_n_sem)...)
plot(cc_d_mean, ylims=(low, high), c=:black, ribbon=cc_d_sem, fillalpha=0.3,  linewidth=3, label=false)
xticks!([1:10:81;],["$i" for i =-20:5:20])
title!("Pairs of distant cells")
xlabel!("Time (ms)")
ylabel!("Mean ± sem deviakion")
savefig(plotsdir("crosscor", "figure_3d"), "scripts/cross-correlogram.jl")

#>
#< 3E
cc_n_mod = mass_crosscor(tmp, neigh, filt=true, around=[-200, 200]) 
cc_n_unmod = mass_crosscor(tmp, neigh, filt=false, around=[-200, 200]) 

σ = 1
x = reverse(cc_n_mod[1:40, :], dims=1) .+ cc_n_mod[41:end-1, :]
# x = drop((x .- mean(x, dims=1)) ./ std(x, dims=1))
x = x ./ mean(x) 
x = mean(drop(x), dims=2)
xs = copy(x)[1+2σ:end-2σ]
x = convolve(x[:], σ)

y = reverse(cc_n_unmod[1:40, :], dims=1) .+ cc_n_unmod[41:end-1, :]
# y = drop((y .- mean(y, dims=1)) ./ std(y, dims=1))
y = y ./ mean(y)
y = mean(drop(y), dims=2)
y = convolve(y[:], σ)

plot([2:length(x)+1;], x, lw=2.5, c=:red, xlims=(0, 25), label="during modulation (smoothed)")
plot!([2:length(y)+1;], y, lw=2.5, c=:black, label="during whole task")
scatter!(2:length(xs)+1, xs, c=:black, label="modulation")
vline!([10], line = (1, :dash, :black), lab="")
hline!([1], line = (1, :dash, :black), lab="")
xticks!([0:4:24;], ["$i" for i = 0:2:12])
title!("Pairs of neighboring cells")
ylabel!("Average normalized cross-correlogram")
xlabel!("Time (ms)")



#>
#< 3F
n = section(tmp.t, tmp.lift, [-200, 200], :conv, :avg)
cors = [cor(n[x[1]], n[x[2]]) for x in neigh]

fr_sim = findall(cors .> 0.2)
fr_diff = findall(cors .<= 0.2)

tmp_sim = tmp[fr_sim, :];
tmp_diff = tmp[fr_diff, :];

neigh_sim = get_pairs(tmp_sim, "n")
neigh_diff = get_pairs(tmp_diff, "n")

cc_sim = mass_crosscor(tmp_sim, neigh_sim)
cc_diff = mass_crosscor(tmp_diff, neigh_diff)

x = reverse(cc_sim[1:40, :], dims=1) .+ cc_sim[41:end-1, :]
# x = drop((x .- mean(x, dims=1)) ./ std(x, dims=1))
x = x ./ mean(x) 
x = mean(drop(x), dims=2)
x = convolve(x[:], σ)
plot(x)

x = reverse(cc_diff[1:40, :], dims=1) .+ cc_diff[41:end-1, :]
# x = drop((x .- mean(x, dims=1)) ./ std(x, dims=1))
x = x ./ mean(x) 
x = mean(drop(x), dims=2)
x = convolve(x[:], σ)
plot(x)
#>
