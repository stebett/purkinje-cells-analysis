using DrWatson
@quickactivate :ens

using KernelEstimator
using StatsPlots
using Spikes
using Query

include(srcdir("spline", "mkdf.jl"))

neigh = couple(data, :n)
data = load_data("data-v6.arrow");

idx = neigh[1]
df = find(data, idx) |> mkdf

train = @from r in df begin
	@where r.trial == 1 
	@select {X=r.timeSinceLastSpike, Y=r.nearest}
	@collect DataFrame
end


@df train npr(:X, :Y, xeval=[1:20;])
