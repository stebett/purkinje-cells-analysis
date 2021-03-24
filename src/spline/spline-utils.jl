using DataFrames

function combine_analysis(data)
	df = [above(r[:c_nearest]) for (_, r) in data] |> DataFrame 
	df.idx = [k for (k, _) in data]
	df.x = [r[:c_nearest][:new_x] for (_, r) in data]
	df.mean = [r[:c_nearest][:est_mean] for (_, r) in data]
	df.ranges = [all_ranges_above(r[:c_nearest]) for (_, r) in data]
	dropmissing!(df)
	# filter!(x->isless(0, x.m), df)
	df
end

function combine_simple_analysis(data)
	df = DataFrame()
	df.idx = [parse(Int, k) for (k, _) in data]
	df.x = [r[:s_time][:new_x] for (_, r) in data]
	df.mean = [r[:s_time][:est_mean] for (_, r) in data]
	df
end


function above(x::Dict)
	y = x[:est_mean] .- x[:est_sd] .> 0.
	indexes = rangeT(y)
	if length(indexes) < 1
		return (t=missing, m=missing, sd=missing)
	end
	long_i = indexes[argmax(diff.(indexes))]
	t = x[:new_x][long_i[1]:long_i[2]]
	peak_m = t[argmax(x[:est_mean][long_i[1]:long_i[2]])]
	peak_sd = argmax(x[:est_sd][long_i[1]:long_i[2]])
	peak_t = extrema(t)
	(t=peak_t, m=peak_m, sd=peak_sd)
end

function all_ranges_above(x::Dict)
	y = x[:est_mean] .- x[:est_sd] .> 0
	indexes = rangeT(y)
	[(x[:new_x][i[1]], x[:new_x][i[2]]) for i in indexes]
 end

function rangeT(y::BitArray{1})
	ranges = []
	find_start = true
	start = NaN
	finish = NaN
	for (i, v) in enumerate(y)
		if find_start
			if v 
				start = i
				find_start = false
			end
		else
			if !v
				finish = i-1
				push!(ranges, (start, finish))
				find_start = true
			end
		end
	end
	ranges
end

function minmax_scale(x::Vector)
	min, max = extrema(x)
	@. (x - min) / (max-min)
end

function Base.parse(::Type{T}, c::String; n::Int=2) where T<:Array{Int, 1}
	c[2:end-1] |> x->split(x, ", ") |> x->convert.(String, x) |> x->parse.(Int, x)
end

