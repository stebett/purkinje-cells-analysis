using DrWatson
@quickactivate :ens

using DataFrames
using Spikes

import Base.ceil

function mkdf(cellpair, tmax = [-600., 600.])
	len = floor(Int, diff(tmax)[1])

	st = cut(cellpair[1, :].t, cellpair[1, :].lift, tmax)
	ext = ceil.(Int, extrema.(st))
	
	bins = bin(st, len, 1.)
	for b in bins
		b[b .> 1] .= 1
	end

	st = norm_len.(st, 0, len)
	isi = binisi.(st)
	times = [tmax[1]+1:tmax[2];]

	st2 = cut(cellpair[2, :].t, cellpair[2, :].lift, tmax)
	st2 = norm_len.(st2, 0, len)
	tforw = binisi_inv.(st2)
	tback = binisi_0.(st2)

	dfs = Array{DataFrame, 1}(undef, length(st))
	for i in eachindex(st)
		df = DataFrame()
		df.event = bins[i]
		df.time = times
		df.neuron = fill(1, size(bins[i]))
		df.trial = fill(i, size(bins[i]))
		df.timeSinceLastSpike = isi[i]
		df.previousIsi = previousisi(isi[i])
		df.ntrial = fill(i, size(bins[i]))
		df.tback = [tback[i][2:end];NaN]
		df.tforw = tforw[i]
		df.nearest = min.(tforw[i], [tback[i][2:end];NaN])
		dfs[i] = df[ext[i][1]:ext[i][2], :]
	end
	dfs[1]
	M = vcat(dfs...)

	for n in names(M)
		filter!(n => x -> !(isnan(x)), M)
	end
	return M
end

function previousisi(x)
	y = fill(NaN, length(x))
	prev = NaN

	for i in 2:length(x)
		if x[i] == 1.
			prev = x[i-1]
		end
		y[i] = prev
	end
	y
end

function get_cell(s::String) 
	x = split(s, '.')
	rat = data.rat .== x[1]
	site = data.site .== x[2]
	tet = data.tetrode .== x[3]
	neuron = data.neuron .== replace(x[4], 't'=>"neuron")
	data[rat .& site .& tet .& neuron, :]
end

function make_couples(s::Vector{<:String})
	vcat(get_cell(s[1]), get_cell(s[2]))
end


binisi(x) = vcat([[1:i;] for i in diff(floor.(x))]...) # TODO check floor
binisi_inv(x) = vcat([[i-1:-1:0;] for i in diff(floor.([0; x]))]...) 
binisi_0(x) = vcat([[0:i-1;] for i in diff(floor.(x))]...) # TODO check floor

norm_len(x, f, l) = [f;x;l]
ceil(t::Type, x::Tuple) = ceil.(t, x)
