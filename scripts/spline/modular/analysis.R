library(gss)

args <- commandArgs(trailingOnly = TRUE)

source(args[1])

load(clusterpath)

time = "time"
if (reference == "multi") {
	time = "timetoevt"
}
indep = c("r.timeSinceLastSpike", time)
if (group != "all") {
	indep <- c(indep, 'r.nearest')
}

formula = as.formula(paste("event ~",  paste(indep, collapse= "+")))
gss = gssanova(formula, data=uniformized_df$data, family="binomial", alpha=alpha)

result = list(index1=index1, 
			  index2=index2,
			  group=group,
			  reference=reference,
			  landmark=landmark,
			  inv.rnfun=uniformized_df$inv.rnfun,
			  rnfun=uniformized_df$rnfun,
			  data=uniformized_df$data,
			  gss=gss)


save(file=resultpath, result)
