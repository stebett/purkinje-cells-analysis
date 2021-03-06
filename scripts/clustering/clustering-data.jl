using DrWatson
@quickactivate :ens

using JLD2 
using Spikes
using NPZ


include(srcdir("spline", "spline-utils.jl"))

multi_all = load(datadir("spline", "multi-all.jld2"));
raw_all = load_data("data-v6.arrow");

dfₛ = combine_simple_analysis(multi_all);
dfₘ = raw_all[in.(raw_all.index, Ref(dfₛ.idx)), :];

sort!(dfₛ, :idx);
sort!(dfₘ, :index);
@assert dfₛ.idx == dfₘ.index

xₘ = multi_psth(dfₘ, 600, 12, 30, true);
xₛ = map(row->row.mean[1. .< row.x .< 5.], eachrow(dfₛ));
xₛ = map(row->row[1:minimum(length.(xₛ))], xₛ);

todrop = drop(xₘ, index=true);
xₘ = xₘ[.!todrop];
xₛ = xₛ[.!todrop];

new_idx = sum(abs.(Xm) .> 3, dims=1)[:] .> 0

xₘ = xₘ[new_idx];
xₛ = xₛ[new_idx];


Xₘ = hcat(minmax_scale.(xₘ)...) |> transpose
Xₛ = hcat(minmax_scale.(xₛ)...) |> transpose

npzwrite(datadir("clustering", "mpsth.npy"), Xₘ)
npzwrite(datadir("clustering", "spline.npy"), Xₛ)
