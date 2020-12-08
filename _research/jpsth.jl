using DrWatson
@quickactivate "ens"

include(scriptsdir("load-data.jl")) 
include(srcdir("spike-tools.jl"))
include(srcdir("data-tools.jl"))
using Plots
gr()


function jpsth(idx1, idx2)
	N = 5000
	n2 = slice(data.t[idx1], data.lift[idx1][1], (-N÷2, N÷2))
	n3 = slice(data.t[idx2], data.lift[idx2][1], (-N÷2, N÷2))

	n2r = [sum(n2[i:i+10]) for i = 1:10:length(n2)-10]
	n3r = [sum(n3[i:i+10]) for i = 1:10:length(n3)-10]

	r = hcat(n2, n3)
	heatmap(r', legend=false, color=:grays)

	M = zeros(length(n2r), length(n3r))
	M .+= n2r
	M .+= n3r'

	p1 = heatmap(M, colorbar=false)
	p2 = plot(sum(M, dims=2)[:, 1], framestyle=:none, legend=false, fill=true)
	p3 = plot(sum(M, dims=1)[1, :], [1:size(M, 1);], framestyle=:none, legend=false, fill=true)
	p4 = plot(framestyle=:none)

	l = @layout [ a{.7w} b{.3w}; c{.7h} d{.3w} ]
	plot(p2, p4, p1, p3, layout=l, size=(700, 500))
end
