using DrWatson
@quickactivate "ens"

using Statistics
using ImageFiltering
using OffsetArrays

# TODO: add inbounds
# TODO: some data (ex. idx=21) have landmarks that are taken at times larger than the spike times, how should I fix that?
include(srcdir("utils.jl"))


"""

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

function slice(spiketrains, landmarks; around=[-50, 50], convolution=false, σ=10, average=false, normalization=false, over=[-500, 500], binsize=1.)

	s = slice_(spiketrains, landmarks, around, binsize)


	if convolution || normalization
		pad = [around[1] - 2σ, around[2] + 2σ]
		tmp = convolve(slice_(spiketrains, landmarks, pad, binsize), Int(σ/binsize))
		s .= tmp
	end

	if normalization
		pad = [over[1] - 2σ, over[2] + 2σ]
		s = slice_(spiketrains, landmarks, pad, binsize) |> x->convolve(x, σ) |> x->norm_slice(s, x)
	end

	if average
		idx = map(length, landmarks) |> x->pushfirst!(x, 0) |> cumsum
		idx_list = [[idx[i]+1:idx[i+1];] for i = 1:length(idx) - 1]

		rows = diff(around)[1]
		cols = (map(length, idx_list) .>= 1) |> sum
		s_avg = zeros(rows, cols)
		k = 1
		for i = idx_list 
			s_avg[:, k] = mean(s[:, i], dims=2)
			k += 1
		end
		return s_avg
	end
	s
end

function bigSlice(data, binsize=1, around=4, average=true, normalization=true) 
	σ = 10
	over = [-5000, -3000]

	s = bigSlice(data.t, data.lift, data.cover, data.grasp, binsize, around)

	if normalization
		pad = [over[1] - 2σ, over[2] + 2σ]
		s = slice_(data.t, data.lift, pad) |> x->convolve(x, σ) |> x->norm_slice(s, x)
	end

	if average
		idx = map(length, data.lift) |> x->pushfirst!(x, 0) |> cumsum
		idx_list = [[idx[i]+1:idx[i+1];] for i = 1:length(idx) - 1]

		rows = 2binsize + 2around*binsize
		cols = (map(length, idx_list) .>= 1) |> sum
		s_avg = zeros(rows, cols)
		k = 1
		for i = idx_list 
			s_avg[:, k] = mean(s[:, i], dims=2)
			k += 1
		end
		return s_avg
	end
	s
end

function cut(spiketrain::Array{Float64,1}, landmark::Number, around::AbstractVector)::Array{Float64, 1}
    idxs = spiketrain[landmark + around[1] .< spiketrain .< landmark + around[2]]
	return idxs .- landmark .- around[1]
end

function cut(spiketrain::Array{Float64,1}, landmarks::Array{Float64,1}, around::AbstractVector)::Array{Array{Float64, 1}, 1}

	s = Array{Float64, 1}[]

    for l in landmarks
		push!(s, cut(spiketrain, l, around))
    end
    s
end

function cut(spiketrains::Array{Array{Float64,1}, 1}, landmark::Number, around::AbstractVector)::Array{Array{Float64, 1}, 1}
	s = Array{Float64, 1}[]

    for st in spiketrains
		push!(s, cut(st, landmark, around))
    end
    s
end

function cut(spiketrains::Array{Array{Float64,1}, 1}, landmarks::Array{Float64,1}, around::AbstractVector)::Array{Array{Float64, 1}, 1}
	s = Array{Float64, 1}[]

    for (spiketrain, l) in zip(spiketrains, landmarks)
		push!(s, cut(spiketrain, l, around))
    end
    s
end

function cut(spiketrains::Array{Array{Float64,1}}, landmarks::Array{Array{Float64,1}}, around::AbstractVector)::Array{Array{Float64, 1}, 1}

	s = Array{Float64, 1}[]

	i = 1
    for (spiketrain, lands) in zip(spiketrains, landmarks)
		for l in lands 
			push!(s, cut(spiketrain, l, around))
		end
    end
    s
end

function bigSlice(spiketrain::Array{T, 1}, lift::T, cover::T, grasp::T, nbins, around)::Array{T, 1} where {T <: Float64}
	reachBin = (cover - lift) / nbins
	graspBin = (grasp - cover) / nbins
	aroundBin = 50. / nbins

	binsizes = [fill(aroundBin, nbins*around)..., fill(reachBin, nbins)..., fill(graspBin, nbins)..., fill(aroundBin, nbins*around)...]

	t0 = lift - nbins*around*aroundBin
	t1 = grasp + nbins*around*aroundBin

	s = spiketrain[t0 .<= spiketrain .<= t1]
	sbin = zeros(2nbins + 2around*nbins)

	if length(s) == 0
		return sbin
	end
	s .= s .- t0

	t = 0
	for i in 1:length(sbin)
		sbin[i] = sum(0 .<= s.-t .< binsizes[i]) / binsizes[i]
		t += binsizes[i]
	end
	sbin
end

function bigSlice(spiketrains::T, lift::T, cover::T, grasp::T, nbins=4, around=2)::Array{Float64, 2} where {T <: Array{Array{Float64, 1}, 1}}
	rows = 2nbins+2around*nbins
	cols = map(length, lift) |> sum
	s = zeros(rows, cols)

	i = 1
	for j in 1:length(spiketrains)
		for k in 1:length(lift[j])
			s[:, i] .= bigSlice(spiketrains[j], lift[j][k], cover[j][k], grasp[j][k], nbins, around)
			i += 1
		end
	end
	s
end

function slice_(spiketrain::Array{Float64,1}, landmark::Number, around::AbstractVector, binsize=1.)::Array{Float64, 1}
	s = zeros(round(Int, diff(around)[1]/binsize))

	if isnan(landmark)
        return fill!(s, NaN)
    end

    idxs = spiketrain[landmark + around[1] .< spiketrain .< landmark + around[2]]
	idxs = idxs .- landmark .- around[1] 
    s[ceil.(Int, idxs ./ binsize)] .= 1
    s
end

function slice_(spiketrain::Array{Float64,1}, landmarks::Array{Float64,1}, around::AbstractVector, binsize=1.)::Array{Float64, 2}
	rows = round(Int, diff(around)[1]/binsize)
	cols = size(landmarks, 1)
	s = zeros(rows, cols)

    for (i, l) in enumerate(landmarks)
        s[:, i] .= slice_(spiketrain, l, around, binsize)
    end
    s
end

function slice_(spiketrains::Array{Array{Float64,1}, 1}, landmarks::Array{Float64,1}, around::AbstractVector, binsize=1.)::Array{Float64, 2}
	rows = round(Int, diff(around)[1]/binsize)
	cols = size(spiketrains, 1)
	s = zeros(rows, cols)

    for (i, (spiketrain, l)) in enumerate(zip(spiketrains, landmarks))
        s[:, i] .= slice_(spiketrain, l, around, binsize)
    end
    s
end

function slice_(spiketrains::Array{Array{Float64,1}}, landmarks::Array{Array{Float64,1}}, around::AbstractVector, binsize=1.)::Array{Float64, 2}
	rows = round(Int, diff(around)[1]/binsize)
	cols = map(length, landmarks) |> sum
	s = zeros(rows, cols)

	i = 1
    for (spiketrain, lands) in zip(spiketrains, landmarks)
		for l in lands 
			s[:, i] .= slice_(spiketrain, l, around, binsize)
			i += 1
		end
    end
    s
end

"""
	convolve(s [, σ])::Union{Array{Float64, 1}, Array{Float64, 2}}

Apply a gaussian kernel with std=σ on a sliced data.

# Arguments
- `s::Union{Array{Number, 1}, Array{Number, 2}}`: the slice of spike times
- `σ::Int=10`:the std of the gaussian kernel
"""
function convolve(s::Array{Float64, 1}, σ=10)::Array{Float64, 1}
    kernel = Kernel.gaussian((σ,))
	OffsetArrays.no_offset_view(imfilter(s, kernel, Inner()))
end


function convolve(s::Array{Float64, 2}, σ=10)::Array{Float64, 2}
	c = zeros(size(s, 1) - 4σ, size(s, 2))
    for i = 1:size(s, 2)
        c[:, i] .= convolve(s[:, i], σ)
    end
    c
end

function norm_slice(target::T, baseline::T)::T where {T <: Array{Float64,1}}
	base_mean = mean(baseline)
	base_std = std(baseline)

    (target .- base_mean) ./ base_std
end

function norm_slice(target::T, baseline::T)::T where {T <: Array{Float64,2}}
	base_mean = mean(baseline, dims=1)
	base_std = std(baseline, dims=1)

    (target .- base_mean) ./ base_std
end
