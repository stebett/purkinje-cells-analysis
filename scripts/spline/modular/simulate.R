library(STAR)
library(configr)

sim.all <- function(file, n) {
	res = read_rdata(file)
	lfun = lapply(res$rnfun, mkSelf)[1] 
	trials = lapply(split(res$data, res$data$trial), function(x) x[, names(res$gss$mf)])
	fake = lapply(trials, function(x) replicate(n, sim.catch(res$gss, lfun, x)))
	list(fake=fake, index1=res$index1, index2=res$index2, group=res$group, reference=res$reference, landmark=res$landmark)
}

sim.catch <- function(gss, lfun, x) {
	tryCatch(as.double(thinProcess(object=gss, m2uFctList=lfun, trueData=x, formerSpikes=with(x, time[match(1, event)]))),
			 error = function(e) list())
}

read_rdata <- function(file) {
	r_data <- load(file)
	x <- get(r_data)
	return(x)
}


# inpath = "data/analyses/spline/batch-artificial/best-neigh/out/data/" 

args <- commandArgs(trailingOnly = TRUE)
configpath = paste(args[1], "params.toml", sep="/")
inpath = paste(args[2], "out", "data", sep="/")
outpath = args[3]

config = read.config(file = configpath)
n_sims = config$mkdf$n_sims
infiles <- list.files(path=inpath, pattern=".R", full.names=T, all.files=T)
simulations = lapply(infiles, function(x) sim.all(x, n_sims))


# outpath = "data/analyses/spline/batch-8/best-neigh/post-proc/simulated.rds"
saveRDS(simulations, outpath)
