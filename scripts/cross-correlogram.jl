using DrWatson
@quickactivate "ens"

using Statistics
using LinearAlgebra
using Plots; gr()

include(srcdir("cross-correlation.jl"))
include(scriptsdir("load-data.jl"))
include(scriptsdir("load-full.jl"))

# 3B
function crosscor_3B(df, idx1, idx2; thr=1.5, binsize=0.5, around=[-200, 200], dir="")
	p = plot(crosscor(df, idx1, idx2; thr=1.5, binsize=0.5, around=[-200, 200], filt=true))
	p = plot!(crosscor(df, idx1, idx2; thr=1.5, binsize=0.5, around=[-200, 200], filt=false))
	if length(dir) > 0
		savefig(plotsdir("crosscor", dir, "$idx1+$idx2.png"))
	else
		p
	end
end

for couple in get_pairs(data, "n")
	crosscor_3B(couple[1], couple[2], dir="new")
end


# 3C
acorrs = data_full[:, :p_acorr1000] 
tmp = data[acorrs .> 0.5, :];
size(tmp)

neigh = get_pairs(tmp, "n")

cc_n = mass_crosscor(tmp, neigh)

cc_n_mean = mean(cc_n, dims=2)
cc_n_std = std(cc_n, dims=2)

plot(cc_n_mean) #, ribbon=cc_n_std,fc=:blue,fa=0.3,label="neighbors", linewidth=3)

# 3D
distant = get_pairs(tmp, "d")
cc_d = mass_crosscor(tmp, distant)

cc_d_mean = mean(cc_d, dims=2)
cc_d_std = std(cc_d, dims=2)
plot!(cc_d_mean) #, ribbon=cc_d_std,fc=:blue,fa=0.3,label="distant", linewidth=3)

# 3E

cc_n_norm = cc_n ./
cc_e = cc_n[40:70, :]

cc_e_mean = mean(cc_e, dims=2)
plot(cc_e_mean)
