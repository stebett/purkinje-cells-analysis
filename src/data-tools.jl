using DrWatson
@quickactivate "ens"


function get_neighbors(df::DataFrame, idx, grouped=false)
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

function find_broken_landmarks(data)
	broken = Int[]
	for i in 1:size(data, 1)
		l = map(length, data[i, ["lift", "cover", "grasp"]])
		if !all(y -> y == l[1], l)
			push!(broken, i)
		end
	end
	broken
end
