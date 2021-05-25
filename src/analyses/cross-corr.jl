using DrWatson
@quickactivate :ens

using Colors
using StatsBase

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

function get_active_couples(couples, ranges)
	active_couples = Dict()
	for c in couples
		active_couples[c] = vcat(ranges[c[1]]..., ranges[c[2]])
	end
	active_couples
end

function merge_ranges_(x::Vector{<:Tuple})
	a = x |> unique |> sort
	val, rep = vcat(collect.(a)...) |> sort |> rle
	b = val[rep .== 1]
	idx = BitArray(eachindex(b) .% 2)
	tuple.(b[idx], b[.!idx])
end

function filter_by_length(x::Vector{<:Tuple}, minlen::Int)
	idx = diff.(x) .< minlen
	if any(idx)
		# @info "Removing $(sum(idx)) intervals"
		return x[.!idx]
	end
	x
end

#%

struct Raster
	index::Int
	landmark::Symbol
	around::Vector
	binsize::Real
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

struct TimeCourse
	index::Int
	landmark::Symbol
	around::Vector
	binsize::Real
	σ::Real
end

function compute(A::TimeCourse, data)
	raster = Raster(A.index, A.landmark, A.around, A.binsize)
	bins = compute(raster, data)
	convolve(mean(bins), A.σ)
end

function visualise!(A::TimeCourse, fig::Figure, x::Vector, p)
	ax = Axis(fig)
	lines!(ax, x; linewidth=p.linewidth)
	ax.xticks = ([0, length(x)÷2, length(x)], string.([A.around[1], A.landmark, A.around[2]]))
	ax.xlabel = "Time (ms)"
	ax.ylabel = "Firing Rate"
	ax
end

struct ModCrossCorr
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

function visualise!(A::ModCrossCorr, fig, r, p)
	ax = Axis(fig, title="Pairs of neighboring cells")
	x = -20:0.5:20
	new_r1 = copy(r[1])
	new_r1[40:41] .= NaN
	new_r2 = copy(r[2])
	new_r2[40:41] .= NaN
	lines!(ax, x, new_r1, color=p.col_mod, linewidth=p.linewidth, label="Modulation")
	lines!(ax, x, new_r2, linewidth=p.linewidth, label="Whole task")
	band!(ax, x, r[1], minimum(r[2]), color=p.col_unmod_shade)
	ax.xlabel = "Time (ms)"
	ax.ylabel = "Normalized count"
	axislegend(ax)
	ax
end

struct GroupCrossCorr
	pad::Int          
	num_bins::Int     
	b1::Int           
	binsize::Real      
	thresh_quant::Real 
	group
end

function compute(A::GroupCrossCorr, data)

	m, ranges = multi_psth(data, A.pad, A.num_bins, A.b1);
	baseline = getindex.(m, Ref(1:ceil(Int, length(m[1])÷3)))
	m ./= mean.(baseline)

	active_trials = get_active_from_merged(m, ranges, A.thresh_quant);
	active_ranges = merge_trials(data, active_trials);

	active_couple = get_active_couples(A.group, active_ranges);

	for (key, val) in active_couple
		if isempty(active_couple[key])
			continue
		end
		active_couple[key] = merge_ranges_(val)
		active_couple[key] = filter_by_length(val, 200)
	end
	group, _= crosscor_c(data, A.group, active_couple, A.binsize) 
	drop(group)
end

function visualise(A::GroupCrossCorr, fig::Figure, neighbors, distant, p)
	ax1 = Axis(fig, title="Pairs of neighboring cells")
	ax2 = Axis(fig, title="Pairs of distant cells")

	n, d = neighbors ./ mean(neighbors), distant ./ mean(distant)
	x = -20:A.binsize:20

	mean_n = mean(n, dims=2)[:]
	mean_n[40:41] .= NaN
	sem_n = sem(n, dims=2)[:]

	lines!(ax1, x, mean_n, color=:red, linewidth=p.linewidth)
	band!(ax1, x, mean_n .+ sem_n, mean_n .- sem_n, color=p.col_mod_shade)
	vlines!.(ax1, [-5, 5], linestyle=:dash, color=:green)

	ax1.xlabel = "Time (ms)"
	ax1.ylabel = "Mean ± sem deviation"

	mean_d = mean(d, dims=2)[:]
	mean_d[40:41] .= NaN
	sem_d = sem(d, dims=2)[:]

	lines!(ax2, x, mean_d, color=p.col_unmod, linewidth=p.linewidth)
	band!(ax2, x, mean_d + sem_d, mean_d - sem_d, color=p.col_unmod_shade)
	vlines!.(ax2, [-5, 5], linestyle=:dash, color=:green)

	ax2.xlabel = "Time (ms)"
	ax2.ylabel = "Mean ± sem deviation"

	ax1, ax2
