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

	if isempty(x) || isempty(y) 
		return fill(NaN, length(lags))
	end

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

	x = vcat((x...)...) #Can't concatenate trials like this!
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

@inline function crosscor(df, cells::Array{Int64, 1}, around::Vector{<:Tuple}, args...; binsize::Number, lags=[-40:40;], thr=1.5)

	if isempty(around)
		return [fill(NaN, length(lags))]
	end

	# section around active ranges and concat each trial with its parts
	x = vcat.([section(df[(df.index .== cells[1]), "t"], df[(df.index .== cells[1]), "cover"], i, binsize=binsize) for i in around]...)
	y = vcat.([section(df[(df.index .== cells[2]), "t"], df[(df.index .== cells[2]), "cover"], i, binsize=binsize) for i in around]...)
	
	if :preimp in args
		return crosscor.(x, y, Ref(lags), demean=true)
	end

	if :norm in args
		return crosscor.(x, y, true, binsize=binsize) #, lags=lags)
	end

	crosscor.(x, y, false, binsize=binsize) # TODO lags=lags)
end

function crosscor(df, couples::Array{Array{Int64, 1}, 1}, around::Vector,  args...; binsize::Number, lags=[-40:40;], thr=1.5)
	m = zeros(length(lags), length(couples))
	for (i, c) in enumerate(couples)
		m[:, i] = crosscor(df, c, around, args..., binsize=binsize, thr=thr, lags=lags)
	end
	m
end

function crosscor(df, couples::Array{Array{Int64, 1}, 1}, around::Dict,  args...; binsize::Number, lags=[-40:40;], thr=1.5)
	active(x) = Tuple{Float64, Float64}[around[x[1]]..., around[x[2]]...]
	# for (i, c) in enumerate(couples)
	# 	m[:, i] = crosscor(df, c, active(c), args..., binsize=binsize, thr=thr, lags=lags)
	# end
	# m
	crosscor.(Ref(df), couples, active.(couples), Ref(args...), binsize=binsize, thr=thr) 
end

