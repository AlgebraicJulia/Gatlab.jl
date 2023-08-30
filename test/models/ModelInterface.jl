module TestModelInterface 

using Gatlab
using Test

struct FinSetC <: Model{Tuple{Int, Vector{Int}}}
end

@instance ThCategory{Int, Vector{Int}} (;model::FinSetC) begin
  Hom(f::Vector{Int}, n::Int, m::Int) = # check f is Hom: n -> m
     length(f) == n && all(1 <= y <= m for y in f) 

  id(m::Int) = collect(1:m)
  compose(f::Vector{Int}, g::Vector{Int}) = g[f]

  dom(f::Vector{Int}) = length(f)
end

@test ThCategory.Ob(-1; model=FinSetC()) # Yikes!
@test ThCategory.Hom([1,2,3], 3, 3; model=FinSetC())
@test !ThCategory.Hom([1,2,3], 3, 2; model=FinSetC())
@test !ThCategory.Hom([1,2,3], 2, 3; model=FinSetC())
@test ThCategory.compose([1,3,2], [1,3,2]; model=FinSetC()) == [1,2,3]

@test ThCategory.id(2; model=FinSetC()) == [1,2]

@test ThCategory.dom([1,2,3]; model=FinSetC()) == 3
@test_throws ErrorException ThCategory.codom([1,2,3]; model=FinSetC())

@test implements(FinSetC(), ThCategory)

# Todo: get things working where Ob and Hom are the same type (i.e. binding dict not monic)
struct TypedFinSetC <: Model{Tuple{Vector{Int}, Vector{Int}}}
  ntypes::Int
end

@instance ThStrictMonCat{Int, Vector{Int}} (;model::FinSetC) begin
  @import Ob, Hom, id, compose, dom, codom

  mcompose(a::Int, b::Int) = a + b
  mcompose(f::Vector{Int}, g::Vector{Int}; context) = [f; g .+ context.B₁]

  munit() = 0
end

@test implements(FinSetC(), ThStrictMonCat)

using .ThStrictMonCat

@test mcompose(id(2; model=FinSetC()), id(2; model=FinSetC()); context=(;B₁=2), model=FinSetC()) ==
  id(4; model=FinSetC())

end # module