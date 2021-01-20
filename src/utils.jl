using DrWatson
@quickactivate "ens"

function skipnan(v::AbstractArray)
    v[.!isnan.(v)]
end

function dropinfcols(v::AbstractArray; idx=false)
	nancols = isinf.(v[1, :])

	new_idx = zeros(Int, sum(.!nancols))
	k = 0
	for i = 1:length(nancols)
		if nancols[i] == false
			new_idx[i-k] = i
		else
			k += 1
		end
	end
	if idx 
		return v[:, .!nancols], new_idx
	end
	v[:, .!nancols]
end

function dropnancols(v::AbstractArray; idx=false)
	nancols = isnan.(v[1, :])

	new_idx = zeros(Int, sum(.!nancols))
	k = 0
	for i = 1:length(nancols)
		if nancols[i] == false
			new_idx[i-k] = i
		else
			k += 1
		end
	end
	if idx 
		return v[:, .!nancols], new_idx
	end
	v[:, .!nancols]
end
