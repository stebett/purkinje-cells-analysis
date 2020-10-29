using DSP
using Distributions

include("utils.jl")

z = [pdf(Normal(0, 10), x) for x in -500:500]

convs = zeros(2000, size(data.t, 1))
for (i, (t, l)) in enumerate(zip(data.t, [c[1] for c in data.l]))
    s = slice(t, l, 500)
    if size(s, 1) == 0
        convs[:, i] .= 0.
    else 
        s = sliding_discretize(s, 1000)
        convs[:, i] = conv(s, z)
    end
end
corrs = cor(convs)
