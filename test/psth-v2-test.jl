using DrWatson
@quickactivate :ens

using Statistics
using Plots; gr()

include(srcdir("section-trial.jl"))
include(srcdir("plot", "psth.jl"))

tmp = data[data.p_acorr .< 0.5, :];

function test_active(df, idx, rng)
	heatmap(hcat(vcat.(section.(Ref(df[df.index .== idx, :t]), Ref(df[df.index .== idx, :cover]), rng)...)...)')
	savefig(plotsdir("crosscor", "active", "$idx"))
end

function test_all_active(df)
	pad = 1000.
	num_bins = 6
	b = 200
	n, r = sectionTrial(df, num_bins, pad, b, :mad);
	active_bins = get_active_bins(n)
	ranges = get_active_ranges(df, num_bins=num_bins, pad=pad, b=b)
	todrop = drop(n, index=true)
	for (idx, bad, act) = zip(df.index, todrop, active_bins)
		if bad
			nothing
		elseif isempty(act)
			nothing
		else
			test_active(df, idx, ranges[idx])
		end
	end
end

test_all_active(tmp)
