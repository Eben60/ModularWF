using ModularWF

@testset "ModularWF" begin
    
@mwf function f1(x) 
    return x
end

@mwf f2(x) = x+2

@mwf struct F3
    x
  end
  
@mwf mutable struct F4
    y
end

@mwf module M2
    
    x1 = 1
    x2 = 2
    f5(x) = x+5

    struct F6
        z
    end

    function f7(x)
        return x+7
    end

end



end

