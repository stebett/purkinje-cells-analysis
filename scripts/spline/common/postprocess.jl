using DrWatson
@quickactivate :ens

using RData
using DataFrames
using DataFramesMeta
using Plots
using Spikes
using Arrow

include(srcdir("spline", "models_summaries.jl"))


inpath = "$(ARGS[1])results/postprocessed.RData"
outpath = "$(ARGS[1])results/result.arrow"


data = RData.load(inpath)["predictions"]

result = DataFrame(index=Union{Float64, Vector{Float64}}[], 
				   group=String[],
				   reference=String[],
				   variable=String[],
				   x=Vector{Float64}[],
				   mean=Vector{Float64}[],
				   sd=Vector{Float64}[])

for row in data
	variables  = filter(x -> (x != "index" && x!= "group" && x != "reference"), 
						row.index2name)

	index = row["index"]
	group = row["group"]
	reference = row["reference"]

	for v in variables
		push!(result, (index, group, reference, v, row[v]["x"], row[v]["mean"], row[v]["sd"]))
	end
end

Arrow.write(outpath, result)
