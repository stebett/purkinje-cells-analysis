
function get_active_trials(mpsth, ranges, thr)
	active_trials = []
	for (spiketrain, rng) in zip(mpsth, ranges)
		push!(active_trials, [x[(y .> thr) .& .!isinf.(y)] for (x, y) = zip(rng, spiketrain)])
	end
	active_trials
end

function merge_trials(df, active_trials)
	active_ranges = Dict{Int, Array{Tuple{Float64, Float64}, 1}}()
	for i in eachindex(active_trials)
		active_ranges[df[i, :index]] = vcat(active_trials[i]...)
	end
	active_ranges
end

