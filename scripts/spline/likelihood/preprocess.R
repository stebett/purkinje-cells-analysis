library(STAR)

args <- commandArgs(trailingOnly = TRUE)
path = paste(args[1], "in", "r.config/", sep="/")
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
	return(tryCatch(uniformize(file), error=function(e) file.remove(file)))
}

lapply(infiles , uniformize.ignore.errors)
