using DrWatson
@quickactivate :ens

include(srcdir("plot", "cross-correlation.jl"))


a = crosscor(data, [1, 2], [-300., 300.], binsize=0.5, lags=[-30:30;], thr=1.5)
b = crosscor(data, [[1, 2], [2, 3]], [-300., 300.], binsize=0.5, lags=[-30:30;], thr=1.5)

@test a == b[:, 1]
