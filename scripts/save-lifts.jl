using DrWatson
@quickactivate "ens"

using NPZ

include(srcdir("spike-tools.jl"))
include(srcdir("data-tools.jl"))
include(scriptsdir("load-data.jl"))

# Remember to write and plot on the report the bad data
function extract_trials(neigh, min_length)
	trials = Array{Array{Float64, 1}, 1}[]
	for n in neigh
		if length(n) >= min_length
			for l in data[n[1], "lift"][1]
				cuts = cut(data[n, "t"], l, [-1000, 1000])

				filter!(x -> length(x) != 0, cuts)
				if length(cuts) >= 3
					push!(trials, cuts[1:3])
				end
			end
		end
	end
	trials
end

function padder(n, trials)
	max_length = length(string(length(trials)))
	lpad(string(n), max_length , '0')
end


dirname = "couples"
rm("data/" * dirname, recursive=true)
mkdir("data/" * dirname)

neigh = unique(get_neighbors(data, grouped=true))
trials = extract_trials(neigh, 2)
for (i, tr) in enumerate(trials)
	for (j, t) in enumerate(tr)
		lm="lift"
		trial = padder(i, trials)
		n = padder(j, trials)
		npzwrite(datadir(dirname, savename(lm, @dict(trial, n), "npy", sort=false)), t)
	end
end

