using Muscade
using StaticArrays
using LinearAlgebra
using MasterTask
using GLMakie
using DelimitedFiles
using StatsBase

const 𝕣 = Float64


function RunSingleAnalysis(structure, measurements, folder_name, folder_path, ϕ, ρ, Nʳʰᴼ; displayTower = false, saveTower = false, drawForces = false, saveResults = false, displayError = false, saveError = false)

    cs_area, E, mass, g, nNodes, tWidth, nHeight, ex_type, ex_scale, σᵤʳᵉˡ, σᵤ, σₗ = Structure(structure)

    state, δLᶠ, Vₑₓ, Fᵁᶠ, Vₑᵁ = ForwardAnalysis(cs_area, E, mass, g, nNodes, tWidth, nHeight, ex_type, ex_scale, folder_name, folder_path; displayTower = displayTower, saveTower = saveTower, drawForces = drawForces)


    # Adding measurement error to δLᶠ
    δLₑᵣᵣ = [randn()*σₗ + i for i in δLᶠ]

    # β = 1/α 
    β = σᵤ^2 /(σₗ^2 * ϕ)

    Vₑₘ, δLₘ = MeasuredElements(measurements, Vₑₓ, δLₑᵣᵣ)

    stateXUA, δLⁱ, Fᵁⁱ  = InverseAnalysis(cs_area, E, mass, g, nNodes, tWidth, nHeight, δLₘ, Vₑₘ, β, ex_scale, folder_name, folder_path, ϕ; displayTower = displayTower, saveTower = saveTower, drawForces = drawForces)

    Vₑₘ, δLʳᵉᶜ = MeasuredElements(measurements, Vₑₓ, δLⁱ)

    η = sqrt(length(δLʳᵉᶜ)) * σₗ

    Fᴱˢᶜᵃˡᵉ = sqrt(nNodes-2)*ex_scale

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
        SaveResults(structure, measurements, folder_name, folder_path, ϕ, ρ, Nʳʰᴼ, cs_area, E, mass, g, nNodes, tWidth, nHeight, ex_type, ex_scale, σₗ, σᵤʳᵉˡ, σᵤ, δLᶠ, δLⁱ, Fᵁᶠ, Fᵁⁱ, ΔδL, ΔδL∞, ΔδL₂, ΔFᵁ, ΔFᵁ∞, ΔFᵁ₂, σᵤ∞ˢ, σᵤ₂ˢ, ΔFᵁ∞ˢ, ΔFᵁ₂ˢ)
    end

    DrawSingleErrors(structure, measurements, folder_name, folder_path, ϕ, ρ, Nʳʰᴼ, σₗ, σᵤ∞ˢ, σᵤ₂ˢ, ΔδL∞, ΔδL₂, ΔFᵁ∞ˢ, ΔFᵁ₂ˢ; displayError = displayError, saveError = saveError)

return σₗ, σᵤ∞ˢ, σᵤ₂ˢ, ΔδL∞, ΔδL₂, ΔFᵁ∞ˢ, ΔFᵁ₂ˢ, Vₑₘ, δLₘ, δLʳᵉᶜ, η, Fᴱˢᶜᵃˡᵉ, Fᵁⁱ
end

