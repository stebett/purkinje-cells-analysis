library(STAR)

args <- commandArgs(trailingOnly = TRUE)
inpath = paste(args[1], "out", "data", sep="/")
outpath = paste(args[1], "results", "postprocessed.RData", sep="/")

read_rdata <- function(file) {
	r_data <- load(file)
	x <- get(r_data)
	return(x)
}

predict.one.var <- function(result, var) {
	pred = quickPredict(result$gss, var)

	x = pred$xx
	mean = pred$est.mean
	sd = pred$est.sd

	if (is.function(result$inv.rnfun[[var]])) {
		x = result$inv.rnfun[[var]](x)
	}

	return(list(x=x, mean=mean, sd=sd))
}

predict.one.result <- function(file) {
	result = read_rdata(file)
	time = "time"
	if (result$reference == "multi") {
		time = "timetoevt"
	}

	vars = c(time, "r.timeSinceLastSpike")
	if (result$group != "all") {
		vars <-c(vars, "r.nearest")
	}


	res = list(index=result$index, reference=result$reference, group=result$group)

	for (var in vars) {
		res[[var]] = predict.one.var(result, var)
		}
	return(res)
	}

infiles <- list.files(path=inpath, pattern=".R", full.names=T, all.files=T)

predictions = lapply(infiles, predict.one.result)

outpath = "~/ens/data/analyses/spline/batch-5/results/postprocessed.RData"
save(predictions, file=outpath)
