using DrWatson
@quickactivate :ens

using RCall
using DataFrames
using DataFramesMeta
using Arrow

respath = "data/analyses/spline/batch-8/best-all"
respath = ARGS[1]
inpath = respath * "/post-proc/simulated.rds"
outpath = respath * "/results/simulated.arrow"

simulations = rcopy(R"readRDS($inpath)")

df = DataFrame(index1=Float64[], index2=Float64[], group=String[], reference=String[], fake=Vector{Vector{Float64}}[])

function Base.vec(x::Float64)
	if isempty(x[1])
		return Float64[]
	end
	return Float64[x]
end

function extract(x)
	r = (collect ∘ values)(x)
	if r[1] isa String
		return []
	end

	r = vec.(r)
	replace(x->(isempty(x[1]) ? Float64[] : x), r)
end

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
