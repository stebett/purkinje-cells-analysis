using DrWatson
@quickactivate :ens

using JLD2
using RCall
using Random
using DataFrames

include(srcdir("spline", "spline-analysis.jl"))
include(srcdir("spline", "spline-utils.jl"))

name="dist"
#% Dist

function produce_data(name::String)
	data = load(datadir("spline-data.jld2"), name);
	data = [sort.(data); sort.(data, rev=true)];
	idx = [d.index for d in data]
	good_idx = parse.(Array{Int, 1}, keys(load(datadir("spline",  "multi-$name.jld2"))))
	m = Dict()
	foreach(good_idx) do i
		target = data[[d == i for d in idx]][1];
		tmp = mkdf(target, reference=:multi)
		try
			m[i] = R"uniformizedf($tmp, c('timeSinceLastSpike','previousIsi','tback','tforw','nearest'))" 
		catch e
			@warn "Index: $i"
			@warn "There has been an error during uniformization:\n$e"
		end
	end;
	m
end

multi_dist = produce_data("dist");
@rput multi_dist;
R"save(multi_dist, file='data/spline/cluster-input/multi-dist.RData')"

multi_neigh = produce_data("neigh");
@rput multi_neigh;
R"save(multi_neigh, file='data/spline/cluster-input/multi-neigh.RData')"

#% Half neigh
neigh = load(datadir("spline-data.jld2"), "neigh");
neigh_all = [sort.(neigh); sort.(neigh, rev=true)];
neigh_idx = [d.index for d in neigh_all]

multi_neigh = load(datadir("spline",  "multi-neigh.jld2"));
good_idx = parse.(Array{Int, 1}, keys(multi_neigh))

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
R"save(df_half, file='data/spline/cluster-input/multi-half-neigh.RData')"

#% Half dist
dist = load(datadir("spline-data.jld2"), "dist");
dist_all = [sort.(dist); sort.(dist, rev=true)];
dist_idx = [d.index for d in dist_all]

multi_dist = load(datadir("spline",  "multi-dist.jld2"));
good_idx = parse.(Array{Int, 1}, keys(multi_dist))

df_half_dist = Dict()
foreach(good_idx) do i
	try
		target = dist_all[[d == i for d in dist_idx]][1];
		df = mkdf(target, reference=:multi)
		idx = df.trial |> unique |> shuffle
		half = maximum(idx) ÷ 2
		df1 = df[in.(df.ntrial, Ref(idx[1:half+1])), :]
		df2 = df[in.(df.ntrial, Ref(idx[half+2:end])), :]
		m1 = R"uniformizedf($df1, c('timeSinceLastSpike','previousIsi','tback','tforw','nearest'))"
		m2 = R"uniformizedf($df2, c('timeSinceLastSpike','previousIsi','tback','tforw','nearest'))"
		df_half_dist[i] = Dict("m1"=>m1, "m2"=>m2)
	catch e
		@show e
	end
end;
@rput df_half_dist;
R"save(df_half_dist, file='data/spline/cluster-input/multi-half-dist.RData')"
