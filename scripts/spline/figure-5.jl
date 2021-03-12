using DrWatson
@quickactivate :ens

using JLD2 
using Spikes
using KernelDensity
using StatsBase

include(srcdir("spline", "spline-plots.jl"))
include(srcdir("spline", "spline-analysis.jl"))
include(srcdir("spline", "spline-utils.jl"))

@load datadir("spline", "simple-complex.jld2") results

#%
allnewx = [r.complex_nearest[:new_x] for (_, r) in results]
allestmean = [r.complex_nearest[:est_mean] for (_, r) in results]
allabove = [above(r.complex_nearest) for (_, r) in results] |> DataFrame

#% All interactions
scatter(allabove.m, fill(-1.5, length(allabove.m)), m=:vline, c=:black, label="Peak position")
plot!(allnewx, allestmean, label ="", xlims=(0, 15), palette=:viridis)
ylabel!("η")
xlabel!("Time (ms)")
title!("Complex models interaction delays")
# savefig(plotsdir("logbook", "all_interactions"), "scripts/spline.jl")

#% Figure 5B
k = kde(allabove.m, Normal(0, 0.1))
plot(k, lw=1.5, l="")
scatter!(allabove.m, fill(0., length(allabove.m)), m=:vline, c=:black, label="Peak position")
ylabel!("Density")
xlabel!("Time (ms)")
title!("Peak cell interaction delay")
# savefig(plotsdir("logbook", "peak_interactions"), "scripts/spline.jl")

#% Figure 5C
allranges = vcat([all_ranges_above(r.complex_nearest) for (_, r) in results]...)
binsize = 0.0001
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

#% Figure 5A
df = load(datadir("spline", "likelihood.csv")) |> DataFrame

transform!(df, [:simple1, :simple2, :complex1, :complex2] => 
		   ((s1, s2, c1, c2) -> (s1 .+ s2) .< (c1 .+ c2)) => :c_better)

bar([sum(df.c_better), sum(.!df.c_better)])
ylabel!("Counts")
xticks!([1, 2], ["Complex model", "Simple model"])
title!("Best model")
savefig(plotsdir("logbook", "11-03", "best-model"), "scripts/spline/figure-5.jl")

#% PSTH multi vs single

@load datadir("spline", "simple-complex-multi.jld2") result_multi

for (k, v) in result_multi
	p1 = plot_quick_prediction(v.simple_time)
	p2 = plot_quick_prediction(results[k].simple_time)
	plot(p1, p2, size=(900, 900))
	savefig("plots/logbook/12-03/psth-multi-vs-single/$k")
end


