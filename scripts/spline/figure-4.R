library(STAR)


read_rdata <- function(file) {
		r_data <- load(file)
	x <- get(r_data)
		return(x)
}

inpath = "/home/ginko/ens/data/analyses/spline/batch-7/out/data"
infiles <- list.files(path=inpath, pattern=".R", full.names=T, all.files=T)

result = read_rdata(infiles[400])


function (m2uSelf)
{
	  force(m2uSelf)
  function(proposedtime, st) {
	      m2uSelf(proposedtime - max(st))
    }
}

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


