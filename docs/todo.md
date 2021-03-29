## Effect of speed

> Is it possible to predict speed from firing rate?

- [ ] Fit a LN model so we can predict spikes and observe the dynamics
- [ ] Measure correlations and vary them and measure how dynamics/information change
- [ ] Build a dataset were every recording for every neuron is divided, and has a single trial in it, and also always has the same length, so you can add features like speed and easily retrieve stuff like non-normalized recordings
- [ ] Maybe the cerebellum cells are always active but produce null-projections when the movement is already ok, so they act as a projection of the movement vector? Is there some way to check this?
- [ ] make movements slower than a second nan

# TODO

- [ ] estimate information carryied by synchrony in sleep vs movement

- [x] move python notebooks away, use that dir for julia notebooks

- [x] refractor spline pipeline

- [x] violin plots for event vs nearest
- [ ] categorical scatterplots (collapse nearest onto timeforspike with mean and std)
- [ ] try out non-parametric kernel regression, MARS, simple anova

- [ ] implement a clustering pipeline with statsplots for plotting (or gadfly or makie)

- [x] rewrite crosscor
- [ ] try out makie, maybe redoing crosscor pipeline

- [ ] maybe make a SpikeTrain class, (ponder the benefits)

- [ ] remove all dataframes dependencies from spikes
- [ ] use dataframesmeta.jl
- [ ] make notebooks with analyses and write stuff, and use them for daily reports
- [ ] bootstraping 
