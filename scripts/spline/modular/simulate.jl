using DrWatson
@quickactivate :ens

using RCall
using DataFrames
using DataFramesMeta
using Arrow

inpath = ARGS[1] * "/post-proc/simulated.rds"
outpath = ARGS[1] * "/results/simulated.rds"

simulations = rcopy(R"readRDS($inpath)")

df = DataFrame(index1=Float64[], index2=Float64[], group=String[], reference=String[], fake=Vector{Vector{Float64}}[])

function Base.vec(x::Float64)
	if isempty(x[1])
		return Float64[]
	end
	return Float64[x]
end
extract(x) = values(x) |> collect |> k -> vec.(k) |> j->replace(k -> isempty(k[1]) ? Float64[] : k, j)

foreach(simulations) do row
	index1 = row[:index1]
	index2 = ismissing(row[:index2]) ? NaN : row[:index2] 
	group = row[:group]
	reference = row[:reference]
	fake = extract(row[:fake])
	@show index1 index2
	if !isempty(fake)
		push!(df, [index1, index2, group, reference, fake])
	end
end

Arrow.write(outpath, df)