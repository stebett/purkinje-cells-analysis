using DrWatson
@quickactivate "ens"

using DataFrames
using Combinatorics

# TODO new file, change get_pairs to couple() and strings to symbols
export get_pairs

function get_pairs(df::DataFrame, kind::String)
	if kind == "neigh" || kind == "neighbors" || kind == "n"
		neigh = get_neighbors(df) |> x->filter(y->length(y)>1, x)
	    couples = [x for n in neigh for x in collect(combinations(n, 2))]
		return couples

	elseif kind == "dist" || kind == "distant" || kind == "d"
		idx = [1:size(df, 1);]
		dist = get_distant(df, idx)
		couples = Array{Int64, 1}[]
		for (i, d) in enumerate(dist)
			for x in d
				push!(couples, [i, x])
			end
		end
		couples = unique(sort.(couples))
		return couples

	elseif kind == "all" || kind == "a"
		return collect(combinations([1:size(df, 1);], 2))
	end
end

function get_distant(df::DataFrame, idx)
	if typeof(idx) ≡ Int
		index = [idx]
	end

    rats = df[idx, :].rat
    sites = df[idx, :].site
    tetrodes = df[idx, :].tetrode

	indexes = Array{Int, 1}[]
	for (rat, site, tetrode) in zip(rats, sites, tetrodes)
		idx = findall((df.rat .== rat) .& (df.site .== site) .& (df.tetrode .!= tetrode))
		push!(indexes, df[idx, :index])
	end
	indexes
end


function get_neighbors(df::DataFrame)
	[g.index for g in groupby(df, [:rat, :site, :tetrode])]
end
