export AbstractShape, in_shape, Rect, Ellipse, Plus, X

abstract type AbstractShape end

struct Rect <: AbstractShape end
struct Ellipse <: AbstractShape end
struct Plus <: AbstractShape end
struct X <: AbstractShape end

function in_shape() end
