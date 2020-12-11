using DrWatson
@quickactivate "ens"

using Pkg

using Arrow
using DataFrames

data = Arrow.Table(datadir("fixed-landmarks.arrow")) |> DataFrame;
data.rat = convert(Array{String, 1}, data.rat);
data.site = convert(Array{String, 1}, data.site);
data.tetrode = convert(Array{String, 1}, data.tetrode);
data.neuron = convert(Array{String, 1}, data.neuron);
data.t = convert(Array{Array{Float64, 1}, 1}, data.t);
data.lift = convert(Array{Array{Float64, 1}, 1}, data.lift);
data.cover = convert(Array{Array{Float64, 1}, 1}, data.cover);
data.grasp = convert(Array{Array{Float64, 1}, 1}, data.grasp);
