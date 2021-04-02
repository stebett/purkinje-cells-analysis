using DrWatson
@quickactivate :ens

using JLD2 
using Spikes
using Arrow
using CSV
using DataFramesMeta
using StatsPlots; pyplot(size=(800,800))

includet(srcdir("spline", "model_summaries.jl"))
includet(srcdir("spline", "plots.jl"))

#' # Load results
batch=7
inpath = "/home/ginko/ens/data/analyses/spline/batch-$batch/results/result.arrow"
inpath_ll = "/home/ginko/ens/data/analyses/spline/ll-batch-$batch/results/result.arrow"
result = Arrow.Table(inpath) |> DataFrame;
result_ll = Arrow.Table(inpath_ll) |> DataFrame;

df_n = get_peaks(result, "best", "neigh");
df_d = get_peaks(result, "best", "dist");
ll_n = @where(result_ll, :reference .== "best", :group .== "neigh")
ll_d = @where(result_ll, :reference .== "best", :group .== "dist")
n_better = df_n[in.(df_n.index, Ref(ll_n[ll_n.c_better .== true, :index])), :];
d_better = df_d[in.(df_d.index, Ref(ll_d[ll_d.c_better .== true, :index])), :];

#' # Neighbors 
#+ fig_ext = ".svg"
plot(n_better.x - n_better.sd, fillalpha=0.05, n_better.mean,  xlims=(0, 40), ylims=(-1,1), legend=false)
hline!([0], lw=1.5, c=:black, s=:dash)

#' # Distant neurons
#+ fig_ext = ".svg"
@df d_better plot(:x, :mean,  xlims=(0, 40), labels=reshape(:index, (1, :)))
hline!([0], lw=1.5, c=:black, s=:dash, label="")

#' # Full picture
#+ fig_ext = ".svg"
figure_5(n_better, d_better, ll_n, ll_d)

# savefig(plotsdir("logbook", "24-03", "figure-5-fixed"), "scripts/spline/figure-5.jl")
