using DrWatson
@quickactivate "ens"


function cut(s::Vector, l::Number, a::Vector)::Vector
	@views s[l + a[1] .< s .< l + a[2]] .- l .- a[1]
end

function cut2(s::Vector, l::Number, a::Vector)::Vector
	@views s[0. .< s .- l .- a[1] .< l + a[2]] 
end

function cut(spiketrain::Vector, landmarks::Vector, around::Vector)::Vector{Vector}
	s = Array{Float64, 1}[]

	for (i, l) in enumerate(landmarks)
		push!(s, cut(spiketrain, l, around))
    end
    s
end

function cut(spiketrains::Vector{Vector}, landmark::Number, around::Vector)::Vector{Vector}
	s = Array{Float64, 1}[]

    for st in spiketrains
		push!(s, cut(st, landmark, around))
    end
    s
end

function cut(spiketrains::Vector{Vector}, landmarks::Vector{Vector}, around::Vector)::Vector{Vector}

	s = Array{Float64, 1}[]

    for (spiketrain, lands) in zip(spiketrains, landmarks)
		for l in lands 
			push!(s, cut(spiketrain, l, around))
		end
    end
    s
end


# function cut(spiketrains::Array{Array{Float64,1}, 1}, landmarks::Array{Float64,1}, around::Vector)::Array{Array{Float64, 1}, 1}
# 	s = Array{Float64, 1}[]

#     for (spiketrain, l) in zip(spiketrains, landmarks)
# 		push!(s, cut(spiketrain, l, around))
#     end
#     s
# end

