using DrWatson
@quickactivate "ens"

using Statistics
using ImageFiltering
using OffsetArrays
import LinearAlgebra.normalize

export section, normalize, convolve, bin 

function section(x, y, z, args...; σ=10, over=[-500, 500], binsize=1.)
	if :conv in args || :norm in args
		z = [z[1] - 2σ, z[2] + 2σ]
	end

	m = cut(x, y, z) |> k->bin(k, floor(Int, diff(z)...), binsize)

	if :conv in args || :norm in args
		m = convolve(m, σ/binsize)

		if :norm in args
			n = section(x, y, z) |> k->bin(k, floor(Int, diff(z)...), binsize) |> k->convolve(k, σ/binsize) 
			m = normalize(m, n)
		end
	end

	if :avg in args && y isa Array{Array{<:Real, 1}, 1}
		idx = map(length, y) |> x->pushfirst!(x, 0) |> cumsum
		idx = [[idx[i]+1:idx[i+1];] for i = 1:length(idx) - 1]
		rows = diff(z)[1]
		cols = (map(length, idx) .> 1) |> sum
		M = Array{<:Real, 1}[]
		for i = idx
			push!(M, mean(hcat(m[i]...), dims=2)[:])
		end
		return M

	elseif :avg in args && y isa Array{<:Real, 1}
		return mean(hcat(m...), dims=2)
	end
	m
end

function normalize(x::Array{Array{<:Real, 1}, 1}, y::Array{Array{<:Real, 1}, })::Array{Array{<:Real, 1}, 1}
	normalize.(x, y)
end

function normalize(x::Array{<:Real, 1}, y::Array{<:Real, 1})::Array{<:Real, 1}
	if std(y) == 0.
		return zeros(size(x))
	end
	(x .- mean(y)) ./ std(y)
end


function convolve(x::Array{Array{<:Real, 1}, 1}, σ::Real=10)::Array{Array{<:Real, 1}, 1}
	convolve.(x, σ)
end

function convolve(x::Array{<:Real, 1}, σ::Real=10)::Array{<:Real, 1}
    kernel = Kernel.gaussian((σ,))
	OffsetArrays.no_offset_view(imfilter(x, kernel, Inner()))
end

function bin(x::Array{Array{<:Real, 1}, 1}, len::Int, binsize::Real=1.)::Array{Array{<:Real,1 }, 1}
	bin.(x, len, binsize)
end

function bin(x::Array{<:Real, 1}, len::Int, binsize::Real=1.)
	[sum([i .<= x .< i+binsize][1]) for i = 1:binsize:len+1-binsize]
end

function cut(x::Array{Array{<:Real, 1}, 1}, y::Array{Array{<:Real, 1}, 1}, z::Array{<:Real, 1})::Array{Array{<:Real, 1}, 1}
	[(cut.(x, y, Ref(z))...)...]
end

function cut(x::Array{<:Real, 1}, y::Array{<:Real, 1}, z::Array{<:Real, 1})::Array{Array{<:Real, 1}, 1}
	cut.(Ref(x), y, Ref(z))
end

function cut(x::Array{<:Real, 1}, y::Real, z::Array{<:Real, 1})::Array{<:Real, 1}
	@views x[y + z[1] .<= x .<= y + z[2]] .- y .- z[1]
end
