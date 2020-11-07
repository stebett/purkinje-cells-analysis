using DrWatson
@quickactivate "ens"

using Statistics
using ImageFiltering

# TODO: add inbounds

"""
      slice[spiketrains, landmarks, around]

Takes as agument an array of arrays, or an array, and returns one/multiple slices of it.


"""
function slice(spiketrains::T, landmark::Number, around::Tuple)::T where {T <: Array{Float64,1}}
    s = spiketrains[landmark + around[1] .< spiketrains .< landmark + around[2]]
    
    if length(s) == 0
        return s
    end
    s .-= s[1]
end


function slice(spiketrains::Array{T, 1}, landmarks::T, around::Tuple)::Array{T, 1} where {T <: Array{Float64,1}}
    s = []

    for (i, t) in enumerate(spiketrains)
        x = t[landmarks[i] + around[1] .< t .< landmarks[i] + around[2]]

        if length(x) > 0
    
            push!(s, x .- x[1])
        else
            push!(s, x)
        end
    end
    s
end


function slice(spiketrains::T, landmarks::T, around::Tuple)::Array{T, 1} where {T <: Array{Array{Float64, 1},1}}
    s = []

    for (i, t) in enumerate(spiketrains)
        tmp = []
        for l in landmarks[i]
            x = t[l + around[1] .< t .< l + around[2]]

            if length(x) > 0
        
                push!(tmp, x .- x[1])
            else
                push!(tmp, x)
            end
        end
        push!(s, tmp)
    end
    s
end



"""
      discretize[slices, timelen, [bin]]

Divide slices recorded during interval `timelen` in bins of size `bin`, .


"""
function discretize(slices::Array{Float64, 1}, timelen, bin=50, step=1)
    d = zeros(timelen ÷ step) 


    for (k, b) in enumerate(1:step:timelen)
        d[k] = length(slices[b .< slices .< b + bin]) / bin
    end
    d
end


function discretize(slices::Array{Array{Float64, 1}, 1}, timelen, bin=50, step=1)
    d = zeros(timelen ÷ step, size(slices, 1))

    for (i, s) in enumerate(slices)
        for (j, b) in enumerate(1:step:timelen)
            d[j, i] = length(s[b .< s .< b + bin]) / bin
        end
    end
    d
end


function discretize(slices::Array{Array{Array{Float64,1}, 1}, 1}, timelen, bin=50, step=1)
    d = zeros(timelen ÷ step, size(slices, 1))

    for (i, sli) in enumerate(slices)
        tmp = zeros(timelen ÷ step, length(sli))
        for (k, s) in enumerate(sli)
            for (j, b) in enumerate(1:step:timelen)
                tmp[j, k] = length(s[b .< s .< b + bin]) / bin
            end
        end
        d[:, i] = mean!(d[:, i], tmp)
    end
    d
end



function old_normalize(slices, landmarks; around=(-200, 200), over=(-5000, -3000), bin=50, step=1)::Array{Float64,2}
	base_slice = slice(slices, landmarks, (over[1], over[2] + bin))
	base_bin = discretize(base_slice, abs(over[1] - over[2]), bin, step)
	base_mean = mean(base_bin, dims=1)
	base_std = std(base_bin, dims=1)

	target_slice = slice(slices, landmarks, (around[1], around[2] + bin))
	target_bin = discretize(target_slice, abs(around[1] - around[2]), bin, step)

    target_norm = (target_bin .- base_mean) ./ base_std
    replace!(target_norm, Inf=>0.)
    replace!(target_norm, NaN=>0.)
end

function skipnan(v::AbstractArray)
    v[.!isnan.(v)]
end