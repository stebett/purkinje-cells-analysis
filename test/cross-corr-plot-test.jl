using DrWatson
@quickactivate :ens

using Statistics
using Plots; gr()

include(srcdir("section-trial.jl"))
include(srcdir("plot", "psth.jl"))
include(srcdir("plot", "cross-correlation.jl"))

tmp = data[data.p_acorr .< 0.5, :];

function test_active(df, idx, rng)
	c1 = vcat.(section.(Ref(df[df.index .== idx[1], :t]), Ref(df[df.index .== idx[1], :cover]), rng)...)
	c2 = vcat.(section.(Ref(df[df.index .== idx[2], :t]), Ref(df[df.index .== idx[2], :cover]), rng)...)
	c3 = crosscor.(c1, c2, false, binsize=1.) |> x->hcat(x...) |> drop |> x->mean(x, dims=2)

	fr1 = hcat(c1...) |> drop |> mean |> x->round(x, digits=3)
	fr2 = hcat(c2...) |> drop |> mean |> x->round(x, digits=3)
	if fr1 < 0.01 || fr2 < 0.01
		return
	end

	heatmap(hcat(c1...)')
	p1 = title!("Mean Firing rate: $fr1")
	heatmap(hcat(c2...)')
	p2 = title!("Mean Firing rate: $fr2")
	p3 = plot(c3)
	
	l = @layout [ a b ; c ]
	p = plot(p1, p2, p3, layout=l)

	savefig(p, plotsdir("crosscor", "test", "$idx"))
	return c3
end


function test_all_active(df)
	pad = 1000.
	num_bins = 6
	b = 200
	n, r = sectionTrial(df, num_bins, pad, b, :mad);
	todrop = drop(n, index=true)
	ranges = get_active_ranges(df, num_bins=num_bins, pad=pad, b=b)
	active(ranges, x) = Tuple{Float64, Float64}[ranges[x[1]]..., ranges[x[2]]...]
	neigh = get_pairs(tmp, "n")
	active_bins = active.(Ref(ranges), neigh)

	c = []
	for (idx, bad, act) = zip(neigh, todrop, active_bins)
		if bad
			nothing
		elseif isempty(act)
			nothing
		else
			push!(c, test_active(df, idx, act))
		end
	end
end

test_all_active(tmp)
