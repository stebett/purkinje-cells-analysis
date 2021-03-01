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
n = convolve(n, σ);
# n = average(n, tmp[:, :lift])

df = DataFrame(hcat(n...)')
df[:y] = speed

train = df[1:2000, :]
test = df[1:600, :]

t = term.(names(train[r"x"]));
f = term(:y) ~ foldl(+, t);

ols = lm(f, train);

pred = predict(ols, test)

scatter(test[:y])
scatter!(pred)
title!("AME: " * string(round(mean(abs.(pred - test[:y])), digits=2)))
