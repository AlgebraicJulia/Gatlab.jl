module TheoryMacros
export @theory, @theorymap, @term, @context

using MLStyle

using ...Models
using ...Syntax
using ...Util

using ..Parsing

function construct_typ(fc::FullContext, e::SymExpr)
  head = lookup(fc, e.head)
  Typ(head, construct_trm.(Ref(fc), e.args))
end

function construct_trm(fc::FullContext, e::SymExpr)
  head = lookup(fc, e.head)
  Trm(head, construct_trm.(Ref(fc), e.args))
end

function construct_context(judgments::Vector{Judgment}, symctx::Vector{Pair{Symbol, SymExpr}})
  c = Context()
  fc = FullContext(judgments, c)
  for (n, symtyp) in symctx
    push!(c.ctx, (Name(n), construct_typ(fc, symtyp)))
  end
  c
end

function construct_judgment(judgments::Vector{Judgment}, decl::Declaration)
  context = construct_context(judgments, decl.context)
  fc = FullContext(judgments, context)
  (name, head) = @match decl.body begin
    NewTerm(head, args, type) =>
      (
        head,
        TrmCon(lookup.(Ref(fc), args), construct_typ(fc, type))
      )
    NewType(head, args) =>
      (
        head,
        TypCon(lookup.(Ref(fc), args))
      )
    NewAxiom(lhs, rhs, type, name) =>
      (
        name,
        Axiom(
          construct_typ(fc, type),
          construct_trm.(Ref(fc), [lhs, rhs])
        )
      )
  end
  Judgment(name, head, context)
end

function theory_impl(parent::Theory, name::Symbol, lines::Vector)
  judgments = copy(parent.judgments)
  for line in lines
    push!(judgments, construct_judgment(judgments, parse_decl(line)))
  end
  Theory(Name(name), judgments)
end

theory_impl(parent::Type{<:AbstractTheory}, name::Symbol, lines::Vector) = theory_impl(theory(parent), name, lines)

macro theory(head, body)
  (name, parent) = @match head begin
    :($(name::Symbol) <: $(parent::Symbol)) => (name, parent)
    _ => error("expected head of @theory macro to be in the form name <: parent")
  end
  lines = @match body begin
    Expr(:block, lines...) => filter(line -> typeof(line) != LineNumberNode, lines)
    _ => error("expected body of @theory macro to be a block")
  end
  tmp = gensym(:theory)
  esc(
    Expr(
      :block,
      :(const $tmp = $(GlobalRef(TheoryMacros, :theory_impl))(
         $parent,
         $(Expr(:quote, name)),
         $lines
      )),
      __source__,
      :(struct $name <: $(GlobalRef(Theories, :AbstractTheory)) end),
      :($(GlobalRef(Theories, :theory))(::$name) = $tmp)
    )
  )
end

function parse_mapping(expr)
  @match expr begin
    :($lhs => $rhs) => (parse_symexpr(lhs) => parse_symexpr(rhs))
    _ => error("illformed line in @gatmap")
  end
end

function onlydefault(xs; default=nothing)
  if length(xs) == 1
    xs[1]
  else
    default
  end
end

function theorymap_impl(dom::Theory, codom::Theory, lines::Vector)
  mappings = parse_mapping.(lines)
  mappings = [onlydefault(filter(m -> Name(m[1].head) == j.name, mappings)) for j in dom.judgments]
  composites = map(zip(mappings, dom.judgments)) do (mapping, judgment)
    make_composite(codom, judgment, mapping)
  end
  TheoryMap(dom, codom, composites)
end

theorymap_impl(dom::Type{<:AbstractTheory}, codom::Type{<:AbstractTheory}, lines::Vector) =
    theorymap_impl(theory(dom), theory(codom), lines)

function make_composite(
  codom::Theory,
  judgment::Judgment,
  mapping::Union{Pair{SymExpr, SymExpr}, Nothing}
)
  if isnothing(mapping)
    typeof(judgment.head) == Axiom || error("must provide a mapping for $(judgment.name)")
    return nothing
  end
  lhs, rhs = mapping
  all(length(arg.args) == 0 for arg in lhs.args) || error("left side of mapping must be a flat expression")
  length(lhs.args) == arity(judgment.head) || error("wrong number of arguments for $(judgment.name)")
  names = Dict(zip(judgment.head.args, Name.(head.(lhs.args))))
  renamed_ctx = Context(map(enumerate(judgment.ctx.ctx)) do (i,nt)
    newname = get(names, Lvl(i; context=true), Anon())
    (newname, nt[2])
  end)
  fc = FullContext(codom.judgments, renamed_ctx)
  if typeof(judgment.head) == TrmCon
    construct_trm(fc, rhs)
  else
    construct_typ(fc, rhs)
  end
end

macro theorymap(head, body)
  dom, codom = @match head begin
    Expr(:->, dom, Expr(:block, _, codom)) => (dom, codom)
    _ => error("expected head of @theorymap to be of the form `dom -> codom`")
  end
  lines = @match body begin
    Expr(:block, lines...) => filter(line -> typeof(line) != LineNumberNode, lines)
    _ => error("expected body of @theorymap to be a block")
  end
  esc(
    quote
      $(GlobalRef(TheoryMacros, :theorymap_impl))($dom, $codom, $lines)
    end
  )
end

function term_impl(theory::Theory, expr::Expr0; context = Context())
  construct_trm(FullContext(theory.judgments, context), parse_symexpr(expr))
end

term_impl(intheory::Type{<:AbstractTheory}, expr::Expr0; context = Context()) =
  term_impl(theory(intheory), expr; context)

macro term(theory, expr)
  esc(:($(GlobalRef(TheoryMacros, :term_impl))($theory, $(Expr(:quote, expr)))))
end

macro term(theory, context, expr)
  esc(:($(GlobalRef(TheoryMacros, :term_impl))($theory, $(Expr(:quote, expr)); context=$context)))
end

function context_impl(T::Type{<:AbstractTheory}, expr)
  T = theory(T)
  @match expr begin
    :([$(bindings...)]) => construct_context(T.judgments, parse_binding.(bindings))
    _ => error("expected a list of bindings")
  end
end

macro context(theory, expr)
  esc(:($(GlobalRef(TheoryMacros, :context_impl))($theory, $(Expr(:quote, expr)))))
end


end
