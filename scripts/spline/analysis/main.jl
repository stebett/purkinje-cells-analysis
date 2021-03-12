using DrWatson
@quickactivate :ens

using JLD2 
using Logging
using Dates

include(srcdir("spline", "spline-analysis.jl"))

function main(p)
	analysisname = p[:psth] *"-"* p[:cells]
	filename = datadir("spline",  "$analysisname.jld2")
	splinedatadir = datadir("spline-data.jld2")
	multi = p[:psth] == "multi" ? true : false

	io = open(datadir("spline", "logs", "$analysisname.log"), "w+")
	logger = SimpleLogger(io)
	global_logger(logger)
	@info "Simulation of $(Dates.format(now(), "dd-mm-YYYY at HH:MM"))"

	@info "Loading dataset from $splinedatadir), $(p[:cells]) cells"
	data = load(splinedatadir, p[:cells]);
	data = all(isa.(data, DataFrame)) ? [sort.(data); sort.(data, rev=true)] : data;

	@info "Starting simulation"; flush(io)
	fitcell_log_save.(data, filename, multi)

	@info "End of simulation"; flush(io); close(io)
end
 



function fitcell_log_save(x, fn, multi) 
	try
		idx = x.index |> string
		tic = Dates.format(now(), "HH:MM")
		@info "Computing cell(s): $idx\nTime: $tic"
		jldopen(fn, "a+") do file
			file[string(idx)] = fitcell(x, multi=multi)
		end
	catch e
		@warn "Exception occurred:\n$e"
	end
end

# tests
r1 = fitcell(allcells[1], multi=true)
r2 = fitcell(allcells[1], multi=false)
r3 = fitcell(allcellpairs[1], multi=true)
r4 = fitcell(allcellpairs[1], multi=false)

# simul
params = Dict(:psth => ["multi", "lift"],
			  :cells => ["all", "neigh", "dist"]) |> dict_list


main.(params)
