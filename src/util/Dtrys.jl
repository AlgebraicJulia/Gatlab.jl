module Dtrys
export Dtry, NonEmptyDtry, AbstractDtry, PACKAGE_ROOT, ■, DtryVar,
  filtermap, mapwithkey, traversewithkey

using AbstractTrees
using OrderedCollections
using MLStyle
using StructEquality

"""
An internal node of a [`Dtry`](@ref). Should not be used outside of this module.

Cannot be empty.
"""
@struct_hash_equal struct Node_{X}
  branches::OrderedDict{Symbol, X}
  function Node_{X}(branches::OrderedDict{Symbol, X}) where {X}
    if length(branches) == 0
      error(
        """
        Attempted to make a Node with no branches. This is an error because
        tries can only be empty at the top level.
        """
      )
    end
    new{X}(branches)
  end
  function Node_(branches::OrderedDict{Symbol, X}) where {X}
    Node_{X}(branches)
  end
end

"""
A leaf node of a [`Dtry`](@ref). Should not be used outside of this module.
"""
@struct_hash_equal struct Leaf_{A}
  value::A
end

abstract type AbstractDtry{A} end

function Base.:(==)(t1::AbstractDtry, t2::AbstractDtry)
  content(t1) == content(t2)
end

"""
A non-empty trie.

See the docs for [`Dtry`](@ref) for general information about tries; these
docs are specific to the reasoning behind having a non-empty variant.

We use non-empty tries because we don't want to worry about the difference
between the empty tuple `()` and a named tuple `(a::())`. In either one, the
set of valid paths is the same. Thus, we only allow a trie to be empty at
the toplevel, and subtries must be non-empty. So the self-similar recursion
happens for non-empty tries, while [`Dtry`](@ref) is just a wrapper around
`Union{NonEmptyDtry{A}, Nothing}`.
"""
struct NonEmptyDtry{A} <: AbstractDtry{A}
  content::Union{Leaf_{A}, Node_{NonEmptyDtry{A}}}
end

content(t::NonEmptyDtry) = getfield(t, :content)

@active Node(t) begin
  inner = content(t)
  if inner isa Node_
    Some(inner.branches)
  end
end

@active Leaf(t) begin
  inner = content(t)
  if inner isa Leaf_
    Some(inner.value)
  end
end

"""
A possibly-empty [trie][1].

We use `trie` in a slightly idiosyncratic way here.

1. Branches are indexed by `Symbol`s rather than `Char`s
2. We only store values at leaf nodes rather than internal nodes.

One way of slickly defining NonEmptyDtry is that it is the free monad on the
polynomial

p = ∑_{U ⋐ Symbol, U ≠ ∅} y^U

Then Dtry = NonEmptyDtry + 1.

[1]: https://en.wikipedia.org/wiki/Dtry
"""
struct Dtry{A} <: AbstractDtry{A}
  content::Union{Nothing, NonEmptyDtry{A}}
end

function content(p::Dtry)
  unwrapped = getfield(p, :content)
  if !isnothing(unwrapped)
    content(unwrapped)
  end
end

@active Empty(t) begin
  isnothing(content(t))
end

@active NonEmpty(t) begin
  if t isa NonEmptyDtry
    Some(t)
  elseif t isa Dtry
    c = getfield(t, :content)
    if !isnothing(c)
      Some(c)
    end
  end
end

"""
Construct a new Dtry node.
"""
function node(d::OrderedDict{Symbol, <:AbstractDtry{A}}) where {A}
  nonempties = OrderedDict{Symbol, NonEmptyDtry{A}}()
  for (k, t) in pairs(d)
    @match t begin
      NonEmpty(net) => begin
        nonempties[k] = net
      end
      Empty() => nothing
    end
  end
  if length(nonempties) > 0
    Dtry{A}(NonEmptyDtry{A}(Node_{NonEmptyDtry{A}}(nonempties)))
  else
    Dtry{A}()
  end
end

node(ps::Pair{Symbol, T}...) where {A, T<:AbstractDtry{A}} = node(OrderedDict{Symbol, T}(ps...))

node(g::Base.Generator) = node(OrderedDict(g))

