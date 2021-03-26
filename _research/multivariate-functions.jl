using DrWatson
@quickactivate :ens

using Spikes
using Distributions
using Statistics
using Plots
using GLM
using SmoothingSplines
using StatsPlots

include(srcdir("spline", "mkdf.jl"))
data = load_data("data-v6.arrow");

active_cells = get_active_cells(data, threshold=4)
# data = vcat([modulated ? find(data, idx) : DataFrame() for (idx, modulated) in active_cells]...)

neigh = couple(data, :n)
dist = couple(data, :d)

function couple_sign(data, idx)
	df = find(data, idx) |> mkdf
	r = glm(@formula(event ~ nearest + previousIsi + timeSinceLastSpike + time),
				df,
				Poisson(),
				LogLink())
	coeftable(r).cols[4][2]
end


function likelihoodtest(data, idx)
	df = find(data, idx) |> mkdf 
	nullmodel = glm(@formula(event ~ timeSinceLastSpike + time + nearest),
				df,
				Poisson(),
				LogLink())
	testmodel = glm(@formula(event ~ previousIsi +  timeSinceLastSpike + time + nearest),
				df,
				Poisson(),
				LogLink())
	lrtest(nullmodel, testmodel)
end




n_sig = map(neigh) do n
	try
		couple_sign(data, n)
	catch e
		NaN
	end
end

d_sig = map(dist) do d
	try
		couple_sign(data, d)
	catch e
		NaN
	end
end


nl = map(neigh) do n
	try
		likelihoodtest(data, n)
	catch e
		NaN
	end
end

dl = map(dist) do d
	try
		likelihoodtest(data, d)
	catch e
		NaN
	end
end

p = 0.001
findall(n_sig .< p)
findall(nl .< p)

findall(d_sig .< p)
outliers = findall(dl .< p)

modulation = get_modulation(data)

for i in dist[outliers]
	t1 = cut(find(data, i[1]).t, find(data,i[1]).lift, [-600., 1200.])
	t2 = cut(find(data, i[2]).t, find(data,i[2]).lift, [-600., 1200.])
	cc = crosscor.(t1, t2, true, binsize=1.0)
	cc_m = mean(drop(cc))
	cc_sem = sem.(drop(cc))
	b1 = bin.(t1, 1800, 1.)
	b2 = bin.(t2, 1800, 1.)
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
	title!("Cross correlation")
	ylabel!("norm crosscor")
	xlabel!("time")
	p = plot(p1, p3, p2, size=(1000, 1000))
	savefig(plotsdir("logbook", "26-03", "$i"))
end


correct_df(data, dist[out1])
