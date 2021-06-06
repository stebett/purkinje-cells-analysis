using DrWatson
@quickactivate :ens

struct PNRate  <: Analysis
	landmark::Symbol
	around::Vector
	over::Vector
	binsize::Int
end



function compute(A::PNRate, data)
	cuts = cut(data[:, :t], data[:, A.landmark], A.around)
	cuts_b = cut(data[:, :t], data[:, :lift], A.over)

	bins = bin.(cuts, diff(A.around)..., binsize=A.binsize)
	bins_b = bin.(cuts_b, diff(A.over)..., binsize=A.binsize)

	avg = average(bins, data)
	avg_b = average(bins_b, data)

	norms = normalize(avg, avg_b)

	pos = [any(col .> 2.5) for col in norms]
	neg = [any(col .< -2.5) for col in norms]

	pos_only = pos .& .!neg
	neg_only = neg .& .!pos

	pos_only, neg_only
end


function visualise!(A::PNRate, fig::Figure, r::Tuple, psth::Matrix, p)
	ax = Axis(fig, title="Averaged Peri-Stimulus Time Histogram")

	pos_val = vec(mean(psth[:, r[1]], dims=2))
	pos_plot = lines!(ax, pos_val; color=p[:col_pos], label="Pos. mod. cells", linewidth=p[:linewidth])

	neg_val = vec(mean(psth[:, r[2]], dims=2))
	neg_plot = lines!(ax, neg_val; color=p[:col_neg], label="Neg. mod. cells", linewidth=p[:linewidth])

	all_val = vec(mean(drop(psth), dims=2))
	all_plot = lines!(ax, all_val; color=p.col_unmod, label="All cells", linewidth=p[:linewidth])

	axislegend(ax)

	ax.xticks = ([0, length(all_val)÷2, length(all_val)], string.([A.around[1], A.landmark, A.around[1]]))
	ax.xlabel = "Time (ms)"
	ax.ylabel = "Averaged change in firing rate"
	ax
end

