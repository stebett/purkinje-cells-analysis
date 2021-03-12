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
# 	save in bson
# aggregate
# save


allcells = eachrow(load_data("data-v6.arrow"));
@load (datadir("cellpairs-v2.jl2")) allcellpairs
@load (datadir("cellpairs-v1.jld2")) cellpairs 

# TODO output is now a dict
# arguments
analaysisname = nothing
data = nothing
multi = nothing

# start of function
io = open("logs/$filname.log", "w+")
logger = SimpleLogger(io)
global_logger(logger)

filename = datadir("spline", "$analysisname.jld2")

if all(isa.(data, DataFrame))
	data = [sort.(data); sort.(data, rev=true)]
end;

@info "Simulation of $(Dates.format(now(), "dd-mm-YYYY at HH:MM"))"; flush(io)

function main(p)
	try
		@info "Computing cell(s): " p[x].index
		@info "Time: $(Dates.format(now(), "HH:MM"))" #flush(io)
		t = @elapsed r = fitcell(p[x], multi=true)
		@info "Successfully fitted in $(round(t, digits=4)) seconds"
	catch e
		@warn "Exception occurred:\n$e"
	end
end
@info "End of simulation"; flush(io)
filename = datadir("spline", "simple-complex-multi.jld2")
result_multi = merge(tmp...)
tag!(results_multi)
try 
	@save filename result_multi
	@info "Successfully saved results at $filename"
catch e
	@warn "Exception occurred during save:\n$e"
end
flush(io)
close(io)

# tests
r1 = fitcell(allcells[1], multi=true)
r2 = fitcell(allcells[1], multi=false)
r3 = fitcell(allcellpairs[1], multi=true)
r4 = fitcell(allcellpairs[1], multi=false)

