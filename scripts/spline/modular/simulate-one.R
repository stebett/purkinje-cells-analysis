library(STAR)

sim.all <- function(res, data, n=1) {
	lfun = lapply(res$rnfun, mkSelf)[1] 
	trials = lapply(split(data, data$trial), function(x) x[, names(res$gss$mf)])
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


# Manual arguments
inpath = "data/analyses/spline/batch-8/best-neigh/out/data/438-437.RData" 
outpath = "data/analyses/spline/batch-8/best-neigh/post-proc/simulated_438-437.rds"
n = 2

# Parsing
args <- commandArgs(trailingOnly = TRUE)
n = args[1]
inpath = args[2]
outpath = args[3]

# Simulate
res = read_rdata(inpath)
data = res$data
simulations = sim.all(res, data, n=n)

# Save
saveRDS(simulations, outpath)
