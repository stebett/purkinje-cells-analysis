using DrWatson
@quickactivate :ens

using JLD2 
using Spikes
using GLM
using CategoricalArrays
using DataFramesMeta

includet(srcdir("spline", "mkdf.jl"))

data = load_data("data-v6.arrow")

neigh = couple(data, :n)
idx = neigh[1]

df = find(data, idx) |> mkdf
df = @where(df, :timeSinceLastSpike .<= 20)
df.isi = categorical(df.timeSinceLastSpike)

spl = fit(SmoothingSpline, df.isi, df.nearest, 400.)
Ypred = SmoothingSplines.predict(spl, df[df.trial .== 1, :nearest])
plot(Ypred)
