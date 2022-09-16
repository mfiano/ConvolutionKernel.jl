export Cell

struct Cell{D}
    x::Int
    y::Int
    data::D
end

function Base.show(io::IO, obj::Cell)
    type = obj |> typeof
    (; x, y) = obj
    if haskey(io, :typeinfo)
        print(io, "Cell($x, $y)")
    else
        data = obj.data
        print(io, "$type($x, $y):\n")
        for f in data |> typeof |> fieldnames
            println(io, " $(f) => ", getfield(data, f))
        end
    end
end

function Base.getproperty(value::Cell, name::Symbol)
    if !in(name, (:x, :y, :data))
        value = getfield(value, :data)
    end
    getfield(value, name)
end

function Base.setproperty!(value::Cell, name::Symbol, x)
    if !in(name, (:x, :y, :data))
        value = getfield(value, :data)
    end
    setfield!(value, name, x)
end
