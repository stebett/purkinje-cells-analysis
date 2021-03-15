using DrWatson
@quickactivate :ens

using StatsPlots; pyplot()
using Measures

function plot_quick_prediction(x, title="")
	plot(x[:est_mean], ribbon=x[:est_sd])
	interval = 1:length(x[:new_x])÷10:length(x[:new_x])
	if x[:include] == "timetoevt"
		xticks!(searchsortedfirst.(Ref(x[:new_x]), [2, 3, 4]), ["lift", "cover", "grasp"])
	else
		xticks!(interval, ["$(round(x[:new_x][i], digits=2))" for i in interval])
	end
	xlabel!(x[:include])
	ylabel!("η")
	title!(string(title))
end

function plot_single_result(x::NamedTuple)
	p = []
	for (k, v) in zip(keys(x), x)
		push!(p, plot_quick_prediction(v, k))
	end
	p3 = plot(framestyle=:none)
	l = @layout [a b c; c d e]
	plot(p[1], p[2], p3, p[3], p[4], p[5], layout=l, size=(1800, 1200), margin=5mm)
end
