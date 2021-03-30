using DrWatson
@quickactivate :ens

using KernelDensity
using Measures
using Distributions
using StatsBase; plotly()
using DataFrames 


function plot_quick_prediction(x, title="")
	plot(x[:est_mean], ribbon=x[:est_sd])
	interval = 1:length(x[:new_x])÷10:length(x[:new_x])
	if x[:include] == "timetoevt"
		xticks!(searchsortedfirst.(Ref(x[:new_x]), [2, 3, 4]), ["lift", "cover", "grasp"])
	else
		xticks!(interval, ["$(round(x[:new_x][i], digits=2))" for i in interval])
	end
	xlabel!(x[:include])
	ylabel!("η")
	title!(string(title))
end

function plot_single_result(x::NamedTuple)
	p = []
	for (k, v) in zip(keys(x), x)
		push!(p, plot_quick_prediction(v, k))
	end
	p3 = plot(framestyle=:none)
	l = @layout [a b c; c d e]
	plot(p[1], p[2], p3, p[3], p[4], p[5], layout=l, size=(1800, 1200), margin=5mm)
end

function figure_5A(ll, title)
	bar([sum(ll.c_better), sum(.!ll.c_better)], lab="")
	ylabel!("Counts")
	xticks!([1, 2], ["Complex", "Simple"])
	title!(title)
end

function figure_5B(df)
	k = kde(df.peak, Normal(0, 0.2))
	dens = k.density[k.x .>= 0]
	x = k.x[k.x .>= 0]
	peaks = df.peak
	peaks[peaks .<= 0] .= 0.1
	plot(x, dens, lw=1.5, lab="",  xscale=:log10)
	scatter!(peaks, fill(0., size(df, 1)), m=:vline, c=:black, label="Peak position")
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

function figure_5(n, d, ll_n, ll_d)
	A = figure_5A(ll_n, "Pairs of neighboring cells\n\nBest model")
	D = figure_5A(ll_d, "Pairs of distant cells\n\nBest model")
	B = figure_5B(n)
	E = figure_5B(d)
	C = figure_5C(n)
	F = figure_5C(d)
	plot(A, D, B, E, C, F, size=(1200, 1600), layout=(3, 2), margin=7mm)
end
