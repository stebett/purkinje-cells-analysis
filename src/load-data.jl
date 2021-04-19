using DrWatson
@quickactivate "ens"

using Arrow
using DataFrames

function load_data(filename::String)
	data = Arrow.Table(datadir("processed", filename)) |> DataFrame;
	data.rat = convert(Array{String, 1}, data.rat);
	data.site = convert(Array{String, 1}, data.site);
	data.tetrode = convert(Array{String, 1}, data.tetrode);
	data.neuron = convert(Array{String, 1}, data.neuron);
	data.t = convert(Array{Array{Float64, 1}, 1}, data.t);
	data.lift = convert(Array{Array{Float64, 1}, 1}, data.lift);
	data.cover = convert(Array{Array{Float64, 1}, 1}, data.cover);
	data.grasp = convert(Array{Array{Float64, 1}, 1}, data.grasp);
	if :index in names(data)
		data.index = convert(Array{Int64, 1}, data.index);
	end
	if :p_acorr in names(data)
		data.p_acorr = convert(Array{Float64, 1}, data.p_acorr);
	end
	data
end

function load_data(analysis, batch, reference, group, file)
	inpath = datadir("analyses/$analysis/batch-$batch/$reference-$group/results/$file")
	Arrow.Table(inpath) |> DataFrame
end

