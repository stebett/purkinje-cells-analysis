using DrWatson
@quickactivate :ens

using Statistics
using StatsPlots
using Spikes
using Plots
data = load_data("data-v6.arrow");


# Responses given stimuli
r_s1 = cut(data.t, data.lift, [-30., 30.]) |> x->bin(x, 60, 1., binary=true)  |> x->BitArray.(x) 
r_s2 = cut(data.t, data.cover, [-30., 30.]) |> x->bin(x, 60, 1., binary=true) |> x->BitArray.(x) 
r_s3 = cut(data.t, data.grasp, [-30., 30.]) |> x->bin(x, 60, 1., binary=true) |> x->BitArray.(x) 


# Distribution of spikes
d1 = sum(r_s1) / length(r_s1)
d2 = sum(r_s2) / length(r_s2)
d3 = sum(r_s3) / length(r_s3)

# P of individual spikes
pr_s1 = map(r_s1) do rᵢ
	p1 = prod(d1[rᵢ])
	p1 = p1 == 1. ? 0. : p1
	p0 = prod((1 .- d1)[.!rᵢ])
	p1 + p0
end

pr_s2 = map(r_s2) do rᵢ
	p1 = prod(d2[rᵢ])
	p1 = p1 == 1. ? 0. : p1
	p0 = prod((1 .- d2)[.!rᵢ])
	p1 + p0
end

pr_s3 = map(r_s3) do rᵢ
	p1 = prod(d3[rᵢ])
	p1 = p1 == 1. ? 0. : p1
	p0 = prod((1 .- d3)[.!rᵢ])
	p1 + p0
end



b_ind1 = d1 ./ (d1 + d2 + d3)
b_ind2 = d2 ./ (d1 + d2 + d3)
b_ind3 = d3 ./ (d1 + d2 + d3)

groupedbar([b1 b2 b3],
        bar_position = :stack,
        label=["s1" "s2" "s3"],
		size=(1400, 600))


ind = h1 .* h2 .* h3 ./ sum(h1 .* h2 .* h3)

j = sum([(x1 .& x2).*(x2 .& x3).*h3 for (x1, x2, x3) in zip(r1, r2, r3)])
j = j / sum(j)

bar(ind)
bar(j)

