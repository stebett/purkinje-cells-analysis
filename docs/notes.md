## Already done

- [x] Peri-Stimulus time histograms
- [ ] Similarity of time course using Correlation coefficient of spike density and of the firing rate
- [ ] Standardized cross-covariance

## PSTH

- [x] Iterate it, having back also the behavioral landmarks
- [x] Take all the data using landmarks as indexes (like take grasp +- 10ms, being sure not to be too near lift)
- [x] Take 1 spike train with his behavioral landmarks
- [x] Divide it in bins of a chosen measure and count N of spikes inside each bin
- [x] Read the paper and see what they've done
- [x] Normalize it


## Similarity of time course of firing rate 1

- [x] spike density around the landmark obtained by convolution of spike times with a 10ms-wide Gaussian
- [x] take a slice of a spiketrain around a landmark and convolute it
- [x] normalize
- [x] pick 3 cases, then go on

## Effect of speed

> Is it possible to predict speed from firing rate?

- [ ] Fit a LN model so we can predict spikes and observe the dynamics
- [ ] Measure correlations and vary them and measure how dynamics/information change
- [ ] Build a dataset were every recording for every neuron is divided, and has a single trial in it, and also always has the same length, so you can add features like speed and easily retrieve stuff like non-normalized recordings
- [ ] Maybe the cerebellum cells are always active but produce null-projections when the movement is already ok, so they act as a projection of the movement vector? Is there some way to check this?
- [ ] make movements slower than a second nan
