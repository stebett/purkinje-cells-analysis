using DrWatson
@quickactivate :ens

using DataFramesMeta
using StatsPlots; pyplot(size=(800,800))
using LaTeXStrings
using Arrow

include(srcdir("spline", "model_summaries.jl"))
include(srcdir("spline", "plots.jl"))

function plots_details(p, peaks)
	p = scatter!(peaks, [-0.2], lab="", c=:black, m=:vline)
	p = hline!([0], lw=1.5, c=:black, s=:dash, lab="")
	p = xlabel!("Time (ms)")
	p = ylabel!("η")
end

# Load results
batch = 8
reference = "best"

batch = ARGS[1]
reference = ARGS[2]

inpath_ll = "/home/ginko/ens/data/analyses/spline/ll-batch-7/results/result.arrow"
inpath_n = "/home/ginko/ens/data/analyses/spline/batch-$batch/$reference-neigh/results/fit.arrow"
inpath_d = "/home/ginko/ens/data/analyses/spline/batch-$batch/$reference-dist/results/fit.arrow"
plots_path = "data/analyses/spline/batch-$batch/plots/"

result_ll = Arrow.Table(inpath_ll) |> DataFrame
result_n = Arrow.Table(inpath_n) |> DataFrame
result_d = Arrow.Table(inpath_d) |> DataFrame

# Select results
ll_n = @where(result_ll, :reference .== reference, :group .== "neigh")
ll_d = @where(result_ll, :reference .== reference, :group .== "dist")

df_n = get_peaks(result_n, reference, "neigh")
df_d = get_peaks(result_d , reference, "dist")

n_better = best_model(df_n, ll_n)
d_better = best_model(df_d, ll_d)

# Neighbors fits
pn = @df n_better plot(:x, :mean,  xlims=(0, 201), ylims=(-1, 1), lab="")
pn = plots_details(pn, n_better.peak)
pn = title!("Complex fit for couples of neighbor cells")
pn = lens!([1, 10], [-0.5, 0.5], inset = (1, bbox(0.5, 0.0, 0.4, 0.4)))
savefig(pn, plots_path * "fits-neigh.png")

# Distant fits
pd = @df d_better plot(:x, :mean, xlims=(0, 201), ylims=(-1, 1), lab="")
pd = plots_details(pd, d_better.peak)
pd = title!("Complex fit for couples of distant cells")
pd = lens!([1, 10], [-0.25, 0.25], inset = (1, bbox(0.5, 0.0, 0.4, 0.4)))
savefig(pd, plots_path * "fits-dist.png")

# Full picture
pf = SplinePlots.figure_5(n_better, d_better, ll_n, ll_d)
save(plots_path * "figure-5.png", pf)
