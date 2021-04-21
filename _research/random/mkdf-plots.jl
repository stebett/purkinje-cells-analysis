using DrWatson
@quickactivate :ens

using Distributions
using StatsPlots; gr(size=(800,800))
using GLM
using DataFrames, Query
using HypothesisTests

include(srcdir("spline", "mkdf.jl"))
data = load_data("data-v6.arrow");


neigh = couple(data, :n)
dist = couple(data, :d)


#%

idx = neigh[1]
df = find(data, idx) |> mkdf
@df df violin(:event, :nearest)
@df df boxplot!(:event, :nearest, alpha=0.5, c=:green)
g = groupby(df, :event) 
ApproximateTwoSampleKSTest(g[1].nearest, g[2].nearest)
UnequalVarianceTTest(g[1].nearest, g[2].nearest)

# Some neurons are correlated positively
# Some neurons negatively
# And other don't show an effect because
#    1. the firing rate of the distant neuron is too high
#    2. There are not enough samples



idxd = dist[53]
dfd = find(data, idxd) |> mkdf
@df dfd violin(:event, :nearest)
@df dfd boxplot!(:event, :nearest, alpha=0.5, c=:green)
gd = groupby(dfd, :event) 
ApproximateTwoSampleKSTest(gd[1].nearest, gd[2].nearest)
UnequalVarianceTTest(gd[1].nearest, gd[2].nearest)

#% 

idxd = dist[56]
dfd = find(data, idxd) |> mkdf
@df dfd histogram2d(:nearest, :timeSinceLastSpike, bins=100, xlims=(0, 50), ylims=(0, 50))
xlabel!("Nearest")
ylabel!("timeSinceLastSpike")

idx = dist[1]
df = find(data, idx) |> mkdf
@df df histogram2d(:nearest, :timeSinceLastSpike, bins=400, xlims=(0, 20), ylims=(0, 20))
xlabel!("Nearest")
ylabel!("timeSinceLastSpike")

#%

idx = neigh[1]
df = find(data, idx) |> mkdf
proc = @from i in df begin
	@where i.timeSinceLastSpike < 10
	@select {i.timeSinceLastSpike, i.nearest}
	@collect DataFrame
end
groups = groupby(proc, :timeSinceLastSpike)
@df 
plot([violin(x.timeSinceLastSpike, x.nearest) for x in groups]...)

@df df violin(:event, :nearest)
@df df boxplot!(:event, :nearest, alpha=0.5, c=:green)
g = groupby(df, :event) 
ApproximateTwoSampleKSTest(g[1].nearest, g[2].nearest)
UnequalVarianceTTest(g[1].nearest, g[2].nearest)
