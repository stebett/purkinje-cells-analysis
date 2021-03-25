using DrWatson
@quickactivate :ens

using Spikes

data = load_data("data-v6.arrow");

cellpair = find(data, [590, 592]);



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

relativetime(cellpair::DataFrame, time, tmax) = relativetime.(cellpair[1, :lift], 
															  cellpair[1, :cover], 
															  cellpair[1, :grasp],
															  Ref(time), Ref(tmax))

relativetime(cell::DataFrameRow, time, tmax) = relativetime.(cell[:lift], 
															 cell[:cover], 
															 cell[:grasp],
															 Ref(time), Ref(tmax))
