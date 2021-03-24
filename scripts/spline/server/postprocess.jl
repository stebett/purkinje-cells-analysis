using DrWatson
@quickactivate :ens

using JLD2 

include(srcdir("spline", "spline-plots.jl"))
include(srcdir("spline", "spline-analysis.jl"))
include(srcdir("spline", "spline-utils.jl"))

R"""
load('data/analyses/spline/batch-4-cluster/neigh/out/multi-neigh-res.RData')
load('data/analyses/spline/batch-4-cluster/neigh/in/multi-neigh.RData')
res = result_multi_neigh
res_clean=apply(res,2,function(x) {S=x[1:27];C=x[28:54];names(S)=sub('S\\.','',names(S));names(C)=sub('C\\.','',names(C));list(C=C,S=S)})
""";

col_names = rcopy(R"colnames(result_multi_neigh)")
d = Dict()
for i in col_names
	d[i] = Dict("C" => R"res_clean[[$i]][['C']]", "S" => R"res_clean[[$i]][['S']]")
end;
r_neigh = Dict()
for i in col_names
	r_neigh[i] = Dict(
					  :s_isi     => quickPredict(R"multi_neigh[[$i]]", d[i]["S"], "r.timeSinceLastSpike"),
					  :s_time    => quickPredict(R"multi_neigh[[$i]]", d[i]["S"], "timetoevt"),
					  :c_isi     => quickPredict(R"multi_neigh[[$i]]", d[i]["C"], "r.timeSinceLastSpike"),
					  :c_time    => quickPredict(R"multi_neigh[[$i]]", d[i]["C"], "timetoevt"),
					  :c_nearest => quickPredict(R"multi_neigh[[$i]]", d[i]["C"], "r.nearest"))
end

#%
R"""
load('data/analyses/spline/batch-4-cluster/dist/out/multi-dist-res.RData')
load('data/analyses/spline/batch-4-cluster/dist/in/multi-dist.RData')
res = result_multi_dist
res_clean=apply(res,2,function(x) {S=x[1:27];C=x[28:54];names(S)=sub('S\\.','',names(S));names(C)=sub('C\\.','',names(C));list(C=C,S=S)})
""";
col_names = rcopy(R"colnames(result_multi_dist)")
d = Dict()
for i in col_names
	d[i] = Dict("C" => R"res_clean[[$i]][['C']]", "S" => R"res_clean[[$i]][['S']]")
end;

r_dist = Dict()
for i in col_names
	r_dist[i] = Dict(
					  :s_isi     => quickPredict(R"multi_dist[[$i]]", d[i]["S"], "r.timeSinceLastSpike"),
					  :s_time    => quickPredict(R"multi_dist[[$i]]", d[i]["S"], "timetoevt"),
					  :c_isi     => quickPredict(R"multi_dist[[$i]]", d[i]["C"], "r.timeSinceLastSpike"),
					  :c_time    => quickPredict(R"multi_dist[[$i]]", d[i]["C"], "timetoevt"),
					  :c_nearest => quickPredict(R"multi_dist[[$i]]", d[i]["C"], "r.nearest"))
end

#%
R"""
load('data/analyses/spline/batch-4-cluster/half-neigh/out/multi-half-neigh-res.RData')
load('data/analyses/spline/batch-4-cluster/half-neigh/in/multi-half-neigh.RData')
res = result_multi_half_neigh
res_clean=apply(res,2,function(x) {gsa1S=x[1:27];gsa2S=x[28:54];gsa1C=x[55:81];gsa2C=x[82:108];names(gsa1S)=sub('gsa1S\\.','',names(gsa1S));names(gsa2S)=sub('gsa2S\\.','',names(gsa2S));;names(gsa1C)=sub('gsa1C\\.','',names(gsa1C));names(gsa2C)=sub('gsa2C\\.','',names(gsa2C));list(gsa1S=gsa1S,gsa2S=gsa2S,gsa1C=gsa1C,gsa2C=gsa2C)})
""";

col_names = rcopy(R"colnames(result_multi_half_neigh)")
d = Dict()
for i in col_names
	d[i] = Dict(:gsa1C => R"res_clean[[$i]][['gsa1C']]",
				:gsa1S => R"res_clean[[$i]][['gsa1S']]",
				:gsa2C => R"res_clean[[$i]][['gsa2C']]",
				:gsa2S => R"res_clean[[$i]][['gsa2S']]")
end;

r_half = Dict()
for i in col_names
	r_half[i] = Dict("s1" => predictLogProb(d[i][:gsa1S], R"df_half[[$i]]$m2$data"),
					 "s2" => predictLogProb(d[i][:gsa2S], R"df_half[[$i]]$m1$data"),
					 "c1" => predictLogProb(d[i][:gsa1C], R"df_half[[$i]]$m2$data"),
					 "c2" => predictLogProb(d[i][:gsa2C], R"df_half[[$i]]$m1$data"))
end

ll_n = DataFrame((index=String[], c_better=Bool[]))
for (k, v) in r_half
	push!(ll_n, (k, (v["s1"] + v["s2"]) < (v["c1"] + v["c2"])))
end

#%
R"""
load('data/analyses/spline/batch-4-cluster/half-dist/out/multi-half-dist-res.RData')
load('data/analyses/spline/batch-4-cluster/half-dist/in/multi-half-dist.RData')
res = result_multi_half_dist
res_clean=apply(res,2,function(x) {gsa1S=x[1:27];gsa2S=x[28:54];gsa1C=x[55:81];gsa2C=x[82:108];names(gsa1S)=sub('gsa1S\\.','',names(gsa1S));names(gsa2S)=sub('gsa2S\\.','',names(gsa2S));;names(gsa1C)=sub('gsa1C\\.','',names(gsa1C));names(gsa2C)=sub('gsa2C\\.','',names(gsa2C));list(gsa1S=gsa1S,gsa2S=gsa2S,gsa1C=gsa1C,gsa2C=gsa2C)})
""";

col_names = rcopy(R"colnames(result_multi_half_dist)")
d = Dict()
for i in col_names
	d[i] = Dict(:gsa1C => R"res_clean[[$i]][['gsa1C']]",
				:gsa1S => R"res_clean[[$i]][['gsa1S']]",
				:gsa2C => R"res_clean[[$i]][['gsa2C']]",
				:gsa2S => R"res_clean[[$i]][['gsa2S']]")
end;

r_half_dist = Dict()
for i in col_names
	r_half_dist[i] = Dict(
					 "s1" => predictLogProb(d[i][:gsa1S], R"df_half_dist[[$i]]$m2$data"),
					 "s2" => predictLogProb(d[i][:gsa2S], R"df_half_dist[[$i]]$m1$data"),
					 "c1" => predictLogProb(d[i][:gsa1C], R"df_half_dist[[$i]]$m2$data"),
					 "c2" => predictLogProb(d[i][:gsa2C], R"df_half_dist[[$i]]$m1$data"))
end

#%
ll_d = DataFrame((index=String[], c_better=Bool[]))
for (k, v) in r_half_dist
	push!(ll_d, (k, (v["s1"] + v["s2"]) < (v["c1"] + v["c2"])))
end

#%
save(datadir("analyses/spline/batch-4-cluster/postprocessed",
			 "multi-neigh.jld2"), r_neigh)
save(datadir("analyses/spline/batch-4-cluster/postprocessed",
			 "multi-dist.jld2"), r_dist)
save(datadir("analyses/spline/batch-4-cluster/postprocessed",
			 "likelihood-neigh.csv"), ll_n)
save(datadir("analyses/spline/batch-4-cluster/postprocessed",
			 "likelihood-dist.csv"), ll_d)

