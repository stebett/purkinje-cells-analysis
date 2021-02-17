using DrWatson
@quickactivate "ens"

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

