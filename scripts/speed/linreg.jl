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

t = term.(names(df[r"x"]));
f = term(:y) ~ foldl(+, t);

ols = lm(f, df);

pred = predict(ols, df)
err = abs.(pred - df[:y])

tmp[:err] = average(err, tmp.lift)
tmp[:stderr] = deviation(err, tmp.lift)
