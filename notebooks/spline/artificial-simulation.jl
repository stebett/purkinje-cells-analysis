### A Pluto.jl notebook ###
# v0.14.0

using Markdown
using InteractiveUtils

# ╔═╡ 20b9e528-a283-11eb-26a8-4573b5aefa33
using DrWatson

# ╔═╡ 31df6724-a283-11eb-27a5-479f54ffc94c
@quickactivate :ens
using DataFramesMeta
using DataFrames
using Plots
using Arrow
using StatsBase

# ╔═╡ 70b91670-a283-11eb-335e-0199a6580fa4
analysis = "spline"
batch = "artificial"
reference = "best"
file = "simulated.arrow";

# ╔═╡ 8165b3f2-a283-11eb-38a4-2bbafc0b186e
data = load_data("artificial-v2.arrow")
sim_neigh = load_data(analysis, batch, reference, "neigh", file)
sim_all = load_data(analysis, batch, reference, "all", file)
idx = [1, 2];

# ╔═╡ 9d06a4a4-a283-11eb-3b19-536998ad8a82
cells = find(data, idx)
landmark = sim_neigh[1, :landmark]

# ╔═╡ 7d46de68-a283-11eb-29cb-39236ec18f0e
c1 = cut(cells[1, :t], cells[1, landmark], [-500., 500.])
c2 = cut(cells[2, :t], cells[2, landmark], [-500., 500.])
cc = crosscor.(c1, c2, -20, 20, 0.5) |> x->zscore.(x) |> sum
plot(cc, legend=false, title="Cross-correlogram between real cells", ylabel="Counts", xlabel="Time (ms)")
xticks!([0, 20, 40, 60, 80], string.([-20, -10, 0, 10, 20]))

# ╔═╡ b72554f4-a283-11eb-38cd-bb04ca251638
# Complex model
c1_c = @where(sim_neigh, :index1 .== idx[1], :index2 .== idx[2]) |> x->[j .+ 500 for k in x.fake for j in k]
cc_c = crosscor.(c1_c, c1, -20, 20, 0.5) |> sum
plot(cc_c, legend=false, title="Complex model", ylabel="Counts", xlabel="Time (ms)")
xticks!([0, 20, 40, 60, 80], string.([-20, -10, 0, 10, 20]))

# ╔═╡ 9edc2852-a289-11eb-38eb-ef449d6b1be2


# ╔═╡ Cell order:
# ╠═20b9e528-a283-11eb-26a8-4573b5aefa33
# ╠═31df6724-a283-11eb-27a5-479f54ffc94c
# ╠═70b91670-a283-11eb-335e-0199a6580fa4
# ╠═8165b3f2-a283-11eb-38a4-2bbafc0b186e
# ╠═9d06a4a4-a283-11eb-3b19-536998ad8a82
# ╠═7d46de68-a283-11eb-29cb-39236ec18f0e
# ╠═b72554f4-a283-11eb-38cd-bb04ca251638
# ╠═9edc2852-a289-11eb-38eb-ef449d6b1be2
