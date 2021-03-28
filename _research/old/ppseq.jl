using DrWatson
@quickactivate :ens

using Spikes
using Plots; gr()

# Import PPSeq
import PPSeq
const seq = PPSeq
import StatsBase: quantile

# Songbird metadata
max_time = 200.

data = load_data("data-v5.arrow");
around = [-100., 100.]


raw = cut(data[:, :t], data[:, :lift], around);
num_neurons = length(raw)


spikes = seq.Spike[]
for (n, t) in enumerate(raw[1:num_neurons])
	for tᵢ in t
		push!(spikes, seq.Spike(n, tᵢ))
	end
end

fig = seq.plot_raster(spikes; color="k") # returns matplotlib Figure
fig.set_size_inches([7, 3]);



#%
config = Dict(

    # Model hyperparameters
    :num_sequence_types =>  2,
    :seq_type_conc_param => 1.0,
    :seq_event_rate => 1.0,

    :mean_event_amplitude => 100.0,
    :var_event_amplitude => 1000.0,

    :neuron_response_conc_param => 0.1,
    :neuron_offset_pseudo_obs => 1.0,
    :neuron_width_pseudo_obs => 1.0,
    :neuron_width_prior => 0.5,

    :num_warp_values => 1,
    :max_warp => 1.0,
    :warp_variance => 1.0,

    :mean_bkgd_spike_rate => 30.0,
    :var_bkgd_spike_rate => 30.0,
    :bkgd_spikes_conc_param => 0.3,
    :max_sequence_length => Inf,

    # MCMC Sampling parameters.
    :num_anneals => 10,
    :samples_per_anneal => 100,
    :max_temperature => 40.0,
    :save_every_during_anneal => 10,
    :samples_after_anneal => 2000,
    :save_every_after_anneal => 10,
    :split_merge_moves_during_anneal => 10,
    :split_merge_moves_after_anneal => 10,
    :split_merge_window => 1.0,
);
#%



# Initialize all spikes to background process.
init_assignments = fill(-1, length(spikes))

# Construct model struct (PPSeq instance).
model = seq.construct_model(config, max_time, num_neurons)

# Run Gibbs sampling with an initial annealing period.
results = seq.easy_sample!(model, spikes, init_assignments, config);

seq.plot_log_likes(config, results);

seq.plot_num_seq_events(config, results);

# Grab the final MCMC sample
final_globals = results[:globals_hist][end]
final_events = results[:latent_event_hist][end]
final_assignments = results[:assignment_hist][:, end]

# Helpful utility function that sorts the neurons to reveal sequences.
neuron_ordering = seq.sortperm_neurons(final_globals)

# Plot model-annotated raster.
fig = seq.plot_raster(
    spikes,
    final_events,
    final_assignments,
    neuron_ordering;
    color_cycle=["red", "blue"] # colors for each sequence type can be modified.
)
fig.set_size_inches([7, 3]);


# Create discrete time grid.
num_timebins = 1000
dt = max_time / num_timebins
timebins = collect((0.5 * dt):dt:max_time)

# Compute a matrix firing rates (num_neurons x num_timebins)
F = seq.firing_rates(
    final_globals,
    final_events,
    timebins
)

# Plot firing rates as a heatmap

F_nrm = copy(F)
for n in 1:num_neurons
    F_nrm[n, :] .-= minimum(F[n, :])
    F_nrm[n, :] ./= maximum(F[n, :])
end

heatmap(F_nrm[neuron_ordering, :]) #; aspect="auto", origin="lower")


b = bin(raw, 200, 1.);
b = convolve(b, 10.);
b = hcat(b[neuron_ordering]...)
b_nrm = copy(b)
for n in 1:size(b_nrm, 2)
    b_nrm[n, :] .-= minimum(b[n, :])
    b_nrm[n, :] ./= maximum(b[n, :])
end
b_nrm = drop(b_nrm)
heatmap(b_nrm')

