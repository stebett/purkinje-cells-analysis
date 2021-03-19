using DrWatson
@quickactivate :ens
using StatsPlots
using Spikes
using Plots
data = load_data("data-v6.arrow");


r1 = cut(data.t, data.lift, [-30., 30.]) |> x->bin(x, 60, 1., binary=true)  |> x->BitArray.(x) 
r2 = cut(data.t, data.cover, [-30., 30.]) |> x->bin(x, 60, 1., binary=true) |> x->BitArray.(x) 
r3 = cut(data.t, data.grasp, [-30., 30.]) |> x->bin(x, 60, 1., binary=true) |> x->BitArray.(x) 


s1 = length(r1) / sum(length.([r1, r2, r3]))
s2 = length(r2) / sum(length.([r1, r2, r3]))
s3 = length(r3) / sum(length.([r1, r2, r3]))

h1 = sum(r1) / sum(sum(r1))
h2 = sum(r2) / sum(sum(r2))
h3 = sum(r3) / sum(sum(r3))



groupedbar([h1 h2 h3],
        bar_position = :grouped,
        label=["h1" "h2" "h3"],
		size=(1400, 600))


b1 = (h1 * s1) ./ (h1 * s1 + h2 * s2 + h3 * s3)
b2 = (h2 * s2) ./ (h1 * s1 + h2 * s2 + h3 * s3)
b3 = (h3 * s3) ./ (h1 * s1 + h2 * s2 + h3 * s3)

groupedbar([b1 b2 b3],
        bar_position = :stack,
        label=["s1" "s2" "s3"],
		size=(1400, 600))

ind = h1 .* h2 .* h3 ./ sum(h1 .* h2 .* h3)

j = sum([(x1 .& x2).*(x2 .& x3).*h3 for (x1, x2, x3) in zip(r1, r2, r3)])
j = j / sum(j)

bar(ind)
bar(j)

