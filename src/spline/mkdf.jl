using DrWatson
@quickactivate "ens"

using DataFrames
using Spikes

function mkdf(cellpair::DataFrame; tmax=[-600., 600.], pad=350., reference=:lift, landmark=:lift, minspikes=2, roundX=true)
	tmax[2] += reference == :multi ? maximum(cellpair[1, :grasp] .- cellpair[1, :lift]) : 0.
	landmark = reference == :best ? [:lift, :cover, :grasp][get_active_events(cellpair)[1]] : :lift

	tpadded = tmax .+ [-pad, pad]
	t₁, t₂  = pad, diff(tmax)[1] + pad - 1
	T = collect(tmax[1] : tmax[2] - 1)

	st = cut(cellpair[1, :t], cellpair[1, landmark], tpadded)
	st₂ = cut(cellpair[2, :t], cellpair[2, landmark], tpadded)
	valid = (length.(st) .>= minspikes) .& (length.(st₂) .>= minspikes)
	st, st₂ = st[valid], st₂[valid]

	isi = binisi.(st₂, t₁, t₂) |> x->vcat(x...)
	isi_r = binisi_r.(st₂, t₁, t₂) |> x->vcat(x...)

	X                    = DataFrame()
	X.time               = T                                      |> x->repeat(x, length(st))
	X.timetoevt          = relativetime(cellpair, T, tmax, valid) |> x->vcat(x...)
	X.trial              = fill.(findall(valid), length(T))       |> x->vcat(x...)
	X.event              = bin.(st, t₁, t₂, binsize=1., binary=true)      |> x->vcat(x...)
	X.timeSinceLastSpike = binisi.(st, t₁, t₂)                    |> x->vcat(x...)
	X.previousIsi 	     = lastisi.(st, t₁, t₂, 0, t₂ + pad)      |> x->vcat(x...)
	X.nearest            = min.(isi, isi_r)                       

	drop!(X)
	X = roundX ? round.(X) : X
end

function mkdf(cell::DataFrameRow; tmax=[-600., 600.], pad=350., reference=:lift, landmark=:lift, minspikes=2, roundX=true)
	T = collect(tmax[1] : tmax[2] - 1)
	tmax[2] += reference == :multi ? maximum(cell[:grasp] .- cell[:lift]) : 0.
	landmark = reference == :best ? [:lift, :cover, :grasp][get_active_events(cell)[1]] : :lift

	tpadded = tmax .+ [-pad, pad]
	t₁, t₂  = pad, diff(tmax)[1] + pad - 1
	T = collect(tmax[1] : tmax[2] - 1)

	st = cut(cell[:t], cell[landmark], tpadded)
	valid = length.(st) .>= minspikes
	st = st[valid]

	X                    = DataFrame()
	X.time               = T                                      |> x->repeat(x, length(st))
	X.timetoevt          = relativetime(cell, T, tmax, valid)     |> x->vcat(x...)
	X.trial              = fill.(findall(valid), length(T))       |> x->vcat(x...)
	X.event              = bin.(st, t₁, t₂, binsize=1., binary=true)      |> x->vcat(x...)
	X.timeSinceLastSpike = binisi.(st, t₁, t₂)                    |> x->vcat(x...)
	X.previousIsi 	     = lastisi.(st, t₁, t₂, tpadded...)       |> x->vcat(x...)

	drop!(X)
	X = roundX ? round.(X) : X
end

function relativetime(lift, cover, grasp, t, tmax)
	y = zeros(size(t))

	cl = cover - lift
	gc = grasp - cover
	gl = grasp - lift

	# intervals
	beforelift = t .< 0.
	liftcover = 0. .<= t .< cl
	covergrasp = cl .<= t .< gl
	aftergrasp = t .>= gl

	y[beforelift] = 2 .- t[beforelift] ./ tmax[1] * 2 
	y[liftcover] = 2 .+ t[liftcover] ./ cl
	y[covergrasp] = 3 .+ (t[covergrasp] .- cl) ./ gc
	y[aftergrasp] = 4 .+ (t[aftergrasp] .- gl) ./ (tmax[2] .- gl) * 2

	y
end

function relativetime(cellpair::DataFrame, time, tmax, valid)
	relativetime.(cellpair[1, :lift][valid], 
				  cellpair[1, :cover][valid], 
				  cellpair[1, :grasp][valid],
				  Ref(time), Ref(tmax))
end

function relativetime(cell::T, time, tmax, valid)  where T <: DataFrameRow 
	relativetime.(cell[:lift][valid],
				  cell[:cover][valid],
				  cell[:grasp][valid],
				  Ref(time), Ref(tmax))
end
