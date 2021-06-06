# Initialise the figure
fig = Figure()

# Define parameters
params = (landmark = :cover,
		  around = [-5000., 5000.],
		  over = [-5000., -2000.])

# Build object
psth = PSTH(params...)

# Load data
data = load(psth)

# Compute the results
results = compute(psth, data)

# Plot the results
fig[1, 1] = visualise!(psth, 
					   fig, 
					   results, 
					   plot_params...)
