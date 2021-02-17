using DrWatson
@quickactivate :ens

using Statistics
import StatsBase.crosscor


@inline function crosscor_custom(c1::Vector, c2::Vector, lags=[-40, 40])
	bins = zeros(diff(lags)[1])
	spikes = c1 .* [1:length(c1);]
	spikes = spikes[spikes .> 0]
	@inbounds for s in spikes
		low = floor(Int, s+lags[1])
		high = floor(Int, s+lags[2]-1)
		idx = findall(0 .< [low:high;] .< length(c2))
		bins[idx] .+= view(c2, max(low, 1):min(high, length(c2)-1))
	end
	bins
end

function mass_crosscor(df, couples; thr=1.5, binsize=0.5, lags=[-40, 40], around=[-200, 200], filt=true)
	m = zeros(diff(lags)[1], length(couples))
	for (i, c) in enumerate(couples)
		m[:, i] = crosscor(df, c[1], c[2], thr=thr, binsize=binsize, lags=lags, around=around, filt=filt)
	end
	m
end



function crosscor(df, idx1::Int, idx2::Int; thr=1., binsize=0.5, lags=[-40, 40], around=[-200, 200], filt=true)
	idx = Colon()
	if filt
		z = section(df[idx1, "t"], df[idx1, "cover"], around, over=[-1000, -500], binsize=binsize, :norm) 

		idx = vcat(z...) .> thr
	end

	x = section(df[idx1, "t"], df[idx1, "cover"], around, binsize=binsize) 
	y = section(df[idx2, "t"], df[idx2, "cover"], around, binsize=binsize) 

	x = vcat(x...)[idx]
	y = vcat(y...)[idx]
	
	crosscor_custom(x, y, lags)
end

function crosscor_3B(df, idx1, idx2; thr=1.5, binsize=0.5, around=[-200, 200], dir="")
	p = plot(crosscor(df, idx1, idx2; thr=1.5, binsize=0.5, around=[-200, 200], filt=true))
	p = plot!(crosscor(df, idx1, idx2; thr=1.5, binsize=0.5, around=[-200, 200], filt=false))
	if length(dir) > 0
		savefig(plotsdir("crosscor", dir, "$idx1+$idx2.png"))
	else
		p
	end
end

# for couple in get_pairs(data, "n")
# 	crosscor_3B(couple[1], couple[2], dir="new")
# end

# function crosscor(s::Matrix, couples::Matrix, lags=[-min(size(x,1)-1, 10*log10(size(x,1))):min(size(x,1), 10*log10(size(x,1)));])
# 	m = zeros(length(lags), length(couples))
# 	for i in 1:length(couples)
# 		m[:, i] = crosscor(s[:, couples[i][1]], s[:, couples[i][2]], lags)
# 	end
# 	mean(dropnancols(m), dims=2)
# end
