using DrWatson
@quickactivate "ens"

include(scriptsdir("load-data.jl"))
include(srcdir("spike-tools.jl"))

using Statistics


speeds = Float64[]

for (lift, cover) in zip([l[1] for l=data.lift], [c[1] for c=data.cover])
    if (length(lift) != length(cover)) || (-1. in lift) || (-1. in cover)
        continue
    end
    push!(speeds, (cover .- lift))
end

n = normalize(data.t, [l[1] for l=data.lift], (-500, 500), (-500, 500))
mean_rate = [mean(skipnan(n[:, i])) for i=1:size(n,2)]

cor(n, speeds)

# Decoding neuronal spikes
