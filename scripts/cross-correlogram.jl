using DrWatson
@quickactivate :ens

using Statistics
using LinearAlgebra
using Plots; gr()
import StatsBase.sem

include(srcdir("plots", "cross-correlation.jl"))
include(srcdir("plots", "psth.jl"))
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

n = hcat(section(tmp.t, tmp.cover, [-50, 50], :norm, :avg)...);
active = tmp[findall(sum(n .> 0.75, dims=1)[:] .> 1), :];
active_neigh = get_pairs(active, "n")


#>

#< Heatmap 2 neurons
# R31 Block27 Tetrode2 C1 & C2 -> 437, 438
idx1, idx2 = active_neigh[2]
idx1, idx2 = 437, 438

tmp = data;

x = section(tmp[findall(tmp.index .== idx1), "t"], tmp[findall(tmp.index .== idx1), "cover"], [-400, 400], binsize=.5) 
c1 = sort_active(hcat(x...), 10)
heatmap(c1', c=:grays, cbar=false)
xticks!([0, 800, 1595], ["-400", "0", "400"])
title!("Spiketrain 437")
xlabel!("Time (ms)")
p1 = ylabel!("Trials")
x_fr = section(tmp[findall(tmp.index .== idx1), "t"], tmp[findall(tmp.index .== idx1), "cover"], [-400, 400], binsize=.5, :conv, :avg) 
plot(x_fr, legend=false)
ylabel!("Firing rate")
p2= xticks!([0, 800, 1595], ["-400", "0", "400"])



y = section(tmp[findall(tmp.index .== idx2), "t"], tmp[findall(tmp.index .== idx2), "cover"], [-400, 400], binsize=.5) 
c2 = sort_active(hcat(y...), 10)
heatmap(c2', c=:grays, cbar=false)
xticks!([0, 800, 1595], ["-400", "0", "400"])
title!("Spiketrain 438")
p3 = xlabel!("Time (ms)")
y_fr = section(tmp[findall(tmp.index .== idx2), "t"], tmp[findall(tmp.index .== idx2), "cover"], [-400, 400], binsize=.5, :conv, :avg) 
plot(y_fr, legend=false)
p4= xticks!([0, 800, 1595], ["-400", "0", "400"])
plot(p1, p3, p2, p4, layout = @layout [ a b ; c d ])
savefig(plotsdir("crosscor", "Figure 3A"), "scripts/cross-correlogram.jl")


heatmap(hcat(crosscor_custom.(x, y)...)')
#savefig(plotsdir("crosscor", "heatmap-couple"), "scripts/cross-correlogram.jl")

#>
#< Heatmap all couples

tmp = data;
tmp = data[acorrs .< 0.2, :];
neigh = get_pairs(tmp, "n")

cc_n = mass_crosscor(tmp, neigh, around=[-500, 500], thr=2.)
cc_n = (cc_n .- mean(cc_n, dims=1)) ./ std(cc_n, dims=1)
cc_n = sort_active(cc_n, 10)
psth(cc_n, -1.5, 1.8, "normalized cross-correlation")
xticks!([1, 41, 79], ["-20", "0", "20"])
xlabel!("Time (ms)")
ylabel!("Couples of neighboring neurons")

savefig(plotsdir("crosscor", "heatmap-small-acorr"), "scripts/cross-correlogram.jl")


#>

#< 3B

cc_mod = crosscor(tmp, idx1, idx2, filt=true)
cc_unmod = crosscor(tmp, idx1, idx2, around=[-2000, 2000], filt=false)
cc_unmod_norm = (cc_unmod ./ mean(cc_unmod)) .* mean(cc_mod)  # TODO

cc_mod[41] = NaN
cc_unmod_norm[41] = NaN

plot(cc_mod, lw=2, c=:orange, labels="during modulation", fill = -1, fillalpha = 0.2, fillcolor=:grey)
plot!(cc_unmod_norm, c=:black, lw=2, labels="during whole task", α=0.6)
xticks!([1:10:81;],["$i" for i =-20:5:20])
xlabel!("Time (ms)")
ylabel!("Count")
savefig(plotsdir("crosscor", "figure_3b"), "scripts/cross-correlogram.jl")
#>
#< 3C

cc_n = mass_crosscor(tmp, neigh, around=[-500, 500], thr=2.)

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
#savefig(plotsdir("crosscor", "figure_3c"), "scripts/cross-correlogram.jl")

#>
#< 3D

cc_d = mass_crosscor(tmp, distant, around=[-400, 400])

cc_d_mean = mean(cc_d, dims=2)
cc_d_mean_norm = cc_d_mean .- mean(cc_d_mean)
cc_d_sem = sem(cc_d, dims=2)

plot(cc_d_mean_norm, c=:black, ribbon=cc_d_sem, fillalpha=0.3,  linewidth=3, label=false)
xticks!([1:10:81;],["$i" for i =-20:5:20])
title!("Pairs of distant cells")
xlabel!("Time (ms)")
ylabel!("Mean ± sem deviakion")
#savefig(plotsdir("crosscor", "figure_3d"), "scripts/cross-correlogram.jl")

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
#savefig(plotsdir("crosscor", "figure_3e"), "scripts/cross-correlogram.jl")


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
plot!(x)
#>
