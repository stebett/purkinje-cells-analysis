using DrWatson
@quickactivate "ens"

using NPZ

include(srcdir("spike-tools.jl"))
include(srcdir("data-tools.jl"))
include(scriptsdir("load-data.jl"))

function save_trials(trials)
	dname = "couples"
	rm(datadir(dname), recursive=true)
	mkdir(datadir(dname))

	for (i, tr) in enumerate(trials)
		for (j, t) in enumerate(tr)
			lm="lift"
			trial = padder(i, trials)
			n = padder(j, trials)
			npzwrite(datadir(dname, savename(lm, @dict(trial, n), "npy", sort=false)), t)
		end
	end
end

# Remember to write and plot on the report the bad data
function extract_trials(neigh, min_length, around=[-1000, 1000])
	trials = Array{Array{Float64, 1}, 1}[]
	for n in neigh
		if length(n) >= min_length
			for l in data[n[1], "lift"][1]
				cuts = cut(data[n, "t"], l, around)

				filter!(x -> length(x) != 0, cuts)
				if length(cuts) >= min_length
					push!(trials, cuts[1:min_length])
				end
			end
		end
	end
	trials
end

function extract_trials(groups::GroupedDataFrame{DataFrame}, min_length)
	trials = Array{Array{Float64, 1}, 1}[]
	speeds = Array{Float64, 1}[]
	for g in groups
		if size(g, 1) >= min_length
			push!(trials, g.t[1:min_length])
			push!(speeds, g.cover[1:min_length] .- g.lift[1:min_length])
		end
	end
	trials, speeds
end

	


function padder(n, trials)
	max_length = length(string(length(trials)))
	lpad(string(n), max_length , '0')
end

function single_trials(df, landmark::String)
	new_df = DataFrame(rat=String[], site=String[], tetrode=String[], neuron=String[], trial=Int[], lift=Float64[], cover=Float64[], grasp=Float64[], t=Array{Float64, 1}[])

	trials = cut(df["t"], df[landmark], [-250, 250])

	idx = map(length, df[landmark]) |> x->pushfirst!(x, 0) |> cumsum
	idx_list = [[idx[i]+1:idx[i+1];] for i = 1:length(idx) - 1]

	for (old_idx, trial_idxs) = enumerate(idx_list)
		for (lm_idx, trial_idx) = enumerate(trial_idxs)
			push!(new_df, [values(df[old_idx, ["rat", "site", "tetrode", "neuron"]])..., lm_idx, df[old_idx, "lift"][lm_idx], df[old_idx, "cover"][lm_idx], df[old_idx, "grasp"][lm_idx], trials[trial_idx]])
		end
	end
	new_df
end

df = single_trials(df, "lift")
groups = groupby(df, [:rat, :site, :trial])
trials, speeds = extract_trials(groups, 3) 
save_trials(trials)


neigh = unique(get_neighbors(data, grouped=true))
trials = extract_trials(neigh, 3, [-1000, 1000])

