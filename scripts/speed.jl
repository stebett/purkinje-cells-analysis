using DrWatson
@quickactivate "ens"

include(scriptsdir("load-data.jl"))
include(srcdir("spike-tools.jl"))
include(srcdir("utils.jl"))
include(srcdir("data-tools.jl"))


using Random
using Statistics
using MultivariateStats
using Plots; plotlyjs()

st = single_trials(data, "lift")
st["speed"] = st.cover - s.lift

histogram(st.speed)

function fit_fourths(st)
	q1 = quantile(skipnan(st.speed), 0.25)
	med = quantile(skipnan(st.speed), 0.50)
	q3 = quantile(skipnan(st.speed), 0.75)

	idx = [st["speed"] .< q1, q1 .<= st["speed"] .< med, med .< st["speed"] .< q3, q3 .<= st["speed"]]

	M = []
	for i in idx
		N = hcat(st[i, "t"]...)
		N = dropnancols(N)
		N = dropinfcols(N)
		N = dropoutliercols(N)
		push!(M, fit(PCA, N, maxoutdim=3))
	end
	M
end

function fit_thirds(st)
	t1 = quantile(skipnan(st.speed), 0.33)
	t3 = quantile(skipnan(st.speed), 0.66)

	idx = [st["speed"] .< t1, t1 .<= st["speed"] .< t3, t3 .<= st["speed"]]

	M = []
	for i in idx
		N = hcat(st[i, "t"]...)
		N = dropnancols(N)
		N = dropinfcols(N)
		N = dropoutliercols(N)
		push!(M, fit(PCA, N, maxoutdim=3))
	end
	M
end

function fit_halfes(st)
	med = median(skipnan(st.speed))

	idx = [st["speed"] .< med, med .<= st["speed"]]

	M = []
	for i in idx
		N = hcat(st[i, "t"]...)
		N = dropnancols(N)
		N = dropinfcols(N)
		N = dropoutliercols(N)
		push!(M, fit(PCA, N, maxoutdim=3))
	end
	M
end

scatter(M[1].proj[:, 1], M[1].proj[:, 2], M[1].proj[:, 3], zcolor=[1:size(M[1].proj, 1);],  xaxis="First component", yaxis="Second component",  legend=false, title="Trajectories of slow vs fast trials", size=(800, 800), color=:blues, ms=5)
scatter!(M[2].proj[:, 1], M[2].proj[:, 2],M[2].proj[:, 3],  zcolor=[1:size(M[2].proj, 1);], xaxis="First component", yaxis="Second component",  legend=false, title="Trajectories of slow vs fast trials", size=(800, 800), color=:reds, ms=5)

scatter!(M[3].proj[:, 1], M[3].proj[:, 2],M[3].proj[:, 3],  zcolor=[1:size(M[3].proj, 1);])
scatter!(M[4].proj[:, 1], M[4].proj[:, 2],M[4].proj[:, 3],  zcolor=[1:size(M[4].proj, 1);])

filename = "pca-speed.pdf"
savefig(plotsdir(filename))


X = hcat(st.t...)
X, idx_nan= dropnancols(X, idx=true)
X, idx_inf = dropinfcols(X, idx=true)
X, idx_out = dropoutliercols(X, idx=true)



M = fit(PCA, X, maxoutdim=3)
y = MultivariateStats.transform(M, X)

med = median(skipnan(st.speed))
speeds = st[idx_nan, "speed"]
speeds = speeds[idx_inf]
speeds = speeds[idx_out]

idx = [speeds .< med, med .<= speeds]
q1 = quantile(skipnan(speeds), 0.25)
med = quantile(skipnan(speeds), 0.50)
q3 = quantile(skipnan(speeds), 0.75)

idx = [speeds .< q1, q1 .<= speeds .< med, med .< speeds .< q3, q3 .<= speeds]

fast = y[:, idx[1]]'
slow = y[:, idx[4]]'

scatter(fast[:, 1], fast[:, 2], fast[:, 3])
scatter!(slow[:, 1], slow[:, 2], slow[:, 3])

