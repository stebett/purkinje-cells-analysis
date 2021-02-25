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
merge(ranges, x) = Tuple{Float64, Float64}[ranges[x[1]]..., ranges[x[2]]...]

tmp = data;
pad = 1000.
num_bins = 6
b = 200
binsize=.5
n, r = sectionTrial(tmp, num_bins, pad, b, :mad);
todrop = drop(n, index=true) .* tmp.index
todrop = todrop[todrop .> 0]
ranges = get_active_ranges(tmp, num_bins=num_bins, pad=pad, b=b, thr=3.5)
neigh = get_pairs(tmp, "n")
merged_ranges = merge.(Ref(ranges), neigh)

#%
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
#%
# savefig(plotsdir("crosscor", "figure_3c"), "scripts/cross-correlogram.jl")
