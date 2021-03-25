using DrWatson
@quickactivate :ens

#%
using Revise
using Spikes
using Statistics
using Plots; gr()
using ColorSchemes
#%

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

data = load_data("data-v5.arrow");

i₁, i₂ = 437, 438
around = [-400., 400.]
binsize = 0.5
σ = 10.

c₁ = cut(data[data.index .== i₁, :t], data[data.index .== i₁, :cover], around)
b₁ = bin(c₁, Int(diff(around)...), binsize) 
r₁ = convolve(b₁, σ) |> mean

c₂ = cut(data[data.index .== i₂, :t], data[data.index .== i₂, :cover], around)
b₂ = bin(c₂, Int(diff(around)...), binsize) 
r₂ = convolve(b₂, σ) |> mean

fig_a1, fig_a2 = figure_A(b₁, r₁, "Spiketrain 437")
fig_a3, fig_a4 = figure_A(b₂, r₂, "Spiketrain 438")

f_3a = plot(fig_a1, fig_a3, fig_a2, fig_a4, layout = @layout [ a b ; c d ])

#%
savefig(plotsdir("crosscor", "Figure_3A"), "scripts/figure-3/a.jl")

# cc = crosscor.(c₁, c₂, true, binsize=0.5)
# cc = sort_active(hcat(cc...), 10)
# heatmap(cc')
