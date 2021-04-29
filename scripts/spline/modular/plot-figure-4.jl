using DrWatson
@quickactivate :ens

using DataFramesMeta
using DataFrames
using Plots
using Arrow
using StatsBase

include(srcdir("spline", "model_summaries.jl"))

# Load results
batch = 8
reference = "best"

batch = ARGS[1]
reference = ARGS[2]

inpath_ll = "/home/ginko/ens/data/analyses/spline/ll-batch-7/results/result.arrow"
inpath_n = "/home/ginko/ens/data/analyses/spline/batch-$batch/$reference-neigh/results/simulated.arrow"
inpath_a = "/home/ginko/ens/data/analyses/spline/batch-$batch/$reference-all/results/simulated.arrow"
plots_path = "data/analyses/spline/batch-$batch/plots/"

data = load_data(:last)
sim_neigh = Arrow.Table(inpath_n) |> DataFrame
sim_all = Arrow.Table(inpath_a) |> DataFrame
result_ll = Arrow.Table(inpath_ll) |> DataFrame

# Select indexes
ll_n = @where(result_ll, :reference .== reference, :group .== "neigh")
best_neigh = best_model(sim_neigh, ll_n)
idx_n = [[i1, i2] for (i1, i2) in zip(best_neigh.index1, best_neigh.index2)]
idx_a = sim_all.index1

indexes = filter(x->(x[1] in idx_a), idx_n)

idx = indexes[1]

n1 = @where(data, :index .== idx[1])
n2 = @where(data, :index .== idx[2])

landmark = [:lift, :cover, :grasp][get_active_events(n1)[1]]
cc_params = [-20, 20, 0.5]
fig_params = (legend = false, ylabel = "Counts", xlabel = "Time (ms)")

c1 = abscut(n1[1, :t], n1[1, landmark], [-500., 500.])
c2 = abscut(n2[1, :t], n2[1, landmark], [-500., 500.])

c1_c = @where(sim_neigh, :index1 .== idx[1], :index2 .== idx[2])[1, :fake]
c1_s = @where(sim_all, :index1 .== idx[1])[1, :fake]

cc = crosscor.(c1, c2, cc_params...) |> sum
cc_c = [sum(crosscor.(c1, fake, cc_params...)) for fake in c1_c] |> sum
cc_s = [sum(crosscor.(c1, fake, cc_params...)) for fake in c1_s] |> sum


using Makie

p1 = plot(-20:0.5:20, cc; fig_params...)
title!("Cross-correlogram between real cells")

p2 = plot(-20:0.5:20, cc_c; fig_params...)
title!("Complex model")

p3 = plot(-20:0.5:20, cc_s; fig_params...)
title!("Simple model")



# savefig(plotsdir("logbook", "21-04", "artificial-cells-simple.png"))
