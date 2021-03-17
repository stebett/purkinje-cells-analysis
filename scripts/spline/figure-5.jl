using DrWatson
@quickactivate :ens

using JLD2 

function Base.parse(::Type{T}, c::String; n::Int=2) where T<:Array{Int, 1}
	c[2:end-1] |> x->split(x, ", ") |> x->convert.(String, x) |> x->parse.(Int, x)
end

include(srcdir("spline", "spline-plots.jl"))
include(srcdir("spline", "spline-analysis.jl"))
include(srcdir("spline", "spline-utils.jl"))

multi_dist = load(datadir("spline",  "multi-dist.jld2"));
multi_neigh = load(datadir("spline", "multi-neigh.jld2"));

df_n = combine_analysis(multi_neigh)
df_d = combine_analysis(multi_dist)

ll_d = load(datadir("spline", "dist-likelihood.csv")) |> DataFrame
ll_n = load(datadir("spline", "neigh-likelihood.csv")) |> DataFrame

transform!(ll_n, [:simple1, :simple2, :complex1, :complex2] => 
		   ((s1, s2, c1, c2) -> (s1 .+ s2) .< (c1 .+ c2)) => :c_better)
transform!(ll_d, [:simple1, :simple2, :complex1, :complex2] => 
		   ((s1, s2, c1, c2) -> (s1 .+ s2) .< (c1 .+ c2)) => :c_better)

complex_models = ll_n.index[ll_n.c_better .== 1]
df_n.idx = parse.(Array{Int, 1}, df_n.idx)
new_idx = map(eachrow(df_n)) do x
	x.idx[1] in complex_models
end
df_n = df_n[new_idx, :]

complex_models = ll_d.index[ll_d.c_better .== 1]
df_d.idx = parse.(Array{Int, 1}, df_d.idx)
new_idx = map(eachrow(df_d)) do x
	x.idx[1] in complex_models
end
df_d = df_d[new_idx, :]
