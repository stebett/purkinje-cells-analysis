function find(df::DataFrame, index::Int, column=Colon())
	df[df.index .== index, column]
end

function find(df::DataFrame, index::Vector, column=Colon())
	if df.index[1] isa Vector 
		return df[df.index .== Ref(index), column]
	end
	df[in.(df.index, Ref(index)), column]
end