function RunFullAnalysis(structure, measurements, ϕᵥ, ρ, Nʳʰᴼ, folder_name, folder_path; displayTower = false, saveTower = false, drawForces = false, saveResults = false, displayError = false, saveError = false, displayDiscrepancy = false, saveDiscrepancy = false, displayLCurve = false, saveLCurve = false, testRegStrat = false)
    
    if testRegStrat
        σᵥ = [0.5^n for n=-30:1:30]
        TestRegStrat(structure, measurements, σᵥ, folder_name, folder_path; displayRegStrat = false, saveRegStrat = true)
    end

    ϕ_acceptable = []

    R₂ᵥ = []

    δLʳᵉᶜ₂ᵥ = []

    Fᵁⁱ₂ᵥ = []

    ϕᵃᶜᵗᶸᵃˡ = []

    Fᴱⁱᵥ = []

    ΔδL₂ˢᵥ = []

    ΔFᴱ₂ˢᵥ = []
    
    cs_area, E, mass, g, nNodes, tWidth, nHeight, ex_type, ex_scale, σᵤʳᵉˡ, σᵤ, σₗ = Structure(structure)

    state, δLᶠ, Vₑₓ, Fᵁᶠ, Vₑᵁ = ForwardAnalysis(cs_area, E, mass, g, nNodes, tWidth, nHeight, ex_type, ex_scale, folder_name, folder_path; displayTower = displayTower, saveTower = saveTower, drawForces = drawForces)

    state⁰, δLᶠ⁰, Vₑₓ⁰, Fᵁᶠ⁰, Vₑᵁ⁰ = ForwardAnalysis(cs_area, E, mass, g, nNodes, tWidth, nHeight, ex_type, 0., folder_name, folder_path; displayTower = displayTower, saveTower = saveTower, drawForces = drawForces)

    # Adding measurement error to δLᶠ
    δLₑᵣᵣ = [randn()*σₗ + i for i in δLᶠ]

    Vₑₘ, δLₘ = MeasuredElements(measurements, Vₑₓ, δLₑᵣᵣ)

    ηᵟᴸ = sqrt(length(δLₘ)) * σₗ
    ηᶠᵉ = sqrt(nNodes-2) * σᵤ

    for ϕ in ϕᵥ

        println("ϕ før: ", ϕ)
        #global η
        #global Fᴱˢᶜᵃˡᵉ

        try
            # β = 1/α 
            β = ηᶠᵉ^2 /(ηᵟᴸ^2 * ϕ)
            println("Før inverse")
            stateXUA, δLⁱ, Fᵁⁱ  = InverseAnalysis(cs_area, E, mass, g, nNodes, tWidth, nHeight, δLₘ, Vₑₘ, β, ex_scale, folder_name, folder_path, ϕ; displayTower = displayTower, saveTower = saveTower, drawForces = drawForces)
            println("etter inverse")
            Vₑₘ, δLʳᵉᶜ = MeasuredElements(measurements, Vₑₓ, δLⁱ)
        
            println("før errorhandling")
            
            # Reconstructed error
            ΔδL₂ = norm(δLᶠ-δLⁱ, 2)
            ΔδL⁰₂ = norm(δLᶠ-δLᶠ⁰, 2)
            ΔδL₂ˢᶜᵃˡᵉᵈ  = ΔδL₂/ΔδL⁰₂
            append!(ΔδL₂ˢᵥ, ΔδL₂ˢᶜᵃˡᵉᵈ)

            # Scaled external forces error
            ΔFᴱ₂ = norm(Fᵁᶠ-Fᵁⁱ, 2)
            ΔFᴱ₂ˢᶜᵃˡᵉᵈ = ΔFᴱ₂/ηᶠᵉ
            append!(ΔFᴱ₂ˢᵥ, ΔFᴱ₂ˢᶜᵃˡᵉᵈ)

            # Drawing error
            # plotte i forhold til σ's 
            println("før saveresults")
            if saveResults
                SaveResults(structure, measurements, folder_name, folder_path, ϕ, ρ, Nʳʰᴼ, cs_area, E, mass, g, nNodes, tWidth, nHeight, ex_type, ex_scale, σₗ, σᵤʳᵉˡ, σᵤ, δLᶠ, δLⁱ, Fᵁᶠ, Fᵁⁱ, ΔδL, ΔδL∞, ΔδL₂, ΔFᵁ, ΔFᵁ∞, ΔFᵁ₂, σᵤ∞ˢ, σᵤ₂ˢ, ΔFᵁ∞ˢ, ΔFᵁ₂ˢ)
            end
        
            # residal
            R = δLʳᵉᶜ - δLₘ
            println("etter drawerrors")
            # Norm of residual
            R₂ = norm(R, 2)
            δLʳᵉᶜ₂ = norm(δLʳᵉᶜ, 2)
            Fᵁⁱ₂ = norm(Fᵁⁱ, 2)

            append!(R₂ᵥ, R₂)
            append!(δLʳᵉᶜ₂ᵥ, δLʳᵉᶜ₂)
            append!(Fᵁⁱ₂ᵥ, Fᵁⁱ₂)
            append!(ϕᵃᶜᵗᶸᵃˡ, [ϕ])
            push!(Fᴱⁱᵥ, Fᵁⁱ)
            println("etter push")
            if R₂ < ηᵟᴸ
                #println("R₂ < η")
                #println("ϕ: ", ϕ)
                #println("R₂: ", R₂)
                #println("η: ", η)
                append!(ϕ_acceptable, ["Y"])
            else
                #println("R₂ !< η")
                #println("ϕ: ", ϕ)
                #println("R₂: ", R₂)
                #println("η: ", η)
                append!(ϕ_acceptable, ["N"])
            end
            println("klarte det")
        catch
            println("ϕ: ", ϕ)
            continue
        end

        

    end
    println("etter inverse")
    #remove completely wrong results

    #####################
    #Fᵁⁱ₂ᵥᵐᵉᵈⁱᵃⁿ = median(Fᵁⁱ₂ᵥ)
    #indʳᵉᵐᴼᵛᵉ₁ = findall(x->x>1.e-3, R₂ᵥ)
    
    #Passer til n = 50 nodes, ex_scale = 100
    #indʳᵉᵐᴼᵛᵉ₁ = findall(x->x>1.e4, R₂ᵥ)
    #indʳᵉᵐᴼᵛᵉ₂ = findall(x->x>1.e3, Fᵁⁱ₂ᵥ)
    #indʳᵉᵐᴼᵛᵉ₃ = findall(x->x<1.e-8, R₂ᵥ)

    # n = 100 nodes, ex_scale = 1000
    #indʳᵉᵐᴼᵛᵉ₁ = findall(x->x>2.e-2, R₂ᵥ)
    #indʳᵉᵐᴼᵛᵉ₂ = findall(x->x>1.e4, Fᵁⁱ₂ᵥ)
    #indʳᵉᵐᴼᵛᵉ₃ = findall(x->x<1.e-10, R₂ᵥ)

        
    #Passer til n = 100 nodes, ex_scale = 100
    indʳᵉᵐᴼᵛᵉ₁ = findall(x->x>1.e4, R₂ᵥ)
    indʳᵉᵐᴼᵛᵉ₂ = findall(x->x>1.e4, Fᵁⁱ₂ᵥ)
    indʳᵉᵐᴼᵛᵉ₃ = findall(x->x<1.e-8, R₂ᵥ)

    println("etter indremove")
    #indʳᵉᵐᴼᵛᵉ₁ = []
    #indʳᵉᵐᴼᵛᵉ₂ = []
    #indʳᵉᵐᴼᵛᵉ₃ = []

    #println("Fᵁⁱ₂ᵥᵐᵉᵈⁱᵃⁿ: ", Fᵁⁱ₂ᵥᵐᵉᵈⁱᵃⁿ)
    #println("Fᵁⁱ₂ᵥ before: ", Fᵁⁱ₂ᵥ)
    #println(indʳᵉᵐᴼᵛᵉ₁)
    #println(indʳᵉᵐᴼᵛᵉ₂)

    append!(indʳᵉᵐᴼᵛᵉ₁, indʳᵉᵐᴼᵛᵉ₂)
    append!(indʳᵉᵐᴼᵛᵉ₁, indʳᵉᵐᴼᵛᵉ₃)

    indʳᵉᵐᴼᵛᵉ = [key for (key, val) in countmap(indʳᵉᵐᴼᵛᵉ₁)]
    sort!(indʳᵉᵐᴼᵛᵉ)
    #println("length(ϕᵥ): ", length(ϕᵥ))
    #println("length(indʳᵉᵐᴼᵛᵉ): ", length(indʳᵉᵐᴼᵛᵉ))

    #println(indʳᵉᵐᴼᵛᵉ)

    ####################
    println("etter indremove2bogaloo")

    #indʳᵉᵐᴼᵛᵉ = findall(x->x>1.e-3, R₂ᵥ)
    println("length(ϕᵃᶜᵗᶸᵃˡ): ", length(ϕᵃᶜᵗᶸᵃˡ))
    deleteat!(ϕᵃᶜᵗᶸᵃˡ, indʳᵉᵐᴼᵛᵉ)
    deleteat!(R₂ᵥ, indʳᵉᵐᴼᵛᵉ)
    deleteat!(Fᵁⁱ₂ᵥ, indʳᵉᵐᴼᵛᵉ)
    deleteat!(Fᴱⁱᵥ, indʳᵉᵐᴼᵛᵉ)
    deleteat!(ΔδL₂ˢᵥ, indʳᵉᵐᴼᵛᵉ)
    deleteat!(ΔFᴱ₂ˢᵥ, indʳᵉᵐᴼᵛᵉ)
    println("etter delete")
    println("length(ϕᵃᶜᵗᶸᵃˡ): ", length(ϕᵃᶜᵗᶸᵃˡ))

    # Quasi-optimality:
    Fᴱⁱˢᵈ = Fᴱⁱᵥ[1:end-1] - Fᴱⁱᵥ[2:end]
    Fᴱⁱˢᵈ₂  = [norm(i, 2) for i in Fᴱⁱˢᵈ]
    QOⁱⁿᵈᵉˣ = argmin(Fᴱⁱˢᵈ₂)+1


    Fᵁⁱ₂ᵥˢᶜᵃˡᵉᵈ = Fᵁⁱ₂ᵥ./ηᶠᵉ
    R₂ᵥˢᶜᵃˡᵉᵈ = R₂ᵥ./ηᵟᴸ

    println("etter scale")

    #println("length(ϕᵃᶜᵗᶸᵃˡ) after removing: ", length(ϕᵃᶜᵗᶸᵃˡ))

    #println("R₂ᵥ after: ", R₂ᵥ)

    #println("Fᵁⁱ₂ᵥ after: ", Fᵁⁱ₂ᵥ)
    #println("Fᵁⁱ₂ᵥ/Median: ", Fᵁⁱ₂ᵥ./Fᵁⁱ₂ᵥᵐᵉᵈⁱᵃⁿ)


    #println("ϕᵥ: ", ϕᵥ)
    #println("ϕ_acceptable: ", ϕ_acceptable)

    logFᵁⁱ₂ᵥˢᶜᵃˡᵉᵈ = log10.(Fᵁⁱ₂ᵥˢᶜᵃˡᵉᵈ)
    logR₂ᵥˢᶜᵃˡᵉᵈ = log10.(R₂ᵥˢᶜᵃˡᵉᵈ)
    logϕᵃᶜᵗᶸᵃˡ = log10.(ϕᵃᶜᵗᶸᵃˡ)
    logΔδL₂ˢ = log10.(ΔδL₂ˢᵥ)
    logΔFᴱ₂ˢ = log10.(ΔFᴱ₂ˢᵥ)

    indᶠᵉ₋₀ = max(findfirst(x->x>0, logFᵁⁱ₂ᵥˢᶜᵃˡᵉᵈ)-1,1)
    indᴿ₋₀ = findfirst(x->x<0, logR₂ᵥˢᶜᵃˡᵉᵈ)

    #ϕᶠᵉ₋₀ = ϕᵃᶜᵗᶸᵃˡ[indᶠᵉ₋₀]
    #ϕᵟᴸ₋₀ = ϕᵃᶜᵗᶸᵃˡ[indᴿ₋₀]

    #Fᴱ₋₀ = logFᵁⁱ₂ᵥˢᶜᵃˡᵉᵈ[indᶠᵉ₋₀]
    #R₋₀ = logR₂ᵥˢᶜᵃˡᵉᵈ[indᴿ₋₀]
    DrawErrors(structure, measurements, folder_name, folder_path, logϕᵃᶜᵗᶸᵃˡ, indᶠᵉ₋₀, indᴿ₋₀, QOⁱⁿᵈᵉˣ, logΔδL₂ˢ, logΔFᴱ₂ˢ; displayError = displayError, saveError = saveError)
    println("før discr")
    DrawDiscrepancy(structure, measurements, folder_name, folder_path, ρ, Nʳʰᴼ, ϕᵃᶜᵗᶸᵃˡ, R₂ᵥˢᶜᵃˡᵉᵈ, Fᵁⁱ₂ᵥˢᶜᵃˡᵉᵈ, ηᵟᴸ/ηᵟᴸ, indᶠᵉ₋₀, indᴿ₋₀, QOⁱⁿᵈᵉˣ; displayDiscrepancy = displayDiscrepancy, saveDiscrepancy = saveDiscrepancy)
    println("før lcurve")
    DrawLCurve(structure, measurements, folder_name, folder_path, ρ, Nʳʰᴼ, ϕᵃᶜᵗᶸᵃˡ, logFᵁⁱ₂ᵥˢᶜᵃˡᵉᵈ, logR₂ᵥˢᶜᵃˡᵉᵈ, indᶠᵉ₋₀, indᴿ₋₀, QOⁱⁿᵈᵉˣ; displayLCurve = displayLCurve, saveLCurve = saveLCurve)
    println("Ferdig")

