using DrWatson
@quickactivate :ens

using DataFramesMeta
using LaTeXStrings
using Arrow

include(srcdir("spline", "model_summaries.jl"))

struct SplineFit
	indexes::Vector
	batch::Int
	reference::String
end


function load(A::SplineFit)
	inpath_n = "/home/ginko/ens/data/analyses/spline/batch-$(A.batch)/$(A.reference)-neigh/results/fit.arrow"
	inpath_a = "/home/ginko/ens/data/analyses/spline/batch-$(A.batch)/$(A.reference)-all/results/fit.arrow"

	result_n = Arrow.Table(inpath_n) |> DataFrame
	result_a = Arrow.Table(inpath_a) |> DataFrame

	s = @where(result_a, :index1 .== A.indexes[1])
	c = @where(result_n, :index1 .== A.indexes[1], :index2 .== A.indexes[2])
	s, c
end

function visualise(A::SplineFit, fig::Figure, r)
	params = (linewidth=2.,)

	s, c = r
	X = c.x
	Ys = s.mean
	Es = s.sd
	Yc = c.mean
	Ec = c.sd

	ax1 = Axis(fig, title = "Simple Model\nTime to event")
	lines!(ax1, X[1], Ys[1]; params...)
	band!(ax1, X[1], Ys[1] .+ Es[1], Ys[1] .- Es[1], color=RGBA(0,0,0,0.25))

	ax2 = Axis(fig, title = "Simple Model\nTime since last spike")
	lines!(ax2, X[2], Ys[2]; params...)
	band!(ax2, X[2], Ys[2] .+ Es[2], Ys[2] .- Es[2], color=RGBA(0,0,0,0.25))

	ax3 = Axis(fig, title = "Complex Model\nTime to event")
	lines!(ax3, X[1], Yc[1]; params...)
	band!(ax3, X[1], Yc[1] .+ Ec[1], Yc[1] .- Ec[1], color=RGBA(0,0,0,0.25))

	ax4 = Axis(fig, title = "Complex Model\nTime since last spike")
	lines!(ax4, X[2], Yc[2]; params...)
	band!(ax4, X[2], Yc[2] .+ Ec[2], Yc[2] .- Ec[2], color=RGBA(0,0,0,0.25))

	ax5 = Axis(fig, title = "Complex Model\nCell interaction delay")
	lines!(ax5, X[3], Yc[3]; axis=(xlabel="prova",), params...)
	band!(ax5, X[3], Yc[3] .+ Ec[3], Yc[3] .- Ec[3], color=RGBA(0,0,0,0.25))

	xlims!(ax2, (0, 50))
	xlims!(ax4, (0, 50))
	xlims!(ax5, (0, 50))

	ax1.xlabel = "Time (ms)"
	ax2.xlabel = "Time (ms)"
	ax3.xlabel = "Time (ms)"
	ax4.xlabel = "Time (ms)"
	ax5.xlabel = "Time (ms)"

	ax1.ylabel = "η"
	ax2.ylabel = "η"
	ax3.ylabel = "η"
	ax4.ylabel = "η"
	ax5.ylabel = "η"

	ax1, ax2, ax3, ax4, ax5
end
