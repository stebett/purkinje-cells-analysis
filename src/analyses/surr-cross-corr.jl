using DrWatson
@quickactivate :ens

using DataFramesMeta
using DataFrames
using Arrow
using StatsBase
using Printf


function select_cells(data, idx, sim_neigh, sim_all)
	n1 = @where(data, :index .== idx[1])
	n2 = @where(data, :index .== idx[2])
	landmark = [:lift, :cover, :grasp][get_active_events(n1)[1]]

	c1 = abscut(n1[1, :t], n1[1, landmark], [-500., 500.])
	c2 = abscut(n2[1, :t], n2[1, landmark], [-500., 500.])

	c1_c = @where(sim_neigh, :index1 .== idx[1], :index2 .== idx[2])[1, :fake]
	c1_s = @where(sim_all, :index1 .== idx[1])[1, :fake]

	return c1, c2, c1_c, c1_s
end

function process(c1, c2, c1_c, c1_s, cc_params)
	cc = crosscor.(c1, c2, cc_params...) |> sum
	cc_c = [sum(crosscor.(c1, fake, cc_params...)) for fake in c1_c] |> sum
	cc_s = [sum(crosscor.(c1, fake, cc_params...)) for fake in c1_s] |> sum

	return cc, cc_c, cc_s
end



struct SurrCrossCorr
	indexes::Vector
	batch::Int
	reference::String

end


function compute(A::SurrCrossCorr, data)
	cc_params = [-20, 20, 0.5]

	inpath_n = "/home/ginko/ens/data/analyses/spline/batch-$(A.batch)/$(A.reference)-neigh/results/simulated.arrow"
	inpath_a = "/home/ginko/ens/data/analyses/spline/batch-$(A.batch)/$(A.reference)-all/results/simulated.arrow"

	sim_neigh = Arrow.Table(inpath_n) |> DataFrame
	sim_all = Arrow.Table(inpath_a) |> DataFrame
	cells = select_cells(data, A.indexes, sim_neigh, sim_all)
	crosscors = process(cells..., cc_params)
end


function visualise(A::SurrCrossCorr, fig, r, p)
	axis = (ylabel = "Counts", xlabel = "Time (ms)")
	x = -20:0.5:20
	cc, cc_c, cc_s = r
	cc ./= mean(cc)
	cc_c ./= mean(cc_c)
	cc_s ./= mean(cc_s)

	ax1 = Axis(fig, title = "Real cells")
	lines!(ax1, x, cc; axis=axis, linewidth=p.linewidth)
	hlines!(ax1, 1, linestyle=:dash, color=:green)

	ax2 =  Axis(fig, title = "Real cell and surrogate\nfrom complex model")
	lines!(ax2, x, cc_c; axis=axis, linewidth=p.linewidth)
	hlines!(ax2, 1, linestyle=:dash, color=:green)

	ax3 =  Axis(fig, title = "Real cell and surrogate\nfrom simple model ")
	lines!(ax3, x, cc_s; axis=axis, linewidth=p.linewidth)
	hlines!(ax3, 1, linestyle=:dash, color=:green)

	title = @sprintf "Cells %d and %d" A.indexes...
	# supertitle = fig[0, :] = Label(fig, title, textsize = 30, color = (:black, 0.25))
	
	ax1.xlabel = "Time (ms)"
	ax2.xlabel = "Time (ms)"
	ax3.xlabel = "Time (ms)"

	ax1.ylabel = "Normalized count"
	ax2.ylabel = "Normalized count"
	ax3.ylabel = "Normalized count"

	ax1, ax2, ax3
end
