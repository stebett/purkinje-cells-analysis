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

#% Likelihood simulation
io = open(datadir("logs", "likelihood.txt"), "w+")
logger = SimpleLogger(io)
global_logger(logger)


@info "Starting the simulation"
df = DataFrame()
for couple in cellpairs # TODO with all neighbors
	for c in [sort(couple), sort(couple, rev=true)]
		@info "Computing couple:" c[:, [:rat, :site, :tetrode, :neuron]]
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
