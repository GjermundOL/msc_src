using Muscade
using StaticArrays
using LinearAlgebra
using MasterTask
using GLMakie
using DelimitedFiles

displayTower = true
saveTower = true
saveResults = false
displayError = false
saveError = false

const 𝕣 = Float64


function RunAnalysis(structure, measurements, ϕ; displayTower = false, saveTower = false, saveResults = false, displayError = false, saveError = false)

    cs_area, E, mass, g, nNodes, tWidth, nHeight, ex_type, ex_scale, σᵤʳᵉˡ, σᵤ, σₗ = Structure(structure)

    state, δLᶠ, Vₑₓ, Fᵁᶠ, Vₑᵁ = ForwardAnalysis(cs_area, E, mass, g, nNodes, tWidth, nHeight, ex_type, ex_scale; displayTower = displayTower, saveTower = saveTower)


    # Adding measurement error to δLᶠ
    δLₑᵣᵣ = [randn()*σₗ + i for i in δLᶠ]

    # β = 1/α 
    β = σᵤ^2 /(σₗ^2 * ϕ)

    Vₑₘ, δLₘ = MeasuredElements(measurements, Vₑₓ, δLₑᵣᵣ)

    stateXUA, δLⁱ, Fᵁⁱ  = InverseAnalysis(cs_area, E, mass, g, nNodes, tWidth, nHeight, δLₘ, Vₑₘ, β; displayTower = displayTower, saveTower = saveTower)

    Vₑₘ, δLʳᵉᶜ = MeasuredElements(measurements, Vₑₓ, δLⁱ)

    η = sqrt(length(δLʳᵉᶜ)) * σₗ

    # total forces in forward analysis
    Fᶠₜₒₜ = ExtractForces(state, Vₑₓ, Fᵁᶠ, nNodes)
    Fᶠₜₒₜ∞ = norm(Fᶠₜₒₜ, Inf)
    Fᶠₜₒₜ₂ = norm(Fᶠₜₒₜ, 2)


    # Measurement error
    ΔδL = abs.(δLᶠ - δLⁱ)
    ΔδL∞  = norm(ΔδL, Inf)
    ΔδL₂ = norm(ΔδL, 2)
    #println("ΔδL: ", ΔδL)
    #println("ΔδL∞: ", ΔδL∞)
    #println("ΔδL₂: ", ΔδL₂)


    # Unscaled external forces error
    ΔFᵁ = abs.(Fᵁᶠ-Fᵁⁱ)
    ΔFᵁ∞ = round(norm(ΔFᵁ, Inf); digits = 3)
    ΔFᵁ₂ = round(norm(ΔFᵁ, 2); digits = 3)
    #println("ΔFᵁ: ", ΔFᵁ)

    # Scaled external forces error
    σᵤ∞ˢ = σᵤ/Fᶠₜₒₜ∞
    σᵤ₂ˢ = σᵤ/Fᶠₜₒₜ₂
    ΔFᵁ∞ˢ = ΔFᵁ∞/Fᶠₜₒₜ∞
    ΔFᵁ₂ˢ = ΔFᵁ₂/Fᶠₜₒₜ₂

    #println("ΔFᵁ∞: ", ΔFᵁ∞)
    #println("ΔFᵁ₂: ", ΔFᵁ₂)



    # Drawing error
    # plotte i forhold til σ's 

    if saveResults
        SaveResults(structure, measurements, cs_area, E, mass, g, nNodes, tWidth, nHeight, ex_type, ex_scale, σₗ, σᵤʳᵉˡ, σᵤ, δLᶠ, δLⁱ, Fᵁᶠ, Fᵁⁱ, ΔδL, ΔδL∞, ΔδL₂, ΔFᵁ, ΔFᵁ∞, ΔFᵁ₂, σᵤ∞ˢ, σᵤ₂ˢ, ΔFᵁ∞ˢ, ΔFᵁ₂ˢ)
    end

    DrawErrors(structure, measurements, σₗ, σᵤ∞ˢ, σᵤ₂ˢ, ΔδL∞, ΔδL₂, ΔFᵁ∞ˢ, ΔFᵁ₂ˢ; displayError = displayError, saveError = saveError)

