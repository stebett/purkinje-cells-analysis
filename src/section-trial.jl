using DrWatson
@quickactivate "ens"

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

function sectionTrial(r::Vector{T}, ranges::Vector{<:Tuple}, bins::Vector{T}, 
		x::Vector{T}, lift::T, cover::T, grasp::T, 
		pad::Int, n::Int, b1::Int) where {T <: Real}
	binSizes!(bins, lift, cover, grasp, pad, n, b1)
	tupleRanges!(ranges, lift-pad, bins)
	r .= cut.(Ref(x), ranges) |> k->length.(k) |> Array{Float64, 1} 
	zscore!(r, mean(r[1:floor(Int, length(r)÷4)]), std(r[1:floor(Int, length(r)÷4)]))
	# r .= normalize(r, r[1:floor(Int, length(r)÷4)], :mad)
end
	
function sectionTrial(r::Vector{Vector{T}}, ranges::Vector{<:Vector{<:Tuple}}, bins::Vector{T}, row, pad::Int, n::Int, b1::Int) where {T <: Real}
	sectionTrial.(r, ranges, Ref(bins), Ref(row.t), row.lift, row.cover, row.grasp, pad, n, b1)
end

function sectionTrial(r::Vector{Vector{Vector{T}}}, ranges::Vector{<:Vector{<:Vector{<:Tuple}}}, bins::Vector{T}, df, pad::Int, n::Int, b1::Int) where {T <: Real}
	sectionTrial.(r, ranges, Ref(bins), eachrow(df), pad, n, b1)
end
															 
function sectionTrial(df, pad::Int, n::Int, b1::Int)
	T = Tuple{Float64, Float64}
	l = 2n + 2pad÷b1

	# Prealloactions
	bins = zeros(l)
	r = [[zeros(l) for _ in 1:length(i)] for i in df.lift]
	ranges = [[Array{T, 1}(undef, l) for _ in 1:length(i)] for i in df.lift]

	sectionTrial(r, ranges, bins, df, pad, n, b1)
	return r, ranges
end
