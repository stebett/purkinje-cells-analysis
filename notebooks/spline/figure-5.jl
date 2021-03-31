using DrWatson
@quickactivate :ens

using JLD2 
using Spikes
using Arrow
using CSV
using StatsPlots; pyplot(size=(800,800))

include(srcdir("spline", "model_summaries.jl"))
include(srcdir("spline", "plots.jl"))

#' # Load results
batch=7
inpath = "/home/ginko/ens/data/analyses/spline/batch-$batch/results/result.arrow"
result = Arrow.Table(inpath) |> DataFrame;
ll_n = CSV.read(datadir("analyses/spline/batch-4/postprocessed",
						"likelihood-neigh.csv"), types=[Array{Int, 1}, Bool], DataFrame);
ll_d = CSV.read(datadir("analyses/spline/batch-4/postprocessed",
						"likelihood-dist.csv"), types=[Array{Int, 1}, Bool], DataFrame);


df_n = get_peaks(result, "multi", "neigh");
df_d = get_peaks(result, "multi", "dist");
n_better = df_n[in.(df_n.index, Ref(ll_n[ll_n.c_better .== true, :index])), :];
d_better = df_d[in.(df_d.index, Ref(ll_d[ll_d.c_better .== true, :index])), :];

#' # Neighbors 
#+ fig_ext = ".svg"
plot(n_better.x, ribbon=n_better.sd, fillalpha=0.05, n_better.mean,  xlims=(0, 40), legend=false)
hline!([0], lw=1.5, c=:black, s=:dash)

#' # Distant neurons
#+ fig_ext = ".svg"
plot(d_better.x, ribbon=d_better.sd, fillalpha=0.05, d_better.mean,  xlims=(0, 40), legend=false)
hline!([0], lw=1.5, c=:black, s=:dash)

#' # Full picture
#+ fig_ext = ".svg"
figure_5(n_better, d_better, ll_n, ll_d)

# savefig(plotsdir("logbook", "24-03", "figure-5-fixed"), "scripts/spline/figure-5.jl")