leaf(x::A) where {A} = Dtry{A}(NonEmptyDtry{A}(Leaf_{A}(x)))

Dtry{A}() where {A} = Dtry{A}(nothing)

struct DtryIndexError <: Exception
  trie::Dtry
  key::Symbol
end

struct DtryDerefError <: Exception
  trie::Dtry
end

function Base.getproperty(t::AbstractDtry{A}, n::Symbol) where {A}
  @match t begin
    Node(bs) =>
      if haskey(bs, n)
        bs[n]
      else
        throw(DtryIndexError(t, n))
      end
    _ => throw(DtryIndexError(t, n))
  end
end

function Base.filter(f, t::AbstractDtry{A}) where {A}
  @match t begin
    Leaf(v) => f(v) ? t : Dtry{A}()
    Node(bs) => begin
      bs′ = OrderedDict{Symbol, NonEmptyDtry{A}}()
      for (n, s) in bs
        @match filter(f, s) begin
          NonEmpty(net) => (bs′[n] = net)
          Empty() => nothing
        end
      end
      node(bs′)
    end
    Empty() => t
  end
end

"""
    filtermap(f, return_type::Type, t::AbstractDtry)

Map the function `f : eltype(t) -> Union{Some{return_type}, Nothing}` over the
trie `t` to produce a trie of type `return_type`, filtering out the elements of
`t` on which `f` returns `nothing`. We pass `return_type` explicitly so that in
the case `t` is the empty trie this doesn't return `Dtry{Any}`.
"""
function filtermap(f, return_type::Type, t::AbstractDtry)
  @match t begin
    Leaf(v) => begin
      @match f(v) begin
        Some(v′) => leaf(v′)
        nothing => Dtry{return_type}()
      end
    end
    Node(bs) => begin
      bs′ = OrderedDict{Symbol, NonEmptyDtry{return_type}}()
      for (n, s) in bs
        @match filtermap(f, return_type, s) begin
          NonEmpty(net) => (bs′[n] = net)
          Empty() => nothing
        end
      end
      node(bs′)
    end
    Empty() => t
  end
end

"""
    zipwith(f, t1::AbstractDtry, t2::AbstractDtry)

Produces a new trie whose leaf node at a path `p` is given by `f(t1[p], t2[p])`.

Throws an error if `t1` and `t2` are not of the same shape: i.e. they don't
have the exact same set of paths.
"""
function zipwith(f, t1::AbstractDtry{A1}, t2::AbstractDtry{A2}) where {A1, A2}
  @match (t1, t2) begin
    (Leaf(v1), Leaf(v2)) => leaf(f(v1, v2))
    (Node(bs1), Node(bs2)) => begin
      keys(bs1) == keys(bs2) || error("cannot zip two tries not of the same shape")
      node(OrderedDict(n => zipwith(f, s1, s2) for ((n, s1), (_, s2)) in zip(bs1, bs2)))
    end
    (Empty(), Empty()) => Dtry{Core.Compiler.return_type(f, Tuple{A1, A2})}()
    _ => error("cannot zip two tries not of the same shape")
  end
end

"""
    zip(t1, t2)

Produces a new trie whose leaf node at a path `p` is given by `(t1[p], t2[p])`.

Throws an error if `t1` and `t2` are not of the same shape: i.e. they don't
have the exact same set of paths.
"""
Base.zip(t1::AbstractDtry, t2::AbstractDtry) = zipwith((a,b) -> (a,b), t1, t2)

Base.getindex(p::Dtry, n::Symbol) = getproperty(p, n)

function Base.getindex(t::AbstractDtry{A})::A where {A}
  @match t begin
    Leaf(v) => v
    _ => throw(DtryDerefError(t))
  end
end

function Base.first(t::AbstractDtry)
  @match t begin
    Leaf(v) => v
    Node(bs) => first(first(values(bs)))
    Empty() => error("cannot take the first value of an empty trie")
  end
end

function Base.hasproperty(t::AbstractDtry, n::Symbol)
  @match t begin
    Node(bs) => haskey(bs, n)
    _ => false
  end
end

function Base.propertynames(t::AbstractDtry)
  @match t begin
    Node(bs) => keys(bs)
    _ => Symbol[]
  end
