using DrWatson
@quickactivate :ens

using Spikes
using MultivariateStats
using DataFrames
using Plots; gr()
using Statistics
using GLM

data = load_data("data-v5.arrow");

tmp = data;
σ = 1.5
around = [-100., 300.]

speed = [x for y=tmp.cover for x=y] .- [x for y=tmp.lift for x=y]

n = cut(tmp[:, :t], tmp[:, :lift], around);
n = bin(n, Int(diff(around)...), 1.);

baseline = cut(tmp[:, :t], tmp[:, :lift], [-1000., -500.]);
baseline = bin(baseline, Int(diff(around)...), 1.);

n = normalize(n, baseline, :mad);
r = [mean(x) for x=n]

scatter(r, speed)

heatmap(cor(r, speed))

df = DataFrame([r, speed], [:r, :y])

train = df[1:2000, :]
test = df[1:600, :]

f = @formula(y ~ r)
ols = lm(f, train);

pred = predict(ols, test)

scatter(test[:y])
scatter!(pred)
title!("AME: " * string(round(mean(abs.(pred - test[:y])), digits=2)))
