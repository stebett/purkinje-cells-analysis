using DrWatson
@quickactivate :ens

using Spikes
using DataFrames

import Base.ceil

binisi(x) = vcat([[1:i;] for i in diff(floor.(x))]...) # TODO check floor
binisi_inv(x) = vcat([[i-1:-1:0;] for i in diff(floor.([0; x]))]...) 

binisi_0(x) = vcat([[0:i-1;] for i in diff(floor.(x))]...) # TODO check floor

get_times(ext, len) = [ext[1]+1:ext[2];] .- len ÷ 2 # TODO check +1
cut_bin(x, y) = x[y[1]+1:y[2]]

function fill_part(x, r, len)
	tmp = fill(NaN, len)
	tmp[r[1]+1:r[2]] .= x
	tmp
end




function prox(x, y)
	r = zeros(size(x))

	for i = eachindex(x)
		tmp = 0
		while 1
		if y[i] == 1.
			r[i] = tmp
			break
		end
		tmp += 1



		

ceil(t::Type, x::Tuple) = ceil.(t, x)



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
		


data = load_data("data-v4.arrow"); # TODO change to v6
neigh = couple(data, :n)


cellpair = data[neigh[1], :];


#%
function mkdf(cellpair, tmax = [-600., 600.])
	len = floor(Int, diff(tmax)[1])

	st = cut(cellpair[1, :].t, cellpair[1, :].lift, tmax)
	ext = ceil.(Int, extrema.(st))
	bins = cut_bin.(bin(st, len, 1.), ext)
	isi = binisi.(st)
	times = get_times.(ext, len)

	st2 = cut(cellpair[2, :].t, cellpair[2, :].lift, tmax)
	ext2 = ceil.(Int, extrema.(st2))

	tforw = cut_bin.(fill_part.(binisi_inv.(st2), ext2, len), ext)
	tback = cut_bin.(fill_part.(binisi_0.(st2), ext2, len), ext)

	dfs = Array{DataFrame, 1}(undef, length(st))
	for i in eachindex(st)
		df = DataFrame()
		df.event = bins[i]
		df.time = times[i]
		df.neuron = fill(1, size(bins[i]))
		df.trial = fill(i, size(bins[i]))
		df.timeSinceLastSpike = isi[i]
		df.previousIsi = previousisi(isi[i])
		df.ntrial = fill(i, size(bins[i]))
		df.tforw = tforw[i]
		df.tback = tback[i]
		dfs[i] = df
	end
	vcat(dfs...)
end
