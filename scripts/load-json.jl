using DrWatson
@quickactivate "ens"

using DataFrames
using JSON3

json_string = read(datadir("full_data.json"));
json_obj = JSON3.read(json_string);


function search_routes(x, l, saved_list::Vector)
	i = 0
	for k in keys(x)
		if x[k] isa JSON3.Object
			idx = i+l
			search_routes(x[k], l+1, [saved_list..., "l$idx" => k])
			i += 1
		else
			global megalist
			push!(megalist, [saved_list..., k => x[k]])
		end
	end
end

global megalist = []
v = []
search_routes(json_obj, 1, v)

dict_list = []
for i = 1:32:length(megalist)-31
	push!(dict_list, union(megalist[i:i+31]...))
end


function nodouble(x)



