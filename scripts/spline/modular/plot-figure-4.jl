using DrWatson
@quickactivate :ens

using DataFramesMeta
using DataFrames
using Arrow
using StatsBase
using Makie
using Printf

include(srcdir("spline", "model_summaries.jl"))

# Load results
batch = 8
reference = "best"

batch = ARGS[1]
reference = ARGS[2]

inpath_ll = "/home/ginko/ens/data/analyses/spline/ll-batch-7/results/result.arrow"
inpath_n = "/home/ginko/ens/data/analyses/spline/batch-$batch/$reference-neigh/results/simulated.arrow"
inpath_a = "/home/ginko/ens/data/analyses/spline/batch-$batch/$reference-all/results/simulated.arrow"
plots_path = "data/analyses/spline/batch-$batch/plots/figure-4/"

data = load_data(:last)
sim_neigh = Arrow.Table(inpath_n) |> DataFrame
sim_all = Arrow.Table(inpath_a) |> DataFrame
result_ll = Arrow.Table(inpath_ll) |> DataFrame

function select_indexes(result_ll, sim_neigh, sim_all)
	ll_n = @where(result_ll, :reference .== reference, :group .== "neigh")
	best_neigh = best_model(sim_neigh, ll_n)
	idx_n = [[i1, i2] for (i1, i2) in zip(best_neigh.index1, best_neigh.index2)]
	idx_a = sim_all.index1

	filter(x->(x[1] in idx_a), idx_n)
end

function select_cells(data, idx)
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


function visualize(cc, cc_c, cc_s, cc_params, idx)
	fig = Figure(resolution = (1200, 700))
	axis = (ylabel = "Counts", xlabel = "Time (ms)")
	x = cc_params[1]:cc_params[3]:cc_params[2]

	ax1 = fig[1, 1] = Axis(fig, title = "Cross-correlogram between real cells")
	lines!(ax1, x, cc; axis=axis)

	ax2 = fig[2, 1] = Axis(fig, title = "Complex model")
	lines!(ax2, x, cc_c; axis=axis)

	ax3 = fig[2, 2] = Axis(fig, title = "Simple model")
	lines!(ax3, x, cc_s; axis=axis)

	title = @sprintf "Cells %d and %d" idx...
	supertitle = fig[0, :] = Label(fig, title, textsize = 30, color = (:black, 0.25))

	filename = @sprintf "%d-%d.png" idx...
	save(plots_path * filename, fig)
end

# Parameters
x = -20:0.5:20
cc_params = [-20, 20, 0.5]

# Main
indexes = select_indexes(result_ll, sim_neigh, sim_all)
for idx in indexes
	cells = select_cells(data, idx)
	crosscors = process(cells..., cc_params)
	visualize(crosscors..., cc_params, idx)
end

