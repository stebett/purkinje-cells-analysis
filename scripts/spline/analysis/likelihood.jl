using DrWatson
@quickactivate :ens

using JLD2 
using Dates
using Logging

include(srcdir("spline", "spline-analysis.jl"))

#%
function likelihood_analysis(p)
	analysisname = p[:cells] * "-likelihood"
	filename = datadir("spline",  "$analysisname.jld2")
	splinedatadir = datadir("spline-data.jld2")

	io = open(datadir("spline", "logs", "$analysisname.log"), "w+")
	logger = SimpleLogger(io)
	global_logger(logger)
	@info "Simulation of $(Dates.format(now(), "dd-mm-YYYY at HH:MM"))"

	@info "Loading dataset from $splinedatadir), $(p[:cells]) cells"
	data = load(splinedatadir, p[:cells]);
	data = all(isa.(data, DataFrame)) ? [sort.(data); sort.(data, rev=true)] : data;

	@info "Starting simulation"; flush(io)
	df = DataFrame()
	for x in data
		idx = x.index |> string
		tic = Dates.format(now(), "HH:MM")
		@info "Computing cell(s): $idx\nTime: $tic"; flush(io)
		try
			push!(df, halffit(x, multi=false))
		catch e
			@warn "Exception occurred:\n$e"
		end
	end
	safesave(datadir("spline", "$analysisname.csv"), df)
	@info "End of simulation"; flush(io); close(io)
end
#%

params = [(cells="dist", ), (cells="neigh", )]
likelihood_analysis.(params)
