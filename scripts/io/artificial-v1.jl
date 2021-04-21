using DrWatson
@quickactivate :ens

using DataFrames
using Arrow
using Distributions
using Random

data = load_data(:last) 

df = similar(data[1:2, :])

Random.seed!(42)
lambdas = rand(TruncatedNormal(20, 200, 0, 500), 300)
t1 = rand.(Poisson.(lambdas)) |> cumsum

t2 = t1 .- 1

lift = collect(1000:500:13000)
cover = collect(1100:500:13100)
grasp = collect(1200:500:13200)

df.rat = ["R", "R"]
df.site = ["site", "site"]
df.tetrode = ["tetrode", "tetrode"]
df.neuron = ["neuron1", "neuron2"]
df.t = [t1, t2]
df.lift = [lift, lift]
df.cover = [cover, cover]
df.grasp = [grasp, grasp]
df.index = [1, 2]
df.p_acorr = [0., 0.]

Arrow.write(datadir("processed/artificial-v1.arrow"), df)
