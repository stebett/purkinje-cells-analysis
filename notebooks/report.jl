### A Pluto.jl notebook ###
# v0.14.0

using Markdown
using InteractiveUtils

# ╔═╡ f62f574e-bbcf-11eb-21fe-f12344791565
using DrWatson

# ╔═╡ 0fb58f78-bbd0-11eb-1fe2-73b388d7e4bf
@quickactivate :ens
using GLMakie

include(srcdir("analyses/psth.jl"))
include(srcdir("analyses/multi-psth.jl"))
include(srcdir("analyses/pos-neg-rate.jl"))
include(srcdir("analyses/correlations.jl"))
include(srcdir("analyses/cross-corr.jl"))
include(srcdir("analyses/surr-cross-corr.jl"))
include(srcdir("analyses/spline-fits.jl"))
include(srcdir("analyses/spline-peaks.jl"))


# ╔═╡ 14b8628c-bbd0-11eb-1cdc-7319e4c15602
data = load_data("data-v7.arrow")
plot_theme = Attributes(Axis = (xgridvisible = false, ygridvisible = false))
linewidth = 2.
σ = 10
colormap = :vik

# ╔═╡ 248f71b2-bbd1-11eb-1577-2b61098be0fb
# Figure 1

# ╔═╡ 18fbd600-bbd0-11eb-2167-630537f68382
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

psth_plot_params = (
					kwargs = (colorrange = (0, 2), colormap = colormap),
					sort_around = 800,
					)

pnrate_plot_params = (
					  kwargs = (linewidth = linewidth,),
					  colors = [:red, :blue, :black],
					  )

mpsth_plot_params = (
					 kwargs = (colorrange = (0, 2), colormap = colormap),
					 sort_binsize = 20,
					 )

psth_res = compute(psth, data)
mpsth_res = compute(mpsth, data)
pnrate_res = compute(pnrate, data)

# ╔═╡ fe8341ae-bbd0-11eb-01f9-7302ebbef359
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


# ╔═╡ 1c1c89be-bbd1-11eb-1971-7f9e36ff05d1
# Figure 2

# ╔═╡ 53f4dc84-bbd0-11eb-2d18-cd38c8e58aa5
timecoursegroup = TimeCourseGroup((
								   landmark = :cover,
								   group = :n,
								   around = [-150., 150.],
								   )...)

correlations = Correlation((
						   around = [-150., 150.],
						   )...)




correlations_plot_params = (
							kwargs = (linewidth = 2.,), 
							color=[:red, :blue]
							)

timecoursegroup_res = compute(timecoursegroup, data)
correlations_res = compute(correlations, data)

# ╔═╡ 0edf178a-bbd1-11eb-0ecf-419cb6e7a9bf
fig = with_theme(plot_theme) do
	Figure(resolution = (1800, 1024))
end

tc_ax1, tc_ax2, tc_ax3 = visualise!(timecoursegroup, fig, timecoursegroup_res, nothing)
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



# ╔═╡ 0ec4af28-bbd1-11eb-3896-bb13bf4b7787


# ╔═╡ 0ea2b038-bbd1-11eb-325e-b1094eb8514e


# ╔═╡ 0e28496c-bbd1-11eb-1f04-a9d6aa04c2ba


# ╔═╡ Cell order:
# ╠═f62f574e-bbcf-11eb-21fe-f12344791565
# ╠═0fb58f78-bbd0-11eb-1fe2-73b388d7e4bf
# ╠═14b8628c-bbd0-11eb-1cdc-7319e4c15602
# ╠═248f71b2-bbd1-11eb-1577-2b61098be0fb
# ╠═18fbd600-bbd0-11eb-2167-630537f68382
# ╠═fe8341ae-bbd0-11eb-01f9-7302ebbef359
# ╠═1c1c89be-bbd1-11eb-1971-7f9e36ff05d1
# ╠═53f4dc84-bbd0-11eb-2d18-cd38c8e58aa5
# ╠═0edf178a-bbd1-11eb-0ecf-419cb6e7a9bf
# ╠═0ec4af28-bbd1-11eb-3896-bb13bf4b7787
# ╠═0ea2b038-bbd1-11eb-325e-b1094eb8514e
# ╠═0e28496c-bbd1-11eb-1f04-a9d6aa04c2ba
