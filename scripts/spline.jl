using DrWatson
@quickactivate :ens

using JLD 

includet(srcdir("spline-pipeline.jl"))
includet(srcdir("spline-R.jl"))
includet(srcdir("spline-plots.jl"))


results_tmp = []
for couple in cellpairs # TODO with all neighbors
	try
		push!(results_tmp, gssanalysis(couple))
	catch e
		@warn "Exception: ", e
		@warn "gssanalysis failed for the following values"
		@show couple[:, [:rat, :site, :tetrode, :neuron]]
	end
end
results = merge(results_tmp...)
save(datadir("spline", "gssmodels.jld"), "iter1", results)
