using DrWatson
@quickactivate :ens

using JLD2
using CSV
using DataFrames

include(srcdir("spline", "mkdf.jl"))

function preprocess(data, p; path)
	indexes = load(path * "../indexes.jld2", string(p[:group]))
	foreach(indexes) do i
		tmp = find(data, i) 
		df = mkdf(tmp, reference=p[:reference])
		write_args_and_configs(df, p, i, path)
	end
end

function pretty(p::Dict)
	index = p[:index] isa Int ? string(p[:index]) : "c(" * join(string.(p[:index]), ',') * ')'
	group = string(p[:group])
	reference = string(p[:reference])
	index, group, reference
end

function write_args_and_configs(df, p, index, path, binneddir="csv/", argsdir="in/r.config/", uniformdir="in/uniformized/")

	index, group, reference = pretty(Dict(p..., :index=>index))
	filename = join([index, group, reference], '-') 

	clusterpath = "/kingdoms/nbc/workspace14/CETO05/bettani/" * argsdir * filename * ".RData"
	uniformpath = path * uniformdir * filename * ".R"
	csvpath = path * binneddir * filename * ".csv"
	cfgpath = path * argsdir * filename * ".R"
	

	content = """
	index <- $index
	group <- '$group'
	reference <- '$reference'
	csvpath <- '$csvpath'
	uniformpath <- '$uniformpath'
	clusterpath <- '$clusterpath'
	"""

	open(cfgpath, "w") do io
		write(io, content)
	end

	CSV.write(csvpath, df)
end


data = load_data("data-v6.arrow");
params = Dict(:reference => [:multi, :best],
			  :group => [:all, :neigh, :dist]) |> dict_list


path = ARGS[1]

foreach(params) do p
	preprocess(data, p, path=path)
end
