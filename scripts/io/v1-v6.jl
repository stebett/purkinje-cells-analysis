using DrWatson
using Test
using Arrow
@quickactivate :ens

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

function equalize_landmarks(df, idx) #TODO don't think it works if lift is smaller
	landmarks = [:lift, :cover, :grasp]
	lengths = [length(x) for x in df[idx, landmarks]]
	@assert !all(y -> y == l[1], l)

	values, n = rle(lengths)
	majority = lengths .== values[argmax(n)]

	short = @view df[idx, landmarks[.!majority]]
	longs = @view df[idx, landmarks[majority]]

	a = df[idx, landmarks[majority][1]]
	b = df[idx, landmarks[.!majority][1]]

	m = zeros(length(b), length(a))
	m .= b
	m .-= a'
	m[m .<= 0] .= 1e10

	sane = argmin.(eachrow(m))

	for l in landmarks[majority]
		df[idx, l] = df[idx, l][sane]
	end
end

function remove_zerotrials(df)
	zeroreach = Dict()
	zerograsp = Dict()
	for row in eachrow(df)
		reach = (row.cover .- row.lift) .== 0
		if any(reach)
			zeroreach[row.index] = findall(reach)
		end
		grasp = (row.grasp .- row.cover) .== 0
		if any(grasp)
			zerograsp[row.index] = findall(grasp)
		end
	end

	for (key, value) in zeroreach
		deleteat!(df[df.index .== key, :lift][1], value)
		deleteat!(df[df.index .== key, :cover][1], value)
		deleteat!(df[df.index .== key, :grasp][1], value)
	end
	for (key, value) in zerograsp
		deleteat!(df[df.index .== key, :lift][1], value)
		deleteat!(df[df.index .== key, :cover][1], value)
		deleteat!(df[df.index .== key, :grasp][1], value)
	end
end

function remove_nan(df)
	for row in eachrow(df[broken, :])
		for i in [row.lift, row.cover, row.grasp]
			if length(i) == 1 && isnan(i[1])
				delete!(df, relative(row.index, df))
				break
			end
		end
	end
end

data_v1 = load_data("data-v1.arrow");
data_v4 = load_data("data-v4.arrow");

#% Add missing columns
data_v1.index = data_v4.index;
data_v1.p_acorr = data_v4.p_acorr;

#% Filter out autocorrelated spiketrains
new = data_v1[data_v1.p_acorr .< 0.2, :];

#% Remove all nan trials
broken = find_broken_landmarks(new)
if length(broken) > 0
	remove_nan(new)
end

#% Remove all uneven trials
still_broken = find_broken_landmarks(new)
for i in still_broken
	equalize_landmarks(new, i)
end

#% Remove all zero length trials
remove_zerotrials(new)

#% Removed repeated spiketrains
unique!(new, :t);

@test isempty(find_broken_landmarks(new))
@test sum([x for c in new.cover for x in c] .- [x for l in new.lift for x in l] .== 0) == 0
@test sum([x for c in new.grasp for x in c] .- [x for l in new.cover for x in l] .== 0) == 0
@test size(new.t) == size(unique(new.t))

# Arrow.write(datadir("data-v6.arrow"), new)
