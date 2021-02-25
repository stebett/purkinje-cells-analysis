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

merged_ranges = merge.(Ref(active_ranges), neigh);

#%
diff(x::Tuple) = floor(Int, x[2] - x[1])

c = []
c3 = []
for (cell, rng) = zip(neigh, merged_ranges)
	for r in rng
		c1 = cut(tmp[tmp.index .== cell[1], :t]..., r)
		c2 = cut(tmp[tmp.index .== cell[2], :t]..., r)
		c3 = crosscor(c1, c2, false, binsize=binsize)
	end

	# fr1 = hcat(c1...) |> drop |> mean
	# fr2 = hcat(c2...) |> drop |> mean

	# if fr1 >= 0.01 && fr2 >= 0.01
	push!(c, c3)
	# end
end
#%

neighbors = hcat(c...) |> drop

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
