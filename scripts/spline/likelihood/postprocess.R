library(STAR)

args <- commandArgs(trailingOnly = TRUE)
inpath = paste(args[1], "in", "r.config", sep="/")
outpath = paste(args[1], "results", "postprocessed.RData", sep="/")

read_rdata <- function(file) {
	r_data <- load(file)
	x <- get(r_data)
	return(x)
}

check.equal <- function(c, s) {
	if (any(c$index != s$index)) {
		stop("Different indexes!")
	}
	if (c$group != s$group) {
		stop("Different groups!")
	}
	if (c$reference != s$reference) {
		stop("Different references!")
	}
}

predict.ignore.errors <- function(c1, s1, c2, s2){
	return(tryCatch(predict.ll(c1, s1, c2, s2), error=function(e) message(e)))
}

predict.ll <- function(file_c1, file_s1, file_c2, file_s2) {
	source(file_c1)
	result_c1 = read_rdata(respath)
	source(file_s1)
	result_s1 = read_rdata(respath)
	source(file_c2)
	result_c2 = read_rdata(respath)
	source(file_s2)
	result_s2 = read_rdata(respath)

	check.equal(result_c1, result_s1)
	check.equal(result_c2, result_s2)
	check.equal(result_c1, result_c2)

	c1 = predictLogProb(result_c1$gss, result_s2$data)
	c2 = predictLogProb(result_c2$gss, result_s1$data)
	s1 = predictLogProb(result_s1$gss, result_c2$data)
	s2 = predictLogProb(result_s2$gss, result_c1$data)

	return(list(ll_c1=c1, ll_s1=s1, ll_c2=c2, ll_s2=s2, n=result_c1$n, index=result_c1$index, group=result_c1$group, reference=result_c1$reference))
	}

infiles_c1 <- list.files(path=inpath, pattern="1-complex.R", full.names=T, all.files=T)
infiles_s1 <- list.files(path=inpath, pattern="1-simple.R", full.names=T, all.files=T)
infiles_c2 <- list.files(path=inpath, pattern="2-complex.R", full.names=T, all.files=T)
infiles_s2 <- list.files(path=inpath, pattern="2-simple.R", full.names=T, all.files=T)

predictions = mapply(predict.ignore.errors, infiles_c1, infiles_s1, infiles_c2, infiles_s2) 

save(predictions, file=outpath)
