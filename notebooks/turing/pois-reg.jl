using DrWatson
@quickactivate :ens

using DataFramesMeta
using StatsPlots
using StatsBase
using Turing
using Distributed

include(srcdir("spline", "mkdf.jl"))


#' Loading
data = load_data("data-v6.arrow")

neigh = couple(data, :n)
idx = neigh[20]

df = find(data, idx) |> mkdf
df = @where(df, :timeSinceLastSpike .<= 20, :trial .== 1)

#' Visualising

histogram(df.timeSinceLastSpike, bins=20)
histogram(df.nearest, bins=50)

#' Convert the DataFrame object to matrices.
x = Matrix(df[:, [:time, :nearest, :timeSinceLastSpike]])
y = Vector(df[:, :event])

#' Rescaling
dt = fit(ZScoreTransform, x, dims=1)
x = StatsBase.transform(dt, x)
n, _ = size(x)

sigmoid(z::Real) = one(z) / (one(z) + exp(-z))

@model poisson_regression(x, y, n, σ²) = begin
	b0 ~ Normal(0, σ²)
	b1 ~ Normal(0, σ²)
	b2 ~ Normal(0, σ²)
	b3 ~ Normal(0, σ²)
	for i = 1:n
		theta = b0 + b1*x[i, 1] + b2*x[i,2] + b3*x[i,3]
		y[i] ~ Bernoulli(sigmoid(theta))
	end
end;

num_chains = 1
chain = mapreduce(
				  c -> sample(poisson_regression(x, y, n, 10), NUTS(200, 0.65), 500, discard_adapt=false), 
				  chainscat, 
				  1:num_chains);


plot(chain)

corner(chain)

function prediction(x::Matrix, chain)
	b0 = mean(chain, :b0)
	b1 = mean(chain, :b1)
	b2 = mean(chain, :b2)
	b3 = mean(chain, :b3)
	r = zeros(size(x, 1))
	for i = 1:n
		theta = b0 + b1*x[i, 1] + b2*x[i,2] + b3*x[i,3]
		r[i] = sigmoid(theta)
	end
	r
end;


pred = prediction(x, chain)
plot(pred)
events = findall(df.event .== 1)
scatter!(events, zeros(length(events)) .+ 0.05 )


#' Only nearest

nearest = x[:, 2]

s₁ = [0, 0, 1, 0, 1]
s₂ = [1, 0, 0, 0, 1]
s₃ = [1, 0, 0, 0, 1]

c = [0, 1, 2, 1, 0]

@model bernoulli_reg(x, y, n, σ²) = begin
	b0 ~ Normal(0, σ²)
	b1 ~ Normal(0, σ²)
	b2 ~ Normal(0, σ²)
	b3 ~ Normal(0, σ²)
	for i = 1:n
		theta = b0 + b1*x[i] + b2*x[i]^2 + b3*x[i]^3
		y[i] ~ Bernoulli(sigmoid(theta))
	end
end;

		


function prediction(x::Vector, chain)
	b0 = mean(chain, :b0)
	b1 = mean(chain, :b1)
	b2 = mean(chain, :b2)
	b3 = mean(chain, :b3)
	r = zeros(size(x, 1))
	for i = 1:n
		theta = b0 + b1*x[i] + b2*x[i]^2 + b3*x[i]^3
		r[i] = sigmoid(theta)
	end
	r
end;

chain_raw = sample(bernoulli_reg(nearest, y, n, 10), NUTS(200, 0.65), 5000, discard_adapt=false)

chain = chain_raw[250:end, :, 1]

plot(chain)

pred = prediction(nearest, chain)
plot(pred)
scatter!(events, zeros(length(events)) .+ 0.05 )

r = range(0, 30, length=n) |> collect
pred = prediction(r, chain)
plot(r, pred)
