module ModularWF

function makeexpr_allnames(modname) 
    s = 
"""
for n in $modname.allnames
    if Base.isidentifier(n) && n ∉ (Symbol("$modname"), :eval, :include) && ! isdefined(Base, n)
        eval(Meta.parse("\$n = $modname.\$n"))
    end
end
"""
    return Meta.parse(s)
end

macro mwf(arg)
    # arg is a begin ... end block
    innermod = arg.args[2] # this must be module
    innermod.head != :module && error("@mwf macro must directly enclose a module. Here it enclosing :($(innermod.head))")
        
    modname = innermod.args[2]
    ex1 = :(allnames = names($modname; all=true))
    ex2 = makeexpr_allnames(modname)
    push!(innermod.args[3].args, ex1)
    ex3 = Expr(:toplevel, innermod, ex2)
    return esc(ex3) 
end

export @mwf

end # module ModularWF
