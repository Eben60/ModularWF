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
    elseif arg.head in (:function, :struct, Symbol("="))
        if arg.head == :function
            fname = arg.args[1].args[1]
        elseif arg.head == :struct
            fname = arg.args[2]
        elseif arg.head == Symbol("=") && (arg.args[1]).head == :call
            fname = (arg.args[1]).args[1] 
        else
            error("Parsing error with @mwf")
        end           

        modname = Symbol("$(@__MODULE__)_$(fname)")
        innermod = Expr(:module, true, modname, Expr(:block, arg))
    else
        error("Parsing error with @mwf")
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

macro mw6(arg)
    dump(arg)
    @show arg.head
    @show arg.args[1].head
    @show (arg.args[1]).args[1] 
    return nothing
end 
export @mw6

end
