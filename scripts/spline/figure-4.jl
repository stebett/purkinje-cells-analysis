using DrWatson
@quickactivate :ens

using DataFramesMeta
using DataFrames
using Statistics
using Plots
using Arrow
using Spikes

batch = 8
inpath_all = "/home/ginko/ens/data/analyses/spline/batch-$batch/best-all/results/simulated.arrow"
sim_all = Arrow.Table(inpath_all) |> DataFrame

data = load_data("data-v6.arrow")
data_all = @where(data, in.(:index, Ref(sim_all.index1)))

sort!(data_all, :index)
sort!(sim_all, :index1)
@assert data_all.index == sim_all.index1
@assert length.(data_all.lift) == length.(sim_all.fake)



r = cut(data_all.t ,data_all.lift, [-600., 600.])
r = [x .- 600 for x in r]
f = [k for x in sim_all.fake for k in x]

bins_r = bin.(r, 0, 1200)
bins_f = bin.(f, -595, 599)

cc = crosscor.(r, f, -80, 80, 1)


