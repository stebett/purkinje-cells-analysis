using DrWatson
@quickactivate :ens

using Plots
using DataFramesMeta

data = load_data(:last)

function plot_trials(t, l, ln)
	x = cut(t, l, [-600., 600.])
	x = bin.(x, 0, 1200)
	x = hcat(x...)'

	xticks = collect(-600:599)
	yticks = collect(eachindex(l))

	heatmap(xticks, yticks, x, c=[:white, :black], cbar=false, yticks=yticks, framestyle=:grid)
	title!(ln)
end

@eachrow data begin
	p1 = plot_trials(:t, :lift, "lift")
	p2 = plot_trials(:t, :cover, "cover")
	p3 = plot_trials(:t, :grasp, "grasp")
	plot(p1, p2, p3, layout=@layout [ a b c ])
	savefig(plotsdir("summaries", string(:index)))
end
