using Random

function test_slice()
    idx = rand(1:length(times))
    s1 = slice(times[idx], grasps[idx], 400)

    idx = rand(1:length(times))
    s2 = slice(times[idx], 300, 400)

    idx = rand(1:length(times))
    s3 = slice(times[idx], grasps[idx], (400, 400))

    idx = rand(1:length(times))
    s4 = slice(times[idx], 300, (400, 400))

    idx = rand(1:length(times)-10)  
    idx2 = idx+10
    s5 = slice(times[idx:idx2], grasps[idx:idx2], 400)

    idx = rand(1:length(times)-10)  
    idx2 = idx+10
    s6 = slice(times[idx:idx2], grasps[idx:idx2], (400, 400))

    return true
end

function test_discretize()
    idx = rand(1:length(times)-10)  
    idx2 = idx+10
    s1 = slice(times[idx:idx2], grasps[idx:idx2], 400)


    idx = rand(1:length(times))
    s2 = slice(times[idx], 300, (400, 400))

    discretize(s1, 800)
    discretize(s2, 800)

    return true
end

function test_normalize()
    idx = rand(1:length(times)-10)  
    idx2 = idx+10
    normalize(times[idx], covers[idx])
    normalize(times[idx:idx2], covers[idx:idx2])
    return true
end

@test test_slice() && test_discretize() && test_normalize()
