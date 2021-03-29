library(gss)

args <- commandArgs(trailingOnly = TRUE)

source(args[1])

load(uniformpath)

time = "time"
if (reference == "multi") {
	time = "timetoevt"
}
indep = c("r.timeSinceLastSpike", time)
if (group != "all") {
	indep <- c(indep, 'r.nearest')
}

formula = as.formula(paste("event ~",  paste(indep, collapse= "+")))
gss = gssanova(formula, data=uniformized_df$data, family="binomial", alpha=1)

result = list(index=index, 
			  group=group,
			  reference=reference,
			  inv.rnfun=uniformized_df$inv.rnfun,
			  rnfun=uniformized_df$rnfun,
			  data=uniformized_df$data,
			  gss=gss)


save(file=args[2], result)
