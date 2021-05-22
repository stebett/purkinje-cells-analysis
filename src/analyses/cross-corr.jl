using DrWatson
@quickactivate :ens

function figure_A(b, r, title; kwargs...)
	b = sort_active(hcat(convolve(b, 1.)...), 10)

	col = cgrad([:white, :black])
	p1 = heatmap(b'; c=col, cbar=false, title=title, kwargs...)
	p1 = xticks!([0, 800, 1595], ["-400", "0", "400"])
	p1 = ylabel!("Trials")

	p2 = plot(r; legend=false, c=:black, kwargs...)
	p2 = ylabel!("Firing rate")
	p2 = xlabel!("Time (ms)")
	p2 = xticks!([0, 800, 1595], ["-400", "0", "400"])

	p1, p2
end
#%

struct Raster
	index::Int
	landmark::Symbol
	around::Vector
	binsize::Real
end

struct TimeCourse
	index::Int
	landmark::Symbol
	around::Vector
	binsize::Real
	σ::Real
end


function compute(A::Raster, data)
	cuts = cut(data[data.index .== A.index, :t], data[data.index .== A.index, A.landmark], A.around)
	bins = bin.(cuts, Int(diff(A.around)...), binsize=A.binsize) 
end

function visualise!(A::Raster, fig::Figure, bins::Vector, plot_params)
	ax = Axis(fig, title="Cell $(A.index)")
	heatmap!(ax, hcat(bins...); colormap=:binary)
	ax.yticks = ([0, length(bins)], string.([1, length(bins)]))
	ax.xticks = []
	ax.ylabel = "Trial #"
	ax
end

function compute(A::TimeCourse, data)
	raster = Raster(A.index, A.landmark, A.around, A.binsize)
	bins = compute(raster, data)
	convolve(bins, A.σ) |> mean
end

function visualise!(A::TimeCourse, fig::Figure, x::Vector, plot_params)
	ax = Axis(fig)
	lines!(ax, x)
	ax.xticks = ([0, length(x)÷2, length(x)], string.([A.around[1], A.landmark, A.around[2]]))
	ax.xlabel = "Time (ms)"
	ax.ylabel = "Firing Rate"
	ax
end


function compute(A::M


pad = 500
n = 2
b1 = 100
binsize=.5
thr = 1.5
around = [-600., 600.]


mpsth, ranges = section_trial(tmp, pad, n, b1);
active_trials = get_active_trials(mpsth, ranges, thr);
active_ranges = merge_trials(tmp, active_trials);

active = Dict()
active[[i1, i2]] = vcat(active_ranges[i1]..., active_ranges[i2]...)

#% Merge neighbors active ranges
modulated = crosscor_c(data, [[i1, i2]], active, 0.5, true) # TODO make sure normalizing is ok

c₁ = cut(data[data.index .== i₁, :t], data[data.index .== i₁, :cover], around)
c₂ = cut(data[data.index .== i₂, :t], data[data.index .== i₂, :cover], around)

unmodulated = crosscor.(c₁, c₂, true,  binsize=0.5) |> mean


function figure_B(modulated, unmodulated; kwargs...)
	m = minimum(drop(modulated[:]))
	modulated[40:41] .= NaN
	unmodulated[40:41] .= NaN
	plot(modulated; c=:orange, labels="during modulation", fill=m,  fillalpha = 0.2, fillcolor=:grey, kwargs...)
	plot!(unmodulated; c=:black, labels="during whole task", α=0.6, kwargs...)
	xticks!([1:10:81;],["$i" for i =-20:5:20])
	xlabel!("Time (ms)")
	ylabel!("Normalized count")
end
#%

