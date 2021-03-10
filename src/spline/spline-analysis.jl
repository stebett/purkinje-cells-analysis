using DrWatson
@quickactivate :ens

using RCall
using Random

include(srcdir("spline", "spline-pipeline.jl"))

function gssanalysis(cellpair)
	idx1 = sort(cellpair)[1, :index]
	idx2 = sort(cellpair, rev=true)[1, :index]

	d = Dict(idx1 => cellanalysis(sort(cellpair)),
			 idx2 => cellanalysis(sort(cellpair, rev=true)))
end

function cellanalysis(cellpair)
	d1df = mkdf(cellpair)

	m1 = R"uniformizedf($d1df)"

	gsa1S = R"gssanova(event~r.timeSinceLastSpike+time, data=$m1$data,family='binomial')"
	gsa1C = R"gssanova(event~r.timeSinceLastSpike+time+r.nearest, data=$m1$data,family='binomial')"

	s_isi = quickPredict(m1, gsa1S, "r.timeSinceLastSpike")
	s_time = quickPredict(m1, gsa1S, "time")
	c_isi = quickPredict(m1, gsa1C, "r.timeSinceLastSpike")
	c_time = quickPredict(m1, gsa1C, "time")
	c_nearest = quickPredict(m1, gsa1C, "r.nearest")

	return (simple_isi=s_isi, simple_time=s_time, complex_isi=c_isi, complex_time=c_time, complex_nearest=c_nearest)
end

function halffit(cellpair)
	df = mkdf(cellpair)

	idx = df.trial |> unique |> shuffle
	half = maximum(idx) ÷ 2
	df1 = df[in.(df.ntrial, Ref(idx[1:half+1])), :]
	df2 = df[in.(df.ntrial, Ref(idx[half+2:end])), :]
	
	m1 = R"uniformizedf($df1)"
	m2 = R"uniformizedf($df2)"

	gsa1S = R"gssanova(event~r.timeSinceLastSpike+time, data=$m1$data,family='binomial')"
	gsa2S = R"gssanova(event~r.timeSinceLastSpike+time, data=$m2$data,family='binomial')"
	gsa1C = R"gssanova(event~r.timeSinceLastSpike+time+r.nearest, data=$m1$data,family='binomial')"
	gsa2C = R"gssanova(event~r.timeSinceLastSpike+time+r.nearest, data=$m2$data,family='binomial')"

	s1 = rcopy(R"predictLogProb($gsa1S, $m2$data)")
    s2 = rcopy(R"predictLogProb($gsa2S, $m1$data)")
    c1 = rcopy(R"predictLogProb($gsa1C, $m2$data)")
    c2 = rcopy(R"predictLogProb($gsa2C, $m1$data)")

	return (simple1=s1, simple2=s2, complex1=c1, complex2=c2)
end

function quickPredict(uniformdf, gssResult, variable)
	x = convert(Dict{Symbol, Any}, R"quickPredict($gssResult, $variable)")
	if isnothing(convert(Int, R"$uniformdf$inv.rnfun[[$variable]]"))
		x[:new_x] = x[:xx]
	else
		# TODO make sure rcopy works
		x[:new_x] = rcopy(R"$uniformdf$inv.rnfun[[$variable]]($(x[:xx]))")
	end
	x
end
