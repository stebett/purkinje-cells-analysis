using DrWatson
@quickactivate :ens

using JLD2 
using Spikes
using GLM
using CategoricalArrays
using DataFramesMeta
using Statistics
using Plots
using Arrow
using KernelEstimator
using Gadfly

includet(srcdir("spline", "mkdf.jl"))

data = load_data("data-v6.arrow")
batch = 7
inpath = "/home/ginko/ens/data/analyses/spline/batch-$batch/results/result.arrow"
inpath_ll = "/home/ginko/ens/data/analyses/spline/ll-batch-$batch/results/result.arrow"
result = Arrow.Table(inpath) |> DataFrame;
result = @where(result, :reference .== "multi", :variable .== "r.nearest")
result_ll = Arrow.Table(inpath_ll) |> DataFrame;

ll_n = @where(result_ll, :reference .== "best", :group .== "neigh")
ll_d = @where(result_ll, :reference .== "best", :group .== "dist")

neigh = couple(data, :n)

idx = neigh[20]
df = find(data, idx) |> mkdf
df = @where(df, :timeSinceLastSpike .<= 20)
sort!(df, :nearest, rev=true)
@with(df, scatter(:event, :nearest, xlabel="isi", ylabel="nearest"))
model = glm(@formula(event ~ nearest),df, Binomial(), ProbitLink())
pred = predict(model, df[:, [:nearest, :time]])

plot(df.nearest, pred)

spline = @where(result, :index .== Ref(idx))



reg = npr(df.nearest, df.event)
cb = bootstrapCB(df.nearest, df.event)


p1 = plot(spline.x, spline.mean, xlims=(1, 50), ylims=(-0.1, 0.2));
p2 = plot(df.nearest, reg);
plot(p1, p2)
