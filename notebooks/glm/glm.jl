using DrWatson
@quickactivate :ens

using Distributions
using CategoricalArrays
using Plots
using GLM

include(srcdir("spline", "mkdf.jl"))
data = load_data("data-v6.arrow");



df = find(data, idx) |> mkdf
r = glm(@formula(event ~ nearest + previousIsi + time), df, Binomial(), LogLink())


df2 = find(data, idx) |> mkdf
df2.event = categorical(df2.event)
r = glm(@formula(event ~ nearest + previousIsi + time), df, Binomial(), LogLink())





function couple_sign(data, idx)
	df = find(data, idx) |> mkdf
	r = glm( @formula(timeSinceLastSpike ~ nearest + previousIsi + time),
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

#%

linreg = glm(@formula(timeSinceLastSpike ~ time + nearest + previousIsi), df, Poisson(), LogLink())
GLM.predict(linreg, df[df.trial .== 1, :]) |> plot
plot!(df[df.trial .== 1, :timeSinceLastSpike])


#%
