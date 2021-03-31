using DrWatson
@quickactivate :ens

using CategoricalArrays
using Distributions
using StatsPlots; pyplot(size=(800,800))
using Weave
using DataFrames

include(srcdir("spline", "mkdf.jl"));
data = load_data("data-v6.arrow");


neigh = couple(data, :n);
dist = couple(data, :d);


#' # Neighbor couple
idx = neigh[10];
df = find(data, idx) |> mkdf;
tmp = df[df.timeSinceLastSpike .< 21, [:timeSinceLastSpike, :nearest, :previousIsi, :time]];
tmp.isi = tmp.timeSinceLastSpike |> categorical
tmp.nearest = tmp.nearest |> categorical
cticks(ctg::CategoricalArray) = (1:length(levels(ctg)), levels(ctg));
@df tmp violin(levelcode.(:isi), levelcode.(:nearest), xticks=cticks(:isi), yscale=:log10);
xlabel!("isi");
ylabel!("nearest")

#' # Distant couple
idx = dist[10];
df = find(data, idx) |> mkdf;
tmp = df[df.timeSinceLastSpike .< 21, [:timeSinceLastSpike, :nearest, :previousIsi, :time]];
tmp.isi = tmp.timeSinceLastSpike |> categorical
tmp.nearest = tmp.nearest |> categorical
cticks(ctg::CategoricalArray) = (1:length(levels(ctg)), levels(ctg));
@df tmp violin(levelcode.(:isi), levelcode.(:nearest), xticks=cticks(:isi), yscale=:log10);
xlabel!("isi");
ylabel!("nearest")

weave("/home/ginko/ens/notebooks/glm/mkdf-plots.jl")
