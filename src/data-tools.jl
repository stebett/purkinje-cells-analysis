using DrWatson
@quickactivate "ens"

using DataFrames



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

function active_neurons(n, low=-0.5, high=1.)
	idx = (sum(n .> high, dims=1) .> 1) .& (sum(n .< low, dims=1) .> 1)
	idx[:]
end

function single_trials(df, landmark::String)
	new_df = DataFrame(rat=String[], site=String[], tetrode=String[], neuron=String[], lift=Float64[], cover=Float64[], grasp=Float64[], t=Array{Float64, 1}[])

	trials = slice(df["t"], df[landmark])

	idx = map(length, df[landmark]) |> x->pushfirst!(x, 0) |> cumsum
	idx_list = [[idx[i]+1:idx[i+1];] for i = 1:length(idx) - 1]

	for (old_idx, trial_idxs) = enumerate(idx_list)
		for (lm_idx, trial_idx) = enumerate(trial_idxs)
			push!(new_df, [values(df[old_idx, ["rat", "site", "tetrode", "neuron"]])...,  df[old_idx, "lift"][lm_idx], df[old_idx, "cover"][lm_idx], df[old_idx, "grasp"][lm_idx], trials[:,trial_idx]])
		end
	end
	new_df
end
