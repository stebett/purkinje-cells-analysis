using DrWatson
@quickactivate :ens

using DataFrames
using StatsPlots

using Measurements
using Statistics

data = load_data("data-v6.arrow");

# Add 25Hz minimum condition (biologically relevant, otherwise badly sorted or not Purkinje)
# Wilcox test for signifcancy

function correlations(data, l, g)
	group = couple(data, g);
	couples = find.(Ref(data), group)
	around = [-150., 150.]
	around_len = diff(around)[1]

	r = Float64[]
	for c in couples
		cuts1 = cut(c[1, :t], c[1, l], around)
		bins1 = bin.(cuts1, around_len)
		conv1 = convolve(bins1, 10)

		cuts2 = cut(c[2, :t], c[2, l], around)
		bins2 = bin.(cuts2, around_len)
		conv2 = convolve(bins2, 10)

		push!(r, cor.(conv1, conv2)...)
	end

	r = drop(r)
	λ = mean(r)
	σ = sem(r)
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

# savefig(plotsdir("presentation", "correlations.png"))
