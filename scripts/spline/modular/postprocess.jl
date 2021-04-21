using DrWatson
@quickactivate :ens

using RData
using DataFrames
using DataFramesMeta
using Spikes
using Arrow

include(srcdir("spline", "model_summaries.jl"))

# inpath = "/home/ginko/ens/data/analyses/spline/batch-test/best-neigh/post-proc/fit.RData"

inpath = ARGS[1]
outpath = ARGS[1]


data = RData.load(inpath)["predictions"]

result = DataFrame(index1=Float64[],
				   index2=Float64[], 
				   group=String[],
				   reference=String[],
				   landmark=String[],
				   variable=String[],
				   x=Vector{Float64}[],
				   mean=Vector{Float64}[],
				   sd=Vector{Float64}[])

for row in data
	variables  = filter(x -> (x != "index1" && 
							  x != "index2" &&
							  x != "group" &&
							  x != "reference" &&
							  x != "landmark"), 
						row.index2name)

	index1 = row["index1"]
	index2 = ismissing(row["index2"]) ? NaN : row["index2"]
	group = row["group"]
	reference = row["reference"]
	landmark = row["landmark"]

	for v in variables
		push!(result, (index1, index2, group, reference, landmark, v, row[v]["x"], row[v]["mean"], row[v]["sd"]))
	end
end

Arrow.write(outpath, result)
