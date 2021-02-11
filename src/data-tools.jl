using DrWatson
@quickactivate "ens"

using DataFrames
using Combinatorics


function get_pairs(data::DataFrame, kind::String)
	if kind == "neigh" || kind == "neighbors" || kind == "n"
		neigh = unique(get_neighbors(data, grouped=true)) 
		idx = map(length, neigh)
		neigh = neigh[idx .> 1]
		couples = Array{Int64, 1}[]
		for n in neigh
			push!(couples, collect(combinations(n, 2))...)
		end
		return couples

	elseif kind == "dist" || kind == "distant" || kind == "d"
		idx = [1:593;]
		dist = get_distant(data, idx, true)
		couples = Array{Int64, 1}[]
		for (i, d) in enumerate(dist)
			for x in d
				push!(couples, [i, x])
			end
		end
		couples = unique(sort.(couples))
		return couples

	elseif kind == "all" || kind == "a"
		return collect(combinations([1:593;], 2))
	end
end

function get_distant(df::DataFrame, idx, grouped=false)
	if typeof(idx) ≡ Int
		index = [idx]
	end

    rats = data[idx, :].rat
    sites = data[idx, :].site
    tetrodes = data[idx, :].tetrode

	if grouped
		indexes = Array{Int, 1}[]
		for (rat, site, tetrode) in zip(rats, sites, tetrodes)
			push!(indexes, findall((df.rat .== rat) .& (df.site .== site) .& (df.tetrode .!= tetrode)))
		end
		return indexes
	end

	indexes = Int[]
	for (rat, site, tetrode) in zip(rats, sites, tetrodes)
		push!(indexes, findall((df.rat .== rat) .& (df.site .== site) .& (df.tetrode .!= tetrode))...)
	end
	indexes
end


function get_neighbors(df::DataFrame, idx=[1:593;]; grouped=false)
	if typeof(idx) ≡ Int
		index = [idx]
	end

    rats = data[idx, :].rat
    sites = data[idx, :].site
    tetrodes = data[idx, :].tetrode

	if grouped
		indexes = Array{Int, 1}[]
		for (rat, site, tetrode) in zip(rats, sites, tetrodes)
			push!(indexes, findall((df.rat .== rat) .& (df.site .== site) .& (df.tetrode .== tetrode)))
		end
		return indexes
	end

	indexes = Int[]
	for (rat, site, tetrode) in zip(rats, sites, tetrodes)
		push!(indexes, findall((df.rat .== rat) .& (df.site .== site) .& (df.tetrode .== tetrode))...)
	end
	indexes
end


function active_neurons(n, low=-0.5, high=1.)
	idx = (sum(n .> high, dims=1) .> 1) .| (sum(n .< low, dims=1) .> 1)
	idx[:]
end
