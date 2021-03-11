using DrWatson
@quickactivate :ens

using JLD2 
using Logging
using Dates

include(srcdir("spline", "spline-analysis.jl"))

data = load_data("data-v6.arrow"); 
neighs = couple(data, :n)
dist = couple(data, :d)
cellpairs = [data[in.(data.index, Ref(n)), :] for n in neigh];
cellpairs2 = [data[in.(data.index, Ref(n)), :] for n in dist];


io = open(datadir("logs", "multi-psth-waveform.txt"), "w+")
logger = SimpleLogger(io)
global_logger(logger)

@info "Simulation of $(Dates.format(now(), "dd-mm-YYYY at HH:MM"))", flush(io)    

tmp = []
for couple in cellpairs
	try
		@info "Computing couple:" couple[:, [:rat, :site, :tetrode, :neuron]]; flush(io)
		push!(tmp, cellanalysis_simple_multi(couple))
	catch e
		@warn "Exception occurred:\n$e"
	end
	@info "Success!"
end
@info "End of simulation"; flush(io)
filename = datadir("spline", "multi-psth-waveform.jld2")
result_multi_waveform = merge(tmp...)
tag!(results_multi_waveform)
try 
	@save filename result_multi_waveform
	@info "Successfully saved results at $filename"
catch e
	@warn "Exception occurred during save:\n$e"
end
flush(io)

@info "Start analysis on distant neurons"

tmp = []
for couple in cellpairs2
	try
		@info "Computing couple:" couple[:, [:rat, :site, :tetrode, :neuron]]; flush(io)
		push!(tmp, cellanalysis_simple_multi(couple))
	catch e
		@warn "Exception occurred:\n$e"
	end
	@info "Success!"
end
@info "End of simulation"; flush(io)
filename = datadir("spline", "multi-psth-waveform.jld2")
result_multi_waveform_dist = merge(tmp...)
tag!(results_multi_waveform_dist)
try 
	@save filename result_multi_waveform_dist
	@info "Successfully saved results at $filename"
catch e
	@warn "Exception occurred during save:\n$e"
end
flush(io)
close(io)


io = open(datadir("logs", "single-psth-waveform.txt"), "w+")
logger = SimpleLogger(io)
global_logger(logger)

@info "Simulation of $(Dates.format(now(), "dd-mm-YYYY at HH:MM"))", flush(io)    

tmp = []
for couple in cellpairs
	try
		@info "Computing couple:" couple[:, [:rat, :site, :tetrode, :neuron]]; flush(io)
		push!(tmp, cellanalysis_simple_single(couple))
	catch e
		@warn "Exception occurred:\n$e"
	end
	@info "Success!"
end
@info "End of simulation"; flush(io)
filename = datadir("spline", "single-psth-waveform.jld2")
result_single_waveform= merge(tmp...)
tag!(result_single_waveform)
try 
	@save filename result_single_waveform
	@info "Successfully saved results at $filename"
catch e
	@warn "Exception occurred during save:\n$e"
end
flush(io)

@info "Starting analysis on distant neurons"

tmp = []
for couple in cellpairs2
	try
		@info "Computing couple:" couple[:, [:rat, :site, :tetrode, :neuron]]; flush(io)
		push!(tmp, cellanalysis_simple_single(couple))
	catch e
		@warn "Exception occurred:\n$e"
	end
	@info "Success!"
end
@info "End of simulation"; flush(io)
filename = datadir("spline", "single-psth-waveform.jld2")
result_single_waveform_dist = merge(tmp...)
tag!(result_single_waveform_dist)
try 
	@save filename result_single_waveform_dist
	@info "Successfully saved results at $filename"
catch e
	@warn "Exception occurred during save:\n$e"
end
flush(io)
close(io)


