using DrWatson
@quickactivate "ens"

using Statistics
import StatsBase.crosscor

include(srcdir("section.jl"))


@inline function crosscor(c1::Vector, c2::Vector, args...; binsize::Number, lags=[-40:40;])
	bins = zeros(length(lags))
	center = ceil(Int, length(lags)/2)
	x = c1 .* [1:length(c1);]
	y = c2 .* [1:length(c2);]

	x = x[x .> 0.]
	y = y[y .> 0.]

	isempty(x) & isempty(y) ? (return zeros(length(lags))) : 0

	x = Array{Int, 1}(x)
	y = Array{Int, 1}(y)

	@inbounds for z in x
		bins[intersect((-z .+ y), lags) .+ center] .+= 1
	end

	if :norm in args
		return bins ./ (length(x)*length(y)*binsize/(max(x..., y...)-min(x...,y...)))
	end
	bins
end

function crosscor(df, cells::Array{Int64, 1}, around::Vector, args...; binsize::Number, lags=[-40:40;], thr=1.5)
	idx = Colon()
	if :filt in args
		z = section(df[(df.index .== cells[1]), "t"], df[(df.index .== cells[1]), "cover"], around, over=[-1000., -500.], binsize=binsize, :norm) 

		idx = vcat(z...) .> thr
	end

	x = section(df[(df.index .== cells[1]), "t"], df[(df.index .== cells[1]), "cover"], around, binsize=binsize) 
	y = section(df[(df.index .== cells[2]), "t"], df[(df.index .== cells[2]), "cover"], around, binsize=binsize) 

	x = vcat(x...)[idx]
	y = vcat(y...)[idx]
	
	crosscor(x, y, args..., binsize=binsize, lags=lags)
end

function crosscor(df, couples::Array{Array{Int64, 1}, 1}, around::Vector,  args...; binsize::Number, lags=[-40:40;], thr=1.5)
	m = zeros(length(lags), length(couples))
	for (i, c) in enumerate(couples)
		m[:, i] = crosscor(df, c, around, args..., binsize=binsize, thr=thr, lags=lags)
	end
	m
end

