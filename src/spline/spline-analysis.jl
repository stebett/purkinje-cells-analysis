using DrWatson
@quickactivate :ens

using RCall
using Random

include(srcdir("spline", "spline-pipeline.jl"))

function fitcell(cell::DataFrameRow; multi)
	timevar = multi ? "timetoevt" : "time"
	d = Dict()

	df = mkdf(cell, multi=multi)
	df_u = R"uniformizedf($df, c('timeSinceLastSpike', 'previousIsi'))"

	formula = "event ~ r.timeSinceLastSpike + $timevar"
	gsaS = R"gssanova(as.formula($formula), data=$df_u$data,family='binomial')"
	d[:s_isi] = quickPredict(df_u, gsaS, "r.timeSinceLastSpike")
	d[:s_time] = quickPredict(df_u, gsaS, timevar)
	d
end

function fitcell(cellpair::DataFrame; multi)
	timevar = multi ? "timetoevt" : "time"
	d = Dict()

	df = mkdf(cellpair, multi=multi)
	df_u = R"uniformizedf($df, c('timeSinceLastSpike','previousIsi','tback','tforw','nearest'))"

	formula = "event ~ r.timeSinceLastSpike + $timevar + r.nearest"
	gsaC = R"gssanova(as.formula($formula), data=$df_u$data,family='binomial')"
	d[:c_isi] = quickPredict(df_u, gsaC, "r.timeSinceLastSpike")
	d[:c_time] = quickPredict(df_u, gsaC, timevar)
	d[:c_nearest] = quickPredict(df_u, gsaC, "r.nearest")
	d
end


function halffit(cellpair; multi)
	df = mkdf(cellpair, multi=multi)

	idx = df.trial |> unique |> shuffle
	half = maximum(idx) ÷ 2
	df1 = df[in.(df.ntrial, Ref(idx[1:half+1])), :]
	df2 = df[in.(df.ntrial, Ref(idx[half+2:end])), :]
	
	m1 = R"uniformizedf($df1, c('timeSinceLastSpike','previousIsi','tback','tforw','nearest'))"
	m2 = R"uniformizedf($df2, c('timeSinceLastSpike','previousIsi','tback','tforw','nearest'))"

	gsa1S = R"gssanova(event~r.timeSinceLastSpike+time, data=$m1$data,family='binomial')"
	gsa2S = R"gssanova(event~r.timeSinceLastSpike+time, data=$m2$data,family='binomial')"
	gsa1C = R"gssanova(event~r.timeSinceLastSpike+time+r.nearest, data=$m1$data,family='binomial')"
	gsa2C = R"gssanova(event~r.timeSinceLastSpike+time+r.nearest, data=$m2$data,family='binomial')"

	s1 = rcopy(R"predictLogProb($gsa1S, $m2$data)")
    s2 = rcopy(R"predictLogProb($gsa2S, $m1$data)")
    c1 = rcopy(R"predictLogProb($gsa1C, $m2$data)")
    c2 = rcopy(R"predictLogProb($gsa2C, $m1$data)")

	return (index=cellpair[1, :].index, simple1=s1, simple2=s2, complex1=c1, complex2=c2)
end
