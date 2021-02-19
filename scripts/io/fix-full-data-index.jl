using DrWatson
@quickactivate :ens

include(scriptsdir("io", "load-full.jl"))

function extract_index(df::DataFrame, path::String, name::String)::Int
	rat, block = split(path, "/")[[5, 7]]
	site = block[6:end]
	tet, cell = split(name, ".")
	neuron = replace(cell, "t"=>"neuron")
	idx = df[((df.rat .== rat) .& (df.site .== site) .& (df.tetrode .== tet) .& (df.neuron .== neuron)), "index"]

	@assert length(idx) == 1
	idx[1]
end
