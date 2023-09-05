module Presentations
export Presentation

using ...Util
using ..Scopes, ..GATs, ..ExprInterop
using StructEquality 

"""
A presentation has a set of generators, given by a `TypeScope`, and a set of 
equations among terms which can refer to those generators. Each element of 
`eqs` is a list of terms which are asserted to be equal.
"""
@struct_hash_equal struct Presentation <: HasContext
  theory::GAT
  scope::TypeScope
  eqs::Vector{Vector{AlgTerm}}
  function Presentation(gat, scope, eqs=[])
    gatscope = AppendScope(gat, scope)
    # scope terms must be defined in GAT 
    sortcheck.(Ref(gatscope), getvalue.(scope))
    # eq terms must be defined in GAT ++ scope
    for eq in eqs 
      length(eq) > 1 || error("At least two things must be equated")
      sortcheck.(Ref(gatscope), eq)
    end
    new(gat, scope, collect.(eqs))
  end
end

Scopes.getcontext(p::Presentation) = AppendScope(p.theory, p.scope)

"""Context of presentation is the underlying GAT"""
ExprInterop.toexpr(p::Presentation) = toexpr(p.theory, p)

function ExprInterop.toexpr(c::Context, p::Presentation)
  c == p.theory || error("Invalid context for presentation")
  decs = GATs.bindingexprs(c, p.scope)
  eqs = map(p.eqs) do ts
    exprs = zip(toexpr.(Ref(p), ts),Iterators.repeated(:(==)))
    Expr(:comparison, collect(Iterators.flatten(exprs))[1:(end-1)]...)
  end
  Expr(:block, [decs..., eqs...]...)
end

"""
Parse, e.g.:

```
(a,b,c)::Ob
f::Hom(a, b)
g::Hom(b, c)
h::Hom(a, c)
h′::Hom(a, c)
compose(f, g) == h == h′
```
"""
function ExprInterop.fromexpr(ctx::Context, e, ::Type{Presentation})
  e.head == :block || error("expected a block to parse into a GATSegment, got: $e")
  scopelines, eqlines = Expr0[], Vector{Expr0}[]
  for line in e.args
    if line.head == :(==)
      push!(eqlines, line.args)
    elseif line.head == :comparison
      er = "Bad comparison: $line"
      all(((i,v),)-> iseven(i) == (v == :(==)), enumerate(line.args)) || error(er)
      push!(eqlines, line.args[1:2:end])
    else
      push!(scopelines, line)
    end
  end
  scope = GATs.parsetypescope(ctx, scopelines)
  apscope = AppendScope(ctx, scope)
  Presentation(ctx, scope, [fromexpr.(Ref(apscope), ts, AlgTerm) for ts in eqlines])
end

end # module 