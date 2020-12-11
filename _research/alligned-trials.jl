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



@inline function get_aligned_trial(df, n, i)
	before = df.grasp[n][i] - df.lift[n][i] + (50)
	s = slice(df.t[n], df.lift[n][i], (-50, before))
	l = [df.lift[n][i], df.cover[n][i], df.grasp[n][i]] .- 50
	speed = df.cover[n][i] - df.lift[n][i]
	return s, l, speed, before
end

aligned_trials = DataFrame(rat=String[], site=String[], tetrode=String[], neuron=String[], lift=Float64[], cover=Float64[], grasp=Float64[], speed=Float64[], t=Array{Number, 1}[])
for n in 1:length(data.t)÷4
	for i = 1:length(data.lift[n])
		trial, landmarks, speed = get_aligned_trial(data, n, i)
		push!(aligned_trials, [data[n, 1:4]..., landmarks..., speed, trial])
	end
end
