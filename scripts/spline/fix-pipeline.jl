using DrWatson
@quickactivate :ens

include(srcdir("spline", "spline-pipeline.jl"))
index = [63, 64]
data = load_data("data-v6.arrow");


cellpair = find(data, index);

# fitted = fitcell(couple, reference=:multi)

timevar = "timetoevt"
d = Dict()

df = mkdf(cellpair, reference=:multi)
df_u = R"uniformizedf($df, c('timeSinceLastSpike','previousIsi','tback','tforw','nearest'))"

formula = "event ~ r.timeSinceLastSpike + $timevar + r.nearest"
gsaC = R"gssanova(as.formula($formula), data=$df_u$data,family='binomial')"

R"""
plot.gss($gsaC, parm='r.nearest', inv.rnfun=$df_u$inv.rnfun)
dev.copy(png,'plots/logbook/24-03/R-plots/63-64-julia.png')
dev.off()
"""

d[:c_isi] = quickPredict(df_u, gsaC, "r.timeSinceLastSpike")
d[:c_time] = quickPredict(df_u, gsaC, timevar)
d[:c_nearest] = quickPredict(df_u, gsaC, "r.nearest")
d
