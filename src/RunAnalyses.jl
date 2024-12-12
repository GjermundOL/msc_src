using Muscade
using StaticArrays
using LinearAlgebra
using MasterTask
using GLMakie


# cross secitonal area (m²)
cs_area = 0.01 #eksempel
# Young's modulus - Steel
y_mod = 200e9
# mass - Steel (kg/m³)
mass = 7850.
# standard acceleration of gravity
g = 9.81
# Number of nodes in the tower
nNodes = 10
# Width of tower
tWidth = 2.0
# Distance between two vertically connected nodes. Distance between n₁ and n₃ is nHeight/2. 
nHeight=2.0
# Type of external forces
type = "test"
# Scale of external forces
scale = 1000000.
const 𝕣 = Float64

println("1")
state, ϵᵥ, Vₑₓ = ForwardAnalysis(cs_area, y_mod, mass, g, nNodes, tWidth, nHeight, type, scale)
println("2")
nₑₗₛ = (nNodes-2)*2
println("3")
Vₑₓⁱⁿ  = [E.iele for E in Vₑₓ]
println("4")
# Test 

## LEGG TIL MÅLEFEIL PÅ ϵₘ
Vₑₘ = Vₑₓⁱⁿ
ϵₘ = ϵᵥ 
println("5")
inv_state = InverseAnalysis(cs_area, y_mod, mass, g, nNodes, tWidth, nHeight, ϵₘ, Vₑₘ)
println("6")