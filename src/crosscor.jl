@inline function crosscor_c(df, c, active_c::Dict, binsize, norm=true) 
	@warn "redo!"
	r = zeros(81, length(c))
	lags = -40. * binsize : binsize : 40. * binsize
	@inbounds for i = eachindex(c)
		c1 = abscut(df[df.index .== c[i][1], :t]..., active_c[c[i]]) 
		c2 = abscut(df[df.index .== c[i][2], :t]..., active_c[c[i]])
		crosscor!(view(r, :, i), c1, c2, lags, norm, binsize=binsize)
	end
	r
end

@inline function crosscor_c(df, c, around::Vector, binsize, norm=true) 
	@warn "redo!"
	r = zeros(81, length(c))
	lags = -40. * binsize : binsize : 40. * binsize
	@inbounds for i = eachindex(c)
		c1 = abscut(df[df.index .== c[i][1], :t]..., df[df.index .== c[i][1], :cover]..., around) 
		c2 = abscut(df[df.index .== c[i][2], :t]..., df[df.index .== c[i][2], :cover]..., around)
		crosscor!(view(r, :, i), c1, c2, lags, norm, binsize=binsize)
	end
	r
end
