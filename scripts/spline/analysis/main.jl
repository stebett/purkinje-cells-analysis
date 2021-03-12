using DrWatson
@quickactivate :ens

using JLD2 
using Logging
using Dates

include(srcdir("spline", "spline-analysis.jl"))

function datagen(p)
	filename = datadir("spline", p[:psth] *"-"* p[:cells] *".jld2")
	splinedatadir = datadir("spline-data.jld2")
	multi = p[:psth] == "multi" ? true : false

	io = open("logs/$filname.log", "w+")
	logger = SimpleLogger(io)
	global_logger(logger)
	@info "Simulation of $(Dates.format(now(), "dd-mm-YYYY at HH:MM"))"

	@info "Loading dataset from $splinedatadir), $(p[:cells]) cells"
	data = load(splinedatadir, p[:cells]);
	data = all(isa.(data, DataFrame)) ? [sort.(data); sort.(data, rev=true)] : data;

	@info "Starting simulation"; flush(io)
	fitcell_log_save.(data, p, multi, io)

	@info "End of simulation"; flush(io); close(io)
end
 



function fitcell_log_save(x, fn, multi, io) 
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

params = Dict(:psth => ["multi", "lift"],
			  :cells => ["all", "neigh", "dist"]) |> dict_list

data, fn, multi = datagen(params[1]);
fitcell_log_save.(data[1:2], fn, multi)

data, fn, multi = datagen(params[2]);
fitcell_log_save.(data[1:2], fn, multi)

data, fn, multi = datagen(params[3]);
fitcell_log_save(data[1], fn, multi)
