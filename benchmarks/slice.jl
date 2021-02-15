using DrWatson
@quickactivate "ens"

using BenchmarkTools
include(scriptsdir("data", "load-arrow.jl"))
include(srcdir("spike-tools.jl"))

suite = BenchmarkGroup()

suite["old-slice"] = BenchmarkGroup(["vector", "matrix", "conv", "norm", "aver"])
suite["new-slice"] = BenchmarkGroup(["vector", "matrix", "conv", "norm", "aver"])

suite["old-slice"]["vector"] = @benchmarkable slice_(data.t[1], data.lift[1][1], [-500, 500])
suite["old-slice"]["matrix"] = @benchmarkable slice_(data.t, data.lift, [-500, 500])
suite["old-slice"]["conv"] = @benchmarkable slice(data.t, data.lift, around=[-500, 500], convolution=true, normalization=false, average=false)
suite["old-slice"]["norm"] = @benchmarkable slice(data.t, data.lift, around=[-500, 500], convolution=true, normalization=true, average=false)
suite["old-slice"]["aver"] = @benchmarkable slice(data.t, data.lift, around=[-500, 500], convolution=true, normalization=false, average=true)

results = run(suite, verbose = true)
