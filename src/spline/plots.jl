using DrWatson
@quickactivate :ens

module SplinePlots

using Makie

function ranges_counts(df; binsize = 0.001, tmax = 50.)
	counts = zeros(Int(tmax/binsize))
	timerange = 0:binsize:tmax-binsize
	for (i, v) in enumerate(timerange)
		counts[i] = sum([r[1] .< v .< r[2] for r in vcat(df.ranges...)])
	end
	counts_perc = counts ./ size(df, 1) .* 100.
	timerange, counts_perc
end

function figure_5(df_n, df_d, ll_n, ll_d)
	params = Dict(:color => (:black, 0.25),
				  :strokecolor => :black,
				  :strokewidth => 1,
				  )

	theme = Attributes(Axis = ( xgridvisible = false, ygridvisible = false))
	fig = with_theme(theme) do
		Figure(resolution = (1800, 1024), 
			   backgroundcolor = RGBf0(0.98, 0.98, 0.98),
			   colormap = :Spectral)
	end

	a = fig[1, 1] = Makie.Axis(fig, title = "Pairs of neighbor cells \n \nBest model")
	b = fig[2, 1] = Makie.Axis(fig, title = "Peak cell interaction delay")
	c = fig[3, 1] = Makie.Axis(fig, title = "Ranges of significant\n cell interaction delays")
	d = fig[1, 2] = Makie.Axis(fig, title = "Pairs of distant Cells \n \nBest model")
	e = fig[2, 2] = Makie.Axis(fig, title = "Peak cell interaction delay")
	f = fig[3, 2] = Makie.Axis(fig, title = "Ranges of significant\n cell interaction delays")

	label_a = fig[1, 1, TopLeft()] = Label(fig, "A", textsize = 25, halign = :right)
	label_b = fig[2, 1, TopLeft()] = Label(fig, "B", textsize = 25, halign = :right)
	label_c = fig[3, 1, TopLeft()] = Label(fig, "C", textsize = 25, halign = :right)
	label_d = fig[1, 2, TopLeft()] = Label(fig, "D", textsize = 25, halign = :right)
	label_e = fig[2, 2, TopLeft()] = Label(fig, "E", textsize = 25, halign = :right)
	label_f = fig[3, 2, TopLeft()] = Label(fig, "F", textsize = 25, halign = :right)

	a.xticks = d.xticks = ([1, 2], ["Complex", "Simple"])
	b.xlabel = e.xlabel = "Time (ms)"
	c.xlabel = f.xlabel = "Time (ms)"
	a.ylabel = d.ylabel = "Count"
	b.ylabel = e.ylabel = "Density"
	c.ylabel = f.ylabel = "% of pairs with\nsignificant interaction"


	barplot!(a, [sum(ll_n.c_better), sum(.!ll_n.c_better)]; params...)
	barplot!(d, [sum(ll_d.c_better), sum(.!ll_d.c_better)]; params...)

	density!(b, df_n.peak; params...)
	density!(e, df_d.peak; params...)
	linkaxes!(b, e)

	lines!(c, ranges_counts(df_n, tmax=120))
	lines!(f, ranges_counts(df_d, tmax=120))
	linkaxes!(c, f)

	vlines!.([b, e, c, f], 10, linestyle = :dash)
	xlims!(b, -30, 120)

	fig
end

export figure_5
end


# function plot_quick_prediction(x, title="")
# 	plot(x[:est_mean], ribbon=x[:est_sd])
# 	interval = 1:length(x[:new_x])÷10:length(x[:new_x])
# 	if x[:include] == "timetoevt"
# 		xticks!(searchsortedfirst.(Ref(x[:new_x]), [2, 3, 4]), ["lift", "cover", "grasp"])
# 	else
# 		xticks!(interval, ["$(round(x[:new_x][i], digits=2))" for i in interval])
# 	end
# 	xlabel!(x[:include])
# 	ylabel!("η")
# 	title!(string(title))
# end

# function plot_single_result(x::NamedTuple)
# 	p = []
# 	for (k, v) in zip(keys(x), x)
# 		push!(p, plot_quick_prediction(v, k))
# 	end
# 	p3 = plot(framestyle=:none)
# 	l = @layout [a b c; c d e]
# 	plot(p[1], p[2], p3, p[3], p[4], p[5], layout=l, size=(1800, 1200), margin=5mm)
# end

