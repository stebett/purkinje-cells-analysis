using DrWatson
@quickactivate "ens"

using DSP
using Plots; gr()
using Distributions

include(srcdir("spike-tools.jl"))
include(scriptsdir("load-data.jl"))


function convolute(spiketrains, landmarks, around=(-500, 500))
    z = [pdf(Normal(0, 10), i) for i in around[1]:around[2]]
    n = normalize(spiketrains, landmarks, around=around, over=around)
    c = conv(n, z)
    replace!(c, Inf=>0.)
    replace!(c, NaN=>0.)
    c
end

function correlate(convolutions)
    C = cor(convolutions)
    replace!(C, Inf=>0.)
    replace!(C, NaN=>0.)
    replace!(C, 1.0=>0.)
    C
end

# convolutions = convolute(data.t, data.l)