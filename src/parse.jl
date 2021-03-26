import Base.parse

function Base.parse(::Type{T}, c::String; n::Int=2) where T<:Array{Int, 1}
	c[2:end-1] |> x->split(x, ", ") |> x->convert.(String, x) |> x->parse.(Int, x)
end

function Base.parse(::Type{T}, c::String; n::Int=2) where T<:Tuple{Int, Int}
	c[2:end-1] |> x->split(x, ", ") |> x->convert.(String, x) |> x->parse.(Int, x) |> Tuple	
end
