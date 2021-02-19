using DrWatson
@quickactivate "ens"

using Statistics
using Plots; gr()



function psth(n::Array{Float64, 2}, low::T=-0.7, high::T=1.6, ct::String="") where {T<:Number}
	heatmap(n', clim=(low, high), size=(750, 1000), colorbar_title=ct, c=:viridis)
end

function psth(n::Array{Array{Float64, 1}}, low::T=-0.7, high::T=1.6) where {T<:Number}
	psth(hcat(n...), low, high)
end

function sort_active(n, center)
	n = drop(n)
	half = size(n, 1) ÷ 2
	rates = mean(@view(n[half-center:half+center, :]), dims=1)
	p = sortperm(rates[:])
	ordered_n = n[:, p]
end
