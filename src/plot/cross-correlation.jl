using DrWatson
@quickactivate "ens"

using Statistics
import StatsBase.crosscor


include(srcdir("section.jl"))
include(srcdir("section-trial.jl"))

@inline function crosscor_c(df, c, active_c, binsize) 
	r = zeros(81, length(c))
	lags = -40. * binsize : binsize : 40. * binsize
	@inbounds for i = eachindex(c)
		c1 = cut(df[df.index .== c[i][1], :t]..., active_c[c[i]]) 
		c2 = cut(df[df.index .== c[i][2], :t]..., active_c[c[i]])
		crosscor!(view(r, :, i), c1, c2, lags, true, binsize=binsize)
	end
	r
end

@inline function crosscor!(r, x::Vector, y::Vector, lags, norm::Bool; binsize::Real)
	if isempty(x) || isempty(y) || any(isinf.(x)) || any(isinf.(y))
		r .= NaN
		return
	end

	@inbounds for k in x
	    r .+= [sum([k+i .<= y .< k+i+binsize]...) for i = lags] # is this faster if y is sorted?
	end
	if norm
		zscore!(r, mean(r), std(r))
	end
end

@inline function crosscor(x::Vector, y::Vector, norm::Bool; binsize::Real)
	lags = -40. * binsize : binsize : 40. * binsize

	if isempty(x) || isempty(y) || any(isinf.(x)) || any(isinf.(y))
		return fill(NaN, length(lags))
	end

	bins = zeros(length(lags))
	center = ceil(Int, length(lags)/2)

	@inbounds for k in x
	    bins .+= [sum([k+i .<= y .< k+i+binsize]...) for i = lags] # is this faster if y is sorted?
	end
	if norm
		# return bins ./ (length(x)*length(y)*binsize/(max(x..., y...)-min(x...,y...)))
		# return (bins .- median(bins)) ./ mad(bins)
		return zscore(bins)
	end
	bins
end


@inline function crosscor(df, cells::Array{Int64, 1}, around::Vector, args...; binsize::Number, lags=[-40:40;], thr=1.5)

	x = cut(df[(df.index .== cells[1]), "t"], df[(df.index .== cells[1]), "cover"], around)
	y = cut(df[(df.index .== cells[2]), "t"], df[(df.index .== cells[2]), "cover"], around)

	x = vcat((x...)...) #Can't concatenate trials like this!
	y = vcat((y...)...)
	
	if isempty(x[x.>0]) || isempty(y[y.>0]) 
		return fill(NaN, length(lags))
	end

	if :preimp in args
		return crosscor(x, y, lags, demean=true)
	end

	if :norm in args
		return crosscor(x, y, true, binsize=binsize)
	end

	crosscor(x, y, false, binsize=binsize)
end

@inline function crosscor(df, cells::Array{Int64, 1}, around::Vector{<:Tuple}, args...; binsize::Number, lags=[-40:40;], thr=1.5)

	if isempty(around)
		return [fill(NaN, length(lags))]
	end

	# section around active ranges and concat each trial with its parts
	x = vcat.([cut(df[(df.index .== cells[1]), "t"], df[(df.index .== cells[1]), "cover"], i) for i in around]...)
	y = vcat.([cut(df[(df.index .== cells[2]), "t"], df[(df.index .== cells[2]), "cover"], i) for i in around]...) # TODO test
	
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

