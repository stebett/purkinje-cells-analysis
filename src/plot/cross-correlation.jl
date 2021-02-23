using DrWatson
@quickactivate "ens"

using Statistics
import StatsBase.crosscor


include(srcdir("section.jl"))
include(srcdir("section-trial.jl"))


@inline function crosscor(c1::Vector, c2::Vector, norm::Bool; binsize::Number, lags=[-40:40;])
	bins = zeros(length(lags))
	center = ceil(Int, length(lags)/2)
	x = c1 .* [1:length(c1);]
	y = c2 .* [1:length(c2);]

	x = x[x .> 0.]
	y = y[y .> 0.]

	x = Array{Int, 1}(x)
	y = Array{Int, 1}(y)

	@inbounds for z in x
		bins[intersect((-z .+ y), lags) .+ center] .+= 1
	end
	if norm
		return bins ./ (length(x)*length(y)*binsize/(max(x..., y...)-min(x...,y...)))
	end
	bins
end

@inline function crosscor(df, cells::Array{Int64, 1}, around::Vector, args...; binsize::Number, lags=[-40:40;], thr=1.5)

	x = section(df[(df.index .== cells[1]), "t"], df[(df.index .== cells[1]), "cover"], around, binsize=binsize) 
	y = section(df[(df.index .== cells[2]), "t"], df[(df.index .== cells[2]), "cover"], around, binsize=binsize) 

	x = vcat(x...)
	y = vcat(y...)
	
	if isempty(x[x.>0]) || isempty(y[y.>0]) 
		return fill(NaN, length(lags))
	end

	if :preimp in args
		return crosscor(x, y, lags, demean=true)
	end

	if :norm in args
		return crosscor(x, y, args..., binsize=binsize, lags=lags, norm=true)
	end

	crosscor(x, y, args..., binsize=binsize, lags=lags, norm=false)

end

@inline function crosscor(df, cells::Array{Int64, 1}, around::Vector, args...; binsize::Number, lags=[-40:40;], thr=1.5, idx)

	x = []
	y = []
	
	if isempty(idx)
		return fill(NaN, length(lags))
	end

	for i in 1:size(idx, 2)
		push!(x, section(df[(df.index .== cells[1]), "t"], df[(df.index .== cells[1]), "cover"], idx[:, i], binsize=binsize))
		push!(y, section(df[(df.index .== cells[2]), "t"], df[(df.index .== cells[2]), "cover"], idx[:, i], binsize=binsize))
	end

	x = vcat((x...)...)
	y = vcat((y...)...)
	
	if isempty(x[x.>0]) || isempty(y[y.>0]) 
		return fill(NaN, length(lags))
	end

	if :preimp in args
		return crosscor(x, y, lags, demean=true)
	end

	if :norm in args
		return crosscor(x, y, true, binsize=binsize, lags=lags)
	end

	crosscor(x, y, false, binsize=binsize, lags=lags)
end

function crosscor(df, couples::Array{Array{Int64, 1}, 1}, around::Vector,  args...; binsize::Number, lags=[-40:40;], thr=1.5)
	m = zeros(length(lags), length(couples))
	for (i, c) in enumerate(couples)
		m[:, i] = crosscor(df, c, around, args..., binsize=binsize, thr=thr, lags=lags)
	end
	m
end

function crosscor(df, couples::Array{Array{Int64, 1}, 1}, around::Vector,  args...; binsize::Number, lags=[-40:40;], thr=1.5, indexes=Array{Array{Float64, 2}})
	m = zeros(length(lags), length(couples))
	for (i, c) in enumerate(couples)
		active = concat(indexes[c]...)
		m[:, i] = crosscor(df, c, around, args..., binsize=binsize, thr=thr, lags=lags,idx=active)
	end
	m
end

function concat(x, y)
	if isempty(x) && isempty(y)
		return []
	elseif isempty(x)
		return y
	elseif isempty(y)
		return x
	end
	hcat(x, y)
end



