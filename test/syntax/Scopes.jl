module TestScopes

using Test, GATlab

# ScopeTags
###########

basicprinted(x; color=false) = sprint(show, x; context=(:color=>color))

tag1 = newscopetag()
tag2 = newscopetag()

@test tag1 != tag2
@test retag(Dict(tag1 => tag2), 4) == 4
@test rename(tag1, Dict(:a => :b), 4) == 4

err = ScopeTagError(nothing, nothing)

@test sprint(showerror, err) isa String

@test basicprinted(tag1) != basicprinted(tag2)
@test basicprinted(tag1; color=true) != basicprinted(tag2)

# Local IDs
###########

lid = LID(2)

@test sprint(show, lid) == "2"

# Idents
########

x = Ident(tag1, LID(1), :x)
y = Ident(tag1, LID(1), :y)

@test x == y
@test hash(x) == hash(y)

@test gettag(x) == tag1
@test getlid(x) == LID(1)
@test nameof(x) == :x
@test isnamed(x)

function basicprinted(x)
  sprint(show, x; context=(:color=>false))
end

@test basicprinted(x) == "x"

nameless = Ident(tag1, LID(1), nothing)

@test basicprinted(nameless) == "#1"

@test gettag(retag(Dict(tag1 => tag2), x)) == tag2
@test nameof(rename(tag1, Dict(:x => :y), x)) == :y

# References
############
@test_throws ArgumentError only(Reference())
@test basicprinted(Reference()) == "_"

y = Ident(tag2, LID(1), :y)
xdoty = Reference(x, Reference(y))
@test xdoty == Reference(x,y)

@test first(xdoty) == x
@test rest(xdoty) == Reference(y)
@test_throws ArgumentError only(xdoty)
@test only(Reference(x)) == x

@test basicprinted(xdoty) == "x.y"

xsub1 = Reference(x, nameless)

@test basicprinted(xsub1) == "x[1]"

@test gettag(first(retag(Dict(tag1 => tag2), xdoty))) == tag2
@test gettag(first(retag(Dict(tag2 => tag2), xdoty))) == tag1
@test gettag(first(rest(retag(Dict(tag2 => tag1), xdoty)))) == tag1
@test basicprinted(rename(tag1, Dict(:x => :y, :y => :z), xdoty)) == "y.y"
@test basicprinted(rename(tag2, Dict(:x => :y, :y => :z), xdoty)) == "x.z"

# Bindings
##########

@test_throws ErrorException Binding{String}(nothing, Set([:x]), "ex")
@test_throws ErrorException Binding{String}(:y, Set([:x]), "ex")
@test_throws ErrorException Binding{String}(:x, Set(Symbol[]), "ex")

bind_x = Binding{String}(:x, Set([:x, :X]), "ex")
bind_y = Binding{String}(:y, Set([:y, :Y]), "why")

@test retag(Dict(tag1 => tag2), bind_x) == bind_x

@test nameof(bind_x) == :x
@test getvalue(bind_x) == "ex"
@test getaliases(bind_x) == Set([:x,:X])
@test isnothing(getsignature(bind_x))
@test basicprinted(bind_x) == "x(aliases=X) => \"ex\""

bind_z = Binding{String, Int}(:x, Set([:x]), "ex", 1)

@test getsignature(bind_z) == 1
@test getline(setline(bind_z, LineNumberNode(1))) == LineNumberNode(1)

# Context
#########

# No tests, just an abstract type

# HasScope
##########

# No tests, just an abstract type

# Scopes
########

xy_scope = Scope([bind_x, bind_y]; tag=tag1)
xy_scope′ = Scope([bind_x]; tag=tag1)

@test xy_scope == xy_scope′
@test hash(xy_scope) == hash(xy_scope′)
@test basicprinted(xy_scope) == "{$(basicprinted(bind_x)), $(basicprinted(bind_y))}"
@test getscope(xy_scope) == xy_scope
@test gettag(xy_scope) == tag1
@test haslid(xy_scope, LID(1))
@test haslid(xy_scope, LID(2))
@test hasident(xy_scope, x)
@test !hasident(xy_scope, Ident(tag1, LID(1), :y))
@test getbindings(xy_scope) == [bind_x, bind_y]
@test getbinding(xy_scope, LID(1)) == bind_x
@test getbinding(xy_scope, x) == bind_x
@test getbinding(xy_scope, :x) == bind_x
@test getlid(xy_scope, :x) == LID(1)
@test getlid(xy_scope; name=:x) == LID(1)
@test_throws ScopeTagError getlid(xy_scope; tag=tag2)
@test_throws KeyError getlid(xy_scope; name=:z)
@test ident(xy_scope; name=:x) == x
@test nameof(ident(xy_scope; name=:X)) == :X
@test ident(xy_scope; lid=LID(1)) == x
@test_throws BoundsError ident(xy_scope; name=:x, level=2)
@test hasident(xy_scope, x)
@test !hasident(xy_scope; tag=tag1)

