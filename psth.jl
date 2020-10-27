using Statistics

include("utils.jl")


function find_active_neurons(spiketrains::T, landmarks::Array{Float64,1}, before=3000, around=(0, 1000)) where {T <: Array{Array{Float64,1},1}}
    
    idx = []

    for (i, (t, l)) in enumerate(zip(spiketrains, landmarks))
        base_slice = slice(t, l - before, around)
        if length(base_slice) == 0
            continue
        end
        base_bin = discretize(base_slice, 1000)
        base_mean = mean(base_bin)
        base_std = std(base_bin)
        target_slice = slice(t, l, 200)
        if length(target_slice) == 0
            continue
        end
        target_bin = discretize(target_slice, 400)
        if any(target_bin .- base_mean .> 2.5base_std)
            push!(idx, i)
        end
    end
	
    return idx
end

function psth(spiketrains, landmarks)
    idx = find_active_neurons(spiketrains, [l[1] for l in landmarks])
    active_neurons = normalize(spiketrains[idx], [l[1] for l in landmarks[idx]])
    heatmap(-400:4:399, 1:141, active_neurons, size=(800, 600),  colorbar_title="Normalized firing rate")
    xaxis!("Time (ms)", (-400, 400), [-400, 0, 400], showaxis = false)
    yaxis!("Neurons", (0, length(idx)), [0, length(idx)])
end