using DrWatson
@quickactivate :ens

using DataFramesMeta
using StatsPlots
using Turing
using Distributed

include(srcdir("spline", "mkdf.jl"))

data = load_data("data-v6.arrow")
neigh = couple(data, :n)

idx = neigh[20]

#' Loading
df = find(data, idx) |> mkdf
df = @where(df, :timeSinceLastSpike .<= 20)

#' Visualising

histogram(df.timeSinceLastSpike)
histogram(df.nearest)

#' Convert the DataFrame object to matrices.
x = Matrix(df[:, [:time, :nearest]])
y = Vector(df[:, :timeSinceLastSpike])

#' Rescaling
x = (x .- mean(x, dims=1)) ./ std(x, dims=1)
n, _ = size(x)


@model poisson_regression(x, y, n, σ²) = begin
	b0 ~ Normal(0, σ²)
	b1 ~ Normal(0, σ²)
	b2 ~ Normal(0, σ²)
	for i = 1:n
		theta = b0 + b1*x[i, 1] + b2*x[i,2]
		y[i] ~ Poisson(exp(theta))
	end
end;

num_chains = 4
chain = mapreduce(
				  c -> sample(poisson_regression(x, y, n, 10), NUTS(200, 0.65), 2500, discard_adapt=false), 
				  chainscat, 
				  1:num_chains);

#Taking the first chain
c1 = chain[:,:,1]

# Calculating the exponentiated means
b0_exp = exp(mean(collect(c1[:b0])))
b1_exp = exp(mean(collect(c1[:b1])))
b2_exp = exp(mean(collect(c1[:b2])))


chains_new = chain[201:2500,:,:]
describe(chains_new)
plot(chains_new)

corner(chains_new)

function prediction(x::Matrix, chain)
	b0 = mean(chain, :b0)
	b1 = mean(chain, :b1)
	b2 = mean(chain, :b2)
	r = zeros(size(x, 1))
	for i = 1:n
		theta = b0 + b1*x[i, 1] + b2*x[i,2]
		r[i] = exp(theta)
	end
	r
end;

pred = prediction(x, chain)
plot(pred)
plot(df.timeSinceLastSpike)
