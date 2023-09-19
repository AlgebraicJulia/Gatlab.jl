module Maps

export SwapMonoid, NatPlusMonoid, PreorderCat

using ...StdTheories
using ....Syntax


SwapMonoid = @theorymap ThMonoid => ThMonoid begin
  default => default
  x⋅y ⊣ [x, y] => y⋅x ⊣ [x,y]
  e => e
end


NatPlusMonoid = @theorymap ThMonoid => ThNatPlus  begin
  default => ℕ 
  e => Z
  (x ⋅ y) ⊣ [x, y] => x+y ⊣ [(x, y)::ℕ]
end

"""Preorders are categories"""
PreorderCat = @theorymap ThCategory => ThPreorder begin
  Ob => default
  Hom => Leq
  compose(f, g) ⊣ [a::Ob, b::Ob, c::Ob, f::(a → b), g::(b → c)] => 
    trans(f, g) ⊣ [a, b, c, f::Leq(a, b), g::Leq(b, c)]  
  id(a) ⊣ [a::Ob] => refl(a) ⊣ [a]
end

"""Thin categories are isomorphic to preorders"""
# PreorderThinCat = compose(PreorderCat, Incl(ThCategory, ThThinCategory))
# ThinCatPreorder = inv(PreorderThinCat)


end # module