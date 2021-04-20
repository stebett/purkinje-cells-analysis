library(STAR)

path = "/home/ginko/ens/data/analyses/spline/batch-8/best-neigh/in/conf"
args <- commandArgs(trailingOnly = TRUE)
path = paste(args[1], "in", "conf", sep="/")
infiles <- list.files(path=path, pattern=".R", full.names=T, all.files=T)

uniformize <- function(file){
	source(file)
	input = read.csv(csvpath)
	rnparm=c('timeSinceLastSpike','previousIsi')
	if (group != "all") {
		rnparm <- c(rnparm, 'nearest')
	}

	rnparmName = paste('r',rnparm,sep='.')

	rnfun=lapply(rnparm,function(x) mkM2U(input,x))
	names(rnfun)=rnparmName
	inv.rnfun=lapply(rnfun, function(x) attributes(x)$qFct)

	res=mapply(function(c,f) f(input[[c]]), rnparm,rnfun)
	colnames(res)=rnparmName
	data=cbind(input,res) 

	uniformized_df = list(inv.rnfun=inv.rnfun, rnfun=rnfun, data=data)

	save(file=uniformpath, uniformized_df, version=2)
}

uniformize.ignore.errors <- function(file){
	return(tryCatch(uniformize(file), error=function(e) message(e)))
}

lapply(infiles , uniformize.ignore.errors)

#### debug
function (df, vN, low, high, delta, alpha = 2, ...)
{
	ii <- df[[vN]]
	if (missing(low))
		low <- min(df$time)
	if (missing(high))
		high <- max(df$time)
	if (missing(delta)) {
		iii <- sort(diff(sort(unique(ii))))
		delta <- min(iii[iii >= diff(range(iii))/1000])
		rm(iii)
	}
	iiD <- c(min(df[[vN]]) - .Machine$double.eps, max(df[[vN]]) +
			 .Machine$double.eps)
	iiRef <- ii[low <= df$time & df$time <= high]
	rm(df, ii, low, high)
	iiB <- seq(iiD[1], iiD[2] + delta, delta)
	iiH <- as.data.frame(hist(iiRef, breaks = iiB, plot = FALSE)[c("mids",
																   "counts")])
	names(iiH) <- c("x", "counts")
	riiD <- range(iiH$x) + delta * c(-1, 1)/2
	ii.fit <- ssden(~x, data = iiH, domain = data.frame(x = riiD),
					weights = iiH$counts, alpha = alpha, ...)
	rm(iiH, iiB, iiRef, iiD)
	mn <- min(ii.fit$domain)
	mx <- max(ii.fit$domain)
	Z <- integrate(function(x) dssden(ii.fit, x), mn, mx, subdivisions = 1000)$value
	dFct <- function(x) {
		result <- numeric(length(x))
		good <- mn <= x & x <= mx
		if (any(good))
			result[good] <- dssden(ii.fit, x[good])/Z
		result

	}}

