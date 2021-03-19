using DrWatson
@quickactivate :ens

using JLD2
using RCall
using Random
using DataFrames

include(srcdir("spline", "spline-analysis.jl"))
include(srcdir("spline", "spline-utils.jl"))

#% Dist
dist = load(datadir("spline-data.jld2"), "dist");
dist_all = [sort.(dist); sort.(dist, rev=true)];
dist_idx = [d.index for d in dist_all]

multi_dist = load(datadir("spline",  "multi-dist.jld2"));
good_idx = parse.(Array{Int, 1}, keys(multi_dist))

df_dist = Dict()
foreach(good_idx) do i
	target = dist_all[[d == i for d in dist_idx]][1];
	df = mkdf(target, reference=:multi)
	df_dist[i] = R"uniformizedf($df, c('timeSinceLastSpike','previousIsi','tback','tforw','nearest'))" 
end;
@rput df_dist;
R"save(df_dist, file='data/spline/multi-dist.RData')"

#% Neigh
neigh = load(datadir("spline-data.jld2"), "neigh");
neigh_all = [sort.(neigh); sort.(neigh, rev=true)];
neigh_idx = [d.index for d in neigh_all]

multi_neigh = load(datadir("spline",  "multi-neigh.jld2"));
good_idx = parse.(Array{Int, 1}, keys(multi_neigh))

df_neigh = Dict()
foreach(good_idx) do i
	try
		target = neigh_all[[d == i for d in neigh_idx]][1];
		df = mkdf(target, reference=:multi)
		df_neigh[i] = R"uniformizedf($df, c('timeSinceLastSpike','previousIsi','tback','tforw','nearest'))" 
	catch e
		@show e
	end
end;
@rput df_neigh;
R"save(df_neigh, file='data/spline/multi-neigh.RData')"

#% Half neigh

df_half = Dict()
foreach(good_idx) do i
	try
		target = neigh_all[[d == i for d in neigh_idx]][1];
		df = mkdf(target, reference=:multi)
		idx = df.trial |> unique |> shuffle
		half = maximum(idx) ÷ 2
		df1 = df[in.(df.ntrial, Ref(idx[1:half+1])), :]
		df2 = df[in.(df.ntrial, Ref(idx[half+2:end])), :]
		m1 = R"uniformizedf($df1, c('timeSinceLastSpike','previousIsi','tback','tforw','nearest'))"
		m2 = R"uniformizedf($df2, c('timeSinceLastSpike','previousIsi','tback','tforw','nearest'))"
		df_half[i] = Dict("m1"=>m1, "m2"=>m2)
	catch e
		@show e
	end
end;
@rput df_half;
R"save(df_neigh, file='data/spline/multi-half.RData')"
