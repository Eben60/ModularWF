using ModularWF
using Test

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

@mwf module M5
    
    x1 = 1
    x2 = 2
    f6(x) = x+6

    struct F7
        z
    end

    function f8(x)
        return x+8
    end

end

@test f1 === ModularWF_f1.f1
@test f2 === ModularWF_f2.f2
@test F3 === ModularWF_F3.F3
@test F4 === ModularWF_F4.F4
@test M5 === Main.M5
@test f6 === M5.f6
@test F7 === M5.F7
@test f8 === M5.f8

@test f1("a") == "a"
@test f2(2) == 4

s3 = F3(3)
@test s3.x == 3

s4 = F4(4)
@test s4.y == 4
s4.y = 44
@test s4.y == 44

@test x1 == 1
@test x2 == 2
@test f6(6) == 12
@test f8(8) == 16


s7 = F7(7.7)
@test s7.z ≈ 7.7

end
;
