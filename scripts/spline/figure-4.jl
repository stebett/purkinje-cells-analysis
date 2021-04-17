using DrWatson
@quickactivate :ens

using DataFramesMeta
using DataFrames
using Statistics
using Plots
using Arrow
using Spikes
using StatsBase

batch = 8

inpath_all = datadir("analyses/spline/batch-$batch/best-all/results/simulated.arrow"
sim_all = Arrow.Table(inpath_all) |> DataFrame

inpath_neigh = datadir("analyses/spline/batch-$batch/best-neigh/results/simulated.arrow"
sim_neigh = Arrow.Table(inpath_neigh) |> DataFrame

data = load_data("data-v6.arrow")
idx = @where(data, :rat .== "R17", :site .== "39", :tetrode .== "tet2").index

landmark = :grasp
c1 = cut(find(data, idx[1], :t)[1], find(data, idx[1], landmark)[1], [-600., 600.])
c2 = cut(find(data, idx[2], :t)[1], find(data, idx[2], landmark)[1], [-600., 600.])

cc = crosscor.(c1, c2, -40, 40, 0.5) |> x->zscore.(x) |> sum |> plot


c1_s = @where(sim_all, :index1 .== idx[1]) |> x->[j .+ 600 for k in x.fake for j in k]
cc_s = crosscor.(c1_s, c1, -80, 80, 1) |> sum
plot(cc_s)

# Complex model
c1_c = @where(sim_neigh, :index1 .== idx[1]) |> x->[j .+ 600 for k in x.fake for j in k]
cc_c = crosscor.(c1_c, c1, -80, 80, 1) |> sum
plot(cc_c)