end

struct FoldedCrossCorr
	σ::Float64
	binsize::Real
end


function compute(A::FoldedCrossCorr, data, neighbors)
	n = mean(neighbors, dims=2) 
	n_unmod = crosscor_c(data, couple(data, :n), [-1000., 1000.], A.binsize, true)

	n ./= mean(n)
	n_unmod ./= mean(n_unmod)

	x = reverse(n[1:39, :], dims=1) .+ n[42:end-1, :]

	scatter_mod = copy(x)
	folded_mod = convolve(x[:], A.σ)

	y = reverse(n_unmod[1:39, :], dims=1) .+ n_unmod[42:end-1, :]
	folded_unmod = convolve(y[:], A.σ)

	folded_mod, folded_unmod, vec(scatter_mod)
end

function visualise(A::FoldedCrossCorr, fig, r, p)
	ax = Axis(fig, title="Pairs of neighboring cells")
	x = 1:A.binsize:20
	fm, fu, sm = r
	lines!(ax, x, fm, color=p.col_pos, label = "Modulation\n(smoothed)", linewidth=p.linewidth)
	lines!(ax, x, fu, color=p.col_unmod, label="Whole task", linewidth=p.linewidth)
	scatter!(ax, x, sm, color=p.col_unmod, label="Modulation", markersize=2)
	vlines!(ax, 5, linestyle=:dash, color=:black)
	ax.ylabel = "Average normalized cross-correlogram"
	ax.xlabel = "Time (ms)"
	ax.xticks = LinearTicks(5)
	axislegend(ax)
	ax
end


struct FoldedCrossCorrNeigh
	σ::Real
end




function compute(A::FoldedCrossCorrNeigh, data)
	timecourses = TimeCourseGroupMean(:cover, :n, [-150., 150.])
	cors = compute(timecourses, data)
	neighs = couple(data, :n)

	lowcor = cors .< median(drop(cors))
	highcor = cors .> median(drop(cors))

	lowcorneighs = GroupCrossCorr((
						pad = 500,
						num_bins = 2,
						b1 = 25,
						binsize = .5,
						thresh_quant = 1.4,
						group = neighs[lowcor],
						)...)

	highcorneighs = GroupCrossCorr((
						pad = 500,
						num_bins = 2,
						b1 = 25,
						binsize = .5,
						thresh_quant = 1.4,
						group = neighs[highcor],
						)...)


	lowcrosscor = compute(lowcorneighs, data) |> drop
	highcrosscor = compute(highcorneighs, data) |> drop

	lowcrosscor ./= mean(lowcrosscor, dims=1)
	highcrosscor ./= mean(highcrosscor, dims=1)

	l, h = mean.(drop.([lowcrosscor, highcrosscor]), dims = 2)
	l_s, h_s = sem.(drop.([lowcrosscor, highcrosscor]), dims = 2)

	l = reverse(l[1:39, :], dims=1) .+ l[42:end-1, :]
	h = reverse(h[1:39, :], dims=1) .+ h[42:end-1, :]

	l_s = (reverse(l_s[1:39, :], dims=1) .+ l_s[42:end-1, :]) ./ 2
	h_s = (reverse(h_s[1:39, :], dims=1) .+ h_s[42:end-1, :]) ./ 2

	vec.([l, l_s, h, h_s])
end

function visualise(A::FoldedCrossCorrNeigh, fig, r, p)
	ax1 = Axis(fig, title="Pairs of neighboring cells\nwith similar firing course")
	ax2 = Axis(fig, title="Pairs of neighboring cells\nwith different firing course")
	x = 1:0.5:20
	l, l_s, h, h_s = r

	l = convolve(l, A.σ) 
	h = convolve(h, A.σ) 
	lines!(ax1, x, l, color=p.col_unmod, linewidth=p.linewidth)
	# band!(ax1, x, l.-l_s, l.+l_s, color=RGBA(0.8,0.8,0.8,0.4))
	vlines!(ax1, 5, linestyle=:dash, color=p.col_unmod)
	lines!(ax2, x, h, color=:black, linewidth=p.linewidth)
	# band!(ax2, x, h.-h_s, h.+h_s color=RGBA(0.8,0.8,0.8,0.4), linewidth=2)
	vlines!(ax2, 5, linestyle=:dash, color=p.col_unmod)

	ax1.ylabel = "Average normalized cross-correlogram"# ± sem deviation"
	ax2.ylabel = "Average normalized cross-correlogram"# ± sem deviation"
	ax1.xlabel = "Time (ms)"
	ax2.xlabel = "Time (ms)"
	ax1.xticks = LinearTicks(5)
	ax2.xticks = LinearTicks(5)
	ax1, ax2
end
