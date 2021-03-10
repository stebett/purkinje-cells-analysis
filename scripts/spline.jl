using DrWatson
@quickactivate :ens

using JLD2 
using Spikes
using RCall

include(srcdir("spline-plots.jl"))

results = load("data/spline/gssmodels.jld2", "results")

s_isi = results[556][1]

function above(x::Dict)
end

x = s_isi

y = x[:est_mean] .- x[:est_sd] .> 0


""" 
Takes first and last value of `x` of the `true` indices of `y`
"""
function rangeT(x::AbstractVector, y::BitArray{1})
	ranges = []
	find_start = true
	start = NaN
	finish = NaN
	for (i, v) in enumerate(y)
		if find_start
			if v 
				start = x[i]
				find_start = false
			end
		else
			if !v
				finish = x[i-1]
				push!(ranges, (start, finish))
				find_start = true
			end
		end
	end
	ranges
end
		






plot_quick_prediction(s_isi)
