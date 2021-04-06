using DrWatson
@quickactivate :ens

using JLD2 
using Spikes
using Arrow
using CSV
using DataFramesMeta
using Makie
# using StatsPlots; pyplot(size=(800,800))

includet(srcdir("spline", "model_summaries.jl"))
# includet(srcdir("spline", "plots.jl"))


#' # Load results
batch=7
inpath = "/home/ginko/ens/data/analyses/spline/batch-$batch/results/result.arrow"
inpath_ll = "/home/ginko/ens/data/analyses/spline/ll-batch-$batch/results/result.arrow"
result = Arrow.Table(inpath) |> DataFrame
result_ll = Arrow.Table(inpath_ll) |> DataFrame;

ll_n = @where(result_ll, :reference .== "best", :group .== "neigh")
ll_d = @where(result_ll, :reference .== "best", :group .== "dist")

df_n = get_peaks(result, "best", "neigh")
df_d = get_peaks(result, "best", "dist")

n_better = best_model(df_n, ll_n)
d_better = best_model(df_d, ll_d)

#' # Neighbors 
#+ fig_ext = ".svg"
@df n_better plot(:x, :mean,  xlims=(0, 40), ylims=(-1, 1), labels=reshape([:index1 :index2], (:, 2))')
scatter!(n_better.peak, [-0.5], lab="")
hline!([0], lw=1.5, c=:black, s=:dash, lab="")

#' # Distant neurons
#+ fig_ext = ".svg"
@df d_better plot(:x, :mean, xlims=(0, 40), ylims=(-1, 1), labels=reshape([:index1 :index2], (:, 2))')
scatter!(d_better.peak, [-0.5], lab="")
hline!([0], lw=1.5, c=:black, s=:dash, lab="")

#' # Full picture
#+ fig_ext = ".svg"
params = Dict(:color => (:black, 0.25),
			  :strokecolor => :black,
			  :strokewidth => 1,
			  )

theme = Attributes(Axis = ( xgridvisible = false, ygridvisible = false))
fig = with_theme(theme) do
	Figure(resolution = (1800, 1024), 
		   backgroundcolor = RGBf0(0.98, 0.98, 0.98),
		   colormap = :Spectral)
end

a = fig[1, 1] = Makie.Axis(fig, font=bold, title = "Pairs of neighbor cells \n \nBest model")
b = fig[2, 1] = Makie.Axis(fig, font=bold, title = "Peak cell interaction delay")
c = fig[3, 1] = Makie.Axis(fig, font=bold, title = "Ranges of significant\n cell interaction delays")
d = fig[1, 2] = Makie.Axis(fig, font=bold, title = "Pairs of distant Cells \n \nBest model")
e = fig[2, 2] = Makie.Axis(fig, font=bold, title = "Peak cell interaction delay")
f = fig[3, 2] = Makie.Axis(fig, font=bold, title = "Ranges of significant\n cell interaction delays")

label_a = fig[1, 1, TopLeft()] = Label(fig, "A", textsize = 25, halign = :right)
label_b = fig[2, 1, TopLeft()] = Label(fig, "B", textsize = 25, halign = :right)
label_c = fig[3, 1, TopLeft()] = Label(fig, "C", textsize = 25, halign = :right)
label_d = fig[1, 2, TopLeft()] = Label(fig, "D", textsize = 25, halign = :right)
label_e = fig[2, 2, TopLeft()] = Label(fig, "E", textsize = 25, halign = :right)
label_f = fig[3, 2, TopLeft()] = Label(fig, "F", textsize = 25, halign = :right)

a.xticks = d.xticks = ([1, 2], ["Complex", "Simple"])
b.xlabel = e.xlabel = "Time (ms)"
c.xlabel = f.xlabel = "Time (ms)"
a.ylabel = d.ylabel = "Count"
b.ylabel = e.ylabel = "Density"
c.ylabel = f.ylabel = "% of pairs with\nsignificant interaction"


barplot!(a, [sum(ll_n.c_better), sum(.!ll_n.c_better)]; params...)
barplot!(d, [sum(ll_d.c_better), sum(.!ll_d.c_better)]; params...)

density!(b, df_n.peak; params...)
density!(e, df_d.peak; params...)
linkaxes!(b, e)

lines!(c, ranges_counts(df_n, tmax=120))
lines!(f, ranges_counts(df_d, tmax=120))
linkaxes!(c, f)

vlines!.([b, e, c, f], 10, linestyle = :dash)
xlims!(b, -30, 120)

savefig(plotsdir("logbook", "06-04", "figure-5"), "scripts/spline/figure-5.jl")

