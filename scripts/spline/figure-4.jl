using DrWatson
@quickactivate :ens

using RCall
using DataFrames
using DataFramesMeta
using Plots

batch = 7
inpath = "/home/ginko/ens/data/analyses/spline/batch-$batch/results/simulations.rds"

simulations = rcopy(R"readRDS($inpath)")

df = DataFrame(index1=Float64[], index2=Float64[], group=String[], reference=String[], fake1=Any[], fake2=Any[])

extract(x, idx) = values(x) |> collect |> k->getindex.(k, idx)

foreach(simulations) do row
	index1 = row[:index][1]
	index2 = length(row[:index]) > 1 ? row[:index][2] : NaN
	group = row[:group]
	reference = row[:reference]
	fake1 = extract(row[:fake], 1)
	fake2 = extract(row[:fake], 1)
	if !isempty(fake)
		push!(df, [index1, index2, group, reference, fake])
	end
end


