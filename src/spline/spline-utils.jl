using DataFrames

function extract(data)
	df = DataFrame()
	for (k, r) in data
		R = r[:c_nearest]
		x = R[:new_x]
		sd = R[:est_sd]
		mean = R[:est_mean]

		act = (mean .+ sd) .> 0
		indexes = rangeT(act)
		if isempty(indexes)
			break
		end

		act_times = map(indexes) do (i, j); x[i], x[j]; end
		longest = diff.(act_times) |> argmax
		longest_i = UnitRange(indexes[longest]...)
		t = x[longest_i]
		peak = t[argmax(mean[longest_i] .+ sd[longest_i])]

		push!(df, (index=parse.(Array{Int, 1}, k), 
				   peak=peak,
				   x=x,
				   mean=mean,
				   sd=sd,
				   ranges=all_ranges_above(R)))
	end
	df
end

function combine_simple_analysis(data)
	df = DataFrame()
	df.idx = [parse(Int, k) for (k, _) in data]
	df.x = [r[:s_time][:new_x] for (_, r) in data]
	df.mean = [r[:s_time][:est_mean] for (_, r) in data]
	df
end


function all_ranges_above(x::Dict)
	y = x[:est_mean] .- x[:est_sd] .> 0
	indexes = rangeT(y)
	[(x[:new_x][i[1]], x[:new_x][i[2]]) for i in indexes]
 end

function rangeT(y::BitArray{1})
	ranges = []
	start_found = false
	start = NaN
	finish = NaN
	for (i, v) in enumerate(y)
		if !start_found
			if v 
				start = i
				start_found = true
			end
		else
			if !v
				finish = i-1
				push!(ranges, (start, finish))
				start_found = false
			end
		end
	end
	if start_found # In case last(y) == true
		push!(ranges, (start, lastindex(y)))
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

function Base.parse(::Type{T}, c::String; n::Int=2) where T<:Tuple{Int, Int}
	c[2:end-1] |> x->split(x, ", ") |> x->convert.(String, x) |> x->parse.(Int, x) |> Tuple	
end
