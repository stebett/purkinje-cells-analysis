using DrWatson
@quickactivate "ens"

using DataFrames

function get_neighbors(df::DataFrame, idx)
    rat = data[idx, :].rat
    site = data[idx, :].site
    tetrode = data[idx, :].tetrode

    findall((df.rat .== rat) .& (df.site .== site) .& (df.tetrode .== tetrode))
end