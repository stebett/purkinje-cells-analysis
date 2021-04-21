using DrWatson
@quickactivate

using RCall
using DataFrames
using DataFramesMeta
using Arrow

batch = "8"
reference = "best"
group = "neigh"
idx1, idx2 = 438, 437
n = 40

simfile = scriptsdir("spline/modular/simulate-one.R")
infile_R = datadir("analyses/spline/batch-$batch/$reference-$group/out/data/$idx1-$idx2.RData")
outfile_R = datadir("analyses/spline/batch-$batch/$reference-$group/post-proc/simulated_$idx1-$idx2.rds")

run(`Rscript $simfile $n $infile_R $outfile_R`) 

infile_J = outfile_R
outfile_J = datadir("analyses/spline/batch-$batch/$reference-$group/results/simulated_$idx1-$idx2.arrow")

simulations = rcopy(R"readRDS($infile_J)")

df = DataFrame(index1=Float64[], index2=Float64[], group=String[], reference=String[], landmark=String[], fake=Vector{Vector{Vector{Float64}}}[])

function Base.vec(x::Float64)
	if isempty(x[1])
		return Float64[]
	end
	return Float64[x]
end

function extract(fake)
	r = (collect ∘ values)(fake)
	r = vec.(r)
end

index1 = simulations[:index1]
index2 = ismissing(simulations[:index2]) ? NaN : simulations[:index2] 
group = simulations[:group]
reference = simulations[:reference]
# landmark = simulations[:landmark]
landmark = "lift"
fake = extract(simulations[:fake])
transformed = [[trial[i] for trial in fake] for i in 1:n]
if !isempty(fake)
	push!(df, [index1, index2, group, reference, landmark, transformed])
end

Arrow.write(outfile_J, df)
