using DrWatson
@quickactivate "ens"

include(scriptsdir("load-data.jl"))
include(srcdir("spike-tools.jl"))

using Statistics


speeds = []
kept= []

for (i, (lifts, covers)) in enumerate(zip(data.lift, data.cover))
    if (length(lifts) != length(covers)) || (-1. in lifts) || (-1. in covers)
        continue
    end
    push!(speeds, (covers .- lifts))
    push!(kept, i)
end


speeds1 = [s[1] for s=speeds]
nans = isnan.(speeds1)
speeds1 = speeds1[.!nans]

n1 = normalize(data.t, [l[1] for l=data.lift], around=(-500, 500), over=(-5000, -3000))
mean_fr = [mean(skipnan(x)) for x=eachcol(n1)]
mean_fr = mean_fr[kept]



cor(speeds1, mean_fr)
