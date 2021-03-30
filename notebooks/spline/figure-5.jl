using DrWatson
@quickactivate :ens

using Plots
using Spikes
using Arrow
using CSV

include(srcdir("spline", "models_summaries.jl"))

inpath = "/home/ginko/ens/data/analyses/spline/batch-5/results/result.arrow"
result = Arrow.Table(inpath) |> DataFrame

ll_n = CSV.read(datadir("analyses/spline/batch-4-cluster/postprocessed",
						"likelihood-neigh.csv"), types=[Array{Int, 1}, Bool], DataFrame)
ll_d = CSV.read(datadir("analyses/spline/batch-4-cluster/postprocessed",
						"likelihood-dist.csv"), types=[Array{Int, 1}, Bool], DataFrame)
