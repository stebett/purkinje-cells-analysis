using DrWatson
@quickactivate :ens

include(srcidr("plots", "psth.jl"))


low, high = -0.7, 1.6
n = section(data.t, data.lift, [-5000, 5000], over=[-5000, -2000], :norm, :avg)
n = sort_active(n, 250)

plot_psth(n, low, high, "Normalized firing rate")
xticks!([0, 5000, 9950], ["$x0", "0", "$x1"])
yticks!([1, 492], ["1", "$h"])
xaxis!("Time (ms)")
yaxis!("Neuron #")
savefig(plotsdir("psth", "psth"), "scripts/psth/psth.jl")
