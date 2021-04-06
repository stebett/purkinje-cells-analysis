using DrWatson
@quickactivate :ens

using RData
using DataFrames
using DataFramesMeta
using Plots
using Spikes
using Arrow

include(srcdir("spline", "model_summaries.jl"))


inpath = "$(ARGS[1])results/postprocessed.RData"
outpath = "$(ARGS[1])results/result.arrow"


data = RData.load(inpath)["predictions"]

df = DataFrame(index1=Float64[], 
			   index2=Float64[], 
			   group=String[],
			   reference=String[],
			   n=Float64[],
			   ll_c1=Float64[],
			   ll_s1=Float64[],
			   ll_c2=Float64[],
			   ll_s2=Float64[],
			   )

for i in 1:length(data)
	try
		index1 = data[i]["index"][1]
		index2 = data[i]["index"][2]
		group = data[i]["group"]
		reference = data[i]["reference"]
		n = data[i]["n"]
		ll_c1 = data[i]["ll_c1"]
		ll_s1 = data[i]["ll_s1"]
		ll_c2 = data[i]["ll_c2"]
		ll_s2 = data[i]["ll_s2"]
		push!(df, [index1, index2, group, reference, n, ll_c1, ll_s1, ll_c2, ll_s2])
	catch e
		@show e
	end
end

result = @transform(df, c_better = (:ll_c1 .+ :ll_c2) .> (:ll_s1 .+ :ll_s2))

Arrow.write(outpath, result)
