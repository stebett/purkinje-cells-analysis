
function above(x::Dict)
	y = x[:est_mean] .- x[:est_sd] .> 0
	indexes = rangeT(y)
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

