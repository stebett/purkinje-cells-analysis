using DrWatson
@quickactivate :ens

struct PSTH 
	landmark::Symbol
	around::Vector
	over::Vector
end


function compute(A::PSTH, data)
	cuts = cut(data[:, :t], data[:, A.landmark], A.around)
	cuts_b = cut(data[:, :t], data[:, A.landmark], A.over)

	bins = bin.(cuts, diff(A.around)...)
	bins_b = bin.(cuts_b, diff(A.over)...)

	convs = convolve(bins)
	convs_b = convolve(bins_b)

	avg = average(convs, data)
	avg_b = average(convs_b, data)

	norms = @. avg / mean(avg_b)
	hcat(norms...)
end


function visualise!(A::PSTH, fig::Figure, x::Matrix, plot_params)
	w, _ = size(x)
	ax = Axis(fig, title="Peri-Stimulus Time Histogram")

	r = sort_active(drop(x), plot_params[:sort_around])
	hm = heatmap!(ax, r; plot_params[:kwargs]...)
	ax.xticks = ([0, w÷2, w], string.([A.around[1], A.landmark, A.around[2]]))
	ax.yticks = ([1, size(r, 2)], string.([1, size(r, 2)]))
	ax.xlabel = "Time (ms)"
	ax.ylabel = "Neuron #"
	ax, hm
end

