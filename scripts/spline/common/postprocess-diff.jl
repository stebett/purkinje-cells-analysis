using DrWatson
@quickactivate :ens

using DataFrames
using Arrow


inpath = "$(ARGS[1])results/result.arrow"
diffpath = "$(ARGS[2])results/result.arrow"

part_1 = Arrow.Table(inpath) |> DataFrame
part_2 = Arrow.Table(diffpath) |> DataFrame

new_df = vcat(part_1, part_2)

Arrow.write(inpath, new_df)
