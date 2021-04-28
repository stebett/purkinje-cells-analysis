using DrWatson
@quickactivate :ens

using DataFramesMeta
using DataFrames
using Plots
using Arrow
using StatsBase

analysis = "spline"
batch = 8
reference = "best"
file = "simulated.arrow"

data = load_data(:last)
sim_all = load_data(analysis, batch, reference, "dist", file)
sim_neigh = load_data(analysis, batch, reference, "neigh", file)

idx = @where(data, :rat .== "R17", :site .== "39", :tetrode .== "tet2").index
idx = [438, 437]
idx = [512, 514]
idx = [555, 554]
n1 = @where(data, :index .== idx[1])
n2 = @where(data, :index .== idx[2])

landmark = [:lift, :cover, :grasp][get_active_events(n1)[1]]
cc_params = [-20, 20, 0.5]
fig_params = (legend = false, ylabel = "Counts", xlabel = "Time (ms)")

c1 = abscut(n1[1, :t], n1[1, landmark], [-500., 500.])
c2 = abscut(n2[1, :t], n2[1, landmark], [-500., 500.])

c1_c = @where(sim_neigh, :index1 .== idx[1], :index2 .== idx[2])[1, :fake]
c1_s = @where(sim_all, :index1 .== idx[1])[1, :fake]

cc = crosscor.(c1, c2, cc_params...)  |> sum
cc_c = [sum(crosscor.(c1, fake, cc_params...)) for fake in c1_c] |> sum
cc_s = [sum(crosscor.(c1, fake, cc_params...)) for fake in c1_s] |> sum


plot(-20:0.5:20, cc; fig_params...)
title!("Cross-correlogram between real cells")

plot(-20:0.5:20, cc_c; fig_params...)
title!("Complex model")

plot(-20:0.5:20, cc_s; fig_params...)
title!("Simple model")



# savefig(plotsdir("logbook", "21-04", "artificial-cells-simple.png"))
