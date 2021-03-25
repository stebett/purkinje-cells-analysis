using DrWatson
@quickactivate :ens

using Spikes

data = load_data("data-v6.arrow");
cellpair = find(data, [590, 592]);

tmax = [-600., 600.]
landmark = :lift
len = floor(Int, diff(tmax)[1])

st = cut(cellpair[1, :t], cellpair[1, landmark], tmax)
	ext = ceil.(Int, extrema.(st))
	ntrials = length(st)

	st = norm_len.(st, 0, len) 
	bins = bin(st, len, 1., binary=true) 
	isi = binisi.(st)
	neuron = ones(Int, len)
	time = [tmax[1]+1:tmax[2];]
	fixed_times = fixtimes(time, len, ntrials, ext)

	st2 = cut(cellpair[2, :].t, cellpair[2, landmark], tmax)
	st2 = norm_len.(st2, 0, len)
	tforw = binisi_inv.(st2) |> x->vcat(x...)
	tback = corrected_tback(st2)
	nearest = min.(tback, tforw)
	timetoevt = relativetime(cellpair, time, tmax)






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

function fixtimes(times, len, ntrials, ext)
	fixed_times = fill(NaN, len*ntrials)
	legal_ranges = [e[1]:e[2] .- 1 for e in ext] 
	for i in 1:ntrials
		rng = legal_ranges[i] .+ ((i-1)*len)
		fixed_times[rng] = times[legal_ranges[i]] 
	end
	fixed_times
end


ceil(t::Type, x::Tuple) = ceil.(t, x)
