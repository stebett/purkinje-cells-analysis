using DrWatson
@quickactivate :ens

using RCall
using StatsPlots
using Measures
pyplot()


include(srcdir("spline-pipeline.jl"))
include(srcdir("spline-R.jl"))

#%
data = load_data("data-v6.arrow"); # TODO change to v6

cells = readlines(datadir("cell-pairs.txt"))
x = [[cells[i], cells[i+1]] for i in 1:2:length(cells)]
cellpairs = make_couples.(x);

#%
function gssanalysis(cellpair)
	d1df = mkdf(sort(cellpair))
	d2df = mkdf(sort(cellpair, rev=true))

	m1 = R"uniformizedf($d1df)"
	m2 = R"uniformizedf($d2df)"

	gsa1S = R"gssanova(event~r.timeSinceLastSpike+time, data=$m1$data,family='binomial')"
	gsa1C = R"gssanova(event~r.timeSinceLastSpike+time+r.nearest, data=$m1$data,family='binomial')"

	s_isi = convert(Dict, R"quickPredict($gsa1S, 'r.timeSinceLastSpike')")
	s_time = convert(Dict, R"quickPredict($gsa1S, 'time')")
	c_isi = convert(Dict, R"quickPredict($gsa1C, 'r.timeSinceLastSpike')")
	c_time = convert(Dict, R"quickPredict($gsa1C, 'time')")
	c_nearest = convert(Dict, R"quickPredict($gsa1C, 'r.nearest')")

	(simple_isi=s_isi, simple_time=s_time, complex_isi=c_isi, complex_time=c_time, complex_nearest=c_nearest)
end


function plot_quick_prediction(x, title="")
	plot(x["est.mean"], ribbon=x["est.sd"])
	interval = 1:length(x["xx"])÷10:length(x["xx"])
	xticks!(interval, ["$(round(x["xx"][i], digits=2))" for i in interval])
	xlabel!(x["include"])
	ylabel!("η")
	title!(string(title))
end

function plot_single_result(x::NamedTuple)
	p = []
	for (k, v) in zip(keys(x), x)
		push!(p, plot_quick_prediction(v, k))
	end
	p3 = plot(framestyle=:none)
	l = @layout [a b c; c d e]
	plot(p[1], p[2], p3, p[3], p[4], p[5], layout=l, size=(1800, 1200), margin=5mm)
end

#%

r = gssanalysis(cellpairs[1])

results = []
for couple in cellpairs
	push!(results, gssanalysis(couple))
	# 9 is crashing, add try
end
