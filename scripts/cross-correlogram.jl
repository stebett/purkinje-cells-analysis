using DrWatson
@quickactivate "ens"

using Statistics
using Plots; gr()
import StatsBase.crosscor

include(srcdir("spike-tools.jl"))
include(srcdir("data-tools.jl"))
include(scriptsdir("load-data.jl"))
include(scriptsdir("load-full.jl"))



function crosscor(s::Array{Float64, 2}, couples::Array{Array{Int64, 1}, 1}, lags=[-min(size(x,1)-1, 10*log10(size(x,1))):min(size(x,1), 10*log10(size(x,1)));])
	m = zeros(length(lags), length(couples))
	for i in 1:length(couples)
		m[:, i] = crosscor(s[:, couples[i][1]], s[:, couples[i][2]], lags)
	end
	mean(dropnancols(m), dims=2)
end


# You need to make a function to select stuff that has decent values on the autocorrelogram
# And another function to see when the modulation of the activity is significant for a given cell
# 3B
function crosscorr_3B()
	around = [-500, 500]

	idx1 = 55
	idx2 = 56
	thr = 2.0
	binsize = 0.5

	sig_lift = slice(data.t[idx1], data.lift[idx1], around=around, binsize=binsize, normalization=true) .> thr
	sig_cover = slice(data.t[idx1], data.cover[idx1], around=around, binsize=binsize, normalization=true) .> thr
	sig_grasp = slice(data.t[idx1], data.grasp[idx1], around=around, binsize=binsize, normalization=true) .> thr

	s1 = slice(data.t[idx1], data.lift[idx1], around=around, binsize=binsize)[sig_lift]
	s2 = slice(data.t[idx1], data.cover[idx1], around=around, binsize=binsize)[sig_cover]
	s3 = slice(data.t[idx1], data.grasp[idx1], around=around, binsize=binsize)[sig_grasp]

	t1 = slice(data.t[idx2], data.lift[idx2], around=around, binsize=binsize)[sig_lift]
	t2 = slice(data.t[idx2], data.cover[idx2], around=around, binsize=binsize)[sig_cover]
	t3 = slice(data.t[idx2], data.grasp[idx2], around=around, binsize=binsize)[sig_grasp]

	s = vcat(s1, s2, s3)
	t = vcat(t1, t2, t3)

	Cₘ = crosscor(s, t, [-40:40;])
	plot(Cₘ)

	s1 = slice(data.t[idx1], data.lift[idx1], around=around, binsize=binsize)[:]
	s2 = slice(data.t[idx1], data.cover[idx1], around=around, binsize=binsize)[:]
	s3 = slice(data.t[idx1], data.grasp[idx1], around=around, binsize=binsize)[:]

	t1 = slice(data.t[idx2], data.lift[idx2], around=around, binsize=binsize)[:]
	t2 = slice(data.t[idx2], data.cover[idx2], around=around, binsize=binsize)[:]
	t3 = slice(data.t[idx2], data.grasp[idx2], around=around, binsize=binsize)[:]

	s = vcat(s1, s2, s3)
	t = vcat(t1, t2, t3)

	C = crosscor(s, t, [-40:40;])
	plot(Cₘ)
	plot!(C)
end
# 3C

around = [-500, 500]
n = slice(data.t, data.lift, around=[-25, 25], normalization=true, average=true)

acorrs = data_full[:, :p_acorr] .< 0.1
activ = active_neurons(n, -0.5, 2.5) 
idx = activ .& acorrs
tmp = data[acorrs, :];

s = slice(tmp.t, tmp.lift, around=around, binsize=1.)
neigh = get_pairs(tmp, "n")
dist = get_pairs(tmp, "d")

plot(crosscor(s, neigh, [-40:40;]))
plot!(crosscor(s, dist, [-40:40;]))









# nbins = 100
# trainsize = 100000
# c1 = slice(data.t[587], data.lift[587][5], around=[-trainsize÷2, trainsize÷2])
# c2 = slice(data.t[588], data.lift[588][5], around=[-trainsize÷2, trainsize÷2])
# spikes = findall(c1 .== 1.)

	

# @inline function crosscor(c1, c2, norm=false, lags=[-40, 40])
# 	bins = zeros(diff(lags)[1])
# 	spikes = c1 .* [1:length(c1);]
# 	@inbounds for s in spikes[spikes .> 0]
# 		a = view(CircularArray(c2), floor(Int, s-lags[1]):floor(Int, s+lags[2]))
# 		bins .+= a
# 	end
# 	bins
# end