return σₗ, σᵤ∞ˢ, σᵤ₂ˢ, ΔδL∞, ΔδL₂, ΔFᵁ∞ˢ, ΔFᵁ₂ˢ, Vₑₘ, δLₘ, δLʳᵉᶜ, η, Fᵁⁱ
end

displayTower = false
saveTower = false
saveResults = false
displayError = false
saveError = false
displayDiscrepancy = true
saveDiscrepancy = true
displayLCurve = true
saveLCurve = true

#structure = "test"
#structure = "draw_tower_20"
#structure = "20_nodes"
#structure = "100_nodes"
structure = "100_nodes_test"
measurements = "tenth"
#measurements = "second"

ϕᵥ¹ = collect(500:-10: 100)
ϕᵥ² = collect(99:-1:10)
ϕᵥ³ = collect(9.9:-0.1:0.1)
ϕᵥ⁴ = collect(0.09:-0.01:0.01)
ϕᵥ⁵ = collect(0.009:-0.001:0.001)

ϕᵥ = vcat(ϕᵥ¹, ϕᵥ², ϕᵥ³, ϕᵥ⁴, ϕᵥ⁵)

#ϕᵥ = [4]
#print("ϕᵥ: ", ϕᵥ)

ϕ_acceptable = []

R₂ᵥ = []

δLʳᵉᶜ₂ᵥ = []

Fᵁⁱ₂ᵥ = []

for ϕ in ϕᵥ


    global η
    σₗ, σᵤ∞ˢ, σᵤ₂ˢ, ΔδL∞, ΔδL₂, ΔFᵁ∞ˢ, ΔFᵁ₂ˢ, Vₑₘ, δLₘ, δLʳᵉᶜ, η, Fᵁⁱ  = RunAnalysis(structure, measurements, ϕ; displayTower, saveTower, saveResults, displayError, saveError)

    # residal
    R = δLʳᵉᶜ - δLₘ

    # Norm of residual
    R₂ = norm(R, 2)
    δLʳᵉᶜ₂ = norm(δLʳᵉᶜ, 2)
    Fᵁⁱ₂ = norm(Fᵁⁱ, 2)

    append!(R₂ᵥ, R₂)
    append!(δLʳᵉᶜ₂ᵥ, δLʳᵉᶜ₂)
    append!(Fᵁⁱ₂ᵥ, Fᵁⁱ₂)

    if R₂ < η
        println("R₂ < η")
        println("ϕ: ", ϕ)
        println("R₂: ", R₂)
        println("η: ", η)
        append!(ϕ_acceptable, ["Y"])
    else
        println("R₂ !< η")
        println("ϕ: ", ϕ)
        println("R₂: ", R₂)
        println("η: ", η)
        append!(ϕ_acceptable, ["N"])
    end

end

#remove completely wrong results

indʳᵉᵐᴼᵛᵉ = findall(x->x>1.e-3, R₂ᵥ)

deleteat!(ϕᵥ, indʳᵉᵐᴼᵛᵉ)
deleteat!(R₂ᵥ, indʳᵉᵐᴼᵛᵉ)
deleteat!(Fᵁⁱ₂ᵥ, indʳᵉᵐᴼᵛᵉ)

println("ϕᵥ: ", ϕᵥ)
println("ϕ_acceptable: ", ϕ_acceptable)

DrawDiscrepancy(structure, measurements, ϕᵥ, R₂ᵥ, η; displayDiscrepancy = displayDiscrepancy, saveDiscrepancy = saveDiscrepancy)

DrawLCurve(structure, measurements, ϕᵥ, Fᵁⁱ₂ᵥ, R₂ᵥ; displayLCurve = displayLCurve, saveLCurve = saveLCurve)