using DrWatson
@quickactivate :ens

using Arrow
using RCall

include(srcdir("spline-pipeline.jl"))

data = load_data("data-v6.arrow"); # TODO change to v6

cells = readlines(datadir("cell-pairs.txt"))
x = [[cells[i], cells[i+1]] for i in 1:2:length(cells)]
cellpairs = make_couples.(x);


d1df = mkdf(sort(cellpairs[1]))
d2df = mkdf(sort(cellpairs[1], rev=true))

Arrow.write("data/spline-d1df-cell1.arrow", d1df)
Arrow.write("/export/home1/users/nbc/bettani/spline/spline-d1df-cell1.arrow", d1df)

