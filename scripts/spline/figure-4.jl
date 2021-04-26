using DrWatson
@quickactivate :ens

using DataFramesMeta
using DataFrames
using Plots
using Arrow
using StatsBase

analysis = "spline"
batch = 8
reference = "best"
file = "simulated.arrow"

data = load_data(:last)
sim_all = load_data(analysis, batch, reference, "all", file)
sim_neigh = load_data(analysis, batch, reference, "neigh", file)

idx = @where(data, :rat .== "R17", :site .== "39", :tetrode .== "tet2").index
idx = [106, 107]

cells = find(data, idx)
landmark = [:lift, :cover, :grasp][get_active_events(cells)[1]]

c1 = cut(cells[1, :t], cells[1, landmark], [-500., 500.])
c2 = cut(cells[2, :t], cells[2, landmark], [-500., 500.])
cc = crosscor.(c1, c2, -20, 20, 0.5) |> x->zscore.(x) |> sum |> plot

# Simple model
c1_s = @where(sim_all, :index1 .== idx[1]) |> x->[j .+ 500 for k in x.fake for j in k]
cc_s = crosscor.(c1_s, c1, -20, 20, 0.5) |> sum
plot(cc_s)

# Complex model
c1_c = @where(sim_neigh, :index1 .== idx[1], :index2 .== idx[2]) |> x->[j .+ 500 for k in x.fake for j in k]
cc_c = crosscor.(c1_c, c1, -20, 20, 0.5) |> sum
plot(cc_c)

# fake psth
function pipe(x)
	r = bin.(x, -500, 500) 
	r = convolve.(r)
	r = zscore.(r)
end

spikes = [(mean ∘ drop ∘ pipe)(x) for x in sim_neigh.fake]
s = hcat(spikes...)
f = heatmap(s', clims=(-1.5, 1.5), title="fake")



index = sim_neigh[:, :index1]
new_index =  [findall(i .== data.index)[1] for i in index]
x = data[new_index, :]
h = cut(x[:, :t], x[:, landmark], [-500., 500.])
h = @. bin(h, 0, 1000) |> convolve |> zscore 
h = average(h, x)
h = hcat(h...) |> transpose
h = heatmap(h, clims=(-1.5, 1.5), title="real")

plot(h, f)
