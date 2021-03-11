using DrWatson
@quickactivate :ens

using JLD2 
using Logging
using Dates

include(srcdir("spline", "spline-analysis.jl"))

data = load_data("data-v6.arrow"); 
cells = readlines(datadir("cell-pairs.txt")) 
x = [[cells[i], cells[i+1]] for i in 1:2:length(cells)]
cellpairs = make_couples.(Ref(data), x); # TODO use all neighs

io = open(datadir("logs", "multi-psth-spline.txt"), "w+")
logger = SimpleLogger(io)
global_logger(logger)

@info "Simulation of $(Dates.format(now(), "dd-mm-YYYY at HH:MM"))"; flush(io)

tmp = []
for couple in cellpairs # TODO with all neighbors
	try
		@info "Computing couple:" couple[:, [:rat, :site, :tetrode, :neuron]]; flush(io)
		push!(tmp, gssanalysis(couple, multi=true))
	catch e
		@warn "Exception occurred:\n$e"
	end
	@info "Success!"
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