end


displayTower = false
saveTower = false
drawForces = false
saveResults = false # Må evnt skrive om til å ta for seg flere kjøringer per log
displayError = false 
saveError = true
displayDiscrepancy = false
saveDiscrepancy = true
displayLCurve = false
saveLCurve = true
testRegStrat = false

#structure = "test"
#structure = "draw_tower_50"
#structure = "20_nodes"
structure = "100_nodes"
#structure = "50_nodes"
#structure = "100_nodes_test"
#structure = "100_nodes_test_soft"
#structure = "100_nodes_test2"
#measurements = "tenth"
measurements = "second"
#measurements = "every"
#measurements = "twentyfifth"
#measurements = "single"

#ρ  = 0.5
#ρᵥ  = collect(0.1:0.1:0.9)
ρᵥ = [0.9]

Nʳʰᴼ = 200

for ρ in ρᵥ

ϕᵥ = [ρ^n for n in -Nʳʰᴼ:5:Nʳʰᴼ]

#ϕᵥ = [ρ]

#Creating folder for figures
dir_path = "./results/"
folder_name = GenerateFolderName(structure, measurements, ρ, Nʳʰᴼ, dir_path)
folder_path = abspath(joinpath(dir_path, folder_name))
mkpath(folder_path)

RunFullAnalysis(structure, measurements, ϕᵥ, ρ, Nʳʰᴼ, folder_name, folder_path; displayTower = displayTower, saveTower = saveTower, drawForces = drawForces, saveResults = saveResults, displayError = displayError, saveError = saveError, displayDiscrepancy = displayDiscrepancy, saveDiscrepancy = saveDiscrepancy, displayLCurve = displayLCurve, saveLCurve = saveLCurve, testRegStrat = testRegStrat)

#σᵥ = [0.5^n for n=-30:1:30]

#TestRegStrat(structure, measurements, σᵥ, folder_name, folder_path; displayRegStrat = false, saveRegStrat = true)

#DrawSingleBar(folder_name, folder_path;displayBar = true, saveBar = true)

#println("log||Fᴱ|| > 0 at ϕ = ", ϕᵃᶜᵗᶸᵃˡ[indᶠᵉ₋₀+1])
#println("log||R|| < 0 at ϕ = ", ϕᵃᶜᵗᶸᵃˡ[indᴿ₋₀])

#println("log||Fᴱ|| < 0 at ϕ = ", ϕᵃᶜᵗᶸᵃˡ[indᶠᵉ₋₀])
#println("log||R|| > 0 at ϕ = ", ϕᵃᶜᵗᶸᵃˡ[indᴿ₋₀-1])

end