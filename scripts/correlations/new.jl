using DrWatson
@quickactivate :ens

using Revise
using Spikes
using DataFrames
using StatsPlots

using Measurements
using Statistics

data = load_data("data-v6.arrow");

function correlations(data, l, g)
	group = couple(data, g);
	couples = find.(Ref(data), group)
	around = [-500., 500.]
	over = [-5000., -500.]

	r = Float64[]
	for c in couples
		spikes1 = cut(c[1, :t], c[1, l], around)
		spikes1 = bin.(spikes1, 0, diff(around)[1])
		spikes1 = convolve(spikes1, 10)

		baseline1 = cut(c[1, :t], c[1, l], over)
		baseline1 = bin.(baseline1, 0, 1000)
		baseline1 = convolve(baseline1, 10)

		spikes1 = normalize(spikes1, baseline1)
		spikes1 = mean(spikes1)

		baseline2 = cut(c[2, :t], c[2, l], over)
		baseline2 = bin.(baseline2, 0, 1000)
		baseline2 = convolve(baseline2, 10)

		spikes2 = cut(c[2, :t], c[2, l], around)
		spikes2 = bin.(spikes2, 0, diff(around)[1])
		spikes2 = convolve(spikes2, 10)

		spikes2 = normalize(spikes2, baseline2)
		spikes2 = mean(spikes2)

		push!(r, cor(spikes1, spikes2))
	end

	r = drop(r)
	λ = mean(r)
	σ = std(r)
	return  λ ± σ
end

n1 = correlations(data, :lift, :n)
n2 = correlations(data, :cover, :n)
n3 = correlations(data, :grasp, :n)

d1 = correlations(data, :lift, :d)
d2 = correlations(data, :cover, :d)
d3 = correlations(data, :grasp, :d)

pyplot(size=(900, 1080))
groupedbar([[n1, n2, n3] [d1, d2, d3]], labels=["Neighbor" "Distant"])
xticks!([1, 2, 3], ["lift", "cover", "grasp"])
xlabel!("Landmark")
ylabel!("Correlation coefficient")
title!("Average time course of firing rate")

savefig(plotsdir("presentation", "correlations.png"))
