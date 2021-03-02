using DrWatson
@quickactivate :ens

#%
using Statistics
using Plots; gr()


#%
data = load_data("data-v5.arrow");
i1 = 437
i2 = 438
tmp = data[(data.index .== i1) .| (data.index .== i2), :]

pad = 250
n = 5
b1 = 50
binsize=.5
thr = 1.5
around = [-600., 600.]


mpsth, ranges = section_trial(tmp, pad, n, b1);
active_trials = get_active_trials(mpsth, ranges, thr);
active_ranges = merge_trials(tmp, active_trials);

active = Dict()
active[[i1, i2]] = vcat(active_ranges[i1]..., active_ranges[i2]...)

#% Merge neighbors active ranges
modulated = crosscor_c(data, [[i1, i2]], active, 0.5, true) # TODO make sure normalizing is ok

c₁ = cut(data[data.index .== i₁, :t], data[data.index .== i₁, :cover], around)
c₂ = cut(data[data.index .== i₂, :t], data[data.index .== i₂, :cover], around)

unmodulated = crosscor.(c₁, c₂, true,  binsize=0.5) |> mean

unmodulated ./= mean(unmodulated)
unmodulated .*= mean(modulated)

m = minimum(modulated)
modulated[41] = NaN
unmodulated[41] = NaN

plot(modulated, lw=2, c=:orange, labels="during modulation", fill = m,  fillalpha = 0.2, fillcolor=:grey)
plot!(unmodulated, c=:black, lw=2, labels="during whole task", α=0.6)
xticks!([1:10:81;],["$i" for i =-20:5:20])
xlabel!("Time (ms)")
ylabel!("Count")
#%
savefig(plotsdir("crosscor", "figure_3B"), "scripts/figure-3/b.jl")
