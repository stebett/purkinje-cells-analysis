using DrWatson
@quickactivate :ens

using Plots; pyplot(900, 1080)
using StatsBase
using Arrow
using DataFramesMeta
using Measures

function figure_A(b, r, title; kwargs...)
	b = sort_active(hcat(convolve(b, 1.)...), 10)

	col = cgrad([:white, :black])
	p1 = heatmap(b'; c=col, cbar=false, title=title, kwargs...)
	p1 = xticks!([0, 800, 1595], ["-400", "0", "400"])
	p1 = ylabel!("Trials")

	p2 = plot(r; legend=false, c=:black, kwargs...)
	p2 = ylabel!("Firing rate")
	p2 = xlabel!("Time (ms)")
	p2 = xticks!([0, 800, 1595], ["-400", "0", "400"])

	p1, p2
end
#%

data = load_data("data-v6.arrow");

i₁, i₂ = 437, 438
around = [-400., 400.]
binsize = 0.5
σ = 10.

c₁ = cut(data[data.index .== i₁, :t], data[data.index .== i₁, :cover], around)
b₁ = bin.(c₁, 0, Int(diff(around)...), binsize=binsize) 
r₁ = convolve(b₁, σ) |> mean

c₂ = cut(data[data.index .== i₂, :t], data[data.index .== i₂, :cover], around)
b₂ = bin.(c₂, 0, Int(diff(around)...), binsize=binsize) 
r₂ = convolve(b₂, σ) |> mean

fig_a1, fig_a2 = figure_A(b₁, r₁, "Spiketrain 437")
fig_a3, fig_a4 = figure_A(b₂, r₂, "Spiketrain 438")
f_3a = plot(fig_a1, fig_a3, fig_a2, fig_a4, layout = @layout [ a b ; c d ])
savefig(f_3a, plotsdir("presentation", "3a.png"))

#'

function get_active_spikes(df, active_bins, ranges)
	map(1:size(df, 1)) do i
		abscut.(Ref(df[i, :t]), [r[active_bins] for r in ranges[i]])
	end
end

function get_all_spikes(df,ranges)
	map(1:size(df, 1)) do i
		abscut.(Ref(df[i, :t]), ranges[i])
	end
end
		
function figure_B(modulated, unmodulated; kwargs...)
	m = minimum(drop(modulated[:]))
	modulated[40:41] .= NaN
	unmodulated[40:41] .= NaN
	plot(modulated; c=:orange, labels="during modulation", fill=m,  fillalpha = 0.2, fillcolor=:grey, kwargs...)
	plot!(unmodulated; c=:black, labels="during whole task", α=0.6, kwargs...)
	xticks!([1:10:81;],["$i" for i =-20:5:20])
	xlabel!("Time (ms)")
	ylabel!("Normalized count")
end
#%

cells = find(data, [i₁, i₂])

pad = 600
num_bins = 2
b1 = 100
thr = 4

mpsth, ranges = multi_psth(cells, pad, num_bins, b1);
baseline = getindex.(mpsth, Ref(1:ceil(Int, length(mpsth[1])÷3)))
m = normalize(mpsth, baseline, :mad)
active_bins = (abs.(m[1]) .> thr) .| (abs.(m[2]) .> thr)

spikes = get_all_spikes(cells, ranges)
spikes_act = get_active_spikes(cells, active_bins, ranges)
			  
unmodulated = crosscor.(spikes[1], spikes[2], -20, 20, 0.5) |> sum
modulated = crosscor.(spikes_act[1], spikes_act[2], -20, 20, 0.5)|> sum

unmod = unmodulated .- mean(unmodulated) .+ mean(modulated)
mod = copy(modulated)
figure_B(mod, unmod)

## Splines

pad = 600
num_bins = 15
b1 = 10
m, _ = multi_psth(cells[1, :], pad, num_bins, b1);
l = size(m, 1)
gr(size=(960, 540))
plot(m, lw=2, c=:green, label="cell 437")
xticks!([1, l÷4, l÷2-num_bins, l÷2, l÷2+num_bins, l÷4*3, l-3], ["$(-round(pad/1000, digits=1))s before lift", "approach", "lift", "cover",  "grasp", "retrieve", "$(round(pad/1000, digits=1))s after grasp"]) 
xaxis!("Time course")
yaxis!("Mean firing rate")
vline!([l÷2-num_bins, l÷2, l÷2+num_bins], line = (0.2, :dash, 0.6, :black), label="")
title!("Multi-psth")
savefig(plotsdir("presentation", "mpsth-437.png"))

include(srcdir("spline", "mkdf.jl"))
df = mkdf(cells, landmark=:cover)
gr(size=(960, 540))
density([@where(df, :event .== 0).time, @where(df, :event .== 1).time], labels=["No spike" "Spike"], lw=2, c=[:black :orange])
ylabel!("Density")
xlabel!("Time from cover")
title!("Distribution of spikes over time")
savefig(plotsdir("presentation", "density-437.png"))


batch = 8
inpath = datadir("analyses/spline/batch-$batch/best-all/results/fit.arrow")
s = Arrow.Table(inpath) |> DataFrame
spline_time = @where(s, :variable .== "time", :index1 .== 437)

gr(size=(1920, 540), margins=10mm)
p = @. exp(spline_time.mean[1] - log(1 + exp(spline_time.mean[1])))
plot(spline_time.x, p, ribbon=spline_time.sd, fillalpha=0.3, legend=false, lw=2, ylims=[0, 1])
xlabel!("Time to cover")
ylabel!("Probability of spiking ± sd")
title!("Smooth spline fit on Time x Spike")
savefig(plotsdir("presentation", "time-spline-437.png"))

batch = 8
inpath = datadir("analyses/spline/batch-$batch/best-neigh/results/fit.arrow")
s = Arrow.Table(inpath) |> DataFrame
spline_nearest = @where(s, :variable .== "r.nearest", :index1 .== 438, :index2 .== 437)
y = @. exp(spline_nearest.mean[1] - log(1 + exp(spline_nearest.mean[1])))
x = spline_nearest.x[1]

gr(size=(960, 1080), margins=10mm)
plot(x, y, ribbon=spline_nearest.sd, fillalpha=0.3, legend=false, lw=2, ylims=[0, 1], xlims=[0, 20])
xlabel!("Time from nearest spike on neighbor neuron (ms)")
ylabel!("Probability ± std")
title!("Smooth spline fit on Nearest x Spike")
savefig(plotsdir("presentation", "nearest-spline-437.png"))

plot(x, y, ribbon=spline_nearest.sd, fillalpha=0.3, label="", lw=2, ylims=[0, 1], xlims=[0, 20])
xlabel!("Time from nearest spike on neighbor neuron (ms)")
ylabel!("Probability ± std")
title!("Smooth spline fit on Nearest x Spike")
m = argmax(y[x .< 20])
scatter!([x[m]], [y[m]], ms=20, c=:green, marker=:star5, alpha=.5, label="maximum")
sig = (y .- spline_nearest.sd[1]) .> 0.5
ysig = copy(y)
ysig[.!sig] .= NaN
xsig = [x[findall(sig .== 1)[1]], x[findall(sig .== 1)[end]]]
plot!(x, ysig, ribbon=spline_nearest.sd, fillalpha=0.3, label="", lw=2, ylims=[0, 1], xlims=[0, 20])
vline!(xsig, style=:dash, alpha=0.8, label="", c=:green)


savefig(plotsdir("presentation", "nearest-spline2-437.png"))

## 
include(srcdir("spline", "model_summaries.jl"))
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
d_better = best_model(df_d, ll_d);
df_n = n_better
df_d = d_better

params = Dict(:color => (:green, 0.5),
			  :strokecolor => :black,
			  :strokewidth => 1,
			  )
theme = Attributes(Axis = ( xgridvisible = false, ygridvisible = false))

fig = with_theme(theme) do
	Figure(resolution = (960, 1080), 
		   backgroundcolor = :white,
		   colormap = :greens)
end
a = fig[1, 1] = Makie.Axis(fig, title = "Pairs of neighbor cells \n \nBest model")
d = fig[2, 1] = Makie.Axis(fig, title = "Pairs of distant Cells \n \nBest model")
barplot!(a, [sum(ll_n.c_better), sum(.!ll_n.c_better)]; params...)
barplot!(d, [sum(ll_d.c_better), sum(.!ll_d.c_better)]; params...)
a.ylabel = d.ylabel = "Count"
a.xticks = d.xticks = ([1, 2], ["Complex", "Simple"])
save(plotsdir("presentation", "best-model.png"), fig)



params = Dict(:color => (:orange, 0.5),
			  :strokecolor => :black,
			  :strokewidth => 1,
			  )
fig = with_theme(theme) do
	Figure(resolution = (960, 1080), 
		   backgroundcolor = :white,
		   colormap = :greens)
end
b = fig[1, 1] = Makie.Axis(fig, title = "Pairs of neighbor cells \n \nPeak cell interaction delay")
e = fig[2, 1] = Makie.Axis(fig, title = "Pairs of distant Cells \n \nPeak cell interaction delay")
b.xlabel = e.xlabel = "Time (ms)"
b.ylabel = e.ylabel = "Density"
density!(b, df_n.peak; params...)
density!(e, df_d.peak; params...)
linkaxes!(b, e)
xlims!(b, -30, 120)
save(plotsdir("presentation", "density.png"), fig)

params = Dict(:color => (:purple, 0.3),
			  :strokecolor => :black,
			  :linewidth => 2,
			  )
fig = with_theme(theme) do
	Figure(resolution = (960, 1080), 
		   backgroundcolor = :white,
		   colormap = :greens)
end
c = fig[1, 1] = Makie.Axis(fig, title = "Pairs of neighbor cells \n \nRanges of significant\n cell interaction delays")
f = fig[2, 1] = Makie.Axis(fig, title = "Pairs of distant Cells \n \nRanges of significant\n cell interaction delays")
c.xlabel = f.xlabel = "Time (ms)"
c.ylabel = f.ylabel = "% of pairs with\nsignificant interaction"
r = ranges_counts(df_n, tmax=120)
lines!(c, r; params...)
band!(c, r[1], r[2], zeros(length(r[1])); params...)
r = ranges_counts(df_d, tmax=120)
lines!(f, r; params...)
band!(f, r[1], r[2], zeros(length(r[1])); params...)
linkaxes!(c, f)
vlines!.([b, e, c, f], 10, linestyle = :dash)
save(plotsdir("presentation", "ranges.png"), fig)
