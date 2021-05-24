using DrWatson
@quickactivate :ens

struct MPSTH 
	around::Real
	num_bins::Int
	b1::Int
end


function compute(A::MPSTH, data)
	mpsth, ranges = multi_psth(data, A.around, A.num_bins, A.b1)
	baseline = getindex.(mpsth, Ref(1:ceil(Int, length(mpsth[1])÷3)))
	@. mpsth / mean(baseline)
end


function visualise!(A::MPSTH, fig::Figure, x::Vector, plot_params)
	ax = Axis(fig, title="Multi Peri-Stimulus Time Histogram")

	sort_agg_peaks!(x, plot_params[:sort_binsize])
	x = hcat(drop(x)...)
	w, h = size(x)

	hm = heatmap!(ax, x; plot_params[:kwargs]...)
	vlines!.(ax, [w÷2-A.num_bins, w÷2, w÷2+A.num_bins], linestyle = :dash, color= :black)

	ax.xticks = ([1, w÷2-A.num_bins, w÷2, w÷2+A.num_bins, w], string.([-A.around, "lift", "cover", "grasp", A.around])) 
	ax.yticks = ([1, h], string.([1, h]))
	ax.xlabel = "Time (ms)"
	ax.ylabel = "Neuron #"
	ax
end

