using Muscade
using StaticArrays
using LinearAlgebra
using MasterTask
using GLMakie
using DelimitedFiles

displayTower = false
saveTower = false
saveResults = true
displayError = true
saveError = true

const 𝕣 = Float64

#structure = "test"
structure = "100_nodes"
measurements = "tenth"

cs_area, E, mass, g, nNodes, tWidth, nHeight, ex_type, ex_scale, σᵤʳᵉˡ, σᵤ, σₗ = Structure(structure)

state, δLᶠ, Vₑₓ, Fᵁᶠ, Vₑᵁ = ForwardAnalysis(cs_area, E, mass, g, nNodes, tWidth, nHeight, ex_type, ex_scale; displayTower = displayTower, saveTower = saveTower)
#println("δLᶠ: ", δLᶠ)
# bar element numbers for all free nodes
Vₑₓⁱⁿ  = [El.iele for El in Vₑₓ]

# Adding measurement error to δLᶠ
δLₑᵣᵣ = [randn()*σₗ + i for i in δLᶠ]

# β = 1/α 
β = σᵤ^2 /σₗ^2

Vₑₘ, δLₘ = MeasuredElements(measurements, Vₑₓ, δLₑᵣᵣ)

stateXUA, δLⁱ, Fᵁⁱ  = InverseAnalysis(cs_area, E, mass, g, nNodes, tWidth, nHeight, δLₘ, Vₑₘ, β; displayTower = displayTower, saveTower = saveTower)

# Measurement error
ΔδL = abs.(δLᶠ - δLⁱ)
ΔδL∞  = norm(ΔδL, Inf)
ΔδL₂ = norm(ΔδL, 2)
#println("ΔδL: ", ΔδL)
println("ΔδL∞: ", ΔδL∞)
println("ΔδL₂: ", ΔδL₂)


# External forces error
ΔFᵁ = abs.(Fᵁᶠ-Fᵁⁱ)
ΔFᵁ∞ = norm(ΔFᵁ, Inf)
ΔFᵁ₂ = norm(ΔFᵁ, 2)
#println("ΔFᵁ: ", ΔFᵁ)
println("ΔFᵁ∞: ", ΔFᵁ∞)
println("ΔFᵁ₂: ", ΔFᵁ₂)



# Drawing error
# plotte i forhold til σ's 

if saveResults
    SaveResults(structure, measurements, cs_area, E, mass, g, nNodes, tWidth, nHeight, ex_type, ex_scale, σₗ, σᵤʳᵉˡ, σᵤ, δLᶠ, δLⁱ, Fᵁᶠ, Fᵁⁱ)
end

DrawErrors(structure, measurements, σₗ, σᵤ, ΔδL∞, ΔδL₂, ΔFᵁ∞, ΔFᵁ₂; displayError = displayError, saveError = saveError)

println("Ferdig")