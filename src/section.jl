using DrWatson
@quickactivate "ens"

using Statistics
using StatsBase
using ImageFiltering
using OffsetArrays
import LinearAlgebra.normalize

export section, normalize, convolve, bin 

function section(x, y, z, args...; σ=10, over=[-500., 500.], binsize=1.)
	if :conv in args 
		z = [z[1] - 2σ, z[2] + 2σ]
	end

	if z isa Tuple
		z = [z[1], z[2]]
	end

	m = cut(x, y, z) |> k->bin(k, floor(Int, diff(z)...), binsize)

	if :conv in args 
		m = convolve(m, σ/binsize)
	end

	if :norm in args
		n = section(x, y, over) |> k->bin(k, floor(Int, diff(over)...), binsize) 
		m = normalize(m, n)
	end

	if :avg in args && y isa Array{Array{Float64, 1}, 1}
		idx = map(length, y) |> x->pushfirst!(x, 0) |> cumsum
		idx = [[idx[i]+1:idx[i+1];] for i = 1:length(idx) - 1]
		rows = diff(z)[1]
		cols = (map(length, idx) .> 1) |> sum
		M = Array{Float64, 1}[]
		for i = idx
			push!(M, mean(hcat(m[i]...), dims=2)[:])
		end
		return M

	elseif :avg in args && y isa Array{Float64, 1}
		return mean(hcat(m...), dims=2)
	end
	m
end

function normalize(x::Array{Array{Float64, 1}, 1}, y::Array{Array{Float64, 1}, }, args...)::Array{Array{Float64, 1}, 1}
	normalize.(x, y)
end

function normalize(x::Array{<:Real, 1}, y::Array{<:Real, 1}, args...)::Array{<:Real, 1}
	if std(y) == 0.
		return zeros(size(x))
	end

	if :mad in args
		return (x .- median(y)) ./ mad(y)
	end

	(x .- mean(y)) ./ std(y)
end


function convolve(x::Array{Array{Float64, 1}, 1}, σ::Float64=10)::Array{Array{Float64, 1}, 1}
	convolve.(x, σ)
end

function convolve(x::Array{Float64, 1}, σ::Float64=10)::Array{Float64, 1}
    kernel = Kernel.gaussian((σ,))
	OffsetArrays.no_offset_view(imfilter(x, kernel, Inner()))
end

function bin(x::Array{Array{Float64, 1}, 1}, len::Int, binsize::Float64=1.)::Array{Array{Float64,1 }, 1}
	bin.(x, len, binsize)
end

function bin(x::Array{Float64, 1}, len::Int, binsize::Float64=1.)::Array{Float64, 1}
	[sum([i .<= x .< i+binsize][1]) for i = 1:binsize:len+1-binsize]
end

function cut(x::Array{Array{Float64, 1}, 1}, y::Array{Array{Float64, 1}, 1}, z::Array{Float64, 1})::Array{Array{Float64, 1}, 1}
	[(cut.(x, y, Ref(z))...)...]
end

function cut(x::Array{Float64, 1}, y::Array{Float64, 1}, z::Array{Float64, 1})::Array{Array{Float64, 1}, 1}
	cut.(Ref(x), y, Ref(z))
end

function cut(x::Array{Float64, 1}, y::Float64, z::Array{Float64, 1})::Array{Float64, 1}
	@views x[y + z[1] .<= x .<= y + z[2]] .- y .- z[1]
end
