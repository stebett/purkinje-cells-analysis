library(STAR)

function (m2uSelf)
{
	  force(m2uSelf)
  function(proposedtime, st) {
	      m2uSelf(proposedtime - max(st))
    }
}

inpath = "/home/ginko/ens/data/analyses/spline/batch-$batch/out/data/"

res = result_multi_neigh
res_clean=apply(res,2,function(x) {S=x[1:27];C=x[28:54];names(S)=sub('S\\.','',names(S));names(C)=sub('C\\.','',names(C));list(C=C,S=S)})

Id=function(x,...) return(x)

m1 = multi_neigh[[2]]
gsa = res_clean[[2]][["C"]]
class(gsa) <- "ssanova"
mf=list(r.timeSinceLastSpike=m1$rnfun$r.timeSinceLastSpike,time=Id)
simf=mkSimFct(gsa,mf,m1$data,with(m1$data,time[event==1]))

tmax=600
wtmax=150
shuffle=FALSE
alpha=1
Id=function(x,...) return(x)

tmax1=data.frame(start=-tmax,end=tmax)

 simf=thinProcess(gsa,mf,
				     trueData=subset(m1$data,time>tmax1$start&time<tmax1$end),
					    formerSpikes=with(m1$data,time[event==1]))

lfun=lapply(m1$rnfun[['r.timeSinceLastSpike']], mkSelf)
thinProcess(c1, lfun, $spiketrain, -300)


