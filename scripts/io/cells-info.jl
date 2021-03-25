using DrWatson
@quickactivate "ens"

include("scripts/io/load-full.jl")

d = Dict()
map(eachrow(data_full)) do row
	d[row.index] = (name=row.name, path=row.path, s=row.s)
end
