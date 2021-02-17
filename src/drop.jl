using DrWatson
@quickactivate "ens"


function drop(v::Matrix; dims=1, nan=true, inf=true, outliers=false, threshold=3.5)
	todrop = falses(size(v, dims % 2 + 1))
	if nan
		todrop .|= sum(isnan.(v), dims=dims)[:] .!= 0
	end

	if inf
		todrop .|= sum(isinf.(v), dims=dims)[:] .!= 0
	end

	if outliers
		todrop .|= sum(v .> threshold, dims=dims)[:] .!= 0
	end

	v[:, .!todrop]
end

function drop(v::Vector; nan=true, inf=true, outliers=false, threshold=3.5)
	todrop = falses(size(v))
	if nan
		todrop .|= isnan.(v) .!= 0
	end

	if inf
		todrop .|= isinf.(v) .!= 0
	end

	if outliers
		todrop .|= v .> threshold .!= 0
	end

	v[.!todrop]
end
