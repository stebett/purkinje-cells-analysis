using DrWatson
@quickactivate :ens

using Distributions
using Plots
using GLM

include(srcdir("spline", "spline-pipeline.jl"))
data = load_data("data-v6.arrow");

function couple_sign(data, idx)
	df = find(data, idx) |> mkdf
	r = glm( @formula(event ~ nearest + previousIsi + timeSinceLastSpike + time),
				df,
				Poisson(),
				LogLink(), rtol=0.2)
	coeftable(r).cols[4][2]
end


neigh = couple(data, :n)
dist = couple(data, :d)

n_sig = map(neigh) do n
	try
		couple_sign(data, n)
	catch e
		@warn e
	end
end
n_sig = n_sig[.!isnothing.(n_sig)]

d_sig = map(dist) do d
	try
		couple_sign(data, d)
	catch e
		@warn e
	end
end
d_sig = d_sig[.!isnothing.(d_sig)]

mean(n_sig)
mean(n_sig)
std(d_sig)
std(d_sig)
sum(n_sig .< 0.001)
sum(d_sig .< 0.001)
