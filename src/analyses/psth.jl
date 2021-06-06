using DrWatson
@quickactivate :ens

struct PSTH  <: Analysis
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

function visualise(A::PSTH, x::Matrix, plot_params)
	fig = Figure()
	visualise!(A, fig, x, plot_params)
end

function visualise!(A::PSTH, fig::Figure, x::Matrix, plot_params)
	ax = fig[1, 1] = Axis(fig, title="Peri-Stimulus Time Histogram")
	w, _ = size(x)

	r = sort_active(drop(x), plot_params[:sort_around])
	hm = heatmap!(ax, r; plot_params[:kwargs]...)
	ax.xticks = ([0, w÷2, w], string.([A.around[1], A.landmark, A.around[2]]))
	ax.yticks = ([1, size(r, 2)], string.([1, size(r, 2)]))
	ax.xlabel = "Time (ms)"
	ax.ylabel = "Neuron #"
	fig, ax, hm
end

