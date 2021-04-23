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
batch = "8"
reference = "best"
file = "simulated_438-437.arrow";

# ╔═╡ 8165b3f2-a283-11eb-38a4-2bbafc0b186e
data = load_data("data-v6.arrow")
sim_neigh = load_data(analysis, batch, reference, "neigh", file)
idx = [437, 438];

# ╔═╡ 9d06a4a4-a283-11eb-3b19-536998ad8a82
cells = find(data, idx)
landmark = [:lift, :cover, :grasp][get_active_events(cells)[1]]

# ╔═╡ 7d46de68-a283-11eb-29cb-39236ec18f0e
c1 = cut(cells[1, :t], cells[1, landmark], [-500., 500.])
c1 = [x .- 500 for x in c1]
c2 = cut(cells[2, :t], cells[2, landmark], [-500., 500.])
c2 = [x .- 500 for x in c2]
cc = crosscor.(c1, c2, -20, 20, 0.5) |> sum
p1 = plot(cc, legend=false, title="Cross-correlogram between real cells - Original cells", ylabel="Counts", xlabel="Time (ms)")
xticks!([0, 20, 40, 60, 80], string.([-20, -10, 0, 10, 20]))

# ╔═╡ 70db6dc6-a2b3-11eb-0d63-91e7c2c2390b
fake = @where(sim_neigh, :index2 .== idx[1], :index1 .== idx[2]).fake[1];

# ╔═╡ b72554f4-a283-11eb-38cd-bb04ca251638
cc_c = [];
for sim in fake[1:5]
	push!(cc_c, sum(crosscor.(c2, sim, -20, 20, 0.5)))
end

p2 = plot(sum(cc_c), legend=false, title="Complex model - Original cells ($(length(cc_c)) sims)", ylabel="Counts", xlabel="Time (ms)")
xticks!([0, 20, 40, 60, 80], string.([-20, -10, 0, 10, 20]))


# ╔═╡ 8d803f84-a2b0-11eb-0910-b7a7ab94c76d
savefig(p1, plotsdir("logbook", "21-04", "original-cells-real.png"))
savefig(p2, plotsdir("logbook", "21-04", "original-cells-complex-20sims-cell2.png"))

# ╔═╡ Cell order:
# ╠═20b9e528-a283-11eb-26a8-4573b5aefa33
# ╠═31df6724-a283-11eb-27a5-479f54ffc94c
# ╠═70b91670-a283-11eb-335e-0199a6580fa4
# ╠═8165b3f2-a283-11eb-38a4-2bbafc0b186e
# ╠═9d06a4a4-a283-11eb-3b19-536998ad8a82
# ╠═7d46de68-a283-11eb-29cb-39236ec18f0e
# ╠═70db6dc6-a2b3-11eb-0d63-91e7c2c2390b
# ╠═b72554f4-a283-11eb-38cd-bb04ca251638
# ╠═8d803f84-a2b0-11eb-0910-b7a7ab94c76d
