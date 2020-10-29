# TODO: add inbounds

"""
      slice[spiketrains, landmarks, after, [before]]

Takes as agument an array of arrays, or an array, and returns one/multiple slices of it.


"""
function slice(spiketrains::T, landmark::T, around::Number)::Array{T,1} where {T <: Array{Float64,1}}
    s = []
	for l in landmark
		x = spiketrains[l - around .< spiketrains .< l + around]
		if x != []
			push!(s, x)
		end
	end
    (s)
end

function slice(spiketrains::T, landmark::Number, around::Number)::T where {T <: Array{Float64,1}}
    s = []

	for l in landmark
		x = spiketrains[l - around .< spiketrains .< l + around]
		if x != []
			push!(s, x...)
		end
	end
	s
end

function slice(spiketrains::T, landmark::T, around::Tuple)::Array{T,1} where {T <: Array{Float64,1}}
    s = []

	for l in landmark
		x = spiketrains[l - around[1] .< spiketrains .< l + around[2]]
		if x != []
			push!(s, x)
		end
    end
    s
end

function slice(spiketrains::T, landmark::Number, around::Tuple)::T where {T <: Array{Float64,1}}
    s = []
	for l in landmark
		x = spiketrains[l - around[1] .< spiketrains .< l + around[2]]
		if x != []
			push!(s, x...)
		end
	end
    s
end

function slice(spiketrains::T, landmarks::T, around::Number)::T where {T <: Array{Array{Float64,1},1}}
    s = []

    for t in spiketrains
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


function slice(spiketrains::T, landmarks::T, around::Tuple)::T where {T <: Array{Array{Float64,1},1}}
    s = []

    for t in spiketrains
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


function slice(spiketrains::T, landmarks::Array{Float64,1}, around::Number)::T where {T <: Array{Array{Float64,1},1}}
    s = []

    for (i, t) in enumerate(spiketrains)
        x = t[landmarks[i] - around .< t .< landmarks[i] + around]
        if x != []
            push!(s, x)
        end
    end
    s
end

function slice(spiketrains::T, landmarks::Array{Float64,1}, around::Tuple)::T where {T <: Array{Array{Float64,1},1}}
    s = []

    for (i, t) in enumerate(spiketrains)
        x = t[landmarks[i] - around[1] .< t .< landmarks[i] + around[2]]
        if x != []
            push!(s, x)
        end
    end
    s
end


"""
      discretize[spiketrains, timelen, [bin]]

Divide spiketrains recorded during interval `timelen` in bins of size `bin`, .


"""
function discretize(spiketrains::T, timelen, bin=50)::T where {T <: Array{Float64,1}}
    d = zeros(timelen ÷ bin)

    for (k, b) in enumerate(0:bin:timelen - 1)
        d[k] = length(spiketrains[b .< spiketrains .- spiketrains[1] .< b + bin]) / bin
    end
    d
end


function discretize(spiketrains::T, timelen, bin=50) where {T <: Array{Array{Float64,1},1}}
    d = zeros(size(spiketrains, 1), timelen ÷ bin)

    for (i, s) in enumerate(spiketrains)
        for (j, b) in enumerate(0:bin:timelen - 1)
            d[i, j] = length(s[b .< s .- s[1] .< b + bin]) / bin
        end
    end
    d
end

function sliding_discretize(spiketrains::T, timelen, bin=50)::T where {T <: Array{Float64,1}}
    d = zeros(timelen) 

    for (k, b) in enumerate(1:timelen)
        d[k] = length(spiketrains[b .< spiketrains .- spiketrains[1] .< b + bin]) / bin
    end
    d
end

function sliding_discretize(spiketrains::T, timelen, bin=50) where {T <: Array{Array{Float64,1},1}}
    d = zeros(size(spiketrains, 1), timelen)

    for (i, s) in enumerate(spiketrains)
        for (j, b) in enumerate(1:timelen)
            d[i, j] = length(s[b .< s .- s[1] .< b + bin]) / bin
        end
    end
    d
end


function normalize(spiketrain::T, landmark::T, before=3000, around=(0, 1000))::Array{Float64,2} where {T <: Array{Float64,1}}
	base_slice = slice(spiketrain, landmark .-  before, around) ## TODO See if you can generalize this
    base_bin = discretize(base_slice, 1000)
    base_mean = mean(base_bin)
    base_std = std(base_bin)

    target_slice = slice(spiketrain, landmark, 200)
    target_bin = discretize(target_slice, 400)

    target_norm = (target_bin .- base_mean) ./ base_std

end

function normalize(spiketrains::T, landmarks::Array{Float64,1}, before=3000, around=(0, 1000))::Array{Float64,2} where {T <: Array{Array{Float64,1},1}}
	base_slice = slice(spiketrains, landmarks .-  before, around)
	base_bin = discretize(base_slice, 1000)
	base_mean = mean(base_bin)
	base_std = std(base_bin)

	target_slice = slice(spiketrains, landmarks, 5000)
	target_bin = discretize(target_slice, 10000)

	target_norm = (target_bin .- base_mean) ./ base_std

end


function normalize(spiketrains::T, landmarks::T, before=3000, around=(0, 1000))::Array{Float64,2} where {T <: Array{Array{Float64,1},1}}
	base_slice = slice(spiketrains, [l .-  before for l in landmarks], around)
	base_bin = discretize(base_slice, 1000)
	base_mean = mean(base_bin)
	base_std = std(base_bin)

	target_slice = slice(spiketrains, landmarks, 5000)
	target_bin = discretize(target_slice, 10000)

	target_norm = (target_bin .- base_mean) ./ base_std

end