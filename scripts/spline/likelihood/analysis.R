library(gss)

args <- commandArgs(trailingOnly = TRUE)

source(args[1])

load(clusterpath)

time = "time"
if (reference == "multi") {
	time = "timetoevt"
}

indep = c("r.timeSinceLastSpike", time)
if (model == "complex") {
	indep <- c(indep, 'r.nearest')
}

formula = as.formula(paste("event ~",  paste(indep, collapse= "+")))
gss = gssanova(formula, data=uniformized_df$data, family="binomial", alpha=1)

result = list(index=index, 
			  n=n,
			  model=model,
			  group=group,
			  reference=reference,
			  inv.rnfun=uniformized_df$inv.rnfun,
			  rnfun=uniformized_df$rnfun,
			  data=uniformized_df$data,
			  gss=gss)

filename = lapply(strsplit(args[1], split="/"), tail, 1)
outpath = paste("out", "data", filename, sep="/")
print(outpath)

save(file=outpath, result)
