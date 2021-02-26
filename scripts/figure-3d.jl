using DrWatson
@quickactivate :ens

#%
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

#%
tmp = data[data.p_acorr .< 0.2, :];

pad = 1000
n = 6
b1 = 50
binsize=.5
thr = 10.5

mpsth, ranges = sectionTrial(tmp, pad, n, b1);

active_trials = get_active_trials(mpsth, ranges, thr);
active_ranges = merge_trials(tmp, active_trials)

#% Merge distant active ranges
dist = get_pairs(tmp, "d")
active_dist = Dict()

for c in dist
	active_dist[c] = vcat(active_ranges[c[1]]..., active_ranges[c[2]])
end

#%
distant = []
for cell = dist
	c1 = cut(tmp[tmp.index .== cell[1], :t]..., active_dist[cell]) |> sort
	c2 = cut(tmp[tmp.index .== cell[2], :t]..., active_dist[cell]) |> sort
	c3 = crosscor(c1, c2, true, binsize=binsize)
	push!(distant, c3)
end
#%

distant_ = hcat(distant...) |> drop
mean_distant = mean(distant_, dims=2)[:]
sem_distant = sem(distant_, dims=2)[:]

plot!(mean_distant, c=:black, ribbon=sem_distant, fillalpha=0.3,  linewidth=3, label=false)
xticks!([1:10:81;],["$i" for i =-20:5:20])
title!("Pairs of distant cells")
xlabel!("Time (ms)")
ylabel!("Mean ± sem deviation")
#%
# savefig(plotsdir("crosscor", "figure_3d"), "scripts/figure-3d.jl")
