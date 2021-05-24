using DrWatson
@quickactivate :ens

include(srcdir("spline", "model_summaries.jl"))

function ranges_counts(df; binsize = 0.001, tmax = 50.)
	counts = zeros(Int(tmax/binsize))
	timerange = 0:binsize:tmax-binsize
	for (i, v) in enumerate(timerange)
		counts[i] = sum([r[1] .< v .< r[2] for r in vcat(df.ranges...)])
	end
	counts_perc = counts ./ size(df, 1) .* 100.
	timerange, counts_perc
end

struct SplinePeaks
	batch::Int
	reference::String
end

function load(A::SplinePeaks)
	inpath_ll = "/home/ginko/ens/data/analyses/spline/ll-batch-7/results/result.arrow"
	inpath_n = "/home/ginko/ens/data/analyses/spline/batch-$(A.batch)/$(A.reference)-neigh/results/fit.arrow"
	inpath_d = "/home/ginko/ens/data/analyses/spline/batch-$(A.batch)/$(A.reference)-dist/results/fit.arrow"
	plots_path = "data/analyses/spline/batch-$(A.batch)/plots/"

	result_ll = Arrow.Table(inpath_ll) |> DataFrame
	result_n = Arrow.Table(inpath_n) |> DataFrame
	result_d = Arrow.Table(inpath_d) |> DataFrame

	# Select results
	ll_n = @where(result_ll, :reference .== A.reference, :group .== "neigh")
	ll_d = @where(result_ll, :reference .== A.reference, :group .== "dist")

	df_n = get_peaks(result_n, A.reference, "neigh")
	df_d = get_peaks(result_d , A.reference, "dist")

	best_model(df_n, ll_n), best_model(df_d, ll_d), ll_n, ll_d
end


function visualise(A::SplinePeaks, fig, r, plot_params)
	df_n, df_d, ll_n, ll_d = r


	a = Axis(fig, title = "Pairs of neighbor cells \n \nBest model")
	b = Axis(fig, title = "Peak cell interaction delay")
	c = Axis(fig, title = "Ranges of significant\n cell interaction delays")
	d = Axis(fig, title = "Pairs of distant Cells \n \nBest model")
	e = Axis(fig, title = "Peak cell interaction delay")
	f = Axis(fig, title = "Ranges of significant\n cell interaction delays")


	a.xticks = d.xticks = ([1, 2], ["Complex", "Simple"])
	b.xlabel = e.xlabel = "Time (ms)"
	c.xlabel = f.xlabel = "Time (ms)"
	a.ylabel = d.ylabel = "Count"
	b.ylabel = e.ylabel = "Density"
	c.ylabel = f.ylabel = "% of pairs with\nsignificant interaction"

	barplot!(a, [sum(ll_n.c_better), sum(.!ll_n.c_better)]; params...)
	barplot!(d, [sum(ll_d.c_better), sum(.!ll_d.c_better)]; params...)

	density!(b, df_n.peak; params...)
	density!(e, df_d.peak; params...)
	linkaxes!(b, e)

	lines!(c, ranges_counts(df_n, tmax=120))
	lines!(f, ranges_counts(df_d, tmax=120))
	linkaxes!(c, f)

	vlines!.([b, e, c, f], 10, linestyle = :dash)
	xlims!(b, -30, 120)

	a, b, c, d, e, f
end

