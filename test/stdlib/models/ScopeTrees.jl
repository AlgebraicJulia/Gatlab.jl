module TestScopeTrees

using Test, Gatlab

t = wrap(
  :a => pure(1),
  :b => wrap(:x => pure(2), :y => pure(1)),
  :c => wrap(:f => wrap(:g => pure(4)))
)

r = fromexpr(r, :(c.f.g), Reference)

end
