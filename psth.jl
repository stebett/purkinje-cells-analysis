using Statistics

# TODO: add inbounds

"""
      slice[times, landmarks, after, [before]]

Takes as agument an array of arrays, or an array, and returns one/multiple slices of it.


"""
function slice(times::T, landmark::T, around::Number)::Array{T, 1} where {T <: Array{Float64,1}}
    s = []
	for l in landmark
		x = times[l - around .< times .< l + around]
		if x != []
			push!(s, x)
		end
	end
    (s)
end

function slice(times::T, landmark::Number, around::Number)::T where {T <: Array{Float64,1}}
    s = []

	for l in landmark
		x = times[l - around .< times .< l + around]
		if x != []
			push!(s, x...)
		end
	end
	s
end

function slice(times::T, landmark::T, around::Tuple)::Array{T, 1} where {T <: Array{Float64,1}}
    s = []

	for l in landmark
		x = times[l - around[1] .< times .< l + around[2]]
		if x != []
			push!(s, x)
		end
    end
    s
end

function slice(times::T, landmark::Number, around::Tuple)::T where {T <: Array{Float64,1}}
    s = []
	for l in landmark
		x = times[l - around[1] .< times .< l + around[2]]
		if x != []
			push!(s, x...)
		end
	end
    s
end

function slice(times::T, landmarks::T, around::Number)::T where {T <: Array{Array{Float64,1},1}}
    s = []

    for t in times
        for landmark in landmarks
            for l in landmark
				x = t[l - around .< t .< l + around]
				if x != []
					push!(s, x)
				end
			end
        end
    end
    s
end


function slice(times::T, landmarks::T, around::Tuple)::T where {T <: Array{Array{Float64,1},1}}
    s = []

    for t in times
        for landmark in landmarks
            for l in landmark
				x = t[l - around[1] .< t .< l + around[2]]
				if x != []
					push!(s, x)
				end
			end
        end
    end
    s
end


"""
      discretize[spikes, timelen, [bin]]

Divide spiketrains recorded during interval `timelen` in bins of size `bin`, .


"""
function discretize(spikes::T, timelen, bin=50)::T where {T <: Array{Float64,1}}
    d = zeros(timelen ÷ bin)

    for (k, b) in enumerate(0:bin:timelen - 1)
        d[k] = length(spikes[b .< spikes .- spikes[1] .< b + bin]) / bin
    end
    d
end


function discretize(spikes::T, timelen, bin=50) where {T <: Array{Array{Float64,1},1}}
    d = zeros(size(spikes, 1), timelen ÷ bin)

    for (i, s) in enumerate(spikes)
        for (j, b) in enumerate(0:bin:timelen - 1)
            d[i, j] = length(s[b .< s .- s[1] .< b + bin]) / bin
        end
    end
    d
end


function normalize(spike::T, landmark::T, before=3000, around=(0, 1000))::Array{Float64, 2} where {T <: Array{Float64, 1}}
	base_slice = slice(spike, landmark .-  before, around) ## TODO See if you can generalize this
    base_bin = discretize(base_slice, 1000)
    base_mean = mean(base_bin)
    base_std = std(base_bin)

    target_slice = slice(spike, landmark, 200)
    target_bin = discretize(target_slice, 400)

    target_norm = (target_bin .- base_mean) ./ base_std

end


function normalize(spikes::T, landmarks::T, before=3000, around=(0, 1000))::Array{Float64, 2} where {T <: Array{Array{Float64,1},1}}
	base_slice = slice(spikes, [l .-  before for l in landmarks], around)
	base_bin = discretize(base_slice, 1000)
	base_mean = mean(base_bin)
	base_std = std(base_bin)

	target_slice = slice(spikes, landmarks, 500)
	target_bin = discretize(target_slice, 1000)

	target_norm = (target_bin .- base_mean) ./ base_std

end