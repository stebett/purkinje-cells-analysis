using DrWatson
@quickactivate "ens"

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

function mkdf(cell::DataFrameRow; tmax = [-600., 600.], pad=150., reference=:lift, landmark=:lift)
	tmax[2] += reference == :multi ? maximum(cell[:grasp] .- cell[:lift]) : 0.
	landmark = reference == :best ? [:lift, :cover, :grasp][get_active_events(cell)[1]] : :lift

	tpadded = tmax .+ [-pad, pad]
	t₁, t₂  = pad, diff(tmax)[1] + pad - 1

	st = cut(cell[:t], cell[landmark], tpadded)
	bins = bin.(st, t₁, t₂, 1., binary=false)
	isi = binisi.(st, t₁, t₂)

	time = collect(tmax[1] : tmax[2] - 1)
	trials = [fill(i, length(time)) for i in eachindex(st)]
	timetoevt = relativetime(cell, time, tmax)

	X                    = DataFrame()
	X.event              = vcat(bins...)
	X.time               = repeat(time, length(st))
	X.trial              = vcat(trials...)
	X.timeSinceLastSpike = vcat(isi...)
	X.timetoevt          = vcat(timetoevt...)
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

relativetime(cellpair::DataFrame, time, tmax) = relativetime.(cellpair[1, :lift], 
															  cellpair[1, :cover], 
															  cellpair[1, :grasp],
															  Ref(time), 
															  Ref(tmax))

relativetime(cell::DataFrameRow, time, tmax) = relativetime.(cell[:lift], 
															 cell[:cover], 
															 cell[:grasp],
															 Ref(time), 
															 Ref(tmax))
