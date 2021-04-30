using DrWatson
@quickactivate :ens

using RCall
using DataFrames
using DataFramesMeta
using Arrow
using TOML

pardir = ARGS[1]
inpath = ARGS[2]
outpath = ARGS[3]
n = TOML.parsefile(pardir * "/params.toml")["mkdf"]["n_sims"]

simulations = rcopy(R"readRDS($inpath)")
data = load_data(:last)


df = DataFrame(index1=Float64[], index2=Float64[], group=String[], reference=String[], landmark=Union{Nothing, String}[], fake=Vector{Vector{Vector{Float64}}}[])

function Base.vec(x::Float64)
	if isempty(x[1])
		return Float64[]
	end
	return Float64[x]
end

function extract(fake)
	result = (collect ∘ values)(fake)
	[vec.(r) for r in result]
end


for row in simulations
	index1 = row[:index1]
	index2 = ismissing(row[:index2]) ? NaN : row[:index2] 
	group = row[:group]
	reference = row[:reference]
	landmark = row[:landmark]
	fake = extract(row[:fake])
	if length(@where(data, :index .== index1).lift[1]) == length(fake) # TODO: make correlation dependent on trials 
		transformed = [[trial[i] for trial in fake] for i in 1:n]
		if !isempty(transformed)
			push!(df, [index1, index2, group, reference, landmark, transformed])
		end
	end
end

df = filter(x->!all(isempty.(x.fake)), df)
Arrow.write(outpath, df)
