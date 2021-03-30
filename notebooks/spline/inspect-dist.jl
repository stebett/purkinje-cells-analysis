using DrWatson
@quickactivate :ens

using JLD2 
using Spikes
using CSV
using DataFrames 
using Statistics
using Measurements
using RCall


include(srcdir("spline", "plots.jl"))
include(srcdir("spline", "spline-utils.jl"))

r_neigh = load(datadir("analyses/spline/batch-4/postprocessed", "multi-neigh.jld2"))
r_dist = load(datadir("analyses/spline/batch-4/postprocessed", "multi-dist.jld2"))

ll_n = CSV.read(datadir("analyses/spline/batch-4/postprocessed", "likelihood-neigh.csv"), 
				types=[Array{Int, 1}, Bool], DataFrame)
ll_d = CSV.read(datadir("analyses/spline/batch-4/postprocessed", "likelihood-dist.csv"),
				types=[Array{Int, 1}, Bool]) |> DataFrame

df_n = extract(r_neigh)
df_d = extract(r_dist)
n_better = df_n[in.(df_n.index, Ref(ll_n[ll_n.c_better .== 1, :index])), :]
d_better = df_d[in.(df_d.index, Ref(ll_d[ll_d.c_better .== 1, :index])), :]

data = load_data("data-v6.arrow");
active_cells = get_active_cells(data, threshold=4)
modulation = get_modulation(data)


for i in d_better.index
	t1 = cut(find(data, i[1]).t, find(data,i[1]).lift, [-600., 1200.])
	t2 = cut(find(data, i[2]).t, find(data,i[2]).lift, [-600., 1200.])
	cc = crosscor.(t1, t2, true, binsize=1.0)
	cc_m = Statistics.mean(cc)
	cc_sem = sem(hcat(cc...))
	b1 = bin(t1, 1800, 1.)
	b2 = bin(t2, 1800, 1.)
	p1 = heatmap(hcat(b1...)', colorbar=false, color=cgrad([:white, :black]))
	xticks!(collect(0:300:1800), string.(-600:300:1200))
	mod = active_cells[i[1]] ? "Modulated" : "Unmodulated"
	maxmod = maximum(modulation[i[1]])
	title!("$mod cell $(i[1])\nMean±std of most modulated landmark: ($maxmod)")
	ylabel!("trial")
	xlabel!("time")
	p2 = heatmap(hcat(b2...)', colorbar=false, color=cgrad([:white, :black]))
	xticks!(collect(0:300:1800), string.(-600:300:1200))
	mod = active_cells[i[2]] ? "Modulated" : "Unmodulated"
	maxmod = maximum(modulation[i[2]])
	title!("$mod cell $(i[2])\nMean±std of most modulated landmark: ($maxmod)")
	ylabel!("trial")
	xlabel!("time")
	p3 = plot(cc_m, ribbon=cc_sem, legend=false)
	xticks!(collect(1:10:81), string.(-40:10:40))
	title!("Cross correlation, ntrials: $(length(find(data, i[1], :lift)[1]))")
	ylabel!("norm crosscor")
	xlabel!("time")
	p4 = plot(find(d_better, i, :x), find(d_better,i, :mean), ribbon=find(d_better, i, :sd), label="")
	scatter!(find(d_better, i, :peak), minimum(find(d_better, i, :mean)), m=:vline, c=:black, label="peak")
	title!("Complex model spline fit")
	ylabel!("eta")
	xlabel!("time")
	p = plot(p1, p3, p2, p4, size=(1000, 1000))
	# savefig(plotsdir("logbook", "24-03", "dist-inspection", "$i"))
end
