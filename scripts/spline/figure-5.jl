using DrWatson
@quickactivate :ens

using JLD2 
using Spikes
using KernelDensity
using Distributions
using Measures
using StatsBase
using DataFrames 

include(srcdir("spline", "spline-plots.jl"))

#% Plots
function figure_5A(ll, title)
	bar([sum(ll.c_better), sum(.!ll.c_better)], lab="")
	ylabel!("Counts")
	xticks!([1, 2], ["Complex", "Simple"])
end

function figure_5B(df)
	k = kde(df.peak, Normal(0, 0.2))
	dens = k.density[k.x .>= 0]
	x = k.x[k.x .>= 0]
	plot(x, dens, lw=1.5, lab="",  xscale=:log10)
	# scatter!(peaks, fill(0., size(df, 1)), m=:vline, c=:black, label="Peak position")
	ylabel!("Density")
	xlabel!("Time (ms)")
	title!("Peak cell interaction delay")
end

function figure_5C(df)
	binsize = 0.001
	tmax = 50.
	counts = zeros(Int(tmax/binsize))
	timerange = 0:binsize:tmax-binsize
	for (i, v) in enumerate(timerange)
		counts[i] = sum([r[1] .< v .< r[2] for r in vcat(df.ranges...)])
	end
	counts_perc = counts ./ size(df, 1) .* 100.
	plot(timerange, counts_perc, ylims=(0, 100), lab="")
	ylabel!("% of pairs with significant interactions")
	xlabel!("Time (ms)")
	title!("Ranges of significant\ncell interaction delays")
end

#%

A = figure_5A(ll_n, "Pairs of neighboring cells\n\nBest model")
D = figure_5A(ll_d, "Pairs of distant cells\n\nBest model")
B = figure_5B(n_better)
E = figure_5B(d_better)
C = figure_5C(n_better)
F = figure_5C(d_better)
F5 = plot(A, D, B, E, C, F, size=(1200, 1600), layout=(3, 2), margin=7mm)

savefig(plotsdir("logbook", "24-03", "figure-5-complete"), "scripts/spline/figure-5.jl")
