using DrWatson
@quickactivate "ens"

using Statistics
import StatsBase.crosscor

include(srcdir("spike-tools.jl"))
include(srcdir("data-tools.jl"))

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

function mass_crosscor(data, couples; thr=1.5, binsize=0.5, lags=[-40, 40], around=[-200, 200], filt=true)
	m = zeros(diff(lags)[1], length(couples))
	for (i, c) in enumerate(couples)
		m[:, i] = crosscor(data, c[1], c[2], thr=thr, binsize=binsize, lags=lags, around=around, filt=filt)
	end
	m
end



function crosscor(data, idx1::Int, idx2::Int; thr=1.5, binsize=0.5, lags=[-40, 40], around=[-200, 200], filt=true)
	if filt
		sig_lift = abs.(slice(data.t[idx1], data.lift[idx1], around=around, binsize=binsize, normalization=true)) .> thr
		sig_cover = abs.(slice(data.t[idx1], data.cover[idx1], around=around, binsize=binsize, normalization=true)).> thr
		sig_grasp = abs.(slice(data.t[idx1], data.grasp[idx1], around=around, binsize=binsize, normalization=true)) .> thr
	else
		sig_lift, sig_cover, sig_grasp = Colon(),Colon(),Colon()
	end

	s1 = slice(data.t[idx1], data.lift[idx1], around=around, binsize=binsize)[sig_lift]
	s2 = slice(data.t[idx1], data.cover[idx1], around=around, binsize=binsize)[sig_cover]
	s3 = slice(data.t[idx1], data.grasp[idx1], around=around, binsize=binsize)[sig_grasp]

	t1 = slice(data.t[idx2], data.lift[idx2], around=around, binsize=binsize)[sig_lift]
	t2 = slice(data.t[idx2], data.cover[idx2], around=around, binsize=binsize)[sig_cover]
	t3 = slice(data.t[idx2], data.grasp[idx2], around=around, binsize=binsize)[sig_grasp]

	s = vcat(s1, s2, s3)
	t = vcat(t1, t2, t3)
	crosscor_custom(s, t, lags)
end

# function crosscor(s::Matrix, couples::Matrix, lags=[-min(size(x,1)-1, 10*log10(size(x,1))):min(size(x,1), 10*log10(size(x,1)));])
# 	m = zeros(length(lags), length(couples))
# 	for i in 1:length(couples)
# 		m[:, i] = crosscor(s[:, couples[i][1]], s[:, couples[i][2]], lags)
# 	end
# 	mean(dropnancols(m), dims=2)
# end
