using DrWatson
@quickactivate :ens

using JLD2 

include(srcdir("spline", "spline-plots.jl"))
include(srcdir("spline", "spline-analysis.jl"))
include(srcdir("spline", "spline-utils.jl"))

R"""
load('data/spline/cluster-results/multi/out/multi-neigh-res.RData')
load('data/spline/cluster-results/multi/in/multi-neigh.RData')
res = result_multi_neigh
res_clean=apply(res,2,function(x) {S=x[1:27];C=x[28:54];names(S)=sub('S\\.','',names(S));names(C)=sub('C\\.','',names(C));list(C=C,S=S)})
""";

col_names = rcopy(R"colnames(result_multi_neigh)")
d = Dict()
for i in col_names
	d[i] = Dict("C" => R"res_clean[[$i]][['C']]", "S" => R"res_clean[[$i]][['S']]")
end;

r = Dict()
for i in col_names
	r[i] = Dict(
	:s_isi => quickPredict(R"multi_neigh[$i]", d[i]["S"], "r.timeSinceLastSpike"),
	:s_time => quickPredict(R"multi_neigh[$i]", d[i]["S"], "time"),
	:c_isi => quickPredict(R"multi_neigh[$i]", d[i]["C"], "r.timeSinceLastSpike"),
	:c_time => quickPredict(R"multi_neigh[$i]", d[i]["C"], "timetoevt"),
	:c_nearest => quickPredict(R"multi_neigh[$i]", d[i]["C"], "r.nearest"))
end
