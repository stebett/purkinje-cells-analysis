using DrWatson
@quickactivate :ens

using RData
using Spikes
using DataFrames

include(srcdir("spline-pipeline.jl"))

function get_cell(s::String) 
	x = split(s, '.')
	rat = data.rat .== x[1]
	site = data.site .== x[2]
	tet = data.tetrode .== x[3]
	neuron = data.neuron .== replace(x[4], 't'=>"neuron")
	data[rat .& site .& tet .& neuron, :]
end

function make_couples(s::Vector{<:String})
	vcat(get_cell(s[1]), get_cell(s[2]))
end



data = load_data("data-v4.arrow"); # TODO change to v6

cells = readlines(datadir("cell-pairs.txt"))
x = [[cells[i], cells[i+1]] for i in 1:2:length(cells)]
cellpairs = make_couples.(x);


d1df = mkdf(sort(cellpair))
m1 = nothing
d2df = mkdf(sort(cellpair, rev=true))
m2 = nothing
