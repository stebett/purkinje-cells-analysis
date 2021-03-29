library(gss)

args <- commandArgs(trailingOnly = TRUE)

source(args[1])
source("/home/ginko/ens/data/analyses/spline/cluster-inputs-2/prova/c(49,47)-dist-best.R")

load(uniformpath)

time = "time"
if (reference == "multi") {
	time = "timetoevt"
}
indep = c("r.timeSinceLastSpike", time)
if (group != "all") {
	indep <- c(indep, 'r.nearest')
}

dep = "event"
formula = as.formula(paste("event ~",  paste(indep, collapse= "+")))

gss = gssanova(formula, data=uniformized_df$data, family="binomial", alpha=1)

result = list(index=index, group=group, reference=reference, inv.rnfun=uniformized_df$inv.rnfun, rnfun=uniformized_df$rnfun, data=uniformized_df$data, gss=gss)

filename = sapply(strsplit(uniformpath, split="[/]"), tail, 1)

path = paste(args[2], filename, sep="/")

save(file=path, result)
