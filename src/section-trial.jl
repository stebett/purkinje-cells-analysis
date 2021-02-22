using DrWatson
@quickactivate "ens"

import DataFrames.DataFrame

"""

# Arguments

- `k::Int`: the number of bins before and after the landmarks
- `n::Int`: the number of segments of a bin

"""

function sectionTrial(x::Array{T, 1}, lift::T, cover::T, grasp::T, n::Int, k::Int) where {T <: Float64}
	b1 = 200. / n
	b2 = (cover - lift) / n
	b3 = (grasp - cover) / n

	if any(isnan.([lift, cover, grasp]))
		return 
	end

	if b2 ≈ 0. || b3 ≈ 0.
		return 
	end


	p1 = [x, lift, [-k, 0]]
	p2 = [x, lift, [0, ceil(Int, cover-lift)]]
	p3 = [x, cover, [0, ceil(Int, grasp-cover)]]
	p4 = [x, grasp, [0, k]]

	m = vcat([section(p..., binsize=b) for (p, b) in zip([p1, p2, p3, p4], [b1, b2, b3, b1])]...)
	m = convolve(m, 1)
	normalize(m, m[1:floor(Int, length(m)÷4)])
end

function sectionTrial(x::T, lift::T, cover::T, grasp::T, n::Int, k::Int) where {T <: Array{Float64, 1}}
	m = sectionTrial.(Ref(x), lift, cover, grasp, n, k)
	 # over=[lift-k, lift-k/2], :norm)
	M = hcat(m[.!isnothing.(m)]...)
	if isempty(M)
		return [NaN]
	end

	mean(M, dims=2)[:]
end

function sectionTrial(x::T, lift::T, cover::T, grasp::T, n::Int, k::Int) where {T <: Array{Array{Float64, 1}, 1}}
	sectionTrial.(x, lift, cover, grasp, n, k)
end

function sectionTrial(df::DataFrame, n::Int=4, k::Int=4)
	sectionTrial(df.t, df.lift, df.cover, df.grasp, n, k)
end
	
