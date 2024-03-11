export ThNat, ThNatPlus, ThNatPlusTimes

import Base: +

# Natural numbers
@theory ThNat begin
  ℕ :: TYPE
  Z :: ℕ
  S(n::ℕ) :: ℕ
end

@theory ThNatPlus <: ThNat begin
  ((x::ℕ) + (y::ℕ))::ℕ
  (n + S(m) == S(n+m) :: ℕ) ⊣ [n::ℕ,m::ℕ]
end

@theory ThNatPlusTimes <: ThNatPlus begin
  ((x::ℕ) * (y::ℕ))::ℕ
  (n * S(m) == ((n * m) + n)) ⊣ [n::ℕ,m::ℕ]
end