using DrWatson
@quickactivate "ens"

import DataFrames.DataFrame

"""

# Arguments

- `k::Int`: the number of bins before and after the landmarks
- `n::Int`: the number of segments of a bin

"""

function sectionTrial(r, x::Array{T, 1}, lift::T, cover::T, grasp::T, n::Int, k::Float64, p, b, args...) where {T <: Float64}

	r .= vcat([section(x, p..., binsize=b) for (p, b) in zip(p, b)]...)

	if :mad in args...
		r .= normalize(r, r[1:floor(Int, length(r)÷4)], :mad)
	end
end

function sectionTrial(r1, r2, r3, x::T, lift::T, cover::T, grasp::T, n::Int, k::Float64, b::Int, args...) where {T <: Array{Float64, 1}}

	params, bins = get_params(lift, cover, grasp, n, k, b)
	if isempty(params)
		r3 .= NaN
		return
	end

	sectionTrial.(r1, Ref(x), lift, cover, grasp, n, k, Ref(params), Ref(bins), Ref(args))

	r1 .= r1[.!isnothing.(r1)]
	if isempty(r1)
		r3 .= NaN
		return
	end

	r2 .= get_ranges(lift, cover, grasp, n, k, bins)
	r3 .= mean(hcat(r1...), dims=2)[:]
end

function sectionTrial(r1::Array{T}, r2::Array{Array{Float64, 2}, 1}, r3::T, x::T, lift::T, cover::T, grasp::T, n::Int, k::Float64, b::Int, args...) where {T <: Array{Array{Float64, 1}, 1}}
	sectionTrial.(r1, r2, r3, x, lift, cover, grasp, n, k, b, args...)
end


function sectionTrial(df::DataFrame, n::Int, pad::Float64, b::Int=200, args...)
	k = Int(pad)
	r1 = [[zeros(2n+k÷b*2n) for _ in 1:length(l)] for l in df.lift]
	r2 = [zeros(2, 2n+k÷b*2n) for _ in 1:size(df, 1)]
	r3 = [zeros(2n+k÷b*2n) for _ in 1:size(df, 1)]

	sectionTrial(r1, r2, r3, df.t, df.lift, df.cover, df.grasp, n, pad, b, args...)
	return r3, r2
	end
	
function get_params(lift, cover, grasp, n, k, b)
	b1 = b / n
	b2 = floor((cover[1] - lift[1]) / n)
	b3 = floor((grasp[1] - cover[1]) / n)

	if any(isnan.([lift[1], cover[1], grasp[1]])) || b2 ≈ 0. || b3 ≈ 0.
		return [], [] 
	end

	p1 = [lift[1], [-k, 0.]]
	p2 = [lift[1], [0., floor(cover[1]-lift[1])]]
	p3 = [cover[1], [0., floor(grasp[1]-cover[1])]]
	p4 = [grasp[1], [0., k]]
	[p1, p2, p3, p4], [b1, b2, b3, b1]
end

function get_ranges(lift, cover, grasp, n, k, b)
	rn1 = [[b[1]*i-k-cover[1]+lift[1], b[1]*(i+1)-k-cover[1]+lift[1]] for i = 0:k/b[1]]
	rn2 = [[b[2]*i-cover[1]+lift[1],b[2]*(i+1)-cover[1]+lift[1]] for i = 0:n-1]
	rn3 = [[b[3]*i, b[3]*(i+1)] for i = 0:n-1]
	rn4 = [[b[1]*i+grasp[1]-cover[1], b[1]*(i+1)+grasp[1]-cover[1]] for i=0:k/b[1]]
	hcat(rn1..., rn2..., rn3..., rn4...)
end
