using DrWatson
@quickactivate "ens"

using Test
include(srcdir("section.jl"))

a = [1:128.;]
l = length(a)

function test_int(a, i)
	result = [i for _ in 1:l/i]
	bin(a, l, i) == result 
end

@testset "Integers" begin
	for i = 1 : 7
		@test test_int(a, 2. ^i)
	end
end

function test_sum(a, i)
	sum(bin(a, l, i)) == l
end
	
@testset "Sum" begin
	for i = 1. : 7
		@test test_sum(a, 2. ^i)
		@test test_sum(a, 1 / i)
	end
end

function test_fractions(a, i)
	result = []
	pattern = [1, [0 for _ in 1:1/i-1]...]
	
	for _ in 1:l
		push!(result, pattern...) 
	end

	bin(a, l, i) == result
end

@testset "Fractions" begin
	for i = 1:50
		@test test_fractions(a, 1/i)
	end
end
