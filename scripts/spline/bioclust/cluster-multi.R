library(gss)

args <- commandArgs(trailingOnly = TRUE)

load(args[1])

result_multi_neigh = sapply(multi_dist[[1:3]], function(x)
  c(S = gssanova(event ~ r.timeSinceLastSpike + time, data=x$data,family='binomial'),
    C = gssanova(event ~ r.timeSinceLastSpike + timetoevt + r.nearest, data=x$data,family='binomial'))
)

save(result_multi_neigh, file=args[2])