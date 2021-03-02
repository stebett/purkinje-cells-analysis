using DrWatson
@quickactivate :ens

using Spikes
using MultivariateStats
using DataFrames
using Plots; gr()
using Statistics
using GLM

data = load_data("data-v5.arrow");

groups = groupby(data, [:rat, :site]);

σ = 10.
around = [-10., 50.]
g = groups[3];

speed = [x for y=g.cover for x=y] .- [x for y=g.lift for x=y]

n = cut(g[:, :t], g[:, :lift], around);
n = bin(n, Int(diff(around)...), 1.);
n = convolve(n, σ);

df = DataFrame(hcat(n...)')
df[:y] = speed

t = term.(names(df[r"x"]));
f = term(:y) ~ foldl(+, t);

ols = lm(f, df);

pred = predict(ols, df[r"x"])

mean(abs.(pred - df[:y]))
