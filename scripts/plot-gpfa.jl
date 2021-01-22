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

p = plot()
for i in 1:length(traj)
	plot!(p, traj[i][1])
    plot!(p, traj[i][2])
end
p


stop=600
p = plot(title="Single trial trajectories around lift extracted by GPFA", xaxis="Dimension 1", yaxis="Dimension 2", size=(800, 800))
for i in 1:length(traj)
	plot!(p, traj[i][1][1:stop], traj[i][2][1:stop], line_z=1:length(traj[i][1][1:stop]), legend=false, lw=1.5, cbar=true, colorbar_title="timestep")
end
p
savefig(plotsdir("gpfa2d-2.pdf"))


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
