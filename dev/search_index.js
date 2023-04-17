var documenterSearchIndex = {"docs":
[{"location":"api/#Library-Reference","page":"Library Reference","title":"Library Reference","text":"","category":"section"},{"location":"api/","page":"Library Reference","title":"Library Reference","text":"Modules = [Gatlab,\n  Gatlab.Util  ,\n  Gatlab.Util.Lists  ,\n  Gatlab.Util.Names  ,\n  Gatlab.Syntax,\n  Gatlab.Syntax.Theories,\n  Gatlab.Syntax.TheoryMaps,\n  Gatlab.Syntax.Pushouts,\n  Gatlab.Syntax.Visualization,\n  Gatlab.Logic ,\n  Gatlab.Logic.EGraphs,\n  Gatlab.Logic.EMatching,\n  Gatlab.Logic.ContextMaps,\n  Gatlab.Models,\n  Gatlab.Models.ModelInterface,\n  Gatlab.Models.Interpret,\n  Gatlab.Dsl   ,\n  Gatlab.Dsl.TheoryMacros           ,\n  Gatlab.Dsl.ContextMaps            ,\n  Gatlab.Dsl.ModelImplementations   ,\n  Gatlab.Stdlib,\n  Gatlab.Stdlib.Categories,\n  Gatlab.Stdlib.Algebra,\n  ]","category":"page"},{"location":"api/#Gatlab.Util.Lists.Bwd","page":"Library Reference","title":"Gatlab.Util.Lists.Bwd","text":"A \"backwards list\"\n\nThis is a singly-linked list that supports efficient appending to the end.\n\nThe head of this list is at index end, to support compatibility with other AbstractVectors.\n\n\n\n\n\n","category":"type"},{"location":"api/#Gatlab.Util.Lists.Cons","page":"Library Reference","title":"Gatlab.Util.Lists.Cons","text":"An internal data structure for implementing Bwd and Fwd\n\nThis is normal cons cell, where head comes before tail.\n\nWe store the length at each cell because we frequently want to look it up, and we want to look it up in O(1) instead of O(n)\n\n\n\n\n\n","category":"type"},{"location":"api/#Gatlab.Util.Lists.Fwd","page":"Library Reference","title":"Gatlab.Util.Lists.Fwd","text":"A \"forwards list\"\n\nThis is a singly-linked list that supports efficient appending to the front.\n\nThe head of this list is at index 1\n\n\n\n\n\n","category":"type"},{"location":"api/#Gatlab.Util.Lists.Fwd-Union{Tuple{Bwd{T}}, Tuple{T}} where T","page":"Library Reference","title":"Gatlab.Util.Lists.Fwd","text":"Converts a forward list into a backwards list in O(n).\n\nWe need to call this sometimes so that we don't end up with quadratic algorithms.\n\n\n\n\n\n","category":"method"},{"location":"api/#Base.vcat-Union{Tuple{Vararg{Bwd{T}}}, Tuple{T}} where T","page":"Library Reference","title":"Base.vcat","text":"Concatenates all of the lists in ls. We use a left fold because append is linear in the length of the left argument, and the left argument is the one that is growing here.\n\n\n\n\n\n","category":"method"},{"location":"api/#Base.vcat-Union{Tuple{Vararg{Fwd{T}}}, Tuple{T}} where T","page":"Library Reference","title":"Base.vcat","text":"Concatenates all of the lists in ls. We use a right fold because append is linear in the length of the left argument, and the right argument is the one that is growing here.\n\n\n\n\n\n","category":"method"},{"location":"api/#Gatlab.Util.Lists.append-Union{Tuple{T}, Tuple{Bwd{T}, Bwd{T}}} where T","page":"Library Reference","title":"Gatlab.Util.Lists.append","text":"Appends the two lists. The runtime is linear in the length of l2\n\n\n\n\n\n","category":"method"},{"location":"api/#Gatlab.Util.Lists.append-Union{Tuple{T}, Tuple{Fwd{T}, Fwd{T}}} where T","page":"Library Reference","title":"Gatlab.Util.Lists.append","text":"Appends the two lists. The runtime is linear in length of l1.\n\n\n\n\n\n","category":"method"},{"location":"api/#Gatlab.Util.Lists.prefixes-Union{Tuple{Bwd{T}}, Tuple{T}} where T","page":"Library Reference","title":"Gatlab.Util.Lists.prefixes","text":"Returns a Bwd list of prefixes of the list\n\n\n\n\n\n","category":"method"},{"location":"api/#Gatlab.Util.Lists.revcat-Union{Tuple{T}, Tuple{Gatlab.Util.Lists.Cons{T}, Gatlab.Util.Lists.Cons{T}}} where T","page":"Library Reference","title":"Gatlab.Util.Lists.revcat","text":"This makes the list reverse(l1) ++ l2 (if we interpret the cons as a fwd list)\n\n\n\n\n\n","category":"method"},{"location":"api/#Gatlab.Util.Names.Name","page":"Library Reference","title":"Gatlab.Util.Names.Name","text":"Names are used to label parts of a GAT.\n\nThey are used for both human input and output of a GAT, but are not used internally.\n\n\n\n\n\n","category":"type"},{"location":"api/#Gatlab.Util.Names.SymLit","page":"Library Reference","title":"Gatlab.Util.Names.SymLit","text":"We have a symbol wrapper because we get symbols from parsing, and it is faster to compare symbols than it is to compare strings.\n\n\n\n\n\n","category":"type"},{"location":"api/#Gatlab.Syntax.Theories.AbstractTheory","page":"Library Reference","title":"Gatlab.Syntax.Theories.AbstractTheory","text":"A type-level signifier for a particular theory, used to control dispatch and to pass around theory objects (which can't be type parameters) at the type level.\n\nStructs which subtype AbstractTheory should always be singletons, and have theory defined on them.\n\n\n\n\n\n","category":"type"},{"location":"api/#Gatlab.Syntax.Theories.FullContext","page":"Library Reference","title":"Gatlab.Syntax.Theories.FullContext","text":"The full context for a Trm or Typ consists of both the list of judgments in the theory, and also the list of judgments in the context.\n\nTODO: maybe we should have different terms for \"context judgment\" and \"theory judgment\"\n\n\n\n\n\n","category":"type"},{"location":"api/#Gatlab.Syntax.Theories.Typ","page":"Library Reference","title":"Gatlab.Syntax.Theories.Typ","text":"The head of a type can never come from a context, only a theory, because it  should point at a type constructor judgment.\n\n\n\n\n\n","category":"type"},{"location":"api/#Gatlab.Syntax.Theories.gettheory","page":"Library Reference","title":"Gatlab.Syntax.Theories.gettheory","text":"Meant to be overloaded as\n\ngettheory(::T) = ...\n\nwhere T is a singleton struct subtyping AbstractTheory\n\nReturns the @ref(Theory) associated to T.\n\n\n\n\n\n","category":"function"},{"location":"api/#Gatlab.Syntax.Theories.gettheory-Tuple{Type{<:AbstractTheory}}","page":"Library Reference","title":"Gatlab.Syntax.Theories.gettheory","text":"A convenience overload of theory\n\n\n\n\n\n","category":"method"},{"location":"api/#Gatlab.Syntax.Theories.lookup-Tuple{FullContext, Name}","page":"Library Reference","title":"Gatlab.Syntax.Theories.lookup","text":"Get the Lvl corresponding to a Name. This is the most recent judgment with that name.\n\n\n\n\n\n","category":"method"},{"location":"api/#Gatlab.Syntax.TheoryMaps.TheoryMap-Tuple{Context}","page":"Library Reference","title":"Gatlab.Syntax.TheoryMaps.TheoryMap","text":"Map a context in the domain theory into a context of the codomain theory\n\n\n\n\n\n","category":"method"},{"location":"api/#Gatlab.Syntax.TheoryMaps.TheoryMap-Tuple{Gatlab.Syntax.Theories.TrmTyp}","page":"Library Reference","title":"Gatlab.Syntax.TheoryMaps.TheoryMap","text":"Suppose dom(f) is [X,Y,Z,P,Q] and codom(f) is [XX,ϕ,ψ] suppose we have a term: P(a,Q(b,c)) ⊢ a::X,b::Y,c::Z i.e. 4({1},5({2},{3}))\n\nf maps all sorts to XX f maps {P(x,y) ⊢ x::X,y::Y} to ϕ(ψ(y),x) i.e. 2(3({2}),{1}) and {Q(u,w) ⊢ u::Y,w::Z}    to ψ(w)      i.e. 3({2})\n\nWe should our term translate first to ϕ(ψ(y),x)  i.e.  2(3({2}),{1})\n\nand then substitute x (i.e. {1}) for the mapped first argument  y (i.e. 5) for f(q(b,c)) i.e. ϕ(ψ(ψ(c)),x) 2(3(3({3})),{1})\n\nSo f(4({1},5({2},{3}))) = 2(3(3({3})),{1})\n\n\n\n\n\n","category":"method"},{"location":"api/#Gatlab.Syntax.Pushouts.pushout-Tuple{Name, TheoryIncl, TheoryIncl}","page":"Library Reference","title":"Gatlab.Syntax.Pushouts.pushout","text":"Pushout two inclusions.      f   A ↪ B  g ↓   ↓   C->⌜D\n\nD is thought of as a copy of B with the unmerged judgments of C added aftewards.\n\n\n\n\n\n","category":"method"},{"location":"api/#Gatlab.Syntax.Pushouts.substitute_level-Tuple{Judgment, Vector{Int64}}","page":"Library Reference","title":"Gatlab.Syntax.Pushouts.substitute_level","text":"v is a FinFunction from old de bruijn levels to new ones. Its domain is the  size of the theory of the judgment.\n\n\n\n\n\n","category":"method"},{"location":"api/#Gatlab.Syntax.Visualization.Sequent","page":"Library Reference","title":"Gatlab.Syntax.Visualization.Sequent","text":"Intermediate representation of a judgment for pretty printing\n\n\n\n\n\n","category":"type"},{"location":"api/#Gatlab.Syntax.Visualization.ctx_dict-Tuple{Context, Theory, Any}","page":"Library Reference","title":"Gatlab.Syntax.Visualization.ctx_dict","text":"Get the strings required to print the a context t1 that extends t2. E.g. [[\"a\",\"b\",\"c\"]=>\"Ob\", [\"f\",\"g\"]=>[\"Hom(a,b)\"], ...]\n\n\n\n\n\n","category":"method"},{"location":"api/#Gatlab.Syntax.Visualization.show_inctx-Tuple{Theory, Context, Trm, Int64}","page":"Library Reference","title":"Gatlab.Syntax.Visualization.show_inctx","text":"Show a debruijn level term in a theory + context i marks where the theory effectively ends (indices higher than this  refer to the context).\n\n\n\n\n\n","category":"method"},{"location":"api/#Gatlab.Syntax.Visualization.show_inctx-Tuple{Theory, Context, Typ, Int64}","page":"Library Reference","title":"Gatlab.Syntax.Visualization.show_inctx","text":"Show a debruijn level type in a theory + context\n\n\n\n\n\n","category":"method"},{"location":"api/#Gatlab.Logic.EGraphs.context-Tuple{EGraph, ETrm}","page":"Library Reference","title":"Gatlab.Logic.EGraphs.context","text":"This computes the inferred context for an etrm.\n\nFor example, if f is an id with etyp Hom(x,y) and g is an id with etyp Hom(y,z), then context(eg, :(g ∘ f)) computes the context [x,y,z,f,g].\n\nThe tricky thing comes from term formers like\n\nweaken(x)::Term(n) ⊣ [n::Nat, x::Term(S(n))]\n\nWe get the ETyp for x from the e-graph, and then we have to ematch its argument with S(n) to figure out what n is... The problem is that in general S will not be injective, so this is ambiguous!\n\nWhat we are going to do for now is say that types in the context of a term former can't be nested. I.e., we only allow types of the form Term(n), not Term(S(n)).\n\nFortunately, I don't think we care about any theories with this kind of context former.\n\n\n\n\n\n","category":"method"},{"location":"api/#Gatlab.Logic.ContextMaps.KleisliContextMap","page":"Library Reference","title":"Gatlab.Logic.ContextMaps.KleisliContextMap","text":"Represents a Kleisli map in the monad for some theory\n\nEach of the elements of values is a term in the context of dom.\n\nThis is the simplest implementation of a ContextMap, however it is not the most efficient because it does not do deduplication of terms, so redundant computations may be performed when interpreting.\n\n\n\n\n\n","category":"type"},{"location":"api/#Gatlab.Logic.ContextMaps.compose-Tuple{KleisliContextMap, KleisliContextMap}","page":"Library Reference","title":"Gatlab.Logic.ContextMaps.compose","text":"This assumes that f and g are valid context maps, and also have compatible domain/codomain.\n\n\n\n\n\n","category":"method"},{"location":"api/#Gatlab.Logic.ContextMaps.substitute-Tuple{Trm, KleisliContextMap}","page":"Library Reference","title":"Gatlab.Logic.ContextMaps.substitute","text":"Assuming t is a term in the context f.dom, this produces a term in the context f.codom by substituting each of the variables in t with the corresponding term in f.codom.\n\n\n\n\n\n","category":"method"},{"location":"api/#Gatlab.Models.ModelInterface.Model","page":"Library Reference","title":"Gatlab.Models.ModelInterface.Model","text":"An element of Model{T} represents a model of the theory T.\n\nNote that unlike with AbstractModel, we do not expect that structs subtyping Model will necessarily be singletons. In general, they may contain runtime data which is used in the implementations of the various methods. For instance, this would be the case for a slice category: the Model corresponding to a slice category would have runtime data of the object that we are slicing over.\n\nAn instance of Model{T} should have overloads for\n\ncheckvalidity\ntyparg\nap\n\nas described in the docstrings for each of these methods.\n\n\n\n\n\n","category":"type"},{"location":"api/#Gatlab.Models.ModelInterface.ap","page":"Library Reference","title":"Gatlab.Models.ModelInterface.ap","text":"Meant to be overloaded as\n\nap(m::Model{T}, ::Val{i}, xs...)\n\nwhere:\n\ni is the level of a term constructor in T\nxs consists of, for each argument to the term constructor i, a valid value\n\nof the relevant type\n\nReturns the result of applying the term constructor to the arguments, according to the model m. For instance, this is used to compose morphisms, or to get the identity morphism at an object.\n\nNote that we assume in ap that the arguments have already been checked, using checkvalidity and typarg.\n\n\n\n\n\n","category":"function"},{"location":"api/#Gatlab.Models.ModelInterface.checkvalidity","page":"Library Reference","title":"Gatlab.Models.ModelInterface.checkvalidity","text":"Meant to be overloaded as\n\ncheckvalidity(m::Model{T}, ::Val{i}, x) where {T <: AbstractTheory} = ...\n\nwhere:\n\ni is the level of a type constructor in T\nx is an arbitrary Julia value\n\nReturns a boolean which is true if x is a valid element of the type i according to Model and false otherwise.\n\nIf the type i has arguments, an implementation of checkvalidity can assume that they have already been checked.\n\nA basic implementation of checkvalidity might simply use dispatching on the type to return true. But in general, it might be necessary to verify runtime data, for instance checking that something is sorted or something is injective.\n\n\n\n\n\n","category":"function"},{"location":"api/#Gatlab.Models.ModelInterface.checkvalidity-Tuple{Model, Val, Any}","page":"Library Reference","title":"Gatlab.Models.ModelInterface.checkvalidity","text":"If not otherwise specified, we assume that a given value is not valid.\n\n\n\n\n\n","category":"method"},{"location":"api/#Gatlab.Models.ModelInterface.typarg","page":"Library Reference","title":"Gatlab.Models.ModelInterface.typarg","text":"Meant to be overloaded as\n\ntyparg(m::Model{T}, ::Val{i}, ::Val{j}, x) where {T <: AbstractTheory} = ...\n\nwhere:\n\ni is the level of a type constructor in T\nj is an integer representing the index of the argument\nx is a possibly invalid of the type i\n\nReturns the value of the type argument j for the type constructor i. For instance, this might return the domain/codomain of a morphism. Returns nothing if typarg can't figure out this value.\n\nChecking of a term t procedes as follows:\n\nget type arguments\ncheck validity of type arguments\ncheck validity of t\n\nSo we can't assume that typarg will be passed valid data. The only guarantee that typarg should make is that it returns the correct arguments given valid data. If given invalid data, typarg can output invalid data, or nothing.\n\ncheckvalidity on the other hand, must reject invalid data.\n\n\n\n\n\n","category":"function"},{"location":"api/#Gatlab.Dsl","page":"Library Reference","title":"Gatlab.Dsl","text":"A module for various features of Gatlab packaged as domain specific languages\n\n\n\n\n\n","category":"module"},{"location":"api/#Gatlab.Dsl.ContextMaps.@context_map-NTuple{4, Any}","page":"Library Reference","title":"Gatlab.Dsl.ContextMaps.@context_map","text":"Usage:\n\n@context_map ThCategory [x::Ob, y::Ob, f::Hom(x,y)] [x::Ob, y::Ob, f::Hom(y,x)] begin   x = y   y = x   f = f end\n\n(not supported yet) @context_map ThGroup [x,y,z] [w] begin   w = x * y * z * inv(x) end\n\n(not supported yet) @context_map ThGroup [x,y,z] [::U] begin   x * y * z * inv(x) end\n\n\n\n\n\n","category":"macro"},{"location":"stdlib/#Standard-Library","page":"Standard Library","title":"Standard Library","text":"","category":"section"},{"location":"stdlib/","page":"Standard Library","title":"Standard Library","text":"Modules = [Gatlab.Stdlib,\n  Gatlab.Stdlib.Categories,\n  Gatlab.Stdlib.Algebra,\n  ]","category":"page"},{"location":"#Gatlab.jl","page":"Gatlab.jl","title":"Gatlab.jl","text":"","category":"section"},{"location":"","page":"Gatlab.jl","title":"Gatlab.jl","text":"CurrentModule = Gatlab","category":"page"},{"location":"","page":"Gatlab.jl","title":"Gatlab.jl","text":"Gatlab.jl is a Julia library for...","category":"page"}]
}
