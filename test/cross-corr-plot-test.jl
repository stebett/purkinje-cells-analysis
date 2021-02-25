using DrWatson
@quickactivate :ens

using Statistics
using Plots; gr()

include(srcdir("section-trial.jl"))
include(srcdir("plot", "psth.jl"))
include(srcdir("plot", "cross-correlation.jl"))


function test_all_active(df, saveplot=false)
	pad = 1000.
	num_bins = 6
	b = 200
	binsize=.5
	n, r = sectionTrial(df, num_bins, pad, b, :mad);
	todrop = drop(n, index=true) .* df.index
	todrop = todrop[todrop .> 0]
	ranges = get_active_ranges(df, num_bins=num_bins, pad=pad, b=b)
	neigh = get_pairs(df, "n")
	merged_ranges = merge.(Ref(ranges), neigh)

	c = []
	for (cell, bad, rng) = zip(neigh, todrop, merged_ranges)
		if cell[1] ∉ todrop && cell[2] ∉ todrop && !isempty(rng)
			c1 = vcat.(section.(Ref(df[df.index .== cell[1], :t]), Ref(df[df.index .== cell[1], :cover]), rng, binsize=binsize)...)
			c2 = vcat.(section.(Ref(df[df.index .== cell[2], :t]), Ref(df[df.index .== cell[2], :cover]), rng, binsize=binsize)...)
			c3 = crosscor.(c1, c2, true, binsize=binsize) |> x->hcat(x...) |> drop |> x->mean(x, dims=2)

			fr1 = hcat(c1...) |> drop |> mean
			fr2 = hcat(c2...) |> drop |> mean

			if fr1 >= 0.01 && fr2 >= 0.01
				if saveplot
					heatmap(hcat(c1...)')
					p1 = title!("Mean Firing rate: $fr1")
					heatmap(hcat(c2...)')
					p2 = title!("Mean Firing rate: $fr2")
					p3 = plot(c3)
					
					l = @layout [ a b ; c ]
					p = plot(p1, p2, p3, layout=l)

					savefig(p, plotsdir("crosscor", "test", "$cell"))
				end
			end
		end
	end
end


function test_all_active2(df, saveplot=false)
	pad = 1000
	n = 6
	b1 = 50
	binsize=.5
	thr = 2.5

	#% mpsth and the timestamps of the bins for the respective spiketrain
	# It has to be done on full data or the index of ranges would be messed up
	mpsth, ranges = sectionTrial(data, pad, n, b1);

	#% Active ranges for each trial TODO take care of inf and nan
	active_ranges = []
	for (spiketrain, rng) in zip(mpsth, ranges)
		push!(active_ranges, [x[y .> thr] for (x, y) = zip(rng, spiketrain)])
	end

	#% Merge neighbors active ranges, keeping trial separated
	merge(r, c) = vcat.(r[c]...)
	neigh = get_pairs(df, "n")

	merged_ranges = merge.(Ref(active_ranges), neigh);

	#%
	c = []
	for (cell, rng) = zip(dist, merged_ranges)
		for r in rng
			c1 = cut(df[df.index .== cell[1], :t]..., r) |> sort
			c2 = cut(df[df.index .== cell[2], :t]..., r) |> sort
			if !isempty(c1) && !isempty(c2)
				c3 = crosscor(c1, c2, true, binsize=binsize)

				fr1 = length(c1)/(max(c1...) - min(c1...)) |> x->round(x, digits=4)
				fr2 = length(c2)/(max(c2...) - min(c2...)) |> x->round(x, digits=4)

				if !isinf(fr1) && !isinf(fr2) 
					push!(c, c3)
					scatter(c1)
					p1 = title!("Mean Firing rate: $fr1")
					scatter(c2)
					p2 = title!("Mean Firing rate: $fr2")
					p3 = plot(c3)
					
					l = @layout [ a b ; c ]
					p = plot(p1, p2, p3, layout=l)

					savefig(p, plotsdir("crosscor", "test3", "$cell"))
				end
			end
		end
	end
	c3
end
