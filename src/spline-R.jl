using DrWatson
@quickactivate :ens

using RCall

R"library(gss)"
R"library(STAR)"

R"""
uniformizedf <- function(d1df,rnparm=c('timeSinceLastSpike','previousIsi','tback','tforw','nearest')
)
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

#compute a smooth fit from a gssanova output
qp.gss <- function(gsa,parm,inv.rnfun)
  {
    qpgss=quickPredict(gsa,parm)
    if(!is.null(inv.rnfun[[parm]]))
      {
        qpgss$newx=inv.rnfun[[parm]](qpgss$xx)
        qpgss$ticks=pretty(qpgss$xx)
        qpgss$labels=inv.rnfun[[parm]](qpgss$ticks)
      }
    qpgss
  }

#plot a smooth fit (pre-computed by qp.gss)
plot.qp.gss <- function(qpgsa,uniform=FALSE,...)
  {
    if(!is.null(qpgsa$newx))
      {
        if(uniform==FALSE)
          {
            qpgsa$xx=qpgsa$newx
            plot(qpgsa,...)
          } else {
            plot(qpgsa,axes=FALSE,...)
            axis(2)
            box()
            axis(1,at=qpgsa$ticks,labels=formatC(qpgsa$labels,2))
          }
      } else {
        plot(qpgsa,...)
      }
    abline(h=0)
  }

#plot a smooth fit on gssanova result (uses qp.gss to predict and plot.qp.gss to plot)
plot.gss <- function(gsa,parm='r.nearest',inv.rnfun=NULL,uniform=FALSE,...)
  {
    qpgss=qp.gss(gsa,parm,inv.rnfun)
    plot.qp.gss(qpgss,uniform,...)
    invisible(qpgss)
  }
"""
