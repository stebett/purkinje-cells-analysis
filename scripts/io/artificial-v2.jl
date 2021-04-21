using DrWatson
@quickactivate :ens

using DataFrames
using Arrow
using Distributions
using Random

data = load_data(:last) 

row = data[data.index .== 438, :]
df = vcat(row, row)

df[2, :t] = df[1, :t] .- 1
df[2, :neuron] = "neuron3"
df.index = [1, 2]

Arrow.write(datadir("processed/artificial-v2.arrow"), df)
