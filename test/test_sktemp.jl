
using ACEtb.SlaterKoster, Test, LinearAlgebra, Calculus
import ACEtb.SlaterKoster.CodeGeneration

SK = ACEtb.SlaterKoster
CG = ACEtb.SlaterKoster.CodeGeneration

CG.sk_table(2)

@show CG.Gsym(1, 0, 1, 0, 0)
CG.Gsym(0,0,0,0,0)
CG.Gsym(0,1,0,-1,0)

@show CG.Gsym(1,1,1,1,0)

# function expr(l1, l2, m1, m2)
#    ex = :(0.0)
#    for M = 0:min(l1,l2)
#       ex1 = Meta.parse(CG.Gsym(l1, l2, m1, m2, M))
#       # Vsym = Meta.parse("V$(SK.LSym[l1])$(SK.LSym[l2])$(SK.MSym[M])")
#       Vsym = Meta.parse("V[$(SK.bondintegral_index(l1, l2, M))]")
#       ex = Calculus.simplify(:($(ex)  + $(ex1) * $(Vsym)))
#    end
#    I1 = SK.orbital_index(l1, m1)
#    I2 = SK.orbital_index(l2, m2)
#    println("mat[$I1, $I2]")
#    println("   ", ex)
# end
#
# for l1 = 0:1, l2 = l1:1 # s,p,d
#    for m1=-l1:l1, m2=-l2:l2
#       ex = :(0.0)
#       for M = 0:min(l1,l2)
#          ex1 = Meta.parse(CG.Gsym(l1, l2, m1, m2, M))
#          # Vsym = Meta.parse("V$(SK.LSym[l1])$(SK.LSym[l2])$(SK.MSym[M])")
#          Vsym = Meta.parse("V[$(SK.bondintegral_index(l1, l2, M))]")
#          ex = Calculus.simplify(:($(ex)  + $(ex1) * $(Vsym)))
#       end
#       I1 = SK.orbital_index(l1, m1)
#       I2 = SK.orbital_index(l2, m2)
#       println("mat[$I1, $I2]")
#       println("   ", ex)
#    end
# end


# joinpath(@__DIR__(), "..", "src")
# using PyCall
# pysys = pyimport("sys")
# push!(pysys."path", joinpath(@__DIR__(), "..", "src"))
# codegen = pyimport("codegen")
# @show codegen.Gsym(1,1,0,0,0)
# ex = Meta.parse(replace(codegen.Gsym(1,1,0,0,0), "**" => "^"))
# ex1 = :( $ex + $ex )
# f = eval(:(beta -> $ex1))
# f(0.0)

CG.Gsym(2, 0, 1, 0, 0)
# 2 * sin(th) * cos(th) * cos(phi)
# = 2 * z * x
CG.Gsym(0, 2, 0, 2, 0)
# sin(th)^2*cos(2phi)
# = sin(th)^2*[cos^2(phi)-sin^2(phi)]
# = x^2 - y^2

## matrix block assembly

V = rand(10) #.- 0.5
U = rand(3) .- 0.5
U = U / norm(U)
Hold = zeros(9,9)
Hnew = zeros(9,9)
SK.OldSK.sk9!(U, V, Hold)
SK._sk!(Hnew, Val(2), U, V)
# perm = [1,2,4,3]
# @test Hold[perm, perm] ≈ Hnew

CG.sksign(0, 2)

perm = [1,3,4,2,5,6,9,7,8]
@test Hold[perm,perm] ≈ Hnew




set1 = JSON.parsefile(@__DIR__() * "/data/sp_o3_offsite_data.json")
@show set1["1"]["V"]
display(hcat(set1["1"]["E"]...))

set2 = JSON.parsefile(@__DIR__() * "/data/spdf_au2_offsite_data.json")
@show set2["1"]["V"]
