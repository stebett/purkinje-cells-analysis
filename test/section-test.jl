using DrWatson
@quickactivate "ens"

using Test
include(srcdir("section.jl"))

a = [0:10:100;]

@test cut(a, 50, [-10, 10]) == [0, 10, 20]

