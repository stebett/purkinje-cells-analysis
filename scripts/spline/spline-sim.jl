using DrWatson
@quickactivate :ens

using JLD2 
using Logging

include(srcdir("spline", "spline-analysis.jl"))

#%
data = load_data("data-v6.arrow"); 
cells = readlines(datadir("cell-pairs.txt")) 
x = [[cells[i], cells[i+1]] for i in 1:2:length(cells)]
cellpairs = make_couples.(Ref(data), x); # TODO use all neighs


#% Simple vs complex simulation
tmp = []
for couple in cellpairs # TODO with all neighbors
	try
		push!(tmp, gssanalysis(couple))
	catch e
		@warn "Exception: ", e
		@warn "gssanalysis failed for the following values"
		@show couple[:, [:rat, :site, :tetrode, :neuron]]
	end
end
@save datadir("spline", "simple-complex.jld2") merge(tmp...)

#% Simple vs complex multi
io = open(datadir("logs", "multi-psth-spline.txt"), "w+")
logger = SimpleLogger(io)
global_logger(logger)

tmp = []
for couple in cellpairs # TODO with all neighbors
	try
		@info "Computing couple:" c[:, [:rat, :site, :tetrode, :neuron]]; flush(io)
		push!(tmp, gssanalysis(couple, multi=true))
	catch e
		@warn "Exception occurred:\n$e"
	end
	@info "Success!"
end
@info "End of simulation"; flush(io)
filename = datadir("spline", "simple-complex-multi.jld2")
result_multi = merge(tmp...)
try 
	@save filename result_multi
	@info "Successfully saved results at $filename"
catch e
	@warn "Exception occurred during save:\n$e"
end
flush(io)
close(io)


#% Likelihood simulation
io = open(datadir("logs", "likelihood.txt"), "w+")
logger = SimpleLogger(io)
global_logger(logger)


@info "Starting the simulation"
df = DataFrame()
for couple in cellpairs # TODO with all neighbors
	for c in [sort(couple), sort(couple, rev=true)]
		@info "Computing couple:" c[:, [:rat, :site, :tetrode, :neuron]]
		flush(io)
		try
			push!(df, halffit(c))
		catch e
			@warn "Exception occurred:\n$e"
		end
		@info "Success!"
	end
end
@info "End of simulation"
flush(io)
safesave(datadir("spline", "likelihood.csv"), df)
close(io)

