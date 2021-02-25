using DrWatson
@quickactivate :ens

using Statistics
using LinearAlgebra
using Plots; gr()
import StatsBase.sem

include(srcdir("plot", "cross-correlation.jl"))
include(srcdir("plot", "psth.jl"))

function sem(x::Matrix; dims=2)
	r = zeros(size(x, dims % 2 + 1)) 
	for i in 1 : length(r)
		r[i] = sem(x[i, :])
	end
	r
end

#<
tmp = data[data.p_acorr .< 0.2, :];
neigh = get_pairs(tmp, "n");
dist = get_pairs(tmp, "d");


#>

#< Heatmap 2 neurons
# R31 Block27 Tetrode2 C1 & C2 -> 437, 438
# findall((df.path .== "/import/bragi8/hygao/R31/data/Block27") .& (df.name .== "tet2.t1"))
idx1, idx2 = 437, 438

x = section(tmp[(tmp.index .== idx1), "t"], tmp[findall(tmp.index .== idx1), "cover"], [-400., 400.], binsize=.5) 
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



y = section(tmp[findall(tmp.index .== idx2), "t"], tmp[findall(tmp.index .== idx2), "cover"], [-400., 400.], binsize=.5) 
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

cc = crosscor.(x, y, binsize=0.5, :norm)
cc = sort_active(hcat(cc...), 10)
heatmap(cc')
#savefig(plotsdir("crosscor", "heatmap-couple"), "scripts/cross-correlogram.jl")


#>
#< Heatmap all couples

cc_n = crosscor(tmp, neigh, [-500., 500.], binsize=0.5, thr=2., :norm)
cc_n = sort_active(cc_n, 10)
psth(cc_n, 0., 13., "normalized cross-correlation")
xticks!([1, 41, 79], ["-20", "0", "20"])
xlabel!("Time (ms)")
ylabel!("Couples of neighboring neurons")

savefig(plotsdir("crosscor", "heatmap-small-acorr"), "scripts/cross-correlogram.jl")


#>

#< 3B
modulated = crosscor(tmp, [idx1, idx2], [-400., 400.], binsize=0.5, :filt, thr=2.)
unmodulated = crosscor(tmp, [idx1, idx2], [-2000., 2000.], binsize=0.5)
unmodulated ./= mean(unmodulated)
unmodulated .*= mean(modulated)


modulated[41] = NaN
unmodulated[41] = NaN

plot(modulated, lw=2, c=:orange, labels="during modulation", fill = -1, fillalpha = 0.2, fillcolor=:grey)
plot!(unmodulated, c=:black, lw=2, labels="during whole task", α=0.6)
xticks!([1:10:81;],["$i" for i =-20:5:20])
xlabel!("Time (ms)")
ylabel!("Count")
savefig(plotsdir("crosscor", "figure_3b"), "scripts/cross-correlogram.jl")
#>
#< 3C

merge(ranges, x) = Tuple{Float64, Float64}[ranges[x[1]]..., ranges[x[2]]...]

tmp = data;
pad = 1000.
num_bins = 6
b = 200
binsize=.5
n, r = sectionTrial(tmp, num_bins, pad, b, :mad);
todrop = drop(n, index=true) .* tmp.index
todrop = todrop[todrop .> 0]
ranges = get_active_ranges(tmp, num_bins=num_bins, pad=pad, b=b)
neigh = get_pairs(tmp, "n")
merged_ranges = merge.(Ref(ranges), neigh)

c = []
for (cell, bad, rng) = zip(neigh, todrop, merged_ranges)
	if cell[1] ∉ todrop && cell[2] ∉ todrop && !isempty(rng)
		c1 = vcat.(section.(Ref(tmp[tmp.index .== cell[1], :t]), Ref(tmp[tmp.index .== cell[1], :cover]), rng, binsize=binsize)...)
		c2 = vcat.(section.(Ref(tmp[tmp.index .== cell[2], :t]), Ref(tmp[tmp.index .== cell[2], :cover]), rng, binsize=binsize)...)
		c3 = crosscor.(c1, c2, true, binsize=binsize) |> x->hcat(x...) |> drop |> x->mean(x, dims=2)

		fr1 = hcat(c1...) |> drop |> mean
		fr2 = hcat(c2...) |> drop |> mean

		if fr1 >= 0.01 && fr2 >= 0.01
			push!(c, c3)
		end
	end
end

neighbors = hcat(c...) |> drop

mean_neighbors = mean(neighbors, dims=2)[:]
sem_neighbors = sem(neighbors, dims=2)[:]

mean_neighbors[41:42] .= NaN 

plot(mean_neighbors, c=:red, ribbon=sem_neighbors, fillalpha=0.3,  linewidth=3, label=false)
xticks!([1:10:81;],["$i" for i =-20:5:20])
title!("Pairs of neighboring cells")
xlabel!("Time (ms)")
ylabel!("Mean ± sem deviation")

#savefig(plotsdir("crosscor", "figure_3c"), "scripts/cross-correlogram.jl")

#>
#< 3D

distant = crosscor(tmp, dist, [-400., 400.], binsize=0.5, :filt, :preimp, thr=1.5) |> drop

mean_distant = mean(distant, dims=2)[:]
sem_distant = sem(distant, dims=2)[:]

plot!(mean_distant, c=:black, ribbon=sem_distant, fillalpha=0.3,  linewidth=3, label=false)
xticks!([1:10:81;],["$i" for i =-20:5:20])
title!("Pairs of distant cells")
xlabel!("Time (ms)")
ylabel!("Mean ± sem deviakion")
#savefig(plotsdir("crosscor", "figure_3d"), "scripts/cross-correlogram.jl")

#>
#< 3E
cc_n_mod = drop(mass_crosscor(tmp, neigh, filt=true, around=[-200., 200.]))
cc_n_unmod = drop(mass_crosscor(tmp, neigh, filt=false, around=[-200., 200.]))

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
#>
