using DrWatson
@quickactivate :ens

using DataFrames
using Spikes
using RCall

import Base.ceil

function mkdf(cellpair::DataFrame; tmax = [-600., 600.], reference=:lift)
	landmark = :lift
	if reference == :multi
		tmax[2] += maximum(cellpair[1, :grasp] .- cellpair[1, :lift])
	elseif reference == :best
		idx = get_active_events(cellpair)
		landmark = [:lift, :cover, :grasp][idx[1]]
	end

	len = floor(Int, diff(tmax)[1])
	st = cut(cellpair[1, :t], cellpair[1, landmark], tmax)
	ext = ceil.(Int, extrema.(st))
	ntrials = length(st)

	st = norm_len.(st, 0, len) 
	bins = bin(st, len, 1., binary=true) 
	isi = binisi.(st)
	neuron = ones(Int, len)
	time = [tmax[1]+1:tmax[2];]
	fixed_times = fixtimes(time, len, ntrials, ext)

	st2 = cut(cellpair[2, :].t, cellpair[2, landmark], tmax)
	st2 = norm_len.(st2, 0, len)
	tforw = binisi_inv.(st2) |> x->vcat(x...)
	tback = corrected_tback(st2)
	nearest = min.(tback, tforw)
	timetoevt = relativetime(cellpair, time, tmax)

	X = DataFrame()

	X.event              = vcat(bins...)
	X.time               = fixed_times
	X.neuron             = repeat(neuron, ntrials)
	X.trial              = X.ntrial = [i for i=1:ntrials for l=1:len]
	X.timeSinceLastSpike = vcat(isi...)
	X.previousIsi        = vcat([previousisi(isi[i]) for i in 1:ntrials]...)
	X.tback              = tback
	X.tforw              = tforw
	X.nearest            = nearest

	if reference == :multi
		X.timetoevt      = vcat(timetoevt...)
	end

	drop(X)
end

function mkdf(cell::DataFrameRow; tmax = [-600., 600.], reference=:lift)
	landmark = :lift
	if reference == :multi
		tmax[2] += maximum(cell[:grasp] .- cell[:lift])
	elseif reference == :best
		idx = get_active_events(cellpair)
		landmark = [:lift, :cover, :grasp][idx[1]]
	end

	len = floor(Int, diff(tmax)[1])
	st = cut(cell[:t], cell[landmark], tmax)
	ext = ceil.(Int, extrema.(st))
	ntrials = length(st)

	st = norm_len.(st, 0, len) 
	bins = bin(st, len, 1., binary=true) 
	isi = binisi.(st)
	neuron = ones(Int, len)
	time = [tmax[1]+1:tmax[2];]
	fixed_times = fixtimes(time, len, ntrials, ext)

	timetoevt = relativetime(cell, time, tmax)

	X = DataFrame()

	X.event              = vcat(bins...)
	X.time               = fixed_times
	X.neuron             = repeat(neuron, ntrials)
	X.trial              = X.ntrial   = [i for i=1:ntrials for l=1:len]
	X.timeSinceLastSpike = vcat(isi...)
	X.previousIsi        = vcat([previousisi(isi[i]) for i in 1:ntrials]...)

	if reference == :multi
		X.timetoevt      = vcat(timetoevt...)
	end

	drop(X)
end


function quickPredict(uniformdf, gssResult, variable)
	x = convert(Dict{Symbol, Any}, R"quickPredict($gssResult, $variable)")
	if isnothing(rcopy(R"$uniformdf$inv.rnfun[[$variable]]"))
		x[:new_x] = x[:xx]
	else
		x[:new_x] = rcopy(R"$uniformdf$inv.rnfun[[$variable]]($(x[:xx]))")
	end
	x
end

R"library(gss)"
R"library(STAR)"

R"""
uniformizedf <- function(d1df,rnparm)
{
  rnparmName= paste('r',rnparm,sep='.')
  rnfun=lapply(rnparm,function(x) mkM2U(d1df,x))
  names(rnfun)=rnparmName

  inv.rnfun=lapply(rnfun, function(x) attributes(x)$qFct)
  res=mapply(function(c,f) f(d1df[[c]]), rnparm,rnfun)
  colnames(res)=rnparmName
  m1=cbind(d1df,res)
#  attr(m1,'rnfun')=rnfun
#  attr(m1,'inv.rnfun')=inv.rnfun
  list(data=m1,rnfun=rnfun,inv.rnfun=inv.rnfun)
}
"""

function relativetime(lift, cover, grasp, t, tmax)
	y = zeros(size(t))

	cl = cover - lift
	gc = grasp - cover
	gl = grasp - lift

	# intervals
	beforelift = t .< 0.
	liftcover = 0. .<= t .< cl
	covergrasp = cl .<= t .< gl
	aftergrasp = t .>= gl

	y[beforelift] = 2 .- t[beforelift] ./ tmax[1] * 2 
	y[liftcover] = 2 .+ t[liftcover] ./ cl
	y[covergrasp] = 3 .+ (t[covergrasp] .- cl) ./ gc
	y[aftergrasp] = 4 .+ (t[aftergrasp] .- gl) ./ (tmax[2] .- gl) * 2

	y
end

relativetime(cellpair::DataFrame, time, tmax) = 
	relativetime.(cellpair[1, :lift], 
				  cellpair[1, :cover], 
				  cellpair[1, :grasp],
				  Ref(time), Ref(tmax))

relativetime(cell::DataFrameRow, time, tmax) = 
	relativetime.(cell[:lift], 
				  cell[:cover], 
				  cell[:grasp],
				  Ref(time), Ref(tmax))

function fixtimes(times, len, ntrials, ext)
	fixed_times = fill(NaN, len*ntrials)
	legal_ranges = [e[1]:e[2] .- 1 for e in ext] 
	for i in 1:ntrials
		rng = legal_ranges[i] .+ ((i-1)*len)
		fixed_times[rng] = times[legal_ranges[i]] 
	end
	fixed_times
end

function previousisi(x)
	y = fill(NaN, length(x))
	prev = NaN

	for i in 2:length(x)
		if x[i] == 1.
			prev = x[i-1]
		end
		y[i] = prev
	end
	y
end

function corrected_tback(st2)
	tback = binisi_0.(st2)
	tback = [[tback[i][2:end];NaN] for i in eachindex(st2)]
	map(eachindex(tback)) do i
		tback[i][1:floor(Int, st2[i][2])] .= NaN
	end
	vcat(tback...)
end

function get_cell(df, s::String) 
	x = split(s, '.')
	rat = df.rat .== x[1]
	site = df.site .== x[2]
	tet = df.tetrode .== x[3]
	neuron = df.neuron .== replace(x[4], 't'=>"neuron")
	df[rat .& site .& tet .& neuron, :]
end

function make_couples(df, s::Vector{<:String})
	vcat(get_cell(df, s[1]), get_cell(df, s[2]))
end


binisi(x) = vcat([[1:i;] for i in diff(floor.(x))]...) # TODO check floor
binisi_inv(x) = vcat([[i-1:-1:0;] for i in diff(floor.([0; x]))]...) 
binisi_0(x) = vcat([[0:i-1;] for i in diff(floor.(x))]...) # TODO check floor


norm_len(x, f, l) = [f;x;l]
ceil(t::Type, x::Tuple) = ceil.(t, x)

