using DrWatson
@quickactivate :ens

using DataFramesMeta
using Plots
using Arrow
using Printf

neigh = Arrow.Table(ARGS[1] * "/results/fit.arrow") |> DataFrame
df = @where(neigh, :variable .== "r.nearest")

p = nothing
@eachrow df begin
	p = plot(:x, :mean, legend=false)
	fn = @sprintf "%s/plots/%d-%d" ARGS[1] :index1 :index2
	savefig(p, fn)
	closeall()
end




