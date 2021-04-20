using DrWatson
@quickactivate :ens

using RCall
using DataFrames
using DataFramesMeta
using Arrow

# respath = "data/analyses/spline/batch-test/best-neigh"
respath = ARGS[1]
inpath = respath * "/post-proc/simulated.rds"
outpath = respath * "/results/simulated.arrow"

simulations = rcopy(R"readRDS($inpath)")

df = DataFrame(index1=Float64[], index2=Float64[], group=String[], reference=String[], landmark=String[], fake=Vector{Vector{Float64}}[])

function Base.vec(x::Float64)
	if isempty(x[1])
		return Float64[]
	end
	return Float64[x]
end

function extract(fake)
	r = (collect ∘ values)(fake)
	r = vec.(r)
	replace(x->(isempty(x) || isempty(x[1]) ? Float64[] : x), r)
end

foreach(simulations) do row
	index1 = row[:index1]
	index2 = ismissing(row[:index2]) ? NaN : row[:index2] 
	group = row[:group]
	reference = row[:reference]
	fake = extract(row[:fake])
	if !isempty(fake)
		push!(df, [index1, index2, group, reference, fake])
	end
end

df = filter(x->!all(isempty.(x.fake)), df)
Arrow.write(outpath, df)
