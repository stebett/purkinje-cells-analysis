using DrWatson
@quickactivate :ens

using RData
using DataFrames
using DataFramesMeta
using Plots
using Spikes
using Arrow

include(srcdir("spline", "model_summaries.jl"))

batch = 7
inpath = "/home/ginko/ens/data/analyses/spline/batch-$batch/results/postprocessed.RData"

data = RData.load(inpath)["predictions"]

R"""
library(STAR)

function (m2uSelf)
{
  force(m2uSelf)
  function(proposedtime, st) {
    m2uSelf(proposedtime - max(st))
  }
}

load('data/analyses/spline/batch-4-cluster/neigh/in/multi-neigh.RData')
load('data/analyses/spline/batch-4-cluster/neigh/out/multi-neigh-res.RData')
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
"""


 gsa=gsaS

 mf=list(r.timeSinceLastSpike=m1$rnfun$r.timeSinceLastSpike,time=Id)
 simf=mkSimFct(gsa,mf,d1df,with(d1df,time[event==1]))

 simf=thinProcess(gsa,mf,
   trueData=subset(d1df,time>tmax1$start&time<tmax1$end),
   formerSpikes=with(d1df,time[event==1]))


simcc <- function(r,case=c('Simple','Complex'),whichpair=c(1,2),
                  tmax=30,bin=1,Ncc=500,NfakeTrains=30,plot=FALSE,return.fake=FALSE)
  {
    rbin=1 #no use: juste for raster construction
    
    ##extract the information needed for the simulations with thinProcess
    if(length(whichpair)!=1) whichpair=1 else if (!whichpair%in%c(1,2))
      stop('whichpair must be 1 or 2')#1 or 2
    gs=r[[c('gs12','gs21')[whichpair] ]]
    timerange=as.numeric(r$parms[[c('tmax1','tmax2')[whichpair]]])
    evt=r[[c('evt1','evt2')[whichpair]]]
    case=match.arg(case) #case='Complex' or 'Simple'
    
    ##setup the arguments for thinProcess
    ##map to uniform functions
    lfun=lapply(gs$rnfun['r.timeSinceLastSpike'],mkSelf)
    
    ##true data: reform a list of sweeps in ltD (for list of true data)
    allData=r$models[[c('m1','m2')[whichpair]]]$data #all the data used for generation
    data=allData[inrange(allData$time,timerange,FALSE),] #drop unused times for trueData
    ltD=lapply(split(data,data$ntrial),function(x) x[,names(gs[[case]]$mf)])
    
    ##get the last spike before the beginning of the window used in the simulation
    prevData= allData[allData$time<min(timerange),]
    tmp= sapply(split(prevData,prevData$ntrial), function(d) max(d$time[d$event>0]))
    prevSpikes=numeric()
    prevSpikes[as.numeric(names(tmp))]=tmp
    ##provide an artificial spike where needeed to initialize the run.
    prevSpikes[is.infinite(prevSpikes)|is.na(prevSpikes)]=min(timerange)
    
    ##Performs the spike train simulation

#fake=mapply(function(tD,pS) thinProcess(object=gs[[case]],
#  m2uFctList=lfun,trueData=tD,formerSpikes=-300)
#  ,ltD,prevSpikes)

    fake=mapply(function(tD,pS) replicate(NfakeTrains,thinProcess(object=gs[[case]],
      m2uFctList=lfun,trueData=tD,formerSpikes=pS)),
      ltD,prevSpikes,SIMPLIFY=FALSE)
    
    ## compute the correlogram: generates the sweeps of the other cell with 'raster'
    ## and computes the crosscorr
    ##get the other cells' sweeps
    r2=rastertm(r$cp[[c(2,1)[whichpair]]]$t,r$cp[[whichpair]][[evt]],
      max(timerange),rbin,plot=F)$data
    ##correlates with the simulated sweeps. replicate as needed
    allsimcc=replicate(Ncc,rowSums(mapply(function(x,y,i)
      crosscorr(x[[i]],y,tmax,bin,plot=FALSE)$bintable,
      fake, r2, sample(1:NfakeTrains,length(fake), replace=TRUE) ))
      )
    x=crosscorr(1,1,tmax,bin,plot=FALSE)$x
    m=rowMeans(allsimcc)
    e=apply(allsimcc,1,sd)  
    
    ##get the real cc on your way
    r1=rastertm(r$cp[[c(1,2)[whichpair]]]$t,r$cp[[whichpair]][[evt]],
      max(timerange),rbin,plot=F)$data
    realcc=rowSums(mapply(function(x,y) crosscorr(x,y,tmax,bin,plot=FALSE)$bintable,r1,r2))
    
    if(plot==TRUE)
      {
      plot(range(x),range(realcc,m+e,m-e),t='n',xlab='time (ms)',ylab='counts')
      filled.2lines(x,m-2*e,m+2*e)
      lines(x,m)
      lines(x,realcc,col=2)
    }
#    browser()
    if(!return.fake) {  
      invisible(list(x=x,simcc=m,sd.simcc=e,realcc=realcc))
    }else{
      invisible(list(x=x,simcc=m,sd.simcc=e,realcc=realcc,fake=fake))
    }
  }


