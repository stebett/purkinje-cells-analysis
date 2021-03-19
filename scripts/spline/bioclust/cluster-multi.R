library(gss)

args <- commandArgs(trailingOnly = TRUE)

load(args[1])

gsaS = gssanova(event ~ r.timeSinceLastSpike + time, data=df_neigh[[1]]$data,family='binomial')
# gsaC = gssanova(event ~ r.timeSinceLastSpike + timetoevt + r.nearest, data=df$data,family='binomial')

save(c(S=gsaS, C=gsaC), file=args[2])
