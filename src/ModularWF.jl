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
    if arg.head == :module
        innermod = arg
    elseif arg.head == :block
        innermod = arg.args[2] # this must be module
        innermod.head != :module && error("@mwf macro must directly enclose a module. Here it enclosing :($(innermod.head))")
    elseif arg.head in (:function, :struct)
        fname = (arg.head == :function) ? arg.args[1].args[1] : arg.args[2]
        modname = Symbol("$(@__MODULE__)_$(fname)")
        innermod = Expr(:module, true, modname, Expr(:block, arg))
    else
        error("cannot make sense of your arguments")
    end
    
    modname = innermod.args[2]
    ex1 = :(allnames = names($modname; all=true))
    ex2 = makeexpr_allnames(modname)
    push!(innermod.args[3].args, ex1)
    ex3 = Expr(:toplevel, innermod, ex2)
    return esc(ex3) 
end

export @mwf

macro mw2(arg)
    @show arg.head
    @show arg.args
    @show typeof(arg.args[2])
    return nothing
end

export @mw2

end 
