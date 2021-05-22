using DrWatson
@quickactivate :ens

using Arrow

data = load_data("data-v6.arrow")

around = [-5000., 5000.]

cuts = cut(data[:, :t], data[:, :cover], around)
bins = bin.(cuts, diff(around)...)
tot = sum.(bins)
avg_rate = average(tot, data) / 10

hist(avg_rate, bins=50)

data_v7 = data[.!(avg_rate .< 25), :]

Arrow.write(datadir("data-v7.arrow"), data_v7)