function (formula, type = NULL, data = list(), alpha = 1.4, weights = NULL,
		 subset, na.action = na.omit, id.basis = NULL, nbasis = NULL,
		 seed = NULL, domain = as.list(NULL), quad = NULL, qdsz.depth = NULL,
		 bias = NULL, prec = 1e-07, maxiter = 30, skip.iter = FALSE)
{
	mf <- match.call()
	mf$type <- mf$alpha <- NULL
	mf$id.basis <- mf$nbasis <- mf$seed <- NULL
	mf$domain <- mf$quad <- mf$qdsz.depth <- mf$bias <- NULL
	mf$prec <- mf$maxiter <- mf$skip.iter <- NULL
	mf[[1]] <- as.name("model.frame")
	mf <- eval(mf, parent.frame())
	cnt <- model.weights(mf)
	mf$"(weights)" <- NULL
	nobs <- dim(mf)[1]
	if (is.null(id.basis)) {
		if (is.null(nbasis))
			nbasis <- max(30, ceiling(10 * nobs^(2/9)))
		if (nbasis >= nobs)
			nbasis <- nobs
		if (!is.null(seed))
			set.seed(seed)
		id.basis <- sample(nobs, nbasis, prob = cnt)
	}
	else {
		if (max(id.basis) > nobs | min(id.basis) < 1)
			stop("gss error in ssden: id.basis out of range")
		nbasis <- length(id.basis)
	}
	if (is.null(quad)) {
		fac.list <- NULL
		for (xlab in names(mf)) {
			x <- mf[[xlab]]
			if (is.factor(x)) {
				fac.list <- c(fac.list, xlab)
				domain[[xlab]] <- NULL
			}
			else {
				if (!is.vector(x))
					stop("gss error in ssden: no default quadrature")
				if (is.null(domain[[xlab]])) {
					mn <- min(x)
					mx <- max(x)
					domain[[xlab]] <- c(mn, mx) + c(-1, 1) * (mx -
															  mn) * 0.05
				}
				else domain[[xlab]] <- c(min(domain[[xlab]]),
										 max(domain[[xlab]]))
				if (is.null(type[[xlab]]))
					type[[xlab]] <- list("cubic", domain[[xlab]])
				else {
					if (length(type[[xlab]]) == 1)
						type[[xlab]] <- list(type[[xlab]][[1]], domain[[xlab]])
				}
			}
		}
		domain <- data.frame(domain)
		mn <- domain[1, ]
		mx <- domain[2, ]
		dm <- ncol(domain)
		if (dm == 1) {
			xlab <- names(domain)
			if (type[[xlab]][[1]] %in% c("per", "cubic.per",
										 "linear.per")) {
				quad <- list(pt = mn + (1:200)/200 * (mx - mn),
							 wt = rep((mx - mn)/200, 200))
			}
		else quad <- gauss.quad(200, c(mn, mx))
		quad$pt <- data.frame(quad$pt)
		colnames(quad$pt) <- colnames(domain)
		}
		else {
			if (is.null(qdsz.depth))
				qdsz.depth <- switch(min(dm, 6) - 1, 18, 14,
									 12, 11, 10)
			quad <- smolyak.quad(dm, qdsz.depth)
			for (i in 1:ncol(domain)) {
				xlab <- colnames(domain)[i]
				form <- as.formula(paste("~", xlab))
				jk <- ssden(form, data = mf, domain = domain[i],
							alpha = 2, id.basis = id.basis, weights = cnt)
				quad$pt[, i] <- qssden(jk, quad$pt[, i])
				quad$wt <- quad$wt/dssden(jk, quad$pt[, i])
			}
			jk <- NULL
			quad$pt <- data.frame(quad$pt)
			colnames(quad$pt) <- colnames(domain)
		}
		if (!is.null(fac.list)) {
			for (i in 1:length(fac.list)) {
				wk <- expand.grid(levels(mf[[fac.list[i]]]),
								  1:length(quad$wt))
				quad$wt <- quad$wt[wk[, 2]]
				col.names <- c(fac.list[i], colnames(quad$pt))
				quad$pt <- data.frame(wk[, 1], quad$pt[wk[, 2],
									  ], stringsAsFactors = TRUE)
				colnames(quad$pt) <- col.names
			}
		}
		quad <- list(pt = quad$pt, wt = quad$wt)
	}
	else {
		for (xlab in names(mf)) {
			x <- mf[[xlab]]
			if (is.vector(x) & !is.factor(x)) {
				if (is.null(range <- domain[[xlab]])) {
					mn <- min(x)
					mx <- max(x)
					range <- c(mn, mx) + c(-1, 1) * (mx - mn) *
						0.05
					range[1] <- min(c(range[1], quad$pt[[xlab]]))
					range[2] <- max(c(range[2], quad$pt[[xlab]]))
				}
				if (is.null(type[[xlab]]))
					type[[xlab]] <- list("cubic", range)
				else {
					if (length(type[[xlab]]) == 1)
						type[[xlab]] <- list(type[[xlab]][[1]], range)
					else {
						mn0 <- min(type[[xlab]][[2]])
						mx0 <- max(type[[xlab]][[2]])
						if ((mn0 > mn) | (mx0 < mx))
							stop("gss error in ssden: range not covering domain")
					}
				}
			}
		}
	}
	term <- mkterm(mf, type)
	term$labels <- term$labels[term$labels != "1"]
	qd.pt <- quad$pt
	qd.wt <- quad$wt
	nmesh <- length(qd.wt)
	if (is.null(bias)) {
		nt <- b.wt <- 1
		t.wt <- matrix(1, nmesh, 1)
		bias0 <- list(nt = nt, wt = b.wt, qd.wt = t.wt)
	}
	else {
		if ((nt <- length(bias$t)) - length(bias$wt))
			stop("gss error in ssden: bias$t and bias$wt mismatch in size")
		b.wt <- abs(bias$wt)/sum(abs(bias$wt))
		t.wt <- NULL
		for (i in 1:nt) t.wt <- cbind(t.wt, bias$fun(bias$t[i],
													 qd.pt))
		bias0 <- list(nt = nt, wt = b.wt, qd.wt = t.wt)
	}
	s <- qd.s <- r <- qd.r <- NULL
	nq <- 0
	for (label in term$labels) {
		x <- mf[, term[[label]]$vlist]
		x.basis <- mf[id.basis, term[[label]]$vlist]
		qd.x <- qd.pt[, term[[label]]$vlist]
		nphi <- term[[label]]$nphi
		nrk <- term[[label]]$nrk
		if (nphi) {
			phi <- term[[label]]$phi
			for (i in 1:nphi) {
				s <- cbind(s, phi$fun(x, nu = i, env = phi$env))
				qd.s <- cbind(qd.s, phi$fun(qd.x, nu = i, env = phi$env))
			}
		}
		if (nrk) {
			rk <- term[[label]]$rk
			for (i in 1:nrk) {
				nq <- nq + 1
				r <- array(c(r, rk$fun(x.basis, x, nu = i, env = rk$env,
									   out = TRUE)), c(nbasis, nobs, nq))
				qd.r <- array(c(qd.r, rk$fun(x.basis, qd.x, nu = i,
											 env = rk$env, out = TRUE)), c(nbasis, nmesh,
								nq))
			}
		}
	}
	if (!is.null(s)) {
		nnull <- dim(s)[2]
		if (qr(s)$rank < nnull)
			stop("gss error in ssden: unpenalized terms are linearly dependent")
		s <- t(s)
		qd.s <- t(qd.s)
	}
	if (nq == 1) {
		r <- r[, , 1]
		qd.r <- qd.r[, , 1]
		z <- sspdsty(s, r, r[, id.basis], cnt, qd.s, qd.r, qd.wt,
					 prec, maxiter, alpha, bias0)
	}
	else z <- mspdsty(s, r, id.basis, cnt, qd.s, qd.r, qd.wt,
					  prec, maxiter, alpha, bias0, skip.iter)
	desc <- NULL
	for (label in term$labels) desc <- rbind(desc, as.numeric(c(term[[label]][c("nphi",
																				"nrk")])))
	desc <- rbind(desc, apply(desc, 2, sum))
	rownames(desc) <- c(term$labels, "total")
	colnames(desc) <- c("Unpenalized", "Penalized")
	obj <- c(list(call = match.call(), mf = mf, cnt = cnt, terms = term,
				  desc = desc, alpha = alpha, domain = domain, quad = quad,
				  id.basis = id.basis, qdsz.depth = qdsz.depth, bias = bias0,
				  skip.iter = skip.iter), z)
	class(obj) <- "ssden"
	obj
}

