using DrWatson
@quickactivate :ens

using Statistics
using StatsPlots
using Spikes
using Plots
data = load_data("data-v6.arrow");

around = [-50., 50.]
binsize = 1.


idxs = [g.index for g in groupby(data, [:rat, :site, :tetrode])]
neigh = data[in.(data.index, Ref(idxs[argmax(length.(idxs))])), :];

dist = data[in.(data.index, Ref(rand(1:size(data, 1), 4))), :];



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