s = Scope{String, Int}()

bind_x_typed = Binding{String, Int}(:x, Set([:x]), "ex", 2)

Scopes.unsafe_pushbinding!(s, bind_x_typed)
@test_throws ErrorException Scopes.unsafe_pushbinding!(s, bind_x_typed)

s_tag = gettag(s)

s_x = Ident(s_tag, LID(1), :x)

@test ident(s; name=:x, sig=2) == s_x
@test_throws KeyError ident(s; name=:x)
@test ident(s; name=:x, isunique=true) == s_x

Scopes.unsafe_addalias!(s, :x, :X)

@test ident(s; name=:X, isunique=true) == s_x

@test length(s) == 1
@test s[:x] == getbinding(s, :x)
@test s[LID(1)] == getbinding(s, LID(1))
@test s[s_x] == getbinding(s, s_x)
@test [s...] == [bind_x_typed]
@test haskey(s, :x)
@test haskey(s, :X)
@test haskey(s, LID(1))
@test haskey(s, s_x)

@test nscopes(s) == 1
@test getscope(s, 1) == s
@test_throws BoundsError getscope(s, 2)
@test getlevel(s, s_tag) == 1
@test_throws KeyError getlevel(s, tag1)
@test getlevel(s, :x) == 1
@test_throws KeyError getlevel(s, :elephant)

# Context Utilities
###################

@test getscope(s, s_tag) == s
@test getscope(s, s_x) == s
@test s_x ∈ s
@test nameof(canonicalize(s, Ident(s_tag, LID(1), :X))) == :x

# ScopeList
###########

@test_throws Exception ScopeList([xy_scope, xy_scope])

bind_z = Binding{String}(:z, Set([:z]), "zee")

xz_scope = Scope([bind_x, bind_z])

@test_throws ErrorException Scope([bind_z, bind_z])

@test LID(1) == getlid(xz_scope; lid=LID(1))
@test_throws KeyError getlid(xz_scope; lid=LID(-1))
@test_throws KeyError getbinding(xz_scope, LID(-1))
@test_throws ScopeTagError getbinding(xz_scope, y)
@test namevalues(xz_scope) == [:x=>"ex",:z => "zee"]
@test valtype(xz_scope) == String

c = ScopeList([xy_scope, xz_scope])

@test getscope(c, 1) == xy_scope
@test getscope(c, 2) == xz_scope
@test nscopes(c) == 2
@test getlevel(c, gettag(xy_scope)) == 1
@test getlevel(c, :x) == 2
@test getlevel(c, :y) == 1
@test hastag(c, gettag(xy_scope))
@test hasname(c, :z)
@test !hasname(c, :w)

@test ident(c; name=:x) == Ident(gettag(xz_scope), LID(1), :x)
@test ident(c; name=:x, level=1) == Ident(gettag(xy_scope), LID(1), :x)
@test nameof(ident(c; level=1, lid=LID(2))) == :y
@test_throws ErrorException ident(c)

# AppendScope
#############

@test_throws Exception AppendScope(ScopeList([xy_scope]), xy_scope)

c = AppendScope(ScopeList([xy_scope]), xz_scope)

@test getscope(c, 1) == xy_scope
@test getscope(c, 2) == xz_scope
@test nscopes(c) == 2
@test getlevel(c, gettag(xy_scope)) == 1
@test getlevel(c, :x) == 2
@test getlevel(c, :y) == 1
@test hastag(c, gettag(xy_scope))
@test hasname(c, :z)
@test !hasname(c, :w)

@test ident(c; name=:x) == Ident(gettag(xz_scope), LID(1), :x)
@test ident(c; name=:x, level=1) == Ident(gettag(xy_scope), LID(1), :x)
@test nameof(ident(c; level=1, lid=LID(2))) == :y

# EmptyContext 
e = EmptyContext()
@test_throws BoundsError getscope(e, 1)
@test_throws KeyError getlevel(e, :x) 
@test_throws KeyError getlevel(e, gettag(x))
@test !hasname(e, :x)
end
