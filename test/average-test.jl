using Test
using Statistics
using Spikes

x = [i % 5 for i in 1:100]
y = [[i for i in 1:5] for _ in 1:20]

@test average(x, y) == fill(2, 20)
@test deviation(x, y) == fill(std([0, 1, 2, 3, 4]), 20)

@test @inferred average(x, y) == fill(2, 20)
@test @inferred deviation(x, y) == fill(std([0, 1, 2, 3, 4]), 20)
