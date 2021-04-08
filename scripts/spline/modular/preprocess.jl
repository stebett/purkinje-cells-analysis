using DrWatson
@quickactivate :ens

using JLD2
using CSV
using DataFrames
using Random
using Spikes

include(srcdir("spline", "mkdf.jl"))


function preprocess(cells; indexes, reference, group, path)
	dir_paths = dirs(path, indexes)

	cells = find(data, indexes) 
	active = get_active_events(tmp)[1]
	landmark = reference == "best" ? [:lift, :cover, :grasp][active] : :lift
	df = mkdf(cells, reference=reference, landmark=landmark)

	write_configs(reference, group, landmark, idx, dir_paths)
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
	open(dir_paths[:conf], "w") do io
		write(io, configs)
	end
end


path = ARGS[1]
reference = ARGS[2]
group = ARGS[3]

data = load_data("data-v6.arrow");
indexes = load(path * "../indexes.jld2", group)
for idx in indexes
	preprocess(data, indexes=idx, reference=reference, group=group, path=path)
end
