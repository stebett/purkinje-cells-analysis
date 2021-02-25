using DrWatson
@quickactivate "ens"

import DataFrames.DataFrame


function sectionTrial(x::Vector{T}, around::Vector{<:Tuple}, binsizes::Vector{T}) where {T <:Real}
	cut.(Ref(x), around) |> k->bin.(k, binsizes) |> k->vcat(k...)
end

function binSizes!(b, lift, cover, grasp, pad, n, b1)
	# Preallocate?
	b .= [fill(b1, pad÷b1)...,
		  fill((cover - lift)/ n, n)...,
		  fill((grasp - cover) / n, n)...,
		  fill(b1, pad÷b1)...]
end

function tupleRanges!(r, start, bins)
	for (i, b) in enumerate(bins)
		r[i] = (start, start + b)
		start += b
	end
end

#%
pad = 1000
n = 6
b1 = 50
l = 2n + 2pad÷b1
bins = zeros(l)
# r = [zeros(l) for _ in 1:length(data.lift[1])]
# ranges = [Array{Tuple{Float64, Float64}, 1}(undef, l) for _ in 1:length(data.lift[1])]
r = [[zeros(l) for _ in 1:length(i)] for i in data.lift];
ranges = [[Array{Tuple{Float64, Float64}, 1}(undef, l) for _ in 1:length(i)] for i in data.lift];
# r = zeros(l)
# ranges = Array{Tuple{Float64, Float64}, 1}(undef, l)
#%

function sectionTrial(r::Vector{T}, ranges::Vector{<:Tuple}, bins::Vector{T}, 
		x::Vector{T}, lift::T, cover::T, grasp::T, 
		pad::Int, n::Int, b1::Int) where {T <: Real}
	binSizes!(bins, lift, cover, grasp, pad, n, b1)
	tupleRanges!(ranges, lift-pad, bins)
	r .= cut.(Ref(x), ranges) |> k->length.(k) |> Array{Float64, 1} 
	r .= normalize(r, r[1:floor(Int, length(r)÷4)], :mad)
end
	
function sectionTrial(r::Vector{Vector{T}}, ranges::Vector{<:Vector{<:Tuple}}, bins::Vector{T}, row, pad::Int, n::Int, b1::Int) where {T <: Real}
	sectionTrial.(r, ranges, Ref(bins), Ref(row.t), row.lift, row.cover, row.grasp, pad, n, b1)
end

function sectionTrial(r::Vector{Vector{Vector{T}}}, ranges::Vector{<:Vector{<:Vector{<:Tuple}}}, bins::Vector{T}, df, pad::Int, n::Int, b1::Int) where {T <: Real}
	sectionTrial.(r, ranges, Ref(bins), eachrow(df), pad, n, b1)
end
															 
ranges[abs.(r) .> 2.]







# """

# # Arguments

# - `k::Int`: the number of bins before and after the landmarks
# - `n::Int`: the number of segments of a bin

# """

# function sectionTrial(r, x::Array{T, 1}, lift::T, cover::T, grasp::T, n::Int, k::Float64, p, b, args...) where {T <: Float64}

# 	r .= vcat([section(x, p..., binsize=b) for (p, b) in zip(p, b)]...)

# 	if :mad in args...
# 		r .= normalize(r, r[1:floor(Int, length(r)÷4)], :mad)
# 	end
# end

# function sectionTrial(r1, r2, r3, x::T, lift::T, cover::T, grasp::T, n::Int, k::Float64, b::Int, args...) where {T <: Array{Float64, 1}}

# 	params, bins = get_params(lift, cover, grasp, n, k, b)
# 	if isempty(params)
# 		r3 .= NaN
# 		return
# 	end

# 	sectionTrial.(r1, Ref(x), lift, cover, grasp, n, k, Ref(params), Ref(bins), Ref(args))

# 	r1 .= r1[.!isnothing.(r1)]
# 	if isempty(r1)
# 		r3 .= NaN
# 		return
# 	end

# 	b = get_ranges(lift, cover, grasp, n, k, bins)
# 	@infiltrate
# 	r2 .= b
# 	r3 .= mean(hcat(r1...), dims=2)[:]
# end

# function sectionTrial(r1::Array{T}, r2, r3::T, x::T, lift::T, cover::T, grasp::T, n::Int, k::Float64, b::Int, args...) where {T <: Array{Array{Float64, 1}, 1}}
# 	sectionTrial.(r1, r2, r3, x, lift, cover, grasp, n, k, b, args...)
# end


# function sectionTrial(df::DataFrame, n::Int, pad::Float64, b::Int=200, args...)
# 	dim = 2n+Int(pad)÷b*2n
# 	r1 = [[zeros(dim) for _ in 1:length(l)] for l in df.lift]
# 	r2 = [Array{Tuple{Float64,Float64}, 1}(undef, dim) for _ in 1:size(df, 1)]
# 	r3 = [zeros(dim) for _ in 1:size(df, 1)]

# 	sectionTrial(r1, r2, r3, df.t, df.lift, df.cover, df.grasp, n, pad, b, args...)
# 	return r3, r2
# 	end
	
# function get_params(lift, cover, grasp, n, k, b)
# 	b1 = b / n
# 	b2 = floor((cover[1] - lift[1]) / n)
# 	b3 = floor((grasp[1] - cover[1]) / n)

# 	if any(isnan.([lift[1], cover[1], grasp[1]])) || b2 ≈ 0. || b3 ≈ 0.
# 		return [], [] 
# 	end

# 	p1 = [lift[1], [-k, 0.]]
# 	p2 = [lift[1], [0., floor(cover[1]-lift[1])]]
# 	p3 = [cover[1], [0., floor(grasp[1]-cover[1])]]
# 	p4 = [grasp[1], [0., k]]
# 	[p1, p2, p3, p4], [b1, b2, b3, b1]
# end

# function get_ranges(lift, cover, grasp, n, k, b)
# 	rn1 = [(b[1]*i-k-cover[1]+lift[1], b[1]*(i+1)-k-cover[1]+lift[1]) for i = 0:k/b[1]]
# 	rn2 = [(b[2]*i-cover[1]+lift[1],b[2]*(i+1)-cover[1]+lift[1]) for i = 0:n-1]
# 	rn3 = [(b[3]*i, b[3]*(i+1)) for i = 0:n-1]
# 	rn4 = [(b[1]*i+grasp[1]-cover[1], b[1]*(i+1)+grasp[1]-cover[1]) for i=0:k/b[1]]
# 	[rn1..., rn2..., rn3..., rn4...]
# end

# function get_active_ranges(df; num_bins, pad, b, thr)
# 	n, r = sectionTrial(df, num_bins, pad, b, :mad);
# 	todrop = drop(n, index=true)
# 	active_bins = get_active_bins(n, thr)

# 	results = Dict{Int, Array{Tuple{Float64, Float64}, 1}}()
# 	for (i, bad, act, rng) = zip(df.index, todrop, active_bins, r)
# 		if bad
# 			results[i] = []
# 		elseif isempty(act)
# 			results[i] = []
# 		else
# 			results[i] = rng[act]
# 		end
# 	end
# 	results
# end

# function get_active_bins(m::Array{Array{Float64, 1}, 1}, thr)
# 	get_active_bins.(m, thr)
# end

# function get_active_bins(m::Array{Float64, 1}, thr)
# 	findall(m .> thr)
# end
