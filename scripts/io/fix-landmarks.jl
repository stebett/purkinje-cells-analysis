using DrWatson
@quickactivate "ens"

include(scriptsdir("load-data.jl"))
include(srcdir("data-tools.jl"))

function find_broken_landmarks(data)
	broken = Int[]
	for i in 1:size(data, 1)
		l = map(length, data[i, ["lift", "cover", "grasp"]])
		if !all(y -> y == l[1], l)
			push!(broken, i)
		end
	end
	broken
end

for i = 16:19
	insert!(data[i, "cover"], 4, NaN)
end

for i = 23:32
	insert!(data[i, "grasp"], 2, NaN)
	insert!(data[i, "grasp"], 2, NaN)
	insert!(data[i, "grasp"], 7, NaN)
	insert!(data[i, "grasp"], 10, NaN)
	insert!(data[i, "grasp"], 10, NaN)
end

for i = 181:184
	deleteat!(data[i, "cover"], 12)
end

for i = 340:341
	data[i, "cover"] = [NaN]
end

for b in find_broken_landmarks(data)
	l = map(length, data[b, ["lift", "cover", "grasp"]])
	if !all(y -> y == l[1], l)
		push!(data[b, "cover"], [NaN for _ = 1:l.lift - l.cover]...)
		push!(data[b, "grasp"], [NaN for _ = 1:l.lift - l.grasp]...)
	end
end





