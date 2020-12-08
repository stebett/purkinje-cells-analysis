using DrWatson
@quickactivate "ens"

include(scriptsdir("load-data.jl"))
include(srcdir("spike-tools.jl"))

using Statistics
using MultivariateStats

stdcover = standardize_landmarks(data.cover)
stdlift = standardize_landmarks(data.lift)
speeds = stdcover - stdlift
speeds = replace(speeds, NaN => 0.)
speeds[speeds .> 1000.] .= 0.
y = speeds[speeds .> 0]
stdlift[speeds .<= 0.] .= -1
stdcover[speeds .<= 0.] .= -1

X = normalize(data.t, stdcover, (-500, 500), (-5000, 5000), false)
X, new_idx = dropnancols(X)
y = speeds[speeds .> 0]
y = y[new_idx]

a = ridge(X', y, 1, bias=false)

# do prediction
yp = X' * a

# measure the error
rmse = sqrt(mean((y - yp).^2))
@show rmse
