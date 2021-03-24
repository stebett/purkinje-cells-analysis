function find(df::DataFrame, index::Int, column=Colon())
	df[df.index .== index, column]
end

function find(df::DataFrame, index::Vector, column=Colon())
	df[in.(df.index, Ref(index)), column]
end
