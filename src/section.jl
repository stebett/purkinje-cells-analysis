using DrWatson
@quickactivate "ens"

using Statistics
using ImageFiltering
using OffsetArrays
import LinearAlgebra.normalize

function slice(x, y, z, args...;σ::Int=10, over::Array{Float64, 1}=[-500, 500], binsize::Float64=1.)
	if :conv in args || :norm in args
		z = [z[1] - 2σ, z[2] + 2σ]
	end

	m = section(x, y, z) |> k->bin(k, diff(z)..., binsize)

	if :conv in args || :norm in args
		m = convolve(m, Int(σ/binsize))

		if :norm in args
			pad = [over[1] - 2σ, over[2] + 2σ]
			m = section(x, y, pad) |> k->bin(k, diff(pad)..., binsize) |> k->convolve(k, Int(σ/binsize)) |> k->normalize(m, k)
		end
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

function section(x::Array{Float64, 1}, y::Number, z::Array{Int, 1})::Array{Float64, 1}
	@views x[y + z[1] .< x .<= y + z[2]] .- y .- z[1]
end

function section(x::Array{Float64, 1}, y::Array{Float64, 1}, z::Array{Int, 1})::Array{Array{Float64, 1}, 1}
	m = Array{Float64, 1}[]

	for yᵢ in y
		push!(m, section(x, yᵢ, z))
    end
    m
end

function section(x::Array{Array{Float64, 1}, 1}, y::Number, z::Array{Int, 1})::Array{Array{Float64, 1}, 1}
	m = Array{Float64, 1}[]

    for xᵢ in x
		push!(m, section(xᵢ, y, z))
    end
    m
end

function section(x::Array{Array{Float64, 1}, 1}, y::Array{Array{Float64, 1}, 1}, z::Array{Int, 1})::Array{Array{Float64, 1}, 1}
	m = Array{Float64, 1}[]

    for (xᵢ, yᵢ) in zip(x, y)
		for yᵢⱼ in yᵢ 
			push!(m, section(xᵢ, yᵢⱼ, z))
		end
    end
    m
end

function bin(x::Array{Float64, 1}, len::Int, binsize::Float64=1.)::Array{Float64, 1}
	m = zeros(floor(Int, len/binsize))
	m[ceil.(Int, x ./ binsize)] .= 1
	m
end

function bin(x::Array{Array{Float64, 1}, 1}, len::Int, binsize::Float64=1.)::Array{Array{Float64,1 }, 1}
	bin.(x, len, binsize)
end


"""

# Arguments

- `k::Int`: the number of bins before and after the landmarks
- `n::Int`: the number of segments of a bin

"""
function sectionTrial(x::Array{T, 1}, lift::T, cover::T, grasp::T, n::Int, k::Int)::Array{T, 1} where {T <: Float64}
	bin1 = 50. / n
	bin2 = (cover - lift) / n
	bin3 = (grasp - cover) / n

	binsizes = [fill(bin1, n*k)..., fill(bin2, n)..., fill(bin3, n)..., fill(bin1, n*k)...]

	t0 = lift - n*k*bin1
	t1 = grasp + n*k*bin1

	s = x[t0 .<= x .<= t1]
	y = zeros(2n + 2k*n)

	if length(s) == 0
		return y
	end
	s .= s .- t0

	t = 0
	for i in 1:length(y)
		y[i] = sum(0 .<= s.-t .< binsizes[i]) / binsizes[i]
		t += binsizes[i]
	end
	y
end

function sectionTrial(spiketrains::T, lift::T, cover::T, grasp::T, nbins=4, around=2)::Array{Float64, 2} where {T <: Array{Array{Float64, 1}, 1}}
	rows = 2nbins+2around*nbins
	cols = map(length, lift) |> sum
	s = zeros(rows, cols)

	i = 1
	for j in 1:length(spiketrains)
		for k in 1:length(lift[j])
			s[:, i] .= bigSlice(spiketrains[j], lift[j][k], cover[j][k], grasp[j][k], nbins, around)
			i += 1
		end
	end
	s
end

function bigSlice(data, binsize=1, around=4, average=true, normalization=true) 
	# TODO
	σ = 10
	over = [-5000, -3000]

	s = bigSlice(data.t, data.lift, data.cover, data.grasp, binsize, around)

	if normalization
		pad = [over[1] - 2σ, over[2] + 2σ]
		s = slice_(data.t, data.lift, pad) |> x->convolve(x, σ) |> x->norm_slice(s, x)
	end

	if average
		idx = map(length, data.lift) |> x->pushfirst!(x, 0) |> cumsum
		idx_list = [[idx[i]+1:idx[i+1];] for i = 1:length(idx) - 1]

		rows = 2binsize + 2around*binsize
		cols = (map(length, idx_list) .>= 1) |> sum
		s_avg = zeros(rows, cols)
		k = 1
		for i = idx_list 
			s_avg[:, k] = mean(s[:, i], dims=2)
			k += 1
		end
		return s_avg
	end
	s
end

function convolve(x::Array{Float64, 1}, σ::Int=10)::Array{Float64, 1}
    kernel = Kernel.gaussian((σ,))
	OffsetArrays.no_offset_view(imfilter(x, kernel, Inner()))
end

function convolve(x::Array{Array{Float64, 1}, 1}, σ::Int=10)::Array{Array{Float64, 1}, 1}
	convolve.(x, σ)
end

function normalize(x::Array{Float64, 1}, y::Array{Float64, 1})::Array{Float64, 1}
	if std(x) == 0.
		return zeros(size(x))
	end
	(((x .- mean(x)) ./ std(x)) .* std(y) ) .+ mean(y)
end

function normalize(x::Array{Array{Float64, 1}, 1}, y::Array{Array{Float64, 1}, })::Array{Array{Float64, 1}, 1}
	normalize.(x, y)
end
