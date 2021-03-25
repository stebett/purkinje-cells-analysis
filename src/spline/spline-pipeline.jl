using DrWatson
@quickactivate :ens

using DataFrames
using Spikes
using RCall

import Base.ceil

function mkdf(cellpair::DataFrame; tmax = [-600., 600.], pad=100., reference=:lift, landmark=:lift)
	tmax[2] += reference == :multi ? maximum(cellpair[1, :grasp] .- cellpair[1, :lift]) : 0.
	landmark = reference == :best ? [:lift, :cover, :grasp][get_active_events(cellpair)[1]] : :lift

	tpadded = tmax .+ [-pad, pad]
	t₁, t₂  = pad, diff(tmax)[1] + pad - 1

	st = cut(cellpair[1, :t], cellpair[1, landmark], tpadded)
	bins = bin.(st, t₁, t₂, 1., binary=false)
	isi = binisi.(st, t₁, t₂)

	time = collect(tmax[1] : tmax[2] - 1)
	trials = [fill(i, length(time)) for i in eachindex(st)]

	st₂ = cut(cellpair[2, :t], cellpair[2, landmark], tpadded)
	tback = binisi.(st₂, t₁, t₂)
	tforw = binisi_r.(st₂, t₁, t₂)
	nearest = min.(tback, tforw)

	timetoevt = relativetime(cellpair, time, tmax)

	X                    = DataFrame()
	X.event              = vcat(bins...)
	X.time               = repeat(time, length(st))
	X.trial              = vcat(trials...)
	X.timeSinceLastSpike = vcat(isi...)
	X.nearest            = vcat(nearest...)
	X.timetoevt          = vcat(timetoevt...)
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
	R"""
	obj = $gssResult
	class(obj)  <- 'ssanova'
	"""
	x = convert(Dict{Symbol, Any}, R"quickPredict(obj, $variable)")
	if isnothing(rcopy(R"$uniformdf$inv.rnfun[[$variable]]"))
		x[:new_x] = x[:xx]
	else
		x[:new_x] = rcopy(R"$uniformdf$inv.rnfun[[$variable]]($(x[:xx]))")
	end
	x
end

function predictLogProb(gssResult, uniformdf)
	R"""
	obj = $gssResult
	class(obj)  <- 'ssanova'
	"""
	rcopy(R"predictLogProb(obj, $uniformdf)")
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
