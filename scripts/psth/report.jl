using DrWatson
@quickactivate :ens

# using CairoMakie
using GLMakie

includet(srcdir("analyses/psth.jl"))
includet(srcdir("analyses/multi-psth.jl"))
includet(srcdir("analyses/pos-neg-rate.jl"))
includet(srcdir("analyses/correlations.jl"))
includet(srcdir("analyses/cross-corr.jl"))

data = load_data("data-v7.arrow")
plot_theme = Attributes(Axis = (xgridvisible = false, ygridvisible = false))
linewidth = 2.
σ = 10
colormap = :vik

# Analyses Parameters
psth = PSTH((
			 landmark = :cover,
			 around = [-5000., 5000.],
			 over = [-5000., -2000.],
			 )...)

mpsth = MPSTH((
			   around = 5000,
			   num_bins = 10,
			   b1 = 50,
			   )...)

pnrate = PNRate((
				 landmark = :cover,
				 around = [-200., 200.],
				 over = [-2000., -1000.],
				 binsize = 50,
				 )...)

timecoursegroup = TimeCourseGroup((
								   landmark = :cover,
								   group = :n,
								   around = [-150., 150.],
								   )...)

correlations = Correlation((
						   around = [-150., 150.],
						   )...)


# Plot Parameters
psth_plot_params = (
					kwargs = (colorrange = (0, 2), colormap = colormap),
					sort_around = 800,
					)


mpsth_plot_params = (
					 kwargs = (colorrange = (0, 2), colormap = colormap),
					 sort_binsize = 20,
					 )


pnrate_plot_params = (
					  kwargs = (linewidth = linewidth,),
					  colors = [:red, :blue, :black],
					  )

correlations_plot_params = (
							kwargs = (linewidth = 2.,), 
							color=[:red, :blue]
							)


# Results
psth_res = compute(psth, data)
mpsth_res = compute(mpsth, data)
pnrate_res = compute(pnrate, data)
timecoursegroup_res = compute(timecoursegroup, data)
correlations_res = compute(correlations, data)

fig = with_theme(plot_theme) do
	Figure(resolution = (1800, 1024))
end

psth_ax, psth_plot= visualise!(psth, fig, psth_res, psth_plot_params)
mpsth_ax, mpsth_plot = visualise!(mpsth, fig, mpsth_res, mpsth_plot_params)
pnrate_ax, pnrate_plots = visualise!(pnrate, fig, pnrate_res, psth_res, pnrate_plot_params)

fig[1, 1] = psth_ax
fig[1, 2] = mpsth_ax
fig[1, 3] = Colorbar(fig, psth_plot, colormap=colormap, width=10, label="Normalized change in firing rate")
fig[2, :] = pnrate_ax

hidespines!.([psth_ax, mpsth_ax, pnrate_ax], :t, :r)

label_a = fig[1, 1, TopRight()] = Label(fig, "A", textsize = 25, halign = :right)
label_b = fig[1, 2, TopRight()] = Label(fig, "B", textsize = 25, halign = :right)
label_c = fig[2, :, TopRight()] = Label(fig, "C", textsize = 25, halign = :right)

# save(plotsdir("report/figure_1.svg"), fig)


# Figure 2

fig = with_theme(plot_theme) do
	Figure(resolution = (1800, 1024))
end

tc_ax1, tc_ax2, tc_ax3 = visualise!(timecoursegroup, fig, timecoursegroup_res, plot_2_params)
corr_ax = visualise!(correlations, fig, correlations_res, plot_params)

fig[1, 1] = tc_ax1
fig[2, 1] = tc_ax2
fig[3, 1] = tc_ax3
fig[:, 2] = corr_ax

hidespines!.([tc_ax1, tc_ax2, tc_ax3, corr_ax], :t, :r)

tc_ax1.title = "Firing time course around lift\nfor pairs of neighboring cells"
tc_ax2.ylabel = "Instantaneous firing rate"
tc_ax3.xlabel = "Time (ms)"

label_a = fig[1, 1, TopRight()] = Label(fig, "A", textsize = 25, halign = :right)
label_b = fig[1, 2, TopRight()] = Label(fig, "B", textsize = 25, halign = :right)

# save(plotsdir("report/figure_2.png"), fig)

# Figure 3

cell1 = (
         index = 437,
         landmark = :cover,
         around = [-400., 400.],
         binsize = 0.5,
		 )

cell2 = (
         index = 438,
         landmark = :cover,
         around = [-400., 400.],
         binsize = 0.5,
		 )


rasters = [Raster(cell...) for cell in [cell1, cell2]]
timecourses = [TimeCourse(cell..., σ) for cell in [cell1, cell2]]

raster1_res = compute(rasters[1], data)
raster2_res = compute(rasters[2], data)

timecourse1_res = compute(timecourses[1], data)
timecourse2_res = compute(timecourses[2], data)


fig = with_theme(plot_theme) do
	Figure(resolution = (1800, 1024))
end
raster1_ax = fig[1, 1][1, 1] = visualise!(rasters[1], fig, raster1_res, nothing)
raster2_ax = fig[2, 1][1, 1] = visualise!(rasters[2], fig, raster2_res, nothing)
timecourse1_ax = fig[1, 1][2, 1] = visualise!(timecourses[1], fig, timecourse1_res, nothing)
timecourse2_ax = fig[2, 1][2, 1] = visualise!(timecourses[2], fig, timecourse2_res, nothing)
hidespines!.([raster1_ax, raster2_ax], :r, :t, :b)
hidespines!.([timecourse1_ax, timecourse2_ax], :r, :t)


