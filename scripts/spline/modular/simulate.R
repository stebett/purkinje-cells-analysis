library(STAR)

sim.agg <- function(file, n=1) {
	res = read_rdata(file)
	sims = tryCatch(sim(res, n), error=function(e) e)
	list(fake=sims, index1=res$index1, index2=res$index2, group=res$group, reference=res$reference, landmark=res$landmark)
}


sim <- function(res, n) {
	lfun = lapply(res$rnfun['r.timeSinceLastSpike'], mkSelf)
	trials = lapply(split(res$data, res$data$trial), function(x) x[, names(res$gss$mf)])
	fake = mapply(function(x) replicate(n, as.double(thinProcess(object=res$gss,
																 m2uFctList=lfun,
																 trueData=x,
																 formerSpikes=-600))), 
				  trials, SIMPLIFY=FALSE)
}

read_rdata <- function(file) {
	r_data <- load(file)
	x <- get(r_data)
	return(x)
}


args <- commandArgs(trailingOnly = TRUE)
inpath = paste(args[1], "out", "data", sep="/")

inpath = "data/analyses/spline/batch-8/best-all/out/data/"
infiles <- list.files(path=inpath, pattern=".R", full.names=T, all.files=T)
simulations = lapply(infiles, sim.agg)


outpath = paste(args[1], "post-proc", "simulated.rds", sep="/")
outpath = "data/analyses/spline/batch-8/best-all/post-proc/simulated.rds"
saveRDS(simulations, outpath)
