using Accessors: @set
using Transducers

import ConstructionBase: constructorof

export Kernel, kernel, align, focused, detect, convolve!

struct Kernel{S <: AbstractShape, CD}
    grid::Grid{CD}
    origin::NTuple{2, Int}
    extents::NTuple{2, Int}
end

function Base.show(io::IO, obj::Kernel{S}) where {S <: AbstractShape}
    type = obj |> typeof
    (x, y) = obj.origin
    (w, h) = obj.extents .* 2 .+ 1
    cells = count(Returns(true), obj)
    print(io, "$w×$h $type(:x => $x, :y => $y, :cells => $cells)")
end

constructorof(::Type{Kernel{S}}) where {S} = Kernel{S}

function kernel(
    ::Type{S},
    grid::G;
    origin=(0, 0),
    extents=(1, 1)
) where {CD, G <: Grid{CD}, S <: AbstractShape}
    Kernel{S, CD}(grid, origin, extents)
end

@inline in_shape(::Kernel{Rect}, x, y) = true
@inline in_shape(kernel::Kernel{Ellipse}, x, y) = sum((x, y) .^ 2 ./ kernel.extents .^ 2) ≤ 1
@inline in_shape(::Kernel{Plus}, x, y) = iszero(x) || iszero(y)
@inline in_shape(::Kernel{X}, x, y) = abs(x) == abs(y)
@inline _in_bounds(kernel, x, y) = checkbounds(Bool, kernel.grid, x, y)
@inline _map(f, kernel) = kernel |> Map(f)
@inline _filter(f, kernel) = kernel |> Filter(f)
@inline _count(f, kernel) = _filter(f, kernel) |> Count()

function Transducers.asfoldable(kernel::Kernel)
    origin = kernel.origin
    ex, ey = kernel.extents
    Iterators.product(-ex:ex, -ey:ey) |>
        Filter(pos -> _in_bounds(kernel, (pos .+ origin)...) && in_shape(kernel, pos...)) |>
        Map(pos -> @inbounds kernel.grid[(pos .+ origin)...])
end

function Base.iterate(k::Kernel)
    foldable = Transducers.asfoldable(k)
    res = iterate(foldable)
    isnothing(res) && return res
    x, s = res
    x, (foldable, s)
end

function Base.iterate(::Kernel, (foldable, s))
    res = iterate(foldable, s)
    isnothing(res) && return res
    x, s = res
    x, (foldable, s)
end

Base.IteratorSize(::Type{<:Kernel}) = Base.SizeUnknown()

align(kernel::Kernel, cell::Cell) = @set kernel.origin = (cell.x, cell.y)
focused(kernel::Kernel) = kernel.grid[kernel.origin...]

Base.map(f::F, kernel::Kernel) where {F} = _map(f, kernel) |> collect
Base.count(f::F, kernel::Kernel) where {F} = _count(f, kernel) |> foldxl(right, init=0)
Base.filter(f::F, kernel::Kernel) where {F} = _filter(f, kernel) |> collect

function detect(f::F, kernel::Kernel, count=1) where {F}
    _count(f, kernel) |> ReduceIf(i -> i == count) |> foldxl(right, init=0) |> ==(count)
end

function convolve!(f::F, kernel::Kernel, pred::P=Returns(true)) where {F, P}
    foreach(kernel.grid) do cell
        k = align(kernel, cell)
        pred(k) && f(k)
    end
end
