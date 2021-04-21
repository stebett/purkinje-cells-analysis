library(STAR)


sim.one <- function(gss, lfun, x) {
	as.double(thinProcess(object=gss, m2uFctList=lfun, trueData=x, formerSpikes=with(x, time[match(1, event)])))
}


read_rdata <- function(file) {
	r_data <- load(file)
	x <- get(r_data)
	return(x)
}

file = "data/analyses/spline/batch-8/best-neigh/out/data/438-437.RData"
# file = "data/analyses/spline/batch-artificial/best-neigh/out/data/1-2.RData" 

res = read_rdata(file)
trials = lapply(split(res$data, res$data$trial), function(x) x[, names(res$gss$mf)])
lfun = lapply(res$rnfun, mkSelf)[1] 

x = trials[[1]]
fake = sim.one(res$gss, lfun, x)
fake

