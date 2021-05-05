### A Pluto.jl notebook ###
# v0.14.0

using Markdown
using InteractiveUtils

# ╔═╡ 7f66e30e-ada6-11eb-1d49-478b2d6b3bcf
using DrWatson

# ╔═╡ 9b5ad232-ada6-11eb-27f1-2d78d6c739ef
@quickactivate :ens
using InformationMeasures
using DataFrames
using Plots
using StatsBase

# ╔═╡ 9fbd1632-ada6-11eb-222a-5721383af37b
data = load_data(:last)
neighs = couple(data, :n) # take also reverse (maybe modify function to add argument)
dist = couple(data, :d)
allcells = data.index

# ╔═╡ ac4a6a20-ada7-11eb-2a91-3997bd35f247
function get_bins(data, group, around, landmark)
	r = []
	for c in group
		cells = find(data, c)
		s1 = cut(cells[1, :t], cells[1, landmark], around)
		b1 = bin.(s1, 0, diff(around)[1])

		if size(cells, 1) == 2
			s2 = cut(cells[2, :t], cells[2, landmark], around)
			b2 = bin.(s2, 0, diff(around)[1])
			
			push!(r, (b1, b2))
		end

		push!(r, b1)
	end
end

function get_bins(data, group, around)
	vcat(get_bins.(Ref(data), Ref(group), Ref(around), [:lift, :cover, :grasp]))

end

function apply_all(data, group, fun, around, landmark)


		push!(r, mean(fun.(b1, b2)))
	mean(r)
end

function apply_all(data, group, fun, around::Vector{<:Real})
	apply_all.(Ref(group), fun, Ref(around), [:lift, :cover, :grasp]) |> mean
end

function apply_all(data, group, fun, around::Vector{<:Vector})
	apply_all.(Ref(group), fun, around)
end

# ╔═╡ 25f46b08-adb9-11eb-202c-8d16fb057f9e
# N = get_bins(data, neighs, around, :lift)
size(cells, 1)

# ╔═╡ 8562f104-adb9-11eb-227b-c543b0a5ae03


# ╔═╡ 614e73ec-adaf-11eb-3c6d-218553d60493
function apply_sliding(data, group, 

function apply_sliding(cell::DataFrameRow, fun, around; step)
	high = diff(around)[1] |> Int
	s = abscut(cell.t, cell.cover, around)
	b = bin.(s, around...)
	sliding_entropy = map(step+1:high) do x
		fun.(view.(b, Ref(x-step:x))) |> mean
	end
end

function apply_sliding(data::DataFrame, fun, around; step) 
	apply_sliding.(eachrow(data), fun, Ref(around); step=step)
end

# ╔═╡ 43ebec92-adb1-11eb-0af3-fd7f550a1d35
interval = [-1000., 1000.]
step = 200
x = interval[1]+step+1:interval[2]
y = apply_sliding(data, get_entropy, interval; step=step)

# ╔═╡ 08c12c3c-adb0-11eb-08a6-f9a55c2cea07
plot(x, mean(y), legend=false)
title!("Entropy around cover")
ylabel!("Entropy")
xlabel!("Time to cover (ms)")

# ╔═╡ 411bfc9e-adb8-11eb-30eb-376687131d7f
interval = [-1000., 1000.]
step = 200
x = interval[1]+step+1:interval[2]
y = apply_sliding(data, get_conditional_entropy, interval; step=step)

# ╔═╡ ce617c8a-adab-11eb-1e53-1d2067aa9fc9
offsets = 50:50:1000.
around = [[-x, x] for x in offsets]

# ╔═╡ a64b2a1a-adac-11eb-0312-bf6a9238f089
mi_n = apply_all(data, neighs, get_mutual_information, around)
mi_d = apply_all(data, dist, get_mutual_information, around)

# ╔═╡ 81ff6b9e-adac-11eb-233c-23c2e093542b
plot(offsets, mi_n, label="Neighbors")
plot!(offsets, mi_d, label="Distant")
title!("Mutual information by interval considered")
xlabel!("Offset")
ylabel!("Mutual info")

# ╔═╡ ac03509a-ada7-11eb-2427-596ff7d88ca7
ce_n = apply_all(data, neighs, get_cross_entropy, around)
ce_d = apply_all(data, dist, get_cross_entropy, around)

# ╔═╡ 061cf0c2-adad-11eb-3916-a345f23d94bf
plot(offsets, ce_n, label="Neighbors")
plot!(offsets, ce_d, label="Distant")
title!("Cross entropy by interval considered")
xlabel!("Offset")
ylabel!("Cross entropy")

# ╔═╡ 43bf2b00-adb4-11eb-0f93-29407f795f15
coe_n = apply_all(data, neighs, get_conditional_entropy, around)
coe_d = apply_all(data, dist, get_conditional_entropy, around)

# ╔═╡ 4fb24b9a-adb4-11eb-1d2f-17ebb2914665
plot(offsets, coe_n, label="Neighbors")
plot!(offsets, coe_d, label="Distant")
title!("Conditional entropy by interval considered")
xlabel!("Offset")
ylabel!("Conditional entorpy")

# ╔═╡ Cell order:
# ╠═7f66e30e-ada6-11eb-1d49-478b2d6b3bcf
# ╠═9b5ad232-ada6-11eb-27f1-2d78d6c739ef
# ╠═9fbd1632-ada6-11eb-222a-5721383af37b
# ╠═ac4a6a20-ada7-11eb-2a91-3997bd35f247
# ╠═25f46b08-adb9-11eb-202c-8d16fb057f9e
# ╠═8562f104-adb9-11eb-227b-c543b0a5ae03
# ╠═614e73ec-adaf-11eb-3c6d-218553d60493
# ╠═43ebec92-adb1-11eb-0af3-fd7f550a1d35
# ╠═08c12c3c-adb0-11eb-08a6-f9a55c2cea07
# ╠═411bfc9e-adb8-11eb-30eb-376687131d7f
# ╠═ce617c8a-adab-11eb-1e53-1d2067aa9fc9
# ╠═a64b2a1a-adac-11eb-0312-bf6a9238f089
# ╠═81ff6b9e-adac-11eb-233c-23c2e093542b
# ╠═ac03509a-ada7-11eb-2427-596ff7d88ca7
# ╠═061cf0c2-adad-11eb-3916-a345f23d94bf
# ╠═43bf2b00-adb4-11eb-0f93-29407f795f15
# ╠═4fb24b9a-adb4-11eb-1d2f-17ebb2914665
