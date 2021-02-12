using DrWatson
@quickactivate "ens"

using DataFrames
using JSON

dict = Dict()
open(datadir("full_data.json"), "r") do f
    global dict
    dict=JSON.parse(f);  # parse and transform data
end


