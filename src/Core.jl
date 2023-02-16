module Core
export TermConstructor, TypeConstructor, TermInContext, TypeInContext, Axiom,
       EmptyTheory, TheoryExt
# Terms
#######

abstract type InContext end 
abstract type Constructor end 
abstract type Theory end


const DeBruijn = Tuple{Int,Int}

"""
head - indexes term constructors in a certain theory, seen as a context
args - 
"""
struct TermInContext <: InContext
  head::DeBruijn # debruijn index into the term context
  args::Vector{TermInContext}
end

struct TypeInContext <: InContext
  head::DeBruijn # debruijn index into the type context
  args::Vector{TermInContext}
end

head(x::InContext) = x.head
args(x::InContext) = x.args

# Judgments
############

"""
A type constructor for some theory of T

ctx  - a theory that is a decendent of the parent of T 
name - just documentation (and for rendering)
args - indexing all the term constructors in ctx
       this should be sufficient to type infer everything in ctx
"""
struct TypeConstructor <: Constructor
  ctx::Theory
  name::Symbol # JUST DOCUMENTATION
  args::Vector{DeBruijn} 
end

"""
A term constructor for some theory of T

ctx  - a theory that is a decendent of the parent of T 
name - just documentation (and for rendering)
typ  - output type of applying the term constructor
args - indexing all the term constructors in ctx
       this should be sufficient to type infer everything in ctx
"""
struct TermConstructor <: Constructor 
  ctx::Theory
  name::Symbol
  typ::TypeInContext
  args::Vector{DeBruijn}
end

struct Axiom <: Constructor
  ctx::Theory
  name::Symbol
  type::TypeInContext
  rhs::TermInContext
  lhs::TermInContext
end

# Theories
###########


struct EmptyTheory <: Theory end 

struct TheoryExt <: Theory
  parent::Theory
  term_constructors::Vector{TermConstructor}
  type_constructors::Vector{TypeConstructor}
  axioms::Vector{Axiom}
  function Theory(parent,term_constructors,type_constructors,axioms)
    for tc in term_constructors ∪ type_constructors
      parent ∈ ancestors(tc.ctx) || error("")
    end 
    new(parent,term_constructors,type_constructors,axioms)
  end
end


"""List all type/term constructors"""
type_constructors(t::EmptyTheory) = []
type_constructors(t::TheoryExt) = vcat([t.type_construcators], type_constructors(t.parent))
term_constructors(t::EmptyTheory) = []
term_constructors(t::TheoryExt) = vcat([t.term_construcators], term_constructors(t.parent))

parent(::EmptyTheory) = EmptyTheory()
parent(t::TheoryExt) = t.parent


end # module