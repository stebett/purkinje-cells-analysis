@inline function crosscor_c(df, c, active_c::Dict, binsize) 
	r = zeros(81, length(c))
	st_len = 0
	@inbounds for i = eachindex(c)
		c1 = abscut(df[df.index .== c[i][1], :t]..., active_c[c[i]]) 
		c2 = abscut(df[df.index .== c[i][2], :t]..., active_c[c[i]])
		st_len += length(c1) + length(c2)
		crosscor!(view(r, :, i), c1, c2, -20, 20, binsize)
	end
	r, st_len
end

@inline function crosscor_c(df, c, around::Vector, binsize, norm=true) 
	# r = zeros(81, length(c))

	r = zeros(81)
	for i in c
		c1 = abscut(find(df, i[1]).t, find(df, i[1]).cover, around) 
		c2 = abscut(find(df, i[2]).t, find(df, i[2]).cover, around) 
		r .+= sum(crosscor.(c1, c2, -20, 20, binsize))
		# crosscor!(view(r, :, i), c1, c2, -20, 20, binsize)
	end
	r
end
