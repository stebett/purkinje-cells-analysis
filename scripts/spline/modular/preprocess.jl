using DrWatson
@quickactivate :ens

using JLD2
using CSV
using DataFrames
using Random
using Spikes
using TOML

include(srcdir("spline", "mkdf.jl"))


function preprocess(alldata; index, reference, group, path, tmax, pad, minspikes, kw...)
	dir_paths = dirs(path, index)
	cells = find(alldata, index) 
	active = get_active_events(cells)[1]
	landmark = reference == "best" ? [:lift, :cover, :grasp][active] : :lift
	df = mkdf(cells, reference=reference, landmark=landmark, tmax=tmax, pad=pad, minspikes=minspikes)
	write_configs(reference, group, landmark, index, dir_paths)
	CSV.write(dir_paths[:csv], df)
end

function dirs(path, indexes)
	remotepath = "/kingdoms/nbc/workspace14/CETO05/bettani/spline"
	fn = join(indexes, '-')

	(csv = "$path/in/csv/$fn.csv",
	 conf = "$path/in/conf/$fn.R",
	 unif = "$path/in/unif/$fn.RData",
	 clust = "$remotepath/$reference-$group/in/unif/$fn.RData", 
	 result = "$remotepath/$reference-$group/out/data/$fn.RData",
	 )
end

function write_configs(reference, group, landmark, indexes, dirs)
	configs = """
	group <- '$group'
	reference <- '$reference'
	landmark <- '$landmark'
	index1 <- $(indexes[1])
	index2 <- $(length(indexes) > 1 ? indexes[2] : "NA")
	csvpath <- '$(dirs[:csv])'
	cfgpath <- '$(dirs[:conf])'
	uniformpath <- '$(dirs[:unif])'
	clusterpath <- '$(dirs[:clust])'
	resultpath <- '$(dirs[:result])'
	"""
	open(dirs[:conf], "w") do io
		write(io, configs)
	end
end

flatten_dict(d::Dict) = Dict(Symbol(k)=>v for (_, subdict) in d for (k, v) in subdict)


# batch_path = "data/analyses/spline/batch-test"
# reference = "best"
# group = "neigh"

batch_path = ARGS[1]
reference = ARGS[2]
group = ARGS[3]

params = TOML.parsefile(batch_path * "/params.toml") |> flatten_dict
params[:path] = batch_path * "/$reference-$group"
params[:reference] = reference
params[:group] = group

data = load_data(params[:data])
indexes = TOML.parsefile(batch_path * "/indexes.toml")[group]
for idx in indexes
	preprocess(data; index=idx, params...)
end
