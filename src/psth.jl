using DrWatson
@quickactivate :ens

using Makie

struct PSTH 
	landmark::Symbol
	around::Vector
	over::Vector
	low::Real
	high::Real
	convolution::Bool
	sort_around::Real
end

function load(A::PSTH)
	load_data("data-v6.arrow")
end

function compute(A::PSTH, data)
	cuts = cut(data[:, :t], data[:, A.landmark], A.around)
	cuts_b = cut(data[:, :t], data[:, A.landmark], A.over)

	bins = bin.(cuts, diff(A.around)...)
	bins_b = bin.(cuts, diff(A.over)...)

	convs = convolve(bins)
	convs_b = convolve(bins_b)

	norms = normalize(convs, convs_b)
	avg = average(norms, data)

	sorted = sort_active(avg, A.sort_around)

	hcat(sorted...)
end

function visualise(A::PSTH, x::Matrix)
	f = (drop ∘ transpose ∘ heatmap)(x)
end

