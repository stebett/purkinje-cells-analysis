using DrWatson
@quickactivate :ens

using JLD2 
using Logging
using Dates

include(srcdir("spline", "spline-analysis.jl"))

# load data
# iterate data
# if eltype(data) <: DataFrame; iterate sorted too
# 	analyise
# 	save in jld
# aggregate
# save

# non rifare single analysis quando fai quelle complesse!

params = Dict(:psth => ["multi", "lift"],
			  :cells => ["all", "neigh", "dist"]) |> dict_list



# start of function

function datagen(p)
	filename = datadir("spline", p[:psth] *"-"* p[:cells] *".jld2")
	splinedatadir = datadir("spline-data.jld2")
	multi = p[:psth] == "multi" ? true : false

	# io = open("logs/$filname.log", "w+")
	# logger = SimpleLogger(io)
	# global_logger(logger)
	@info "Simulation of $(Dates.format(now(), "dd-mm-YYYY at HH:MM"))"

	@info "Loading dataset from $splinedatadir), $(p[:cells]) cells"
	data = load(splinedatadir, p[:cells]);

	@info "Generating reversed data couples"
	data = all(isa.(data, DataFrame)) ? [sort.(data); sort.(data, rev=true)] : data;
	data, filename, multi
end
 
@info "Starting simulation"; flush(io)
fitcell_log_save.(data, p)
@info "End of simulation"; flush(io); close(io)



function fitcell_log_save(x, fn, multi) #TODO add io
	try
		idx = x.index |> string
		tic = Dates.format(now(), "HH:MM")

		@info "Computing cell(s): $idx\nTime: $tic"
		save(fn, idx=fitcell(x, multi=multi))

		@info "Successfully fitted!"; # flush(io) 
		
	catch e
		@warn "Exception occurred:\n$e"

	end
end


# tests
r1 = fitcell(allcells[1], multi=true)
r2 = fitcell(allcells[1], multi=false)
r3 = fitcell(allcellpairs[1], multi=true)
r4 = fitcell(allcellpairs[1], multi=false)

data, fn, multi = datagen(params[1]);
fitcell_log_save(data[1], fn, multi)

data, fn, multi = datagen(params[2]);
fitcell_log_save(data[2], fn, multi)

data, fn, multi = datagen(params[3]);
fitcell_log_save(data[1], fn, multi)

data, fn, multi = datagen(params[4]);
fitcell_log_save(data[2], fn, multi)

data, fn, multi = datagen(params[5]);
fitcell_log_save(data[1], fn, multi)

data, fn, multi = datagen(params[6]);
fitcell_log_save(data[1], fn, multi)


