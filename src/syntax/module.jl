module Syntax

using Reexport

include("Scopes.jl")
include("ExprInterop.jl")
include("GATs.jl")
include("Presentations.jl")
include("TheoryInterface.jl")
include("TheoryMaps.jl")

@reexport using .Scopes
@reexport using .ExprInterop
@reexport using .GATs
@reexport using .Presentations
@reexport using .TheoryInterface
@reexport using .TheoryMaps

end
