using DrWatson
@quickactivate "ens"

using Statistics
using Plots; gr()
using CircularArrays
import StatsBase.crosscor

include(srcdir("spike-tools.jl"))
include(srcdir("data-tools.jl"))
include(scriptsdir("load-data.jl"))




function crosscor(s::Array{Float64, 2}, couples::Array{Array{Int64, 1}, 1}, lags=[-min(size(x,1)-1, 10*log10(size(x,1))):min(size(x,1), 10*log10(size(x,1)));])
	m = zeros(length(lags), length(couples))
	for i in 1:length(couples)
		m[:, i] = crosscor(s[:, couples[i][1]], s[:, couples[i][2]], lags)
	end
	mean(dropnancols(m), dims=2)
end

@inline function crosscor(c1, c2, norm=false, lags=[-40, 40])
	@infiltrate
	bins = zeros(diff(lags)[1])
	spikes = c1 .* [1:length(c1);]
	@inbounds for s in spikes[spikes .> 0]
		a = view(CircularArray(c2), floor(Int, s-lags[1]):floor(Int, s+lags[2]))
		bins .+= a
	end
	bins
end


# 3B
around = [-300, 300]

s1 = slice(data.t[157], data.lift[157], around=around, binsize=0.5)[:]
s2 = slice(data.t[157], data.cover[157], around=around, binsize=0.5)[:]
s3 = slice(data.t[157], data.grasp[157], around=around, binsize=0.5)[:]
s = vcat(s1, s2, s3)

t1 = slice(data.t[158], data.lift[158], around=around, binsize=0.5)[:]
t2 = slice(data.t[158], data.cover[158], around=around, binsize=0.5)[:]
t3 = slice(data.t[158], data.grasp[158], around=around, binsize=0.5)[:]
t = vcat(s1, s2, s3)

Cₘ = crosscor(s, t, [-40:40;])

around2 = [-2000, 2000]
s2 = slice(data.t[157], data.cover[157], around=around2, binsize=0.5)[:]
t2 = slice(data.t[158], data.cover[158], around=around2, binsize=0.5)[:]

C = crosscor(s2, t2, [-40:40;])
plot(Cₘ)
plot!(C)

# 3C
around = [-50, 50]
n = slice(data.t, data.lift, around=[-25, 25], normalization=true, average=true)
idx = active_neurons(n, -0.5, 2.5)
tmp = data[idx, :];

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

	

