# Initialise the figure
fig = Figure()

# Define parameters
params = (sigma=1,
		  binsize=0.5)


# Build object
crosscor = FoldedCrossCorr(params...)

# Load data
data = load(crosscor)

# Compute the results
results = compute(crosscor, data)

# Plot the results
fig[1, 1] = visualise!(crosscor, 
					   fig, 
					   results, 
					   plot_params...)
