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
- [x] make output go in tmp directory, reduce mess with paths
- [x] violin plots for event vs nearest
- [x] categorical scatterplots (collapse nearest onto timeforspike with mean and std)
- [x] rewrite crosscor
- [x] use dataframesmeta.jl
- [x] make notebooks with analyses and write stuff, and use them for daily reports
- [x] figure out why best time starts from 0

- [x] try out non-parametric kernel regression, MARS, simple anova
- [x] simulate cells
- [x] plot all fits for each analysis

- [ ] implement a clustering pipeline with statsplots for plotting (or gadfly or makie)

- [x] try out makie, maybe redoing crosscor pipeline

- [ ] maybe make a SpikeTrain class, (ponder the benefits)
- [ ] remove all dataframes dependencies from spikes

- [ ] bootstraping 

- [ ] add git hash to metadata |> maybe use a toml for the whole batch, with all the parameters, so that it is very easy to change, and has the hash of each commit for each simulation produced
- [ ] you need some way to make the pipeline usable with any single data, maybe also offline so that it can be automatized, but mostly you need to be able to feed data to the simulation

- [ ] add best reference to best
- [ ] figure 4
