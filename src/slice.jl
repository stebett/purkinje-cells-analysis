using DrWatson
@quickactivate "ens"

include(srcdir("data-tools.jl"))
# All spikes / Only near landmark / Only 1 trial, fixed size / Averaged trials
# Convolution type (normal with σ, step with n), normalization
#
# Behaviour with nan
# other return values? (ex. new indexing, landmarks, speed)
#

"""

# Arguments

| **Neuron**      | | One neuron    | One's neighboring neurons | One's distant neurons | All neurons | All neighboring neurons | All distant neurons |All neurons from the same site (same registration) | All neurons from the same rat |
| **Trial**       | | One trial     | Averaged trials         | All single trials   | 
| **Convolution** | | Rectangular   | Gaussian                |
| **args**        | | Normalization | 


"""


"""

	slice(spiketrains, landmarks, [average=false, around=(-50, 50), convolution='rect'])

Select the spikes around a landmark and apply convolution and optionally averaging before returning

# Arguments

- `spiketrains::
- `landmarks::
- `average::Bool=false`
- `around::Tuple=(-50, 50)`
- `convolution::String="rect"`: the kind of convolution to apply


"""


function newSlice(spiketrains, landmarks; around=(-50, 50), convolution=false, σ=10, average=false, normalization=false, over=(-500, 500), )

	s = slice(spiketrains, landmarks, around)

	if convolution
		s = convolve(s, σ)
	end

	if normalization
		s = normalize(s, convolve(slice(spiketrains, landmarks, over), σ))
	end

	if average
		idx = map(length, landmarks) |> x->pushfirst!(x, 0) |> cumsum
		idx_list = [[idx[i]+1:idx[i+1];] for i = 1:length(idx) - 1]

		rows = abs.(around) |> sum
		cols = (map(length, idx_list) .>= 1) |> sum
		s_avg = zeros(rows, cols)
		k = 1
		for i = idx_list 
			s_avg[:, k] = mean(s[:, i], dims=2)
			k += 1
		end
		return dropnancols(s_avg)[1]
	end

	dropnancols(s)[1]
end


"""
	filterSpikes(df, [column, index, spec, trial])

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

	julia> filterSpikes(data)
	return all spiketrains with all trials

	julia> filterSpikes(data, index=1)
	return spiketrain with `index = 1`

	julia> filterSpikes(data, index=1, spec="neigh")
	return spiketrain with `index = 1` along with neighbor neurons

	julia> filterSpikes(data, spec="neigh")
	return all spiketrains grouped by neighboring neurons

	julia> filterSpikes(data, rat="R16", site=13)
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
