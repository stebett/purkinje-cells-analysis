using DrWatson
@quickactivate "ens"

using DataFrames

json_string = read(datadir("full_data.json"));
json_obj = JSON3.read(json_string);

data_dict = Dict(json_obj);


df = DataFrame(rat=String[], site=String[], tetrode=String[], neuron=String[], lift=Float64[], cover=Float64[], grasp=Float64[], t=Array{Number, 1}[])

