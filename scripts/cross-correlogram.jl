using DrWatson
@quickactivate "ens"

using Statistics
using Plots; gr()
import StatsBase.crosscor

include(srcdir("spike-tools.jl"))
include(srcdir("data-tools.jl"))
include(scriptsdir("load-data.jl"))




function crosscor(s::Array{Float64, 2}, couples::Array{Array{Int64, 1}, 1}, lags=[-20:20;])
	m = zeros(length(lags), length(couples))
	for i in 1:length(couples)
		m[:, i] = crosscor(s[:, couples[i][1]], s[:, couples[i][2]], lags)
	end
	mean(dropnancols(m), dims=2)
end


# 3C

around = [-50, 50]
n = slice(data.t, data.lift, around=[-50, 50], normalization=true, average=true)
idx = active_neurons(n, -0.5, 0.5)

s = slice(data.t[idx], data.lift[idx], around=around, binsize=0.5)
neigh = get_pairs(data, "n")
dist = get_pairs(data, "d")

plot(crosscor(s, neigh, [-40:40;]))
plot!(crosscor(s, dist, [-40:40;]))



# 3B

s1 = slice(data.t[2], data.lift[2], around=around, binsize=0.5)[:]
s2 = slice(data.t[2], data.cover[2], around=around, binsize=0.5)[:]
s3 = slice(data.t[2], data.grasp[2], around=around, binsize=0.5)[:]
s = vcat(s1, s2, s3)

t1 = slice(data.t[3], data.lift[3], around=around, binsize=0.5)[:]
t2 = slice(data.t[3], data.cover[3], around=around, binsize=0.5)[:]
t3 = slice(data.t[3], data.grasp[3], around=around, binsize=0.5)[:]
t = vcat(s1, s2, s3)

C = crosscor(s, t, [-40:40;])









# nbins = 100
# trainsize = 100000
# c1 = slice(data.t[587], data.lift[587][5], around=[-trainsize÷2, trainsize÷2])
# c2 = slice(data.t[588], data.lift[588][5], around=[-trainsize÷2, trainsize÷2])
# spikes = findall(c1 .== 1.)

# @inline function crosscorrelate(c1, c2, nbins=100)
# 	bins = zeros(nbins)
# 	@inbounds for s in spikes
# 		bins .+= view(c2, s:s+nbins-1)
# 	end
# 	bins
# end
	

