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
