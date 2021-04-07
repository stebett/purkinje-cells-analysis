using DrWatson
@quickactivate :ens

using RData
using DataFrames
using DataFramesMeta
using Spikes
using Arrow

include(srcdir("spline", "model_summaries.jl"))


inpath = "$(ARGS[1])results/postprocessed.RData"
outpath = "$(ARGS[1])results/result.arrow"


data = RData.load(inpath)["predictions"]

result = DataFrame(index1=Float64[],
				   index2=Float64[], 
				   group=String[],
				   reference=String[],
				   variable=String[],
				   x=Vector{Float64}[],
				   mean=Vector{Float64}[],
				   sd=Vector{Float64}[])

for row in data
	variables  = filter(x -> (x != "index" && x!= "group" && x != "reference"), 
						row.index2name)

	index1 = row["index"][1]
	index2 = length(row["index"]) > 1 ? row["index"][2] : NaN
	group = row["group"]
	reference = row["reference"]

	for v in variables
		push!(result, (index1, index2, group, reference, v, row[v]["x"], row[v]["mean"], row[v]["sd"]))
	end
end

Arrow.write(outpath, result)
