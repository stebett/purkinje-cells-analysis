using DrWatson
@quickactivate :ens

using LsqFit
using Spikes
using Distributions
using Plots
using DataFrames
using GLM

include(srcdir("spline", "spline-pipeline.jl"))
data = load_data("data-v6.arrow");

tmax = [-600., 600.]
len = floor(Int, diff(tmax)[1])

st = cut(find(data, 30, :t), find(data, 30, :lift), tmax)
ext = ceil.(Int, extrema.(st))
st = cut(find(data, 31, :t), find(data, 31, :lift), tmax)

st = norm_len.(st, 0, len) 
isi = binisi.(st)

st2 = norm_len.(st2, 0, len)
tforw = binisi_inv.(st2) |> x->vcat(x...)
tback = corrected_tback(st2)

isi = vcat(isi...)
nearest = min.(tback, tforw)

ntrials = length(st)
time = [tmax[1]+1:tmax[2];]
fixed_times = fixtimes(time, len, ntrials, ext)

## Simulate some data for a dummy GLM 
a = DataFrame(X=fixed_times,
			  Y=isi,
			 Z=nearest)


### Fit Poisson GLM
r = GLM.fit(GeneralizedLinearModel,
			@formula(Y ~ X + Z),
			a,
			Poisson(),
			LogLink())

p = predict(r, a[:, [:X, :Z]])
plot(p)

function model(x, p)
	@. p[2]*exp(-x*p[1])+ p[3]*exp(-x*p[4])
end

p0 = [0.5, 0.5, 0.5, 0.5 ]
fitted = curve_fit(model, a.X, a.Y, p0)
coef(fitted)

plot(model(a.X, coef(fitted)))

