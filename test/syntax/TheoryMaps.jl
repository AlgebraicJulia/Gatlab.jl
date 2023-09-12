module TestTheoryMaps 

using GATlab
using Test

# Set up 
########

T = ThCategory.THEORY
T2 = ThPreorder.THEORY

# TheoryMaps 
############
x = toexpr(PreorderCat);
tm2 = fromexpr(T, T2, x, TheoryMap)
x2 = toexpr(tm2)
@test x == x2

# Validation of putative theory maps 
#-----------------------------------
@test_throws LoadError @eval @theorymap ThCategory => ThPreorder begin
  Ob => default
  Hom => Leq
  compose(f, g) ⊣ [(a,b,c,d)::Ob, f::(a → b), g::(c → d)] => 
    trans(f, g) ⊣ [a,b,c,d, f::Leq(a, b), g::Leq(c, d)] # wrong ctx for compose
  id(a) ⊣ [a::Ob] => refl(a) ⊣ [a]
end

@test_throws LoadError @eval @theorymap ThCategory => ThPreorder begin
  Ob => default
  Hom => Leq
  compose(f, g) ⊣ [(a,b,c)::Ob, f::(a → b), g::(b → c)] => 
    trans(f, g) ⊣ [a, b, c, f::Leq(a, b), g::Leq(b, c)]
  id(a) ⊣ [a::Ob] => refl(a) ⊣ [a, b] # codom has different context
end

@test_throws LoadError @eval @theorymap ThCategory => ThPreorder begin
  Ob => default
  Hom => default # bad type map
  compose(f, g) ⊣ [(a,b,c)::Ob, f::(a → b), g::(b → c)] => 
    trans(f, g) ⊣ [a, b, c, f::Leq(a, b), g::Leq(b, c)]
  id(a) ⊣ [a::Ob] => refl(a) ⊣ [a]
end

@test_throws LoadError @eval @theorymap ThCategory => ThPreorder begin
  Ob => default
  Hom => Leq
  compose(f, g) ⊣ [a::Ob, b::Ob, c::Ob, f::(a → b), g::(b → c)] => 
    trans(f, g) ⊣ [a, b, c, f::Leq(a, b), g::Leq(b, c)]  
  id(b) ⊣ [b::Ob] => refl(a) ⊣ [a] # the LHS doesn't match id's originally defined context
end

# Applying theorymap as a function to Ident and TermInCtx
#--------------------------------------------------------
(Ob, Hom), (Cmp, Id) = typecons(T), termcons(T)
@test PreorderCat(Ob) == AlgSort(ident(T2; name=:default))
@test PreorderCat(Cmp) isa TermInCtx
@test PreorderCat(argcontext(getvalue(T[Cmp]))) isa TypeScope

xterm = fromexpr(ThMonoid.THEORY, :(x ⊣ [x]), TermInCtx)
res = NatPlusMonoid(xterm)
toexpr(ThNat.THEORY, res)

xterm = fromexpr(ThMonoid.THEORY, :(e⋅(e⋅x) ⊣ [x]), TermInCtx)
res = NatPlusMonoid(xterm)
expected = fromexpr(ThNatPlus.THEORY, :(Z+(Z+x) ⊣ [x::ℕ]), TermInCtx)
@test toexpr(ThNatPlus.THEORY, res) == toexpr(ThNatPlus.THEORY, expected)

# Inclusions 
#############
TLC = ThLawlessCat.THEORY
incl = TheoryIncl(TLC, T)
toexpr(incl)
@test_throws ErrorException TheoryIncl(T, TLC)

end # module
