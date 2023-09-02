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

makeexpr_typedglobal(x::Symbol, m::Symbol) = Meta.parse("$(x)::typeof($(m).$(x)) = $(m).$(x)")

macro mwf(arg)
    if arg.head == :module
        wrappermod = arg
    elseif arg.head in (:function, :struct, Symbol("="), :const)
        if arg.head == :function
            fname = arg.args[1].args[1]
        elseif arg.head == :struct
            fname = arg.args[2]
        elseif arg.head == Symbol("=") && (arg.args[1]).head == :call
            fname = (arg.args[1]).args[1]
        elseif arg.head == :const && (arg.args[1]).head == Symbol("=")
            fname = (arg.args[1]).args[1] 
        else
            error("Parsing error with @mwf")
        end           
        
        modname = Symbol("$(@__MODULE__)_$(fname)")
        wrappermod = Expr(:module, true, modname, Expr(:block, arg))
    else
        error("Parsing error with @mwf")
    end
    
    modname = wrappermod.args[2]
    ex1 = :(allnames = names($modname; all=true))
    push!(wrappermod.args[3].args, ex1)

    if arg.head == :const && isdefined(parentmodule(__module__), fname)
        ex2 = makeexpr_typedglobal(fname, modname)
    else
        ex2 = makeexpr_allnames(modname)
    end

    ex3 = Expr(:toplevel, wrappermod, ex2)
    return esc(ex3) 
end

export @mwf

# function istypedglobal(v)
#     notavar = (isvar = false, t_glob = false, btype = nothing)
#     ! isdefined(@__MODULE__, v) && return notavar
#     eval(v) isa Function && return notavar
#     btype = Core.get_binding_type(@__MODULE__, v)
#     t_glob = (btype != Any)
#     return (; isvar = true, brype, t_glob)
# end

function istypedglobal(m, v)
    notavar = (isvar = false, t_glob = false, btype = nothing)
    ! isdefined(m, v) && (println("unknown"); return notavar)
    getproperty(m, v) isa Function && return notavar
    btype = Core.get_binding_type(m, v)
    t_glob = (btype != Any)
    return (; isvar = true, btype, t_glob)
end

# export istypedglobal

end
