using DrWatson
@quickactivate "ens"

include(scriptsdir("load-data.jl"))
include(srcdir("spike-tools.jl"))

function interval(data, l1, l2)
	intervals = Float64[]
	idxs = Int[]
	for i = 1:size(data, 1)
		push!(intervals, abs.(data[i, l2] - data[i, l1])...)
		push!(idxs, [i for _ = 1:length(data[i, l1])]...)
	end
	intervals, idxs
end

