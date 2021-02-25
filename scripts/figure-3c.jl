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
thr = 2.5

#% mpsth and the timestamps of the bins for the respective spiketrain
# It has to be done on full data or the index of ranges would be messed up
mpsth, ranges = sectionTrial(data, pad, n, b1);

#% Active ranges for each trial TODO take care of inf and nan
active_ranges = []
for (spiketrain, rng) in zip(mpsth, ranges)
	push!(active_ranges, [x[y .> thr] for (x, y) = zip(rng, spiketrain)])
end

#% Merge neighbors active ranges, keeping trial separated
merge(r, c) = vcat.(r[c]...)
neigh = get_pairs(tmp, "n")

merged_neigh= merge.(Ref(active_ranges), neigh);

#%
neighbors = []
for (cell, rng) = zip(neigh, merged_neigh)
	for r in rng
		c1 = cut(df[df.index .== cell[1], :t]..., r) |> sort
		c2 = cut(df[df.index .== cell[2], :t]..., r) |> sort

		if !isempty(c1) && !isempty(c2)
			c3 = crosscor(c1, c2, true, binsize=binsize)

			fr1 = length(c1)/(max(c1...) - min(c1...)) |> x->round(x, digits=4)
			fr2 = length(c2)/(max(c2...) - min(c2...)) |> x->round(x, digits=4)

			if !isinf(fr1) && !isinf(fr2) 
				push!(neighbors, c3)
			end
		end
	end
end
#%

neighbors = hcat(neighbors...) |> drop

mean_neighbors = mean(neighbors, dims=2)[:]
sem_neighbors = sem(neighbors, dims=2)[:]

mean_neighbors[41:42] .= NaN 

plot(mean_neighbors, c=:red, ribbon=sem_neighbors, fillalpha=0.3,  linewidth=3, label=false)
xticks!([1:10:81;],["$i" for i =-20:5:20])
title!("Pairs of neighboring cells")
xlabel!("Time (ms)")
ylabel!("Mean ± sem deviation")
#%
# savefig(plotsdir("crosscor", "figure_3c"), "scripts/cross-correlogram.jl")
