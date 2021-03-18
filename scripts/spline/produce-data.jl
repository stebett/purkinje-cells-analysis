using DrWatson
@quickactivate :ens

using JLD2
using RCall
using Random
using DataFrames

include(srcdir("spline", "spline-analysis.jl"))
include(srcdir("spline", "spline-utils.jl"))

dist = load(datadir("spline-data.jld2"), "dist");

multi_dist = load(datadir("spline",  "multi-dist.jld2"));
good_idx = parse.(Array{Int, 1}, keys(multi_dist))

good_dist = DataFrame[]
foreach(x->(x.index ∉ good_idx ? push!(good_dist, x) : nothing), dist)

dfs = Dict()
foreach(good_dist) do x
	try
		dfs[x.index] = mkdf(x)
	catch e
		@show e
	end
end;
