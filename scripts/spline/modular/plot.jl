using DrWatson
@quickactivate :ens

using DataFramesMeta
using Plots
using Arrow
using Printf
using TOML
using Measures

respath = "data/analyses/spline/batch-8/best-dist"
respath = ARGS[1]
data = load_data(:last)
fits = Arrow.Table(respath * "/results/fit.arrow") |> DataFrame
sims = Arrow.Table(respath * "/results/simulated.arrow") |> DataFrame
params = TOML.parsefile(respath * "/../params.toml")
tmax = params["mkdf"]["tmax"]
n = params["mkdf"]["n_sims"]

fig_pars = (
		   grid = false,
		   legend = false,
		   lw = 2.0,
		   )

function plot_trials(t, l)
	x = cut(t, l, tmax)
	x = bin.(x, 0, diff(tmax)[1])
	x = hcat(x...)'
	xticks = collect(tmax[1]:tmax[2]-1)
	yticks = collect(eachindex(l))
	heatmap(xticks, yticks, x, c=[:white, :black], cbar=false, yticks=yticks, framestyle=:grid)
end


function summary(fits, sims, data, respath, tmax, n, fig_params, i1, i2)
	nearest = @where(fits, :index1 .== i1, :index2 .== i2, :variable .== "r.nearest")
	isi = @where(fits, :index1 .== i1, :index2 .== i2, :variable .== "r.timeSinceLastSpike")
	t = @where(fits, :index1 .== i1, :index2 .== i2, :variable .== "time")
	s = @where(sims, :index1 .== i1, :index2 .== i2)
	c1 = @where(data, :index .== i1)
	c2 = @where(data, :index .== i2)

	landmark = [:lift, :cover, :grasp][get_active_events(c1)][1]
	st1 = cut(c1[1, :t], c1[1, landmark], tmax)
	st1 = [st .+ tmax[1] for st in st1]
	st2 = cut(c2[1, :t], c2[1, landmark], tmax)
	st2 = [st .+ tmax[1] for st in st2]
	cc_real = crosscor.(st1, st2, -20, 20, 0.5) |> sum |> plot # TODO: parameters in toml

	fake = @where(sims, :index1 .== i1, :index2 .== i2).fake
	cc_fake = zeros(81);
	if !isempty(fake)
		for f in fake[1]
			cc_fake += sum(crosscor.(st1, f, -20, 20, 0.5))
		end
	end

	p_nearest = plot(nearest.x, nearest.mean; fig_params...)
	title!("Nearest fit")
	ylabel!("eta")
	xlabel!("Time (ms)")

	p_isi = plot(isi.x, isi.mean; fig_params...)
	title!("Isi fit")
	ylabel!("eta")
	xlabel!("Time (ms)")

	p_t = plot(t.x, t.mean; fig_params...)
	title!("Time fit")
	ylabel!("eta")
	xlabel!("Time (ms)")

	p_real = plot(cc_real; fig_params...)
	title!("Cross-correlogram between real cells")
	ylabel!("Count")
	xlabel!("Time (ms)")
	xticks!([0, 20, 40, 60, 80], string.([-20, -10, 0, 10, 20]))

	p_fake = plot(cc_fake ./ n; fig_params...)
	title!("Complex model ($(isempty(fake) ? 0 : length(fake[1])) sims)")
	ylabel!("Mean count")
	xlabel!("Time (ms)")
	xticks!([0, 20, 40, 60, 80], string.([-20, -10, 0, 10, 20]))

	p_psth_1 = plot_trials(c1[1, :t], c1[1, landmark])
	title!("Cell $i1")
	xlabel!("Trial #")
	ylabel!("Time to " * string(landmark) * " (ms)")

	p_psth_2 = plot_trials(c2[1, :t], c2[1, landmark])
	title!("Cell $i2")
	xlabel!("Trial #")
	ylabel!("Time to " * string(landmark) * " (ms)")

	layout = @layout [ psth1{0.25w} real fake ; psth2{0.25w} t isi nearest ]
	final = plot(p_psth_1, p_real, p_fake, p_psth_2, p_t, p_isi, p_nearest, size=(1800, 1000), layout=layout,  margin=10mm)

	fn = @sprintf "%s/plots/%d-%d" respath i1 i2
	savefig(final, fn)
end

for (i1, i2) in zip(fits.index1, fits.index2)
	summary(fits, sims, data, respath, tmax, n, fig_pars, i1, i2)
end
