using DrWatson
@quickactivate :ens

using Spikes
using CSV
using DataFramesMeta
using Plots

#+ term=false
include(srcdir("spline", "mkdf.jl"))

data = load_data("data-v6.arrow") 
couple = @where(data, :rat .== "R17", :site .== "39", :tetrode .== "tet2")

df_j = mkdf(couple)
select!(df_j, Not(:timetoevt))

df_r = CSV.read(nbdir("spline", "R17-39-tet2-1-2.csv"), DataFrame)
select!(df_r, Not([:Column1, :ntrial, :neuron]))
select!(df_r, names(df_j));


#' ISI starts from 0 in target cell
#+ term=false
isi_j = @where(df_j, :trial .== 1, -500 .<= :time .<= 500)
isi_r = @where(df_r, :trial .== 1, -500 .<= :time .<= 500);

#' # Now in mkdf isi and timesincelastspike is ceiled
#' The problem appears fixed!
describe(isi_j)

#'
describe(isi_r)

#' No difference in fact
around = (isi_r.timeSinceLastSpike .<= 5) .| (isi_r.event .== 1)

comparison_isi = DataFrame()
comparison_isi.julia = isi_j.timeSinceLastSpike[around][1:20] |> Vector{Int}
comparison_isi.r = isi_r.timeSinceLastSpike[around][1:20] 
comparison_isi.spike = isi_r.event[around][1:20] 
comparison_isi


#' There is still some difference in nearest
around = (isi_r.nearest .<= 5)

comparison_nearest = DataFrame()
comparison_nearest.j = isi_j.nearest[around][1:20] |> Vector{Int}
comparison_nearest.r = isi_r.nearest[around][1:20] 
comparison_nearest

#' Let's check tforw
comparison_tforw = DataFrame()
comparison_tforw.j = isi_j.tforw[around][1:20] |> Vector{Int}
comparison_tforw.r = isi_r.tforw[around][1:20] 
comparison_tforw

#' Let's check tback
#' tback is one bin back in my implementation, let's fix
comparison_tback = DataFrame()
comparison_tback.j = isi_j.tback[around][1:20] |> Vector{Int}
comparison_tback.r = isi_r.tback[around][1:20] 
comparison_tback

#' Fixed! The idea is that for the cell target cell we want the isi to start from 1, while for the other cell it should start from 0 
isi_j == isi_r
