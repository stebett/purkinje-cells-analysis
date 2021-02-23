using DrWatson
@quickactivate "ens"

import DataFrames.DataFrame

"""

# Arguments

- `k::Int`: the number of bins before and after the landmarks
- `n::Int`: the number of segments of a bin

"""

function sectionTrial(r, x::Array{T, 1}, lift::T, cover::T, grasp::T, n::Int, k::Float64, p, b, args...) where {T <: Float64}
	k  = vcat([section(x, p..., binsize=b) for (p, b) in zip(p, b)]...)
	r .= k

	if :mad in args
		r .= normalize(r, r[1:floor(Int, length(r)÷4)], :mad)
	end
end

function sectionTrial(r1, r2, x::T, lift::T, cover::T, grasp::T, n::Int, k::Float64, args...) where {T <: Array{Float64, 1}}

	p, b = get_params(lift, cover, grasp, n, k)
	if isempty(p)
		r1[1] .= NaN
		return r1
	end
	r2 .= get_ranges(lift, cover, grasp, n, k, b)

	sectionTrial.(r1, Ref(x), lift, cover, grasp, n, k, Ref(p), Ref(b), Ref(args))
	r1 .= r1[.!isnothing.(r1)]

	if isempty(r1)
		r1 .= NaN
	end

	mean(hcat(r1...), dims=2)[:]
end

function sectionTrial(r1, r2, x::T, lift::T, cover::T, grasp::T, n::Int, k::Float64, args...) where {T <: Array{Array{Float64, 1}, 1}}
	sectionTrial.(r1, r2, x, lift, cover, grasp, n, k, args...)
end

function sectionTrial(r1, r2, df::DataFrame, n::Int=4, k::Float64=1000., args...) where {T <: Array{Array{Float64, 1}, 1}}
	sectionTrial(r1, r2, df.t, df.lift, df.cover, df.grasp, n, k, args...)
end
	
function get_params(lift, cover, grasp, n, k)
	b1 = 200. / n
	b2 = floor((cover[1] - lift[1]) / n)
	b3 = floor((grasp[1] - cover[1]) / n)

	if any(isnan.([lift[1], cover[1], grasp[1]]))
		return [], [] 
	end

	if b2 ≈ 0. || b3 ≈ 0.
		return  [], []
	end

	p1 = [lift[1], [-k, 0.]]
	p2 = [lift[1], [0., floor(cover[1]-lift[1])]]
	p3 = [cover[1], [0., floor(grasp[1]-cover[1])]]
	p4 = [grasp[1], [0., k]]
	return [p1, p2, p3, p4], [b1, b2, b3, b1]
end

function get_ranges(lift, cover, grasp, n, k, b)
	rn1 = [[b[1]*i-k-cover[1]+lift[1], b[1]*(i+1)-k-cover[1]+lift[1]] for i = 0:k/b[1]]
	rn2 = [[b[2]*i-cover[1]+lift[1],b[2]*(i+1)-cover[1]+lift[1]] for i = 0:n-1]
	rn3 = [[b[3]*i, b[3]*(i+1)] for i = 0:n-1]
	rn4 = [[b[1]*i+grasp[1]-cover[1], b[1]*(i+1)+grasp[1]-cover[1]] for i=0:k/b[1]]
	return hcat(rn1..., rn2..., rn3..., rn4...)
end
