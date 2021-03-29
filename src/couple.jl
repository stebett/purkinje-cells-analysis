
function couple(df::DataFrame, kind::Symbol)
	if kind == :n || kind == :neigh
		neigh = get_neighbors(df) |> x->filter(y->length(y)>1, x)
	    couples = [x for n in neigh for x in collect(combinations(n, 2))]
		return couples

	elseif kind == :d || kind == :dist
		dist = get_distant(df)
		couples = unique(sort.(dist))
		return couples

	elseif kind == :a 
		return collect(combinations(df.index, 2))
	end
end


function get_distant(df::DataFrame)

    rats = df[:, :rat]
    sites = df[:, :site]
    tetrodes = df[:, :tetrode]
	indexes = df[:, :index]
	dist = []

	for (rat, site, tetrode, index) in zip(rats, sites, tetrodes, indexes)
		idx = df[(df.rat .== rat) .& (df.site .== site) .& (df.tetrode .!= tetrode), :index]
		for i in idx
			push!(dist, [index, i])
		end
	end
	dist
end

function get_neighbors(df::DataFrame)
	[g.index for g in groupby(df, [:rat, :site, :tetrode])]
end
