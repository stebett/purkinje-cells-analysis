using DataFrames
using DataFramesMeta

function best_model(df, ll)
	index = ll[ll.c_better .== true, [:index1, :index2]]
	df[(in.(df.index1, Ref(index[!, 1]))) .& (in.(df.index2, Ref(index[!, 2]))), :]
end

function ranges_counts(df; binsize = 0.001, tmax = 50.)
	counts = zeros(Int(tmax/binsize))
	timerange = 0:binsize:tmax-binsize
	for (i, v) in enumerate(timerange)
		counts[i] = sum([r[1] .< v .< r[2] for r in vcat(df.ranges...)])
	end
	counts_perc = counts ./ size(df, 1) .* 100.
	timerange, counts_perc
end


function get_peaks(df, ref, group)
	tmp = @where(df, :reference .== ref, :group .== group, :variable .== "r.nearest")
	res = DataFrame()
	for d in eachrow(tmp)
		act = (d.mean .- d.sd) .> 0 #TODO add confidence interval
		maxrange = 0.0 .< d.x .< 200.0
		act = act .& maxrange
		indexes = rangeT(act)
		if isempty(indexes)
			continue
		end

		act_times = map(indexes) do (i, j); d.x[i], d.x[j]; end
		longest = diff.(act_times) |> argmax
		longest_i = UnitRange(indexes[longest]...)
		t = d.x[longest_i]
		peak = t[argmax(d.mean[longest_i])]

		push!(res, (index1=d.index1, 
					index2=d.index2, 
					peak=peak,
					x=d.x,
					mean=d.mean,
					sd=d.sd,
					ranges=[(d.x[i[1]], d.x[i[2]]) for i in indexes]))
	end
	res
end

# function summarize_complex_model(data)
# 	df = DataFrame()
# 	for (k, r) in data
# 		R = r[:c_nearest]
# 		x = R[:new_x]
# 		sd = R[:est_sd]
# 		mean = R[:est_mean]

# 		act = (mean .+ sd) .> 0
# 		indexes = rangeT(act)
# 		if isempty(indexes)
# 			break
# 		end

# 		act_times = map(indexes) do (i, j); x[i], x[j]; end
# 		longest = diff.(act_times) |> argmax
# 		longest_i = UnitRange(indexes[longest]...)
# 		t = x[longest_i]
# 		peak = t[argmax(mean[longest_i] .+ sd[longest_i])]

# 		push!(df, (index=parse.(Array{Int, 1}, k), 
# 				   peak=peak,
# 				   x=x,
# 				   mean=mean,
# 				   sd=sd,
# 				   ranges=[(x[i[1]], x[i[2]]) for i in indexes]))
# 	end
# 	df
# end

# function summarize_simple_model(data)
# 	df = DataFrame()
# 	df.idx = [parse(Int, k) for (k, _) in data]
# 	df.x = [r[:s_time][:new_x] for (_, r) in data]
# 	df.mean = [r[:s_time][:est_mean] for (_, r) in data]
# 	df
# end


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

