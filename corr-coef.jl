using DSP
using Distributions

include("utils.jl")



function covariants(spiketrains, landmarks, idx)
    z = [pdf(Normal(0, 10), x) for x in -500:500]
    nor = sliding_normalize(spiketrains[idx], landmarks[idx], around=(500,500))
    convs = conv(nor, z)
    cor(convs)
end

idx = find_active_neurons(data.t, [l for l in data.l])

cc = covariants(data.t, [data.l for l in data.l], idx)


plot(cc[:, 39])
plot!(cc[:, 1])