using DrWatson
@quickactivate "ens"
using DataFrames
using DataStructures
using JSON3

json_string = read(datadir("full_data.json"));
json_obj = JSON3.read(json_string);

function nodouble(x)
	key_list = []
	for i in 1:length(x)
		key = x[i][1]
		if key in key_list
			x[i] = Symbol("$key.2")=>x[i][2]
		end
		push!(key_list, x[i][1])
	end
	sort(OrderedDict(x))
end

function search_routes(x, l, saved_list::Vector)
	for k in keys(x)
		if x[k] isa JSON3.Object
			l += 1
			search_routes(x[k], l, [saved_list..., Symbol("l$l") => k])
		else
			global megalist
			push!(megalist, [saved_list..., k => x[k]])
		end
	end
end


global megalist = []
v = []
search_routes(json_obj, 0, v)

dict_list = []
for i = 1:32:length(megalist)-31
	push!(dict_list, nodouble(union(megalist[i:i+31]...)))
end

for i in 1:length(dict_list)
	for k in keys(dict_list[i])
		if dict_list[i][k] isa JSON3.Array && (length(dict_list[i][k]) > 1)
			dict_list[i][k] = [Array(dict_list[i][k])]

		elseif dict_list[i][k] == Union{}[]
			dict_list[i][k] = [nothing]

		elseif !(dict_list[i][k] isa JSON3.Array) 
			dict_list[i][k] = [dict_list[i][k]]
		end
	end
end

for i in 1:length(dict_list)
	if !(Symbol("mean.2") in keys(dict_list[i]))
		 dict_list[i][Symbol("mean.2")] = [nothing]
	 end
end

dfs = [DataFrame(i) for i in dict_list];

rn = names(dfs[1][r"l\d"]);
for i in 1:length(dfs)
	rename!(dfs[i], Pair.(names(dfs[i][r"l\d"]), rn));
end

df = vcat(dfs...);


