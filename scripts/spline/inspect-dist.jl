using DrWatson
@quickactivate :ens

using JLD2 
using Spikes
using DataFrames 

include(srcdir("spline", "spline-plots.jl"))

function extract(data)
	df = DataFrame((index=Vector[], t=Tuple[], m=Float64[], x=Vector[], mean=Vector[], ranges=Vector[]))
	for (k, r) in data
		x = r[:c_nearest]
		y = x[:est_mean] .> 0.
		indexes = rangeT(y)
		if length(indexes) > 0
			long_i = indexes[argmax(diff.(indexes))]
			t = x[:new_x][long_i[1]:long_i[2]]
			peak_m = t[argmax(x[:est_mean][long_i[1]:long_i[2]])]
			peak_t = extrema(t)
			push!(df, [parse.(Array{Int, 1}, k), 
					   peak_t,
					   peak_m,
					   x[:new_x], 
					   x[:est_mean],
					   all_ranges_above(x)])
		end
	end
	df
end

r_neigh = load(datadir("analyses/spline/batch-4-cluster/postprocessed", "multi-neigh.jld2"))
r_dist = load(datadir("analyses/spline/batch-4-cluster/postprocessed", "multi-dist.jld2"))

ll_n = load(datadir("analyses/spline/batch-4-cluster/postprocessed",
					"likelihood-neigh.csv")) |> DataFrame
ll_n.c_better = parse.(Bool, ll_n.c_better)
ll_d = load(datadir("analyses/spline/batch-4-cluster/postprocessed",
					"likelihood-dist.csv")) |> DataFrame
ll_d.c_better = parse.(Bool, ll_d.c_better)


df_n = extract(r_neigh)
df_d = extract(r_dist)
n_better = df_n[in.(df_n.index, Ref(ll_n[ll_n.c_better .== 1, :index])), :]
d_better = df_d[in.(df_d.index, Ref(ll_d[ll_d.c_better .== 1, :index])), :]

data = load_data("data-v6.arrow");
idx = parse.(Array{Int, 1}, d_better.idx)

ccs = map(idx) do i
	t1 = cut(find(data, i[1]).t, find(data,i[1]).lift, [-300., 300.])
	t2 = cut(find(data, i[2]).t, find(data,i[2]).lift, [-300., 300.])
	cc = mean(crosscor.(t1, t2, true, binsize=1.0))
end

for i in idx
end

t1 = cut(find(data, i[1]).t, find(data,i[1]).lift, [-300., 300.])
t2 = cut(find(data, i[2]).t, find(data,i[2]).lift, [-300., 300.])
cc = mean(crosscor.(t1, t2, true, binsize=1.0))
b1 = bin(t1, 600, 1.)
b2 = bin(t2, 600, 1.)
p1 = heatmap(hcat(b1...)', colorbar=false, color=cgrad([:white, :black]))
ylabel!("trial")
xlabel!("time")
p2 = heatmap(hcat(b2...)', colorbar=false, color=cgrad([:white, :black]))
ylabel!("trial")
xlabel!("time")
p3 = plot(cc)
ylabel!("norm crosscor")
xlabel!("time")
p4 = plot(find(d_better, i, :x), find(d_better,i, :mean)
	

