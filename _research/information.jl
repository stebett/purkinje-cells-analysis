using DrWatson
@quickactivate :ens

using Statistics
using StatsPlots
using Spikes
using Plots
data = load_data("data-v6.arrow");


around = [-200., 200.]
binsize = 5.
# Responses given stimuli

r₁ = cut(data.t, data.lift, around) |> x->bin(x, Int(diff(around)[1]), binsize, binary=true)  |> x->BitArray.(x) 
m = length(r₁)
p₁ = mean.(r₁)
ind_p₁ = [pₖ^sum(rₖ) * (1-pₖ)^sum(.!rₖ) for (rₖ, pₖ) in zip(r₁, p₁)] |> x->log.(x) |> sum
dep_p₁ = [count(x->x==r₁[i], r₁) / m for i in 1:m] |> x->log.(x) |> sum

r₂ = cut(data.t, data.cover, around) |> x->bin(x, Int(diff(around)[1]), binsize, binary=true)  |> x->BitArray.(x) 
p₂ = mean.(r₂)
ind_p₂ = [pₖ^sum(rₖ) * (1-pₖ)^sum(.!rₖ) for (rₖ, pₖ) in zip(r₂, p₂)] |> x->log.(x) |> sum
dep_p₂ = [count(x->x==r₂[i], r₂) / m for i in 1:m] |> x->log.(x) |> sum

r₃ = cut(data.t, data.grasp, around) |> x->bin(x, Int(diff(around)[1]), binsize, binary=true)  |> x->BitArray.(x) 
p₃ = mean.(r₃)
ind_p₃ = [pₖ^sum(rₖ) * (1-pₖ)^sum(.!rₖ) for (rₖ, pₖ) in zip(r₃, p₃)] |> x->log.(x) |> sum
dep_p₃ = [count(x->x==r₃[i], r₃) / m for i in 1:m] |> x->log.(x) |> sum

b₁ = @. dep_p₁ / (dep_p₁ +  dep_p₂ +  dep_p₃) 
b₂ = @. dep_p₂ / (dep_p₁ +  dep_p₂ +  dep_p₃) 
b₃ = @. dep_p₃ / (dep_p₁ +  dep_p₂ +  dep_p₃) 

b_ind₁ = @. ind_p₁ / (ind_p₁ +  ind_p₂ +  ind_p₃) 
b_ind₂ = @. ind_p₂ / (ind_p₁ +  ind_p₂ +  ind_p₃) 
b_ind₃ = @. ind_p₃ / (ind_p₁ +  ind_p₂ +  ind_p₃) 

r = [r₁; r₂; r₃]
joint = [sum(i in rᵢ for i in r)/length(r) for rᵢ in [r₁, r₂, r₃]]

sum(joint .* log2.([b₁, b₂, b₃] ./ [b_ind₁, b_ind₂, b_ind₃]))
