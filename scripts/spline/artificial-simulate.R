library(STAR)


sim.all <- function(file, n) {
	res = read_rdata(file)
	lfun = lapply(res$rnfun['r.timeSinceLastSpike'], mkSelf)
	trials = lapply(split(res$data, res$data$trial), function(x) x[, names(res$gss$mf)])

	fake = mapply(function(x) replicate(n, sim.catch(res$gss, lfun, x)), trials)

	list(fake=fake, index1=res$index1, index2=res$index2, group=res$group, reference=res$reference, landmark=res$landmark)
}

sim.catch <- function(gss, lfun, x) {
	tryCatch(as.double(thinProcess(object=gss, m2uFctList=lfun, trueData=x, formerSpikes=with(x, time[match(1, event)]))),
			 error = function(e) e)
}

sim.one <- function(gss, lfun, x) {
	as.double(thinProcess(object=gss, m2uFctList=lfun, trueData=x, formerSpikes=with(x, time[match(1, event)])))
}

read_rdata <- function(file) {
	r_data <- load(file)
	x <- get(r_data)
	return(x)
}

file = "data/analyses/spline/batch-8/best-neigh/out/data/134-136.RData"
res = read_rdata(file)
lfun = lapply(res$rnfun, mkSelf)[-2] 

x = data.frame(time=-600:599,
			   event = rep(c(0, 0, 1), times=200),
			   r.timeSinceLastSpike = rep(c(3, 2, 1), times=200),
			   r.nearest = rep(c(1, 0, 1), times=200))

fake = sim.one(res$gss, lfun, x)
fake


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
			result <- list(IFct = IFct, targetFct = targetFct,
						   posMax = posMax, intensityMax = intensityMax)
			warning("intensityMax not large enough.")
			return(result)
		}
		if (runif(1, 0, intensityMax) <= intensity) {
			st <- c(st, poissonTime)
		}
	}
	as.spikeTrain(st[-(1:stLength)])
}

