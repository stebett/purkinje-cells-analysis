using DrWatson
@quickactivate "ens"

using NPZ
using Plots; gr()

include(srcdir("spike-tools.jl"))
include(srcdir("data-tools.jl"))
include(scriptsdir("load-data.jl"))


# 2D
#


traj = Array{Array{Float64, 1}, 1}[]
for t in 1:length(readdir(datadir("trajectories")))÷2
	tmp = Array{Float64, 1}[]
	for i in [1 2]
		push!(tmp, npzread(datadir("trajectories", "traj_" * string(t) * "_" * string(i) * ".npy")))
	end
	push!(traj, tmp)
end

# Check variability to determine stop

p1 = plot(legend=false);
p2 = plot(legend=false);
for i in 1:length(traj)
	plot!(p1, traj[i][1])
    plot!(p2, traj[i][2])
end
plot(p1, p2)


stop=900
p = plot(title="Single trial trajectories around lift extracted by GPFA", xaxis="Dimension 1", yaxis="Dimension 2", size=(800, 800))
for i in 1:50
	plot!(p, traj[i][1][1:stop], traj[i][2][1:stop], line_z=1:length(traj[i][1][1:stop]), legend=false, lw=1.5, cbar=true, colorbar_title="timestep")
end
p

savefig(plotsdir("gpfa2d-dark.pdf"))


# 3D
traj = Array{Array{Float64, 1}, 1}[]
for t in 1:length(readdir(datadir("trajectories")))÷3
	tmp = Array{Float64, 1}[]
	for i in [1 2 3]
		push!(tmp, npzread(datadir("trajectories", "traj_" * string(t) * "_" * string(i) * ".npy")))
	end
	push!(traj, tmp)
end

p = plot()
for i in 1:length(traj)
	# plot!(p, traj[i][1])
    # plot!(p, traj[i][2])
    plot!(p, traj[i][3])
end
p

stop=600
p = plot(title="Single trial trajectories around lift extracted by GPFA", xaxis="Dimension 1", yaxis="Dimension 2", size=(800, 800))
for i in 1:length(traj)
	plot!(p, traj[i][1][1:stop], traj[i][2][1:stop], traj[i][3][1:stop], line_z=1:length(traj[i][1][1:stop]), legend=false, lw=1.5, cbar=true, colorbar_title="timestep")
end
p
savefig(plotsdir("gpfa2d.pdf"))

# gpfa with speeds
#

function plot_gpfa(traj, stop=900, title="")
	p = plot(title=title, xaxis="Dimension 1", yaxis="Dimension 2", size=(800, 800))
	for i in 1:length(traj)
		plot!(p, traj[i][1][1:stop], traj[i][2][1:stop], line_z=1:length(traj[i][1][1:stop]), legend=false, lw=1.5, cbar=true, colorbar_title="timestep")
	end
	p
end


function plot_gpfa_slow_vs_fast(traj, idx_slow, idx_fast, stop=900)
	p = plot(title="Trajectories of slowest trials", xaxis="Dimension 1", yaxis="Dimension 2", size=(900, 600))
	for i in 1:length(traj[idx_slow])
		plot!(p, traj[idx_slow][i][1][1:stop], traj[idx_slow][i][2][1:stop], line_z=1:length(traj[i][1][1:stop]), legend=false, lw=1.5, cbar=false, color=:blues, colorbar_title="timestep")
	end
	p1 = plot(title="Trajectories of fastest trials", xaxis="Dimension 1", yaxis="Dimension 2", size=(900, 600))
	for i in 1:length(traj[idx_fast])
		plot!(p1, traj[idx_fast][i][1][1:stop], traj[idx_fast][i][2][1:stop], line_z=1:length(traj[i][1][1:stop]), legend=false, lw=1.5, cbar=false, color=:reds,colorbar_title="timestep")
	end
	plot(p, p1)
end



function single_trials(df, landmark::String)
	new_df = DataFrame(rat=String[], site=String[], tetrode=String[], neuron=String[],
		trial=Int[], lift=Float64[], cover=Float64[], grasp=Float64[], t=Array{Float64, 1}[])

	trials = cut(df["t"], df[landmark], [-250, 250])

	idx = map(length, df[landmark]) |> x->pushfirst!(x, 0) |> cumsum
	idx_list = [[idx[i]+1:idx[i+1];] for i = 1:length(idx) - 1]

	for (old_idx, trial_idxs) = enumerate(idx_list)
		for (lm_idx, trial_idx) = enumerate(trial_idxs)
			push!(new_df, [values(df[old_idx, ["rat", "site", "tetrode", "neuron"]])..
						   ., lm_idx, df[old_idx, "lift"][lm_idx], df[old_idx, "cover"][lm_idx], df[old_idx, "grasp"][lm
																													  _idx], trials[trial_idx]])
		end
	end
	new_df
end

function extract_trials(groups::GroupedDataFrame{DataFrame}, min_length)
	trials = Array{Array{Float64, 1}, 1}[]
	speeds = Array{Float64, 1}[]
	for g in groups
		if size(g, 1) >= min_length
			push!(trials, g.t[1:min_length])
			push!(speeds, g.cover[1:min_length] .- g.lift[1:min_length])
		end
	end
	trials, speeds
end
df = single_trials(data, "lift")
groups = groupby(df, [:rat, :site, :trial])
trials, speeds = extract_trials(groups, 3) 
speeds = hcat(speeds...)[1, :]
speeds = speeds[761:end]

q1 = quantile(skipnan(speeds), 0.02)
q3 = quantile(skipnan(speeds), 0.98)
slow = speeds .> q3
fast = speeds .< q1
plot_gpfa_slow_vs_fast(traj[1:end], slow[1:end], fast[1:end])


function plot_gpfa_speed(traj, speeds, stop=500, color=:inferno)
	p = plot(title="Trajectories of single trials projected on GPFA dimensions", xaxis="Dimension 1", yaxis="Dimension 2", size=(900, 600))
	for (i, s) in enumerate(speeds)
		if s < 800
			plot!(p, traj[i][1], traj[i][2], line_z=s, legend=false, lw=1.5, cbar=true, colorbar_title="Trial duration", c=color)
		end
	end
	p
end
plot_gpfa_speed(traj[1:30], speeds[1:30], 900, :redsblues)
plot_gpfa_speed(traj[1:90], speeds[1:90], 900, :redsblues)
