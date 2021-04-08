library(STAR)


inpath = "/home/ginko/ens/data/analyses/spline/batch-7/out/data"
infiles <- list.files(path=inpath, pattern=".R", full.names=T, all.files=T)

simulations = lapply(infiles, sim.agg)

saveRDS(simulations, "data/analyses/spline/batch-7/results/simulations-simple.rds")


sim.agg <- function(file, n=2) {
	res = read_rdata(file)
	sims = list()
	if (res$group == 'all') {
		if (res$reference == 'best') {
			sims = tryCatch(sim(res, n), error=function(e) e)
		}
	}
	list(fake=sims, index=res$index, group=res$group, reference=res$reference)
}

sim.agg <- function(file, n=2) {
	res = read_rdata(file)
	sims = list()
	if (res$group != 'all') {
		if (res$reference == 'best') {
			sims = sim(res, n)
		}
	}
	list(fake=sims, index=res$index, group=res$group, reference=res$reference)
}

sim <- function(res, n) {
	lfun = lapply(res$rnfun['r.timeSinceLastSpike'], mkSelf)
	trials = lapply(split(res$data, res$data$trial), function(x) x[, names(res$gss$mf)])
	fake = mapply(function(x) replicate(n, as.double(thinProcess(object=res$gss,
																 m2uFctList=lfun,
																 trueData=x,
																 # TODO: probably fix 
																 formerSpikes=-600))), 
				  trials, SIMPLIFY=FALSE)
}

read_rdata <- function(file) {
	r_data <- load(file)
	x <- get(r_data)
	return(x)
}


#for debugging
thinProcess <- 
	function (object, m2uFctList, trueData, formerSpikes, intensityMax, 
			  ...) 
	{
		if (!inherits(object, c("ssanova", "ssanova0"))) 
			stop("object should be a ssanova or a ssanova0 object.")
		if (is.null(names(m2uFctList))) 
			stop("m2uFctList should be a NAMED list of functions.")
		if (!all(sapply(m2uFctList, function(f) inherits(f, "function")))) 
			stop("m2uFctList should be a named list of FUNCTIONS.")
		family4fit <- object[["call"]][["family"]]
		if (!(family4fit %in% c("binomial", "poisson"))) 
			stop("The fit should have been done with the binomial or the poisson family.")
		mf <- object[["mf"]]
		allVN <- names(mf)[names(mf) %in% object[["terms"]][["labels"]]]
		nVar <- length(allVN)
		varVN <- allVN[allVN %in% names(m2uFctList)]
		binWidth <- with(trueData, diff(time)[1])
		nbPrev <- dim(mf)[1]
		df0 <- mf[nbPrev, allVN]
		IFct <- switch(family4fit, binomial = function(df = df0) {
						   pred <- exp(predict(object, df))
						   pred/(1 + pred)/binWidth
			  }, poisson = function(df = df0) {
				  exp(predict(object, df))/binWidth
			  })
		if (missing(intensityMax)) {
			intensityMax <- maxIntensity(object, trueData, ...)
		}
		else {
			if (intensityMax <= 0) 
				stop("intensityMax must be > 0.")
		}
		from <- with(trueData, range(time))
		to <- from[2]
		from <- from[1]
		n2sim <- (to - from) * intensityMax
		n2sim <- ceiling(n2sim + 3 * sqrt(n2sim))
		pProc <- from + cumsum(rexp(n2sim, intensityMax))
		while (max(pProc) < to) {
			pProc <- c(pProc, max(pProc) + cumsum(rexp(n2sim, intensityMax)))
		}
		pProc <- pProc[pProc <= to]
		st <- formerSpikes
		stLength <- length(st)
		for (poissonTime in pProc) {
			vVector <- sapply(m2uFctList, function(f) f(poissonTime, 
														st))
			dfIdx <- (poissonTime - from)%/%binWidth + 1
			theDF <- trueData[dfIdx, ]
			theDF[, varVN] <- vVector
			intensity <- IFct(theDF)
			if (intensity > intensityMax) {
				#            result <- list(IFct = IFct, targetFct = targetFct, 
				#                posMax = posMax, intensityMax = intensityMax)
				warning("intensityMax not large enough.")
				#            return(result)
			}
			if (runif(1, 0, intensityMax) <= intensity) {
				st <- c(st, poissonTime)
			}
		}
		as.spikeTrain(st[-(1:stLength)])
	}
