module Visualization
export sequent

using ...Util
using ..Backend 
using ..Backend: TrmTyp, TypCon, TrmCon, Constructor, Axiom, TheoryMap, args,TrmTyp

using DataStructures

# Types/Terms 
#############

"""
Show a debruijn level term in a theory + context
i marks where the theory effectively ends (indices higher than this 
refer to the context).
"""
function show_inctx(th::Theory,c::Context, trm::Trm, i::Int)
  if trm.head > i
    isempty(trm.args) || error("Bad term")
    hed = c[trm.head - i][1]
  else 
    hed = th.judgments[trm.head].name
  end
  a = isempty(trm.args) ? "" : "($(join([show_inctx(th,c,x,i) for x in trm.args],",")))"
  return "$(string(hed))$a"
end

"""Show a debruijn level type in a theory + context"""
function show_inctx(th::Theory,c::Context, trm::Typ, i::Int)  
  a = isempty(trm.args) ? "" : "($(join([show_inctx(th,c,x,i) for x in trm.args],",")))"
  return "$(string(th.judgments[trm.head].name))$a"
end


# Contexts 
##########

ctx_string(c::Context, t::Theory, i) = join(map(ctx_dict(c,t,i)) do (xs,t)
  if length(xs) == 0 return "" end 
  (length(xs)==1 ? only(xs) : "($(join(xs, ",")))") * ":$t" 
end, " | ")


"""
Get the strings required to print the a context t1 that extends t2.
E.g. [["a","b","c"]=>"Ob", ["f","g"]=>["Hom(a,b)"], ...]
"""
function ctx_dict(ctx::Context,th::Theory,i)
  typdict = DefaultOrderedDict{Typ,OrderedSet{String}}(()->OrderedSet{String}())
  for (k,v) in ctx push!(typdict[v],string(k)) end 
  return [collect(v) => show_inctx(th,ctx,k,i) for (k,v) in collect(typdict)]
end 


# Judgments 
###########

"""Intermediate representation of a judgment for pretty printing"""
struct Sequent 
  name::String
  ctx::String
  judgment::String
end 

function Base.show(io::IO,::MIME"text/plain",s::Sequent)
  numerator = s.ctx
  n = maximum(length.([numerator, s.judgment])) + 2
  off_n,off_d = [repeat(" ",(n-length(x))÷2) for x in [numerator, s.judgment]]
  title = repeat("-", n) * "  " * s.name
  println(io,join([off_n * numerator, title, off_d * s.judgment,""], "\n"))
end

# Convert the i'th judgment into a sequent
function sequent(t::Theory, i ::Int)
  j, i1 = t[i], i-1
  name, ctx = string(j.name), j.ctx
  if j.head isa Constructor 
    arg_syms = string.(first.([ctx[a] for a in j.head.args]))
    typ = j.head isa TrmCon ? ": $(show_inctx(t, ctx,j.head.typ,i1))" : ": TYPE"
    arg = isempty(arg_syms) ? "" : "($(join(arg_syms, ",")))"
    return Sequent("$name introduction", ctx_string(ctx,t,i1), "$(name)$arg $typ")
  else # AXIOM
    eqs = join([show_inctx(t,ctx,x,i1) for x in j.head.equands], " = ")
    typ = show_inctx(t, ctx, j.head.typ, i1)
    return Sequent(name, ctx_string(ctx,t,i1), "$eqs : $typ")  
  end 
end 


# Theories
##########

function Base.show(io::IO, m::MIME"text/plain", t::Theory)  
  n = string(t.name)
  n_name = repeat('#',length(string(n)) + 4)

  tys,trs,axs = map([TrmCon,TypCon,Axiom]) do T
    findall(j->j.head isa T, t.judgments)
  end

  println(io,"$n_name\n# $n #\n$n_name\n\nType Constructors\n=================")
  for i in tys show(io,m,sequent(t,i)) end 
  if !isempty(trs)
    println(io,"\nTerm Constructors\n=================")
    for i in trs show(io,m,sequent(t,i))  end
  end
  if !isempty(axs)
    println(io,"\nAxioms\n======")
    for i in axs show(io,m,sequent(t,i)) end
  end
end 


# Theory morphisms 
##################


# function Base.show(io::IO,::MIME"text/plain",thom::TheoryMap)
#   X,Y = dom(thom), codom(thom)
#   nX,nY = name.([X, Y])
#   tymap = join(reverse(vcat(map(enumerate(all_typecons(X))) do (d,tcs)  
#     depth = d - 1
#     map(enumerate(tcs)) do (i,tc)
#       println("DEPTH $depth i $i")
#       y = typemap(thom, DeBruijn(depth,i)) 
#       return "$(name(tc)): $(name(debruijn_to_cons(Y,y; term=false)))"
#     end
#   end...)),", ")
#   trmap = join(reverse(vcat(map(enumerate(all_termcons(X))) do (d,tcs) 
#     depth = d - 1
#     map(enumerate(tcs)) do (i,tc)
#       trm = termmap(thom, DeBruijn(depth,i))
#       as = args(trm)
#       if all(a->a.depth==0, headof.(as)) && 1:length(as) == [z.idx for z in headof.(as)]
#           tstr = name(debruijn_to_cons(Y, headof(trm))) # special case: easy!
#       else 
#         tctx = Context(Y, map(enumerate(tc.args)) do (i,a)
#           arg_tcon = debruijn_to_cons(codom(tc.ctx), a)
#           new_type = thom(Context(X),Context(Y),arg_tcon.typ+depth+1)
#           TrmCon(Y, Symbol("[$i]"),new_type, [f(X,Y,a+depth+1) for a in args(arg_tcon)])
#         end)
#         trm′ = map(x->x.depth==0 ? x : x+1, trm) # keep zeros, increment all else
#         tstr = show_term(tctx, trm′).judgment
#       end 
#       return "$(name(tc)): $tstr"
#     end
#   end...)), ", ")
#   trstr = isempty(trmap) ? "" : " || $trmap"
#   println(io, "TheoryHom($nX,$nY)($tymap$trstr)")
# end 

end # module 