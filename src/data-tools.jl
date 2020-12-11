using DrWatson
@quickactivate "ens"



"""
	filterData(df, [column, index, spec, trial])

Select recordings based on column name, then select again taking neighbors/distant/all neurons based on the previous selection

# Arguments
- `df::DataFrame`: the dataframe containing the data
- `rat::String="all"`: accepts index for rat
- `site::String="all"`: accepts index for site
- `groupby::String="none"`: accepts names of columns
- `index::Union{Int, String}="all"`: accepts indexes for the selected column
- `spec::String="none"`: also accepts `"neigh"`, `"dist"`, 
- `trial`:::Union{Int, String}="all"`: index of trial, accepts also `"all"`

# Examples

	julia> filterData(data)
	return all spiketrains with all trials

	julia> filterData(data, index=1)
	return spiketrain with `index = 1`

	julia> filterData(data, index=1, spec="neigh")
	return spiketrain with `index = 1` along with neighbor neurons

	julia> filterData(data, spec="neigh")
	return all spiketrains grouped by neighboring neurons

	julia> filterData(data, rat="R16", site=13)
	return all spiketrains coming from one registration
"""

function filterData(df; rat="all", site="all", groupby="none", index="all", spec="none")
	selection = deepcopy(df);

	if index ≡ "all"
		index = [1:593;]

	elseif typeof(index) ≡ Int
		index = [index]
	end

	if rat ≠ "all"
		intersect!(index, findall(selection.rat .≡ rat))
	end

	if site ≠ "all"
		intersect!(index, findall(selection.site .≡ site))
	end

	if spec ≡ "neigh"
		push!(index, get_neighbors(selection, index)...)

	elseif spec ≡ "dist"
		index = get_distant(selection, index)
	end

	selection[unique(index), 5:end]
end

function filterLandmarks(df, index)
end

"""
	standardize_landmarks(landmarks)

Takes an array of arrayis containing the landmarks times and returns where the rows are the landmarks times for corresponding recording site, with -1 instead of `missing`
"""
function standardize_landmarks(landmarks::Array{Array{Float64,1},1})::Array{Float64, 2}
    maxLen = maximum(map(length, landmarks))
    std_landmarks = zeros(maxLen, size(landmarks, 1))

    for (i, row) in enumerate(landmarks)
        std_landmarks[:, i] .= [row..., [-1 for _ in 1:maxLen-length(row)]...]
    end
    std_landmarks
end
	
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
