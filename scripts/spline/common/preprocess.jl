using DrWatson
@quickactivate :ens


using CSV
using DataFrames

includet(srcdir("spline", "mkdf.jl"))

function preprocess(data, p, batch=5)
	indexes = p[:group] == :all ? data.index : couple(data, p[:group])
	foreach(indexes) do i
		tmp = find(data, i) 
		df = mkdf(tmp, reference=p[:reference])
		dir = datadir("analyses/spline/batch-$batch/in", string.(p[:reference], :/, p[:group], :/)) 
		file = "$dir$i.csv"
		CSV.write(file, df)
	end
end


data = load_data("data-v6.arrow");

params = Dict(:reference => [:multi, :best],
			  :group => [:all, :neigh, :dist]) |> dict_list

foreach(params) do p
	preprocess(data, p)
end
