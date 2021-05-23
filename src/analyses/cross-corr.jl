using DrWatson
@quickactivate :ens

using Colors

includet(srcdir("crosscor.jl"))

function merge_ranges(y)
	ranges::Vector{Tuple{Float64, Float64}} = []
	start, finish = 0., 0.
	for c in y
		if finish != c[1]
			push!(ranges, (start, finish))
			start = c[1]
		end
		finish = c[2]
	end
	push!(ranges, (start, last(y)[2]))
	ranges[2:end]
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

struct ModCrossCorr
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


function compute(A::ModCrossCorr, data)
	i1 = 437
	i2 = 438
	tmp = data[(data.index .== i1) .| (data.index .== i2), :]

	pad = 400
	n = 2
	b1 = 100
	binsize=.5
	thr = 1.5
	around = [-700., 700.]


	mpsth, ranges = section_trial(tmp, pad, n, b1);
	active_trials = get_active_trials(mpsth, ranges, thr);
	active_ranges = merge_trials(tmp, active_trials);

	active = Dict()
	active[[i1, i2]] = merge_ranges(vcat(active_ranges[i1]..., active_ranges[i2]...))

	#% Merge neighbors active ranges
	modulated, total_spikes = crosscor_c(data, [[i1, i2]], active, 0.5)
	total_time = diff.(active[[i1, i2]]) |> sum
	modulated /= (total_spikes * binsize / total_time)

	c₁ = cut(data[data.index .== i1, :t], data[data.index .== i1, :cover], around)
	c₂ = cut(data[data.index .== i2, :t], data[data.index .== i2, :cover], around)

	unmodulated = crosscor.(c₁, c₂, -20, 20,  .5) |> sum
	total_spikes_unmod = sum(length.(c₁) .+ length.(c₂))
	total_time_unmod = diff(around)[1] * length(find(data, i1, :cover)[1])
	unmodulated /= (total_spikes_unmod * binsize / total_time_unmod)

	vec(modulated ./ mean(modulated)), unmodulated ./ mean(modulated)
end

function visualise!(A::ModCrossCorr, r)
	x = -20:0.5:20
	new_r1 = copy(r[1])
	new_r1[40:41] .= NaN
	new_r2 = copy(r[2])
	new_r2[40:41] .= NaN
	f = lines(x, new_r1, color=:gold, linewidth=2)
	lines!(x, new_r2)
	band!(x, r[1], minimum(r[2]), color=RGBA(0.8,0.8,0.8,0.4), linewidth=2, transparency=true)
	f
end

r = compute(A, data)
visualise!(A, r)

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

