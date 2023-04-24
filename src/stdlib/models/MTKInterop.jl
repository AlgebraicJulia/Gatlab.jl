module MTKInterop

using ModelingToolkit

using ....Models
using ....Dsl
using ...StdTheories

using ..ContextMaps
using ..SimpleLenses

module Impl

zero() = 0

one() = 1

-(x) = Base.:(-)(x)

+(x,y) = Base.:(+)(x,y)

*(x,y) = Base.:(*)(x,y)

sin(x) = Base.sin(x)

cos(x) = Base.cos(x)

tan(x) = Base.tan(x)

exp(x) = Base.exp(x)

sigmoid(x) = 1 / (1 + exp(-x))

end

@simple_model ThElementary NumR Impl

function ModelingToolkit.ODESystem(v::SimpleKleisliLens; name)
  length(v.dom.dir) == length(v.dom.pos) || error("Expected domain to be a tangent bundle")
  @variables t
  D = Differential(t)
  state_vars = [(@variables $x(t))[1] for x in map(nt -> Symbol(nt[1]), v.dom.pos.ctx)]
  param_vars = [(@parameters $p)[1] for p in map(nt -> Symbol(nt[1]), v.codom.dir.ctx)]
  derivatives = interpret(NumR(), v.morphism.update, vcat(state_vars, param_vars))
  eqs = [D(x) ~ dx for (x,dx) in zip(state_vars, derivatives)]
  ODESystem(eqs, t, state_vars, param_vars; name)
end

end