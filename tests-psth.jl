using Random

function test_slice()
    idx = rand(1:length(spiketrains))
    s1 = slice(spiketrains[idx], grasps[idx], 400)

    idx = rand(1:length(spiketrains))
    s2 = slice(spiketrains[idx], 300, 400)

    idx = rand(1:length(spiketrains))
    s3 = slice(spiketrains[idx], grasps[idx], (400, 400))

    idx = rand(1:length(spiketrains))
    s4 = slice(spiketrains[idx], 300, (400, 400))

    idx = rand(1:length(spiketrains)-10)  
    idx2 = idx+10
    s5 = slice(spiketrains[idx:idx2], grasps[idx:idx2], 400)

    idx = rand(1:length(spiketrains)-10)  
    idx2 = idx+10
    s6 = slice(spiketrains[idx:idx2], grasps[idx:idx2], (400, 400))

    return true
end

function test_discretize()
    idx = rand(1:length(spiketrains)-10)  
    idx2 = idx+10
    s1 = slice(spiketrains[idx:idx2], grasps[idx:idx2], 400)


    idx = rand(1:length(spiketrains))
    s2 = slice(spiketrains[idx], 300, (400, 400))

    discretize(s1, 800)
    discretize(s2, 800)

    return true
end

function test_normalize()
    idx = rand(1:length(spiketrains)-10)  
    idx2 = idx+10
    normalize(spiketrains[idx], covers[idx])
    normalize(spiketrains[idx:idx2], covers[idx:idx2])
    return true
end

@test test_slice() && test_discretize() && test_normalize()
