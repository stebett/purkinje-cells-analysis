using DrWatson
@quickactivate "ens"

using Statistics
using ImageFiltering

# TODO: add inbounds
include(srcdir("utils.jl"))


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

function newSlice(spiketrains, landmarks; around=(-50, 50), convolution=false, σ=10, average=false, normalization=false, over=(-500, 500))

	s = slice(spiketrains, landmarks, around)

	if convolution
		s = convolve(s, σ)
	end

	if normalization
		s = slice(spiketrains, landmarks, over) |> x->convolve(x, σ) |> x->normalize(s, x)
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
		return dropnancols(s_avg)
	end

	dropnancols(s)
end

"""
	slice(spiketrain, landmark, around)

Takes spike times and landmark times as input and returns sparse array or matrix.
The legal combinations of types for `spiketrain` and `landmark` are: `Array{Number, 1}, Number`, `Array{Array{Number, 2}}, `Array{Number, 2}`

"""

function slice(spiketrain::Array{Float64,1}, landmark::Number, around::Tuple)::Array{Float64, 1}
	s = abs.(around) |> sum |> zeros

	if isnan(landmark)
        return fill!(s, NaN)
    end

    idxs = spiketrain[landmark + around[1] .< spiketrain .< landmark + around[2]]
	idxs = idxs .- landmark .- around[1] .+ 1
    s[floor.(Int, idxs)] .= 1
    s
end

function slice(spiketrain::Array{Float64,1}, landmarks::Array{Float64,1}, around::Tuple)::Array{Float64, 2}
	rows = abs.(around) |> sum
	cols = size(landmarks, 1)
	s = zeros(rows, cols)

    for (i, l) in enumerate(landmarks)
        s[:, i] .= slice(spiketrain, l, around)
    end
    s
end

function slice(spiketrains::Array{Array{Float64,1}, 1}, landmarks::Array{Float64,1}, around::Tuple)::Array{Float64, 2}
	rows = abs.(around) |> sum
	cols = size(spiketrains, 1)
	s = zeros(rows, cols)

    for (i, (spiketrain, l)) in enumerate(zip(spiketrains, landmarks))
        s[:, i] .= slice(spiketrain, l, around)
    end
    s
end

function slice(spiketrains::Array{Array{Float64,1}}, landmarks::Array{Array{Float64,1}}, around::Tuple)::Array{Float64, 2}
	rows = abs.(around) |> sum
	cols = map(length, landmarks) |> sum
	s = zeros(rows, cols)

	i = 1
    for (spiketrain, lands) in zip(spiketrains, landmarks)
		for l in lands 
			s[:, i] .= slice(spiketrain, l, around)
			i += 1
		end
    end
    s
end

"""
	convolve(slice [, σ])::Union{Array{Float64, 1}, Array{Float64, 2}}

Apply a gaussian kernel with std=σ on a sliced data.

# Arguments
- `slice::Union{Array{Number, 1}, Array{Number, 2}}`: the slice of spike times
- `σ::Int=10`:the std of the gaussian kernel
"""
function convolve(slice::Array{Float64, 1}, σ=10)::Array{Float64, 1}
    kernel = Kernel.gaussian((σ,))
    imfilter(slice, kernel, "circular")
end


function convolve(slices::Array{Float64, 2}, σ=10)::Array{Float64, 2}
    c = zeros(size(slices))
    for i = 1:size(slices, 2)
        c[:, i] .= convolve(slices[:, i], σ)
    end
    c
end

function normalize(target::T, baseline::T)::T where {T <: Array{Float64,1}}
	base_mean = mean(baseline)
	base_std = std(baseline)

    (target .- base_mean) ./ base_std
end

function normalize(target::T, baseline::T)::T where {T <: Array{Float64,2}}
	base_mean = mean(baseline, dims=1)
	base_std = std(baseline, dims=1)

    (target .- base_mean) ./ base_std
end
