using DrWatson
@quickactivate :ens

using JLD2
using DataFrames

indir = datadir("analyses", "spline", "batch-2/")
dist_good_idx = parse.(Array{Int, 1}, keys(load(indir * "multi-dist.jld2")))
neigh_good_idx = parse.(Array{Int, 1}, keys(load(indir * "multi-neigh.jld2")))
all_good_idx = parse.(Int, keys(load(indir * "multi-all.jld2")))

save(datadir("analyses", "spline", "cluster-inputs-2", "indexes.jld2"),
	 "dist", dist_good_idx,
	 "neigh", neigh_good_idx,
	 "all", all_good_idx)
