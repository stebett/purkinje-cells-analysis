using DrWatson
@quickactivate :ens

using DataFramesMeta
using StatsPlots; pyplot()
using StatsBase
using Turing
using Distributed

include(srcdir("spline", "mkdf.jl"))


#' Loading
data = load_data("data-v6.arrow")

neigh = couple(data, :n)
dist = couple(data, :d)
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

#' Only nearest

nearest = x[:, 2]

@model bernoulli_reg(x, y, n, σ²) = begin
	b0 ~ Normal(0, σ²)
	b1 ~ Normal(0, σ²)
	b2 ~ Normal(0, σ²)
	for i = 1:n
		theta = b0 + b1*x[i] + b2*x[i]^2 
		y[i] ~ Bernoulli(sigmoid(theta))
	end
end;


function prediction(x::Vector, chain)
	b0 = mean(chain, :b0)
	b1 = mean(chain, :b1)
	b2 = mean(chain, :b2)
	r = zeros(size(x, 1))
	for i = 1:length(x)
		theta = b0 + b1*x[i] + b2*x[i]^2 
		r[i] = sigmoid(theta)
	end
	r
end;

chain_raw = sample(bernoulli_reg(nearest, y, n, 10), NUTS(200, 0.65), 500, discard_adapt=false)

chain = chain_raw[250:end, :, 1]

plot(chain)

pred = prediction(nearest, chain)
plot(pred)
events = findall(df.event .== 1)
scatter!(events, zeros(length(events)) .+ 0.05 )

r = range(0, 30, length=n) |> collect
pred = prediction(r, chain)
plot(r, pred)


gr()

for idx in neigh[1:10]
	p = fast_predict(data, idx);
	savefig(p, plotsdir("logbook", "06-04", "mcmc-neigh", string(idx)))
end

function fast_predict(data, idx)
	df = find(data, idx) |> mkdf
	df = @where(df, :nearest .<= 50)

	x = df.nearest
	y = df.event

	p = sortperm(x)
	x = x[p]
	y = y[p]

	dt = fit(ZScoreTransform, x)
	x_new = StatsBase.transform(dt, x)
	n = length(x_new)
	chain = sample(bernoulli_reg(x_new, y, n, 1), NUTS(200, 0.65), 250, discard_adapt=true)

	pred = prediction(x_new, chain)

	p = plot(x, pred, legend=false)
	ylabel!("p")
	xlabel!("time to nearest spike")

	p
end

# Synth data


y = rand([0,0,0,1], 900) 
isi = binisi(findall(y .== 1), 401, 500) .- 1
isi_r = binisi_r(findall(y .== 1), 399, 498) .- 1
x = min.(isi, isi_r)
y = y[400:499]

perm = sortperm(x)

dt = fit(ZScoreTransform, x)
x_new = StatsBase.transform(dt, x)
n = length(x_new)
chain = sample(bernoulli_reg(x_new, y, n, 1), NUTS(200, 0.65), 500, discard_adapt=true)

pred = prediction(x_new, chain)
p = plot(x[perm], pred[perm], legend=false)
ylabel!("p")
xlabel!("time to nearest spike")

