using DrWatson
@quickactivate :ens

using DataFramesMeta
using StatsPlots; pyplot()
using StatsBase
using StatsFuns: logistic
using Turing

include(srcdir("spline", "mkdf.jl"))


#' Loading
data = load_data("data-v6.arrow")

neigh = couple(data, :n)
dist = couple(data, :d)
idx = dist[19]

df = find(data, idx) |> mkdf
df = @where(df, :nearest .<= 50)

#' Visualising

histogram(df.event, bins=2)
histogram(df.nearest, bins=50)

#' Convert the DataFrame object to matrices.
x = df.nearest
y = df.event

perm = sortperm(x)

#' Rescaling
dt = fit(ZScoreTransform, x)
zx = StatsBase.transform(dt, x)
n = length(x)

#' Only nearest

@model binomial_reg(x, y, n, σ²) = begin
	b0 ~ Normal(0, σ²)
	b1 ~ Normal(0, σ²)
	b2 ~ Normal(0, σ²)
	for i = 1:n
		theta = b0 + b1*x[i] + b2*x[i]^2 
		y[i] ~ Bernoulli(logistic(theta))
	end
end;


function prediction(x::Vector, chain)
	b0 = mean(chain, :b0)
	b1 = mean(chain, :b1)
	b2 = mean(chain, :b2)
	r = zeros(size(x, 1))
	for i = 1:length(x)
		theta = b0 + b1*x[i] + b2*x[i]^2 
		r[i] = logistic(theta)
	end
	r
end;

m = binomial_reg(zx, y, n, 1)
sampler = NUTS()

chain = sample(m, sampler, 500)

pred = prediction(x, chain)
plot(x[perm], pred[perm])
