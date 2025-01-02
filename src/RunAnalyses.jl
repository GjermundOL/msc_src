using Muscade
using StaticArrays
using LinearAlgebra
using MasterTask
using GLMakie
using DelimitedFiles


# cross secitonal area (m²)
cs_area = 0.01 #eksempel
# Young's modulus - Steel
y_mod = 200e9
# mass - Steel (kg/m³)
mass = 7850.
# standard acceleration of gravity
g = 9.81
# Number of nodes in the tower
nNodes = 4
# Width of tower
tWidth = 2.0
# Distance between two vertically connected nodes. Distance between n₁ and n₃ is nHeight/2. 
nHeight=2.0
# Type of external forces
type = "test"
# Scale of external forces
scale = 1.e2
# Relative standard deviation of external forces
σᵤʳᵉˡ = 1
# Standard deviation of external forces
σᵤ = scale*σᵤʳᵉˡ
# Relative standard deviation of measurements
σₗ = 1e-8

const 𝕣 = Float64




#println("1")
state, δLᵥ, Vₑₓ = ForwardAnalysis(cs_area, y_mod, mass, g, nNodes, tWidth, nHeight, type, scale; displayTower=false, saveTower=false)
#println("2")
Vₑₓⁱⁿ  = [E.iele for E in Vₑₓ]
#println("3")

println("δL fra framover: ", δLᵥ)

# Adding measurement error to δLᵥ
δLₑᵣᵣ = [randn()*σₗ + i for i in δLᵥ]

# absolute deviation of measurements
#σₗ = abs.(δLᵥ-δLₑᵣᵣ)

# β = 1/α 
β = σᵤ^2 /σₗ^2

# Measuring every other element
Vₑₘ = Vₑₓⁱⁿ[1:2:length(Vₑₓⁱⁿ)]
δLₘ = δLₑᵣᵣ[1:2:length(δLₑᵣᵣ)]
#β  = βᵗᵉᵐᵖ[1:2:length(βᵗᵉᵐᵖ)]

# Measuring every element
#Vₑₘ = Vₑₓⁱⁿ
#δLₘ = δLₑᵣᵣ
#β  = βᵗᵉᵐᵖ

#println("4")
stateXUA = InverseAnalysis(cs_area, y_mod, mass, g, nNodes, tWidth, nHeight, δLₘ, Vₑₘ, β; displayTower=false, saveTower=false)
#println("5")

println("Ferdig")