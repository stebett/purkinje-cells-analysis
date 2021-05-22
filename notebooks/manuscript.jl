### A Pluto.jl notebook ###
# v0.14.0

using Markdown
using InteractiveUtils

# ╔═╡ 5792f232-b62f-11eb-260e-d3cbaa41544c
using DrWatson

# ╔═╡ 6956d90c-b62f-11eb-0f5e-b9c07f2ead0e
@quickactivate :ens
using Plots
using Measurements


# ╔═╡ 1e46dcaa-b6ed-11eb-018d-d1a70a3c5803
using StatsBase

data = load_data("data-v6.arrow");

#%
pad = 5000
num_bins = 10
b1 = 50

n, ranges = multi_psth(data, pad, num_bins, b1);

baseline = getindex.(n, Ref(1:ceil(Int, length(n[1])÷3)))
n = normalize(n, baseline, :mad)
sort_agg_peaks!(n, 10)
m = hcat(n...) |> drop |> transpose 


# ╔═╡ 3bad46f2-b713-11eb-0e86-17dcf31baedc
using PyCall
scipy = pyimport("scipy.ndimage")


function correlations(data, l, g)
	group = couple(data, g);
	couples = find.(Ref(data), group)
	around = [-150., 150.]
	around_l = diff(around)[1]


	r = Float64[]
	for c in couples
		spikes1 = cut(c[1, :t], c[1, l], around)
		spikes1 = bin.(spikes1, around_l)
		spikes1 = scipy.gaussian_filter1d.(spikes1, 10)
		
		spikes2 = cut(c[2, :t], c[2, l], around)
		spikes2 = bin.(spikes2, around_l)
		spikes2 = scipy.gaussian_filter1d.(spikes2, 10)

		push!(r, cor.(spikes1, spikes2)...)
	end
	r = drop(r)
	λ = mean(r)
	σ = std(r)
	return  λ ± σ
end

# ╔═╡ c6af8d14-b630-11eb-1815-1568831ce41b
function ens.average(x::Vector, y::Vector{<:Vector{<:Real}})
	a = cumsum(length.(y))
	b = pushfirst!(a[1:end-1] .+ 1, 1)
	c = UnitRange.(b, a) 
	[(mean)(x[r]) for r in c]
end

# ╔═╡ 6ea509c4-b62f-11eb-24bf-015448d18cf3
data = load_data(:last);

# ╔═╡ 74d66c16-b62f-11eb-32d9-87089b94d089
function psth(landmark)
	around = [-200., 200.]
	over = [-2000., -1000.]
	around_l = diff(around)[1]
	over_l = diff(over)[1]

	spikes = cut(data.t, data[:, landmark], around)
	baseline = cut(data.t, data[:, :lift], over)

	binned = bin.(spikes, 0, around_l, binsize=50)
	binned_baseline = bin.(baseline, 0, over_l, binsize=50)
	
	averaged = average(binned, data[:, landmark])
	averaged_baseline = average(binned_baseline, data[:, landmark])
	
	

	normalized = normalize(averaged, averaged_baseline)
	# normalized = normalize(binned, binned_baseline)

	X = hcat(normalized...)
end

# ╔═╡ cc0d66f6-b62f-11eb-0f48-2b28cd4bf96e
l =  psth(:lift)
c =  psth(:cover)
g =  psth(:grasp)

ln = maximum(abs.(l), dims=1) .> 2.5
cn = maximum(abs.(c), dims=1) .> 2.5
gn = maximum(abs.(g), dims=1) .> 2.5;

# ╔═╡ 4e86624e-b631-11eb-186c-7784a399f4b6
sum(ln)

# ╔═╡ 64c3986e-b6f0-11eb-3b33-33701c7e6b03
sum(cn)

# ╔═╡ 6476e5e6-b6f0-11eb-0c12-13e154172b3f
sum(gn)

# ╔═╡ 3eaccfb6-b703-11eb-2351-a51702b6fbe9
sum(gn .| cn .| ln)

# ╔═╡ 52a032ce-b703-11eb-3f01-1f1454dd007d
sum(gn .| cn .| ln) / size(data, 1) * 100

# ╔═╡ 8698c914-b70e-11eb-1161-c37e4276c831
a = zeros(151)
for i in 1:151
	x = l[:, i]
	if any(2.5 .<= x) && any(x .<= -2.5)
		a[i] = 3
	elseif any(x .<= -2.5)
		a[i] = 2
	elseif any(x .>= 2.5)
		a[i] = 1
	end
end

# ╔═╡ 064a70ba-b70f-11eb-1f85-2171367ed4ce
sum(a .== 3)

# ╔═╡ 0ef6b91a-b70f-11eb-00aa-53e78802c841
sum(a .== 2)

# ╔═╡ 12dde4b8-b70f-11eb-08b5-cb7868b2a7cc
sum(a .== 1)

# ╔═╡ 16de79e2-b70f-11eb-1308-95ba415891ea
sum(a .== 0)

# ╔═╡ d5750042-b70f-11eb-0996-ed3f9f12285a
landmark = :lift
around = [-5000., 5000.]
over = [-5000., -3000.]
around_l = diff(around)[1]
over_l = diff(over)[1]

spikes = cut(data.t, data[:, landmark], around)
baseline = cut(data.t, data[:, :lift], over)

binned = bin.(spikes, 0, around_l, binsize=1)
binned_baseline = bin.(baseline, 0, over_l, binsize=1)

convolved = convolve(binned, 5)
convolved_baseline = convolve(binned_baseline, 10)

averaged = average(convolved, data[:, landmark])
averaged_baseline = average(convolved_baseline, data[:, landmark])

normalized = normalize(averaged, averaged_baseline);

# ╔═╡ 0fcf365e-b710-11eb-08fc-6d1885bed2d5
plot(mean(normalized[a .== 1]), c=:red)
plot!(mean(normalized[a .== 2]), c=:blue)
plot!(mean(drop(normalized)), c=:black)

# savefig("/home/ginko/ens/docs/manuscript/figures/1C.png")

# ╔═╡ 2f0da90a-b711-11eb-0f98-3d2860559718
x = ln .& cn .& gn
sum(x)

# ╔═╡ 53326988-b711-11eb-0934-47656191dd66
sum(((ln .& cn) .| (cn .& gn) .| (ln .& gn)) .& .!x )

# ╔═╡ c659a7e6-b711-11eb-152c-3988c78f8689
sum(ln .& cn .& .!x) 

# ╔═╡ caa626bc-b711-11eb-065e-9d76106c24ea
sum(cn .& gn .& .!x)

# ╔═╡ cece2f64-b711-11eb-0afa-b17bceac8a9b
sum(ln .& gn .& .!x)

# ╔═╡ 6752ca48-b711-11eb-1a05-1bf030c644d9
sum(ln .& .!cn .& .!gn)

# ╔═╡ 76b947fa-b711-11eb-0f13-f50e1e9f1b2c
sum(.!ln .& cn .& .!gn)

# ╔═╡ 7b7c40e4-b711-11eb-1eec-53f79d91f208
sum(.!ln .& .!cn .& gn)

# ╔═╡ 48a24766-b6ee-11eb-1287-835b2feeea57

l = size(m, 2)
low, high = -7, 7

heatmap(m, c=:viridis, clim=(low, high), colorbar_title="Normalized firing rate", yflip=true)
xticks!([1, l÷4, l÷2-num_bins÷2, l÷2+num_bins÷2, l÷4*3, l], ["$(-round(pad/1000, digits=1))s before lift", "approach", "reach", "grasp", "retrieve", "$(round(pad/1000, digits=1))s after grasp"]) 
xaxis!("Landmarks")
yaxis!("Neuron #")
vline!([l÷2-num_bins, l÷2, l÷2+num_bins], line = (0.2, :dash, 0.6, :white), legend=false)

# savefig("/home/ginko/ens/docs/manuscript/figures/multi-psth.png")

# ╔═╡ 5e5b4f62-b713-11eb-0e90-8183710ea14e
correlations(data, :lift, :n)

# ╔═╡ d01d7a92-b8a0-11eb-0fd4-d52a9fa00693
convolve([0, 1, 0, 0, 1]) |> plot

# ╔═╡ Cell order:
# ╠═5792f232-b62f-11eb-260e-d3cbaa41544c
# ╠═6956d90c-b62f-11eb-0f5e-b9c07f2ead0e
# ╠═c6af8d14-b630-11eb-1815-1568831ce41b
# ╠═6ea509c4-b62f-11eb-24bf-015448d18cf3
# ╠═74d66c16-b62f-11eb-32d9-87089b94d089
# ╠═cc0d66f6-b62f-11eb-0f48-2b28cd4bf96e
# ╠═4e86624e-b631-11eb-186c-7784a399f4b6
# ╠═64c3986e-b6f0-11eb-3b33-33701c7e6b03
# ╠═6476e5e6-b6f0-11eb-0c12-13e154172b3f
# ╠═3eaccfb6-b703-11eb-2351-a51702b6fbe9
# ╠═52a032ce-b703-11eb-3f01-1f1454dd007d
# ╠═8698c914-b70e-11eb-1161-c37e4276c831
# ╠═064a70ba-b70f-11eb-1f85-2171367ed4ce
# ╠═0ef6b91a-b70f-11eb-00aa-53e78802c841
# ╠═12dde4b8-b70f-11eb-08b5-cb7868b2a7cc
# ╠═16de79e2-b70f-11eb-1308-95ba415891ea
# ╠═d5750042-b70f-11eb-0996-ed3f9f12285a
# ╠═0fcf365e-b710-11eb-08fc-6d1885bed2d5
# ╠═1e46dcaa-b6ed-11eb-018d-d1a70a3c5803
# ╠═2f0da90a-b711-11eb-0f98-3d2860559718
# ╠═53326988-b711-11eb-0934-47656191dd66
# ╠═c659a7e6-b711-11eb-152c-3988c78f8689
# ╠═caa626bc-b711-11eb-065e-9d76106c24ea
# ╠═cece2f64-b711-11eb-0afa-b17bceac8a9b
# ╠═6752ca48-b711-11eb-1a05-1bf030c644d9
# ╠═76b947fa-b711-11eb-0f13-f50e1e9f1b2c
# ╠═7b7c40e4-b711-11eb-1eec-53f79d91f208
# ╠═48a24766-b6ee-11eb-1287-835b2feeea57
# ╠═3bad46f2-b713-11eb-0e86-17dcf31baedc
# ╠═5e5b4f62-b713-11eb-0e90-8183710ea14e
# ╠═d01d7a92-b8a0-11eb-0fd4-d52a9fa00693
