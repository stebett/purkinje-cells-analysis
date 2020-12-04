using DrWatson
@quickactivate "ens"

using Statistics
using ImageFiltering

# TODO: add inbounds


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
	
"""
	slice(spiketrain, landmark, around)

Takes spike times and landmark times as input and returns sparse array or matrix.
The legal combinations of types for `spiketrain` and `landmark` are: `Array{Number, 1}, Number`, `Array{Array{Number, 2}}, `Array{Number, 2}`

"""
function slice(spiketrain::T, landmark::Number, around::Tuple)::Array{Number, 1} where {T <: Array{Float64,1}}
    s = zeros(abs(around[1])+abs(around[2]))

    if landmark == -1.
        return fill!(s, NaN)
    end

    idxs = spiketrain[landmark + around[1] .< spiketrain .< landmark + around[2]]
    if length(idxs) > 0
        idxs .-= idxs[1] - 1
    end
    s[floor.(Int, idxs)] .= 1
    s
end


function slice(spiketrains::Array{T, 1}, landmarks::T, around::Tuple)::Array{Number, 2} where {T <: Array{Float64,1}}
    s = zeros(abs(around[1])+abs(around[2]), size(spiketrains, 1))

    for (i, (spiketrain, l)) in enumerate(zip(spiketrains, landmarks))
        s[:, i] .= slice(spiketrain, l, around)
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
function convolve(slice::Array{Number, 1}, σ=10)::Array{Float64, 1}
    kernel = Kernel.gaussian((σ,))
    imfilter(slice, kernel, "circular")
end


function convolve(slices::Array{Number, 2}, σ=10)::Array{Float64, 2}
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

function normalize(spiketrains::Array{Array{Float64,1}, 1}, landmarks::Array{Float64,1}, around::Tuple, over::Tuple, σ=10)::Array{Float64, 2}
    target = slice(spiketrains, landmarks, around) |> convolve # TODO use σ
    baseline =  slice(spiketrains, landmarks, over) |> convolve
    normalize(target, baseline)
end

function normalize(spiketrains::Array{Array{Float64,1}, 1}, landmarks::Array{Array{Float64,1},1}, around::Tuple, over::Tuple, σ=10)::Array{Float64, 2}
    std_landmarks = standardize_landmarks(landmarks)
    tmp = Array{Float64, 2}[]
    for i = 1:size(std_landmarks, 1)
        push!(tmp, normalize(spiketrains, std_landmarks[i, :], around, over, σ))
    end
    nanmean(tmp)
end

function skipnan(v::AbstractArray)
    v[.!isnan.(v)]
end

function dropnancols(v::Array{Float64, 2})
	nancols = isnan.(v[1, :])

	new_idx = zeros(Int, sum(.!nancols))
	k = 0
	for i = 1:length(nancols)
		if nancols[i] == false
			new_idx[i-k] = i
		else
			k += 1
		end
	end
	v[:, .!nancols], new_idx
end


function nanmean(v::Array{Array{Float64, N}, 1}) where N
    m = zeros(size(v[1]))
    for i in 1:size(v[1], 2)
        tmp = Array{Float64, 1}[]
        for matrix in v
            if any(isnan.(matrix[:, i]))
                continue
            end
            push!(tmp, matrix[:, i])
        end
        if length(tmp) == 0
            m[:, i] .= NaN
            continue
        end
        m[:, i] .= mean(tmp)
    end
    m
end
