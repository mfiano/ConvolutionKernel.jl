export grid

struct Grid{CD} <: AbstractMatrix{Cell{CD}}
    cells::Matrix{Cell{CD}}
end

Base.size(A::Grid) = size(A.cells)
Base.IndexStyle(::Type{<:Grid}) = IndexCartesian()

Base.@propagate_inbounds function Base.getindex(A::Grid, x, y)
    @boundscheck checkbounds(A.cells, x, y)
    A.cells[x, y]
end

function grid(f::F, w::T, h::T) where {F, T <: Int}
    Grid([Cell(x, y, f(x, y)) for x ∈ 1:w, y ∈ 1:h])
end