end

Base.keys(t) = Base.propertynames(t)
Base.valtype(t::AbstractDtry{A}) where {A} = A
Base.valtype(::Type{<:AbstractDtry{A}}) where {A} = A
Base.eltype(t::AbstractDtry{A}) where {A} = A
Base.eltype(::Type{<:AbstractDtry{A}}) where {A} = A

"""
    map(f, return_type::Type, t::AbstractDtry)

Produce a new trie of the same shape as `t` where the value at a path `p` is
given by `f(t[p])`. We pass in the return type explicitly so that in the case
that `t` is empty we don't get `Dtry{Any}`.

There is a variant defined later where `return_type` is not passed in, and it
tries to use type inference from the Julia compiler to infer `return_type`: use
of this should be discouraged.
"""
function Base.map(f, return_type::Type, t::AbstractDtry)
  @match t begin
    Leaf(v) => leaf(f(v))
    Node(bs) => node(
      OrderedDict{Symbol, Dtry{return_type}}(
        (n => map(f, return_type, t′)) for (n, t′) in bs
      )
    )
    Empty() => Dtry{return_type}()
  end
end

"""
    map(f, t::AbstractDtry)

Variant of `map(f, return_type, t::AbstractDtry)` which attempts to infer the
return type of `f`.
"""
function Base.map(f, t::AbstractDtry{A}) where {A}
  B = Core.Compiler.return_type(f, Tuple{A})
  map(f, B, t)
end

"""
    flatten(t::AbstractDtry{Dtry{A}})

The monad operation for Dtrys. Works on NonEmptyDtrys and Dtrys.
"""
function flatten(t::AbstractDtry{Dtry{A}}) where {A}
  @match t begin
    Leaf(v) => v
    # Note that if flatten(v) is empty, the `node` constructor will
    # automatically remove it from the built trie.
    Node(bs) => node(n => flatten(v) for (n, v) in bs)
    Empty() => Dtry{A}()
  end
end

struct DtryVar
  content::Union{Nothing, Tuple{Symbol, DtryVar}}
end

PACKAGE_ROOT = DtryVar(nothing)
■ = PACKAGE_ROOT

content(v::DtryVar) = getfield(v, :content)

@active Root(v) begin
  isnothing(content(v))
end

@active Nested(v) begin
  inner = content(v)
  if !isnothing(inner)
    Some(inner)
  end
end

function Base.getproperty(v::DtryVar, n::Symbol)
  @match v begin
    Root() => DtryVar((n, v))
    Nested((n′, v′)) => DtryVar((n′, getproperty(v′, n)))
  end
end

function Base.:(*)(v1::DtryVar, v2::DtryVar)
  @match v1 begin
    Root() => v2
    Nested((n, v1′)) => DtryVar((n, v1′ * v2))
  end
end

"""
    mapwithkey(f, return_type::Type, t::AbstractDtry)

Constructs a new trie with the same shape as `t` where the value at the path
`p` is `f(p, t[p])`.
"""
function mapwithkey(f, return_type::Type, t::AbstractDtry; prefix=PACKAGE_ROOT)
  @match t begin
    Leaf(v) => leaf(f(prefix, v))
    Node(bs) =>
      node([k => mapwithkey(f, return_type, v; prefix=getproperty(prefix, k)) for (k, v) in bs]...)
    Empty() => Dtry{return_type}()
  end
end

"""
    traversewithkey(f, t::AbstractDtry; prefix=PACKAGE_ROOT)

Similar to [`mapwithkey`](@ref) but just evaluates `f` for its side effects
instead of constructing a new trie.
"""
function traversewithkey(f, t::AbstractDtry; prefix=PACKAGE_ROOT)
  @match t begin
    Leaf(v) => (f(prefix, v); nothing)
    Node(bs) => begin
      for (k, v) in bs
        traversewithkey(f, v; prefix=getproperty(prefix, k))
      end
    end
    Empty() => nothing
  end
end

