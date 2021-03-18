using DrWatson
@quickactivate :ens

using JLD2 
using Logging
using Dates

include(srcdir("spline", "spline-analysis.jl"))

function main(p)
	analysisname = string(p[:reference]) *"-"* p[:cells]
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
	fitcell_log_save.(data, filename, p[:reference])

	@info "End of simulation"; flush(io); close(io)
end
 

function fitcell_log_save(x, fn, reference) 
	try
		idx = x.index |> string
		tic = Dates.format(now(), "HH:MM")
		@info "Computing cell(s): $idx\nTime: $tic"
		jldopen(fn, "a+") do file
			file[string(idx)] = fitcell(x, reference=reference)
		end
	catch e
		@warn "Exception occurred:\n$e"
	end
end

# simul
params = Dict(:reference => [:multi, :best],
			  :cells => ["all", "neigh", "dist"]) |> dict_list


main.(params)
