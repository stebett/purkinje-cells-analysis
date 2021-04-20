using DrWatson
@quickactivate :ens

using DataFramesMeta
using StatsPlots; pyplot(size=(800,800))
using LaTeXStrings

include(srcdir("spline", "model_summaries.jl"))
include(srcdir("spline", "plots.jl"))


#' # Load results
batch=7
inpath = "/home/ginko/ens/data/analyses/spline/batch-$batch/results/result.arrow"
inpath_ll = "/home/ginko/ens/data/analyses/spline/ll-batch-$batch/results/result.arrow"
result = Arrow.Table(inpath) |> DataFrame
result_ll = Arrow.Table(inpath_ll) |> DataFrame;

ll_n = @where(result_ll, :reference .== "best", :group .== "neigh")
ll_d = @where(result_ll, :reference .== "best", :group .== "dist")

df_n = get_peaks(result, "best", "neigh")
df_d = get_peaks(result, "best", "dist")

n_better = best_model(df_n, ll_n)
d_better = best_model(df_d, ll_d);

logit_inv(η) = 1 / (1 + exp(-η))
logit_inv(η::Vector) = 1 ./ (1 .+ exp.(-η))

#' # Neighbors 
#+ fig_ext = ".svg"
@df n_better plot(:x, :mean,  xlims=(0, 201), ylims=(-1, 1), lab="")
scatter!(n_better.peak, [-0.2], lab="", c=:black, m=:vline)
hline!([0], lw=1.5, c=:black, s=:dash, lab="")
title!("Complex fit for couples of neighbor cells")
xlabel!("Time (ms)")
ylabel!("η")
lens!([1, 10], [-0.5, 0.5], inset = (1, bbox(0.5, 0.0, 0.4, 0.4)))

#' # Distant neurons
#+ fig_ext = ".svg"
@df d_better plot(:x, :mean, xlims=(0, 201), ylims=(-1, 1), lab="")
scatter!(d_better.peak, [-0.2], lab="", c=:black, m=:vline)
hline!([0], lw=1.5, c=:black, s=:dash, lab="")
title!("Complex fit for couples of distant cells")
xlabel!("Time (ms)")
ylabel!("η")
lens!([1, 10], [-0.25, 0.25], inset = (1, bbox(0.5, 0.0, 0.4, 0.4)))

#' # Distant neurons eta inverted
#+ fig_ext = ".svg"

d_better = @transform(d_better, inv_eta = logit_inv.(:mean))

@df d_better plot(:x, :inv_eta, xlims=(0, 201), ylims=(0, 1), lab="")
scatter!(d_better.peak, [0.45], lab="", c=:black, m=:vline)
hline!([0.5], lw=1.5, c=:black, s=:dash, lab="")
title!("Complex fit for couples of distant cells")
xlabel!("Time (ms)")
ylabel!(L"p = \frac{1}{1 + e^η}")
lens!([1, 10], [0.4, 0.6], inset = (1, bbox(0.5, 0.0, 0.4, 0.4)))

#' # Full picture
#+ fig_ext = ".svg"
SplinePlots.figure_5(df_n, df_d, ll_n, ll_d)

savefig(plotsdir("logbook", "07-04", "dist_eta_inverted.png"))
