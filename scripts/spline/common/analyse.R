library(gss)
library(STAR)

args <- commandArgs(trailingOnly = TRUE)

path <- args[1]
reference <- args[2]
group <- args[3]
index <- args[4]

input = read.csv(paste(path, "in", reference, group, index, sep="/"))



rnparm=c('timeSinceLastSpike','previousIsi')
if (group != "all") {
	rnparm <- c(rnparm, 'nearest')
}

rnparmName= paste('r',rnparm,sep='.')

rnfun=lapply(rnparm,function(x) mkM2U(input,x))
names(rnfun)=rnparmName
inv.rnfun=lapply(rnfun, function(x) attributes(x)$qFct) #save

res=mapply(function(c,f) f(input[[c]]), rnparm,rnfun)
colnames(res)=rnparmName
data=cbind(input,res) 

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

gss = gssanova(formula, data=data, family="binomial", alpha=1)

index_val = gsub("(.csv)", "", index)

result = list(index=index, group=group, reference=reference, inv.rnfun=inv.rnfun, rnfun=rnfun, data=data, gss=gss)

filename = paste(paste(path, "out", "data", index_val, sep="/"), "RData", sep=".")

save(file=filename, result)