"""
    fold(emptycase::A, leafcase, nodecase, t::AbstractDtry)::A

Fold over `t` to produce a single value.

Args:
- `emptycase::A`
- `leafcase::eltype(t) -> A`
- `nodecase::OrderedDict{Symbol, A} -> A`
"""
function fold(emptycase::A, leafcase, nodecase, t::AbstractDtry)::A where {A}
  @match t begin
    Empty() => emptycase
    Leaf(v) => leafcase(v)
    Node(bs) => nodecase(OrderedDict(k => fold(emptycase, leafcase, nodecase, v) for (k,v) in bs))
  end
end

"""
    all(f, t::AbstractDtry)

Checks if `f` returns `true` when applied to all of the elements of `t`.

Args:
- `f::eltype(t) -> Bool`
"""
function Base.all(f, t::AbstractDtry)
  fold(true, f, d -> all(values(d)), t)
end

# precondition: the union of the keys in t1 and t2 is prefix-free
function Base.merge(t1::AbstractDtry{A}, t2::AbstractDtry{A}) where {A}
  @match (t1, t2) begin
    (Leaf(_), _) || (_, Leaf(_)) =>
      error("cannot merge tries with overlapping keys")
    (Empty(), _) => t2
    (_, Empty()) => t1
    (Node(b1), Node(b2)) => begin
      b = OrderedDict{Symbol, NonEmptyDtry{A}}()
      for (n, t) in b1
        if haskey(b2, n)
          @match merge(t, b2[n]) begin
            NonEmpty(t′) => (b[n] = t′)
            _ => nothing
          end
        else
          b[n] = t
        end
      end
      for (n, t) in b2
        if !haskey(b1, n)
          b[n] = t
        end
      end
      node(b)
    end
  end
end

"""
Make a trie out of a dict from trie keys to values.

Fails if the keys in the dict are not prefix-free.
"""
function Dtry(d::OrderedDict{DtryVar, A}) where {A}
  branches = OrderedDict{Symbol, OrderedDict{DtryVar, A}}()
  for (v, x) in d
    @match v begin
      Root() =>
        if length(d) == 1
          return leaf(x)
        else
          error("attempted trie conversion failed because keys were not prefix-free")
        end
      Nested((n, v′)) =>
        if haskey(branches, n)
          branches[n][v′] = x
        else
          branches[n] = OrderedDict(v′ => x)
        end
    end
  end
  node(n => Dtry(d′) for (n, d′) in branches)
end

Dtry(pairs::Pair{DtryVar, A}...) where {A} = Dtry(OrderedDict{DtryVar, A}(pairs...))

function Base.show(io::IO, v::DtryVar)
  print(io, "■")
  while true
    @match v begin
      Root() => break
      Nested((n, v′)) => begin
        print(io, ".", n)
        v = v′
      end
    end
  end
end

function Base.haskey(t::AbstractDtry, v::DtryVar)
  @match (t, v) begin
    (Leaf(_), Root) => true
    (Node(_), Nested((n, v))) => hasproperty(t, n) && haskey(getproperty(t, n), v)
    _ => false
  end
end

struct DtryVarNotFound <: Exception
  p::Dtry
  v::DtryVar
end

function Base.getindex(t::AbstractDtry, v::DtryVar)
  @match (t, v) begin
    (Leaf(v), Root) => v
    (Node(_), Nested((n, v′))) =>
      if hasproperty(t, n)
        getproperty(t, n)[v′]
      else
        throw(DtryVarNotFound(t, v))
      end
    _ => throw(DtryVarNotFound(t, v))
  end
end

function AbstractTrees.children(t::AbstractDtry)
  @match t begin
    Leaf(_) => ()
    Node(bs) => bs
  end
end

function AbstractTrees.printnode(io::IO, t::AbstractDtry{A}; kw...) where {A}
  @match t begin
    Leaf(v) => print(io, v)
    Node(bs) => print(io, nameof(typeof(t)), "{$A}")
    Empty() => print(io, "{}")
  end
end

function Base.show(io::IO, t::AbstractDtry{A}) where {A}
  @match t begin
    Leaf(v) => print(io, "leaf(", v, ")::$(nameof(typeof(t))){$A}")
    Node(_) => print_tree(io, t)
    Empty() => print(io, "Dtry{$A}()")
  end
end

end