using DrWatson
@quickactivate :ens

using JLD2
using CSV
using DataFrames
using Random

include(srcdir("spline", "mkdf.jl"))

function preprocess(data, p; path)
	indexes = load(path * "../indexes.jld2", string(p[:group]))
	foreach(indexes) do i
		tmp = find(data, i) 
		df = mkdf(tmp, reference=p[:reference])
		idx = df.trial |> unique |> shuffle
		half = length(idx) ÷ 2
		df1 = df[in.(df.trial, Ref(idx[1:half])), :]
		df2 = df[in.(df.trial, Ref(idx[half+1:end])), :]
		write_args_and_configs(df1, p, i, path, 1)
		write_args_and_configs(df2, p, i, path, 2)
	end
end

function pretty(p::Dict, n::Int)
	index = p[:index] isa Int ? string(p[:index]) : "c(" * join(string.(p[:index]), ',') * ')'
	group = string(p[:group])
	reference = string(p[:reference])
	index, group, reference, string(n)
end

function write_args_and_configs(df, p, index, path, n; binneddir="csv/", argsdir="in/r.config/", uniformdir="in/uniformized/")

	index, group, reference = pretty(Dict(p..., :index=>index), n)
	filename = join([index, group, reference, n], '-') 

	clusterpath = "/kingdoms/nbc/workspace14/CETO05/bettani/" * uniformdir * filename * ".RData"
	uniformpath = path * uniformdir * filename * ".RData"
	csvpath = path * binneddir * filename * ".csv"
	cfgpath_s = path * argsdir * filename * "-simple.R"
	cfgpath_c = path * argsdir * filename * "-complex.R"
	

	content = """
	n <- $n
	index <- $index
	group <- '$group'
	reference <- '$reference'
	csvpath <- '$csvpath'
	uniformpath <- '$uniformpath'
	clusterpath <- '$clusterpath'
	resultpath <- '$resultpath'
	"""
	simple = content * "model <- 'simple'\n"
	open(cfgpath_s, "w") do io
		write(io, simple)
	end

	complex = content * "model <- 'complex'\n"
	open(cfgpath_c, "w") do io
		write(io, complex)
	end

	if !isnothing(df)
		CSV.write(csvpath, df)
	end
end

function produce_only_configs(p, ;path)
	indexes = load(path * "../indexes.jld2", string(p[:group]))
	foreach(indexes) do i
		write_args_and_configs(nothing, p, i, path, 1)
		write_args_and_configs(nothing, p, i, path, 2)
	end
end

path = ARGS[1]
only_config = ARGS[2] == "config"

params = Dict(:reference => [:best],
			  :group => [:neigh, :dist]) |> dict_list

if only_config
	foreach(params) do p
		produce_only_configs(p, path=path)
	end
else
	data = load_data("data-v6.arrow");
	foreach(params) do p
		preprocess(data, p, path=path)
	end
end


