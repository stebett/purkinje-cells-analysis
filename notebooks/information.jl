### A Pluto.jl notebook ###
# v0.14.0

using Markdown
using InteractiveUtils

# ╔═╡ 5571276e-a354-11eb-3e16-730bbe9b67ce
using DrWatson

# ╔═╡ 6322315a-a354-11eb-2350-bfd0a372ef25
@quickactivate :ens

using DataFrames
using Statistics
using StatsPlots
using Spikes
using Plots

# ╔═╡ b5953dd8-a354-11eb-2c10-2befb705c662
function get_p(df, landmark, around, binsize)
    r = cut(df[:, :t], df[:, landmark], around) |> x->bin(x, Int(diff(around)[1]), binsize, binary=true)  |> x->BitArray.(x)
    m = length(r)
    p = mean.(r)
    ind_p = [pₖ^sum(rₖ) * (1-pₖ)^sum(.!rₖ) for (rₖ, pₖ) in zip(r, p)] |> x->log.(x) |> sum
    dep_p = [count(x->x==r[i], r) / m for i in 1:m] |> x->log.(x) |> sum
    r, dep_p, ind_p
end


function cost(df, around, binsize)
    r₁, dep_p₁, ind_p₁ = get_p(df, :lift, around, binsize)
    r₂, dep_p₂, ind_p₂ = get_p(df, :cover, around, binsize)
    r₃, dep_p₃, ind_p₃ = get_p(df, :grasp, around, binsize)

    b₁ = @. dep_p₁ / (dep_p₁ +  dep_p₂ +  dep_p₃)
    b₂ = @. dep_p₂ / (dep_p₁ +  dep_p₂ +  dep_p₃)
    b₃ = @. dep_p₃ / (dep_p₁ +  dep_p₂ +  dep_p₃)

    b_ind₁ = @. ind_p₁ / (ind_p₁ +  ind_p₂ +  ind_p₃)
    b_ind₂ = @. ind_p₂ / (ind_p₁ +  ind_p₂ +  ind_p₃)
    b_ind₃ = @. ind_p₃ / (ind_p₁ +  ind_p₂ +  ind_p₃)

    r = [r₁; r₂; r₃]
    joint = [sum(i in rᵢ for i in r)/length(r) for rᵢ in [r₁, r₂, r₃]]
    sum(joint .* log2.([b₁, b₂, b₃] ./ [b_ind₁, b_ind₂, b_ind₃]))
end

# ╔═╡ bcce001c-a354-11eb-2522-5d451a403da8
data = load_data("data-v6.arrow");

neighs = couple(data, :n)
dist = couple(data, :d)

# ╔═╡ cc206e7e-a354-11eb-150a-7361da3945f4
around = [-50., 50.]
binsize = 1.

# ╔═╡ cee96cee-a354-11eb-08bf-5be412f2ab80
n_cost = map(neighs) do n
    cost(find(data, n), around, binsize)
end

# ╔═╡ 0a6dda04-a355-11eb-2f7c-c7c94ce28fc1

d_cost = map(dist) do d
    cost(find(data, d), around, binsize)
end

# ╔═╡ Cell order:
# ╠═5571276e-a354-11eb-3e16-730bbe9b67ce
# ╠═6322315a-a354-11eb-2350-bfd0a372ef25
# ╠═b5953dd8-a354-11eb-2c10-2befb705c662
# ╠═bcce001c-a354-11eb-2522-5d451a403da8
# ╠═cc206e7e-a354-11eb-150a-7361da3945f4
# ╠═cee96cee-a354-11eb-08bf-5be412f2ab80
# ╠═0a6dda04-a355-11eb-2f7c-c7c94ce28fc1
