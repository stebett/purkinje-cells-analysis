using DrWatson
@quickactivate :ens

using RCall
using StatsPlots
using Measures
using OrderedCollections
pyplot()


include(srcdir("spline-pipeline.jl"))
include(srcdir("spline-R.jl"))

#%
data = load_data("data-v6.arrow"); 

cells = readlines(datadir("cell-pairs.txt")) 
x = [[cells[i], cells[i+1]] for i in 1:2:length(cells)]
cellpairs = make_couples.(Ref(data), x); # TODO use all neighs

function quickPredict(uniformdf, gssResult, variable)
	x = convert(Dict{Symbol, Any}, R"quickPredict($gssResult, $variable)")
	if isnothing(convert(Int, R"$uniformdf$inv.rnfun[[$variable]]"))
		x[:new_x] = x[:xx]
	else
		x[:new_x] = convert(Array{Float64, 1}, R"$uniformdf$inv.rnfun[[$variable]]($(x[:xx]))")
	end
	x
end

#%
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

	(simple_isi=s_isi, simple_time=s_time, complex_isi=c_isi, complex_time=c_time, complex_nearest=c_nearest)
end

function gssanalysis(cellpair)
	idx1 = sort(cellpair)[1, :index]
	idx2 = sort(cellpair, rev=true)[1, :index]

	d = Dict(idx1 => cellanalysis(sort(cellpair)),
			 idx2 => cellanalysis(sort(cellpair, rev=true)))
end


function plot_quick_prediction(x, title="")
	plot(x[:est_mean], ribbon=x[:est_sd])
	interval = 1:length(x[:new_x])÷10:length(x[:new_x])
	xticks!(interval, ["$(round(x[:new_x][i], digits=2))" for i in interval])
	xlabel!(x[:include])
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

