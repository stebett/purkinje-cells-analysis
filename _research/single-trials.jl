using DrWatson
@quickactivate "ens"

include(scriptsdir("load-data.jl"))
include(srcdir("spike-tools.jl"))

using DataFrames
# distances = Float64[]
# weirds = Int[]
# for idx_t in 1:length(data.t)
# 	if length(data.lift[idx_t]) != length(data.grasp[idx_t])
# 		push!(weirds, idx_t)
# 		continue
# 	end

# 	for idx_l in 1:length(data.lift[idx_t]) - 1
# 		push!(distances, data.lift[idx_t][idx_l + 1] - data.grasp[idx_t][idx_l])
# 	end
# end


function get_trial(df, n)
	after = -df.lift[n][1]
	before = df.grasp[n][1] - df.lift[n][1] + (df.lift[n][2] - df.grasp[n][1]) / 2
	s = slice(df.t[n], df.lift[n][1], (after, before))
	l = [df.lift[n][1], df.cover[n][1], df.grasp[n][1]]
	speed = df.cover[n][1] - df.lift[n][1]
	return s, l, speed, before
end

@inline function get_trial(df, n, i, after)
	before = df.grasp[n][i] - df.lift[n][i] + (df.lift[n][i + 1] - df.grasp[n][i]) / 2
	s = slice(df.t[n], df.lift[n][i], (-after, before))
	l = [df.lift[n][i], df.cover[n][i], df.grasp[n][i]] .- after
	speed = df.cover[n][i] - df.lift[n][i]
	return s, l, speed, before
end

function get_trial(df, n, after)
	before = df.grasp[n][end] - df.lift[n][end] + (df.t[n][end] - df.grasp[n][end]) / 2
	s = slice(df.t[n], df.lift[n][end], (-after, before))
	l = [df.lift[n][end], df.cover[n][end], df.grasp[n][end]] .- after
	speed = df.cover[n][end] - df.lift[n][end]
	return s, l, speed 
end

single_trials = DataFrame(rat=String[], site=String[], tetrode=String[], Neuron=String[], lift=Float64[], cover=Float64[], grasp=Float64[], speed=Float64[], t=Array{Number, 1}[])
for n in 1:length(data.t)÷4
	trials = min(length(data.lift[n]), length(data.grasp[n]))

	trial, landmarks, speed, cutoff = get_trial(data, n)
	push!(single_trials, [data[n, 1:4]..., landmarks..., speed, trial])

	for i = 2:trials-1
		trial, landmarks, speed, cutoff = get_trial(data, n, i, cutoff)
		push!(single_trials, [data[n, 1:4]..., landmarks..., speed, trial])
	end

	trial, landmarks, speed = get_trial(data, n, cutoff)
	push!(single_trials, [data[n, 1:4]..., landmarks..., speed, trial])
end
