function minmax_scale(x::Vector)
	min, max = extrema(x)
	@. (x - min) / (max-min)
end
