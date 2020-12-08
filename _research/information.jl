using DrWatson
@quickactivate "ens"

include(scriptsdir("load-data.jl")) 
include(srcdir("spike-tools.jl"))

r = slice(data.t, [l[2] for l = data.lift], (-20, 20))
r = Array{Int, 2}(r)
heatmap(r', legend=false, color=:grays)

function pₙ(x)
	words = []
	for i = 1:size(x, 2)
		if x[:, i] ∉ words
			push!(words, (x[:, i]))
		end
	end
	c = zeros(length(words))
	for i = 1:length(words)
		c[i] = sum(x[:, k]==words[i] for k = 1:size(x, 2)) / size(x, 2)
	end
	c
end

Sₙ(x) = -sum(pₙ(x) .* log2.(pₙ(x)))
