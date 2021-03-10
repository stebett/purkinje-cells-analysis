using DrWatson
@quickactivate :ens

using JLD2 
using Spikes
using RCall
using StatsBase

include(srcdir("spline-plots.jl"))

results_ = load("data/spline/gssmodels.jld2", "results")

function above(x::Dict)
	y = x[:est_mean] .- x[:est_sd] .> 0
	indexes = rangeT(y)
	long_i = indexes[argmax(diff.(indexes))]
	t = x[:new_x][long_i[1]:long_i[2]]
	peak_m = t[argmax(x[:est_mean][long_i[1]:long_i[2]])]
	peak_sd = argmax(x[:est_sd][long_i[1]:long_i[2]])
	peak_t = extrema(t)
	(t=peak_t, m=peak_m, sd=peak_sd)
end

function all_ranges_above(x::Dict)
	y = x[:est_mean] .- x[:est_sd] .> 0
	indexes = rangeT(y)
	[(x[:new_x][i[1]], x[:new_x][i[2]]) for i in indexes]
 end



function rangeT(y::BitArray{1})
	ranges = []
	find_start = true
	start = NaN
	finish = NaN
	for (i, v) in enumerate(y)
		if find_start
			if v 
				start = i
				find_start = false
			end
		else
			if !v
				finish = i-1
				push!(ranges, (start, finish))
				find_start = true
			end
		end
	end
	ranges
end
		




allnewx = [r.complex_nearest[:new_x] for (_, r) in results]
allestmean = [r.complex_nearest[:est_mean] for (_, r) in results]
allabove = [above(r.complex_nearest) for (_, r) in results] |> DataFrame

scatter(allabove.m, fill(-1.5, length(allabove.m)), m=:vline, c=:black, label="Peak position")
plot!(allnewx, allestmean, label ="", xlims=(0, 15), palette=:viridis)
ylabel!("η")
xlabel!("Time (ms)")
title!("Complex models interaction delays")
# savefig(plotsdir("logbook", "all_interactions"), "scripts/spline.jl")

k = kde(allabove.m, Normal(0, 0.1))
plot(k, lw=1.5, l="")
scatter!(allabove.m, fill(0., length(allabove.m)), m=:vline, c=:black, label="Peak position")
ylabel!("Density")
xlabel!("Time (ms)")
title!("Peak cell interaction delay")
# savefig(plotsdir("logbook", "peak_interactions"), "scripts/spline.jl")

allranges = vcat([all_ranges_above(r.complex_nearest) for (_, r) in results]...)

binsize = 0.01
tmax = 50.
counts = zeros(Int(tmax/binsize))
timerange = 0:binsize:tmax-binsize
for (i, v) in enumerate(timerange)
	counts[i] = sum([r[1] .< v .< r[2] for r in allranges]) 
end

counts_perc = counts ./ length(results) .* 100.
plot(timerange, counts_perc)
ylabel!("% of pairs with significant interactions")
xlabel!("Time (ms)")
title!("Ranges of significant\ncell interaction delays")
# savefig(plotsdir("logbook", "interaction_ranges"), "scripts/spline.jl")
