using DrWatson
@quickactivate :ens

using JLD2 

include(srcdir("spline", "spline-plots.jl"))
include(srcdir("spline", "spline-analysis.jl"))
include(srcdir("spline", "spline-utils.jl"))

R"load('data/spline/cluster-results/multi/out/multi-neigh-res.RData')"

col_names = rcopy(R"colnames(result_multi_neigh)")
d = Dict()
for i in col_names
	d[i] = rcopy(R"result_multi_neigh[, $i]") # maybe don't rcopy
end

df = DataFrame(x, col_names);
df.idx = row_names
