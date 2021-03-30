using DrWatson
@quickactivate :ens

using JLD2 
using Spikes
using Arrow

include(srcdir("spline", "plots.jl"))
# include(srcdir("spline", "utils.jl"))

batch=6
inpath = "/home/ginko/ens/data/analyses/spline/batch-$batch/results/result.arrow"

result = Arrow.Table(inpath) |> DataFrame

ll_n = CSV.read(datadir("analyses/spline/batch-4/postprocessed",
						"likelihood-neigh.csv"), types=[Array{Int, 1}, Bool], DataFrame)
ll_d = CSV.read(datadir("analyses/spline/batch-4/postprocessed",
						"likelihood-dist.csv"), types=[Array{Int, 1}, Bool], DataFrame)


df_n = get_peaks(result, "multi", "neigh")
df_d = get_peaks(result, "multi", "dist")
n_better = df_n[in.(df_n.index, Ref(ll_n[ll_n.c_better .== 1, :index])), :]
d_better = df_d[in.(df_d.index, Ref(ll_d[ll_d.c_better .== 1, :index])), :]

plot(n_better.x - 2n_better.sd, n_better.mean,  xlims=(0, 100), legend=false)
hline!([0], lw=3, c=:black)

figure_5(n_better, d_better, ll_n, ll_d)

savefig(plotsdir("logbook", "24-03", "figure-5-fixed"), "scripts/spline/figure-5.jl")
