using DrWatson
@quickactivate :ens

using DataFrames
using Arrow

data = load_data(:last) 

df = similar(data[1:2, :])

t1 = collect(1:3:3001)
t2 = collect(0:3:3000)

lift = [1400, 1400, 1400]
cover = [1500, 1500, 1500]
grasp = [1600, 1600, 1600]

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
