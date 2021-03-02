using DrWatson
@quickactivate :ens

using Revise
using Spikes
using DataFrames

using Measurements
using Statistics

data = load_data("data-v5.arrow");

neigh = couple(data, :n);
relative!(neigh, data);

dist = couple(data, :d);
relative!(dist, data);

function correlations(landmark::Symbol, neigh, dist)
	n = cut(data.t, data[:, landmark], [-500., 500.])
	n = bin(n, 1000, 1.0)
	n = convolve(n, 10.)
	n = average(n, data)

	mean_neigh = mean(drop([cor(n[i]...) for i in neigh]))
	std_neigh = std(drop([cor(n[i]...) for i in neigh]))

	mean_dist = mean(drop([cor(n[i]...) for i in dist]))
	std_dist = std(drop([cor(n[i]...) for i in dist]))

	return mean_neigh ± std_neigh, mean_dist ± std_dist
end
