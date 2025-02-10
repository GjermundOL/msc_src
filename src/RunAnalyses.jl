using Muscade
using StaticArrays
using LinearAlgebra
using MasterTask
using GLMakie
using DelimitedFiles
using StatsBase

const 𝕣 = Float64

function RunSingleAnalysis(structure, measurements, folder_name, folder_path, ϕ, ρ, Nʳʰᴼ; displayTower = false, saveTower = false, drawForces = false, saveResults = false, displayError = false, saveError = false)

    Aᶜˢ, E, density, g, nNodes, tWidth, nHeight, ex_type, ex_scale, σᶠʳᵉˡ, σᶠ, σˢ = Structure(structure)

    state, Sᵗ, Vₑₓ, Fᴱᶠ, Vₑᶠ = ForwardAnalysis(Aᶜˢ, E, density, g, nNodes, tWidth, nHeight, ex_type, ex_scale, folder_name, folder_path; displayTower = displayTower, saveTower = saveTower, drawForces = drawForces)

    Sₑᵣᵣ = [randn()*σˢ + i for i in Sᵗ]

    # β = 1/α 
    β = σᶠ^2 /(σˢ^2 * ϕ)

    Vₑₘ, Sᵐ, Sᵐ⁻¹ = MeasuredElements(measurements, Vₑₓ, Sₑᵣᵣ)

    stateXUA, Sⁱ, Fᴱⁱ  = InverseAnalysis(Aᶜˢ, E, density, g, nNodes, tWidth, nHeight, Sᵐ, Vₑₘ, β, ex_scale, folder_name, folder_path, ϕ; displayTower = displayTower, saveTower = saveTower, drawForces = drawForces)

    Vₑₘ, Sʳ, Sʳ⁻¹ = MeasuredElements(measurements, Vₑₓ, Sⁱ)

    η = sqrt(length(Sʳ)) * σˢ

    Fᴱₛ = sqrt(nNodes-2)*ex_scale 

    Fᶠₜₒₜ = ExtractForces(state, Vₑₓ, Fᴱᶠ, nNodes)
    Fᶠₜₒₜ∞ = norm(Fᶠₜₒₜ, Inf)
    Fᶠₜₒₜ₂ = norm(Fᶠₜₒₜ, 2)

    ΔS = abs.(Sᵗ - Sⁱ)
    ΔS∞  = norm(ΔS, Inf)
    ΔS₂ = norm(ΔS, 2)

    ΔFᴱ = abs.(Fᴱᶠ-Fᴱⁱ)
    ΔFᴱ∞ = round(norm(ΔFᴱ, Inf); digits = 3)
    ΔFᴱ₂ = round(norm(ΔFᴱ, 2); digits = 3)

    σᶠ∞ₛ = σᶠ/Fᶠₜₒₜ∞
    σᶠ₂ₛ = σᶠ/Fᶠₜₒₜ₂
    ΔFᴱ∞ₛ = ΔFᴱ∞/Fᶠₜₒₜ∞
    ΔFᴱ₂ₛ = ΔFᴱ₂/Fᶠₜₒₜ₂

    if saveResults
        SaveResults(structure, measurements, folder_name, folder_path, ϕ, ρ, Nʳʰᴼ, Aᶜˢ, E, density, g, nNodes, tWidth, nHeight, ex_type, ex_scale, σˢ, σᶠʳᵉˡ, σᶠ, Sᵗ, Sⁱ, Fᴱᶠ, Fᴱⁱ, ΔS, ΔS∞, ΔS₂, ΔFᴱ, ΔFᴱ∞, ΔFᴱ₂, σᶠ∞ₛ, σᶠ₂ₛ, ΔFᴱ∞ₛ, ΔFᴱ₂ₛ)
    end

    DrawSingleErrors(structure, measurements, folder_name, folder_path, ϕ, ρ, Nʳʰᴼ, σˢ, σᶠ∞ₛ, σᶠ₂ₛ, ΔS∞, ΔS₂, ΔFᴱ∞ₛ, ΔFᴱ₂ₛ; displayError = displayError, saveError = saveError)

return σˢ, σᶠ∞ₛ, σᶠ₂ₛ, ΔS∞, ΔS₂, ΔFᴱ∞ₛ, ΔFᴱ₂ₛ, Vₑₘ, Sᵐ, Sʳ, η, Fᴱₛ, Fᴱⁱ
end

function RunFullAnalysis(structure, measurementsᵥ, ρ, Nʳʰᴼ, nˢᵗᵉᵖˢ; displayTower = false, saveTower = false, drawForces = false, saveResults = false, displayError = false, saveError = false, displayDiscrepancy = false, saveDiscrepancy = false, displayLCurve = false, saveLCurve = false, testRegStrat = false)
    
    dir_path = abspath(joinpath("./results/", "$(ρ)"))
    folder_name = GenerateFolderName(structure, "forward", ρ, Nʳʰᴼ, dir_path)
    folder_path = abspath(joinpath(dir_path, folder_name))
    mkpath(folder_path)
    
    Aᶜˢ, E, density, g, nNodes, tWidth, nHeight, ex_type, ex_scale, σᶠʳᵉˡ, σᶠ, σˢ = Structure(structure)

    state, Sᵗ, Vₑₓ, Fᴱᶠ, Vₑᶠ = ForwardAnalysis(Aᶜˢ, E, density, g, nNodes, tWidth, nHeight, ex_type, ex_scale, folder_name, folder_path; displayTower = displayTower, saveTower = saveTower, drawForces = drawForces)

    state⁰, Sᵗ⁰, Vₑₓ⁰, Fᴱᶠ⁰, Vₑᶠ⁰ = ForwardAnalysis(Aᶜˢ, E, density, g, nNodes, tWidth, nHeight, "test", 0., folder_name, folder_path)
    
    for measurements in measurementsᵥ
        
        dir_path = abspath(joinpath("./results/", "$(ρ)"))
        folder_name = GenerateFolderName(structure, measurements, ρ, Nʳʰᴼ, dir_path)
        folder_path = abspath(joinpath(dir_path, folder_name))
        mkpath(folder_path)

        if testRegStrat
            αᵥ = [0.5^n for n=-50:1:50]
            TestRegStrat(structure, measurements, αᵥ, folder_name, folder_path; displayRegStrat = false, saveRegStrat = true)
            σᵥ = [0.5^n for n=-50:1:50]
            TestRegStratParameter(structure, measurements, σᵥ, folder_name, folder_path; displayRegStrat = false, saveRegStrat = true)
        end

        r₂ᵥ = []

        Sʳ₂ᵥ = []

        Fᴱⁱ₂ᵥ = []

        ϕᵃᶜᵗᶸᵃˡ = []

        nᵃᶜᵗᶸᵃˡ = []

        Fᴱⁱᵥ = []

        ΔSᵐ₂ₛᵥ = []

        ΔSᵐ⁻¹₂ₛᵥ = []

        ΔFᴱ₂ₛᵥ = [] 
        
        Sₑᵣᵣ = [randn()*σˢ + i for i in Sᵗ] 

        Vₑₘ, Sᵐ, Sᵐ⁻¹ = MeasuredElements(measurements, Vₑₓ, Sₑᵣᵣ)

        ηˢ = sqrt(length(Sᵐ)) * σˢ
        ηᶠ = sqrt(nNodes-2) * σᶠ 

        α₀ = ηˢ^2 / ηᶠ^2

        nᵥ = [n for n in -Nʳʰᴼ:nˢᵗᵉᵖˢ:Nʳʰᴼ]

        for n in nᵥ

            ϕ = ρ^n

            try
                # β = 1/α 
                β = 1 /(α₀ * ϕ)

                stateXUA, Sⁱ, Fᴱⁱ  = InverseAnalysis(Aᶜˢ, E, density, g, nNodes, tWidth, nHeight, Sᵐ, Vₑₘ, β, ex_scale, folder_name, folder_path, ϕ; displayTower = displayTower, saveTower = saveTower, drawForces = drawForces)

                Sʳ, Sʳ⁻¹ = MeasuredElements(measurements, Vₑₓ, Sⁱ)[2:3]
            
                Sᵗᵐ, Sᵗᵐ⁻¹ = MeasuredElements(measurements, Vₑₓ, Sᵗ)[2:3]
                Sᵗ⁰ᵐ, Sᵗ⁰ᵐ⁻¹ = MeasuredElements(measurements, Vₑₓ, Sᵗ⁰)[2:3]

                ΔSᵐ₂ = norm(Sᵗᵐ-Sʳ, 2)
                ΔS⁰ᵐ₂ = norm(Sᵗᵐ-Sᵗ⁰ᵐ, 2)
                ΔSᵐ₂ₛ  = ΔSᵐ₂/ΔS⁰ᵐ₂
                append!(ΔSᵐ₂ₛᵥ, ΔSᵐ₂ₛ)

                if measurements == "every"
                    append!(ΔSᵐ⁻¹₂ₛᵥ, NaN)
                else
                    ΔSᵐ⁻¹₂ = norm(Sᵗᵐ⁻¹-Sʳ⁻¹, 2)
                    ΔSᵐ⁻¹⁰₂ = norm(Sᵗᵐ⁻¹-Sᵗ⁰ᵐ⁻¹, 2)
                    ΔSᵐ⁻¹₂ₛ  = ΔSᵐ⁻¹₂/ΔSᵐ⁻¹⁰₂
                    append!(ΔSᵐ⁻¹₂ₛᵥ, ΔSᵐ⁻¹₂ₛ)
                end

                ΔFᴱ₂ = norm(Fᴱᶠ-Fᴱⁱ, 2)
                ΔFᴱ₂ₛ = ΔFᴱ₂/ηᶠ
                append!(ΔFᴱ₂ₛᵥ, ΔFᴱ₂ₛ)

                r = Sʳ - Sᵐ
                r₂ = norm(r, 2)
                Sʳ₂ = norm(Sʳ, 2)
                Fᴱⁱ₂ = norm(Fᴱⁱ, 2)

                append!(r₂ᵥ, r₂)
                append!(Sʳ₂ᵥ, Sʳ₂)
                append!(Fᴱⁱ₂ᵥ, Fᴱⁱ₂)
                append!(ϕᵃᶜᵗᶸᵃˡ, [ϕ])
                append!(nᵃᶜᵗᶸᵃˡ, [n])
                push!(Fᴱⁱᵥ, Fᴱⁱ)
            catch
                println("ϕ: ", ϕ)
                continue
            end

            

        end

        Fᴱⁱ₂ᵥₛ = Fᴱⁱ₂ᵥ./ηᶠ
        r₂ᵥₛ = r₂ᵥ./ηˢ 

        logFᴱⁱ₂ᵥₛ = log10.(Fᴱⁱ₂ᵥₛ)
        logr₂ᵥₛ = log10.(r₂ᵥₛ)
        logϕᵃᶜᵗᶸᵃˡ = log10.(ϕᵃᶜᵗᶸᵃˡ)
        logΔSᵐ₂ₛ = log10.(ΔSᵐ₂ₛᵥ)
        logΔSᵐ⁻¹₂ₛ = log10.(ΔSᵐ⁻¹₂ₛᵥ)
        logΔFᴱ₂ₛ = log10.(ΔFᴱ₂ₛᵥ)

        indʳᵉᵐᴼᵛᵉ₁ = findall(x->x> 0.5 + logr₂ᵥₛ[1], logr₂ᵥₛ)
        indᵩᶠˡᵃᵗ = findfirst(x->x<-5, logϕᵃᶜᵗᶸᵃˡ)
        indʳᵉᵐᴼᵛᵉ₂ = findall(x->x> 0.1 + logFᴱⁱ₂ᵥₛ[indᵩᶠˡᵃᵗ], logFᴱⁱ₂ᵥₛ)
        if length(indʳᵉᵐᴼᵛᵉ₂)>= 1
            indʳᵉᵐᴼᵛᵉ₃ = collect(Int64, indʳᵉᵐᴼᵛᵉ₂[1]:length(logFᴱⁱ₂ᵥₛ))
        else
            indʳᵉᵐᴼᵛᵉ₃ = []
        end

        append!(indʳᵉᵐᴼᵛᵉ₁, indʳᵉᵐᴼᵛᵉ₂)
        append!(indʳᵉᵐᴼᵛᵉ₁, indʳᵉᵐᴼᵛᵉ₃)

        indʳᵉᵐᴼᵛᵉ = [key for (key, val) in countmap(indʳᵉᵐᴼᵛᵉ₁)]
        sort!(indʳᵉᵐᴼᵛᵉ)

        deleteat!(ϕᵃᶜᵗᶸᵃˡ, indʳᵉᵐᴼᵛᵉ)
        deleteat!(nᵃᶜᵗᶸᵃˡ, indʳᵉᵐᴼᵛᵉ)
        deleteat!(r₂ᵥ, indʳᵉᵐᴼᵛᵉ)
        deleteat!(Fᴱⁱ₂ᵥ, indʳᵉᵐᴼᵛᵉ)
        deleteat!(Fᴱⁱᵥ, indʳᵉᵐᴼᵛᵉ)
        deleteat!(ΔSᵐ₂ₛᵥ, indʳᵉᵐᴼᵛᵉ)
        deleteat!(ΔSᵐ⁻¹₂ₛᵥ, indʳᵉᵐᴼᵛᵉ)
        deleteat!(ΔFᴱ₂ₛᵥ, indʳᵉᵐᴼᵛᵉ)
        deleteat!(logFᴱⁱ₂ᵥₛ, indʳᵉᵐᴼᵛᵉ)
        deleteat!(logr₂ᵥₛ, indʳᵉᵐᴼᵛᵉ)
        deleteat!(logϕᵃᶜᵗᶸᵃˡ, indʳᵉᵐᴼᵛᵉ)
        deleteat!(logΔSᵐ₂ₛ, indʳᵉᵐᴼᵛᵉ)
        deleteat!(logΔSᵐ⁻¹₂ₛ, indʳᵉᵐᴼᵛᵉ)
        deleteat!(logΔFᴱ₂ₛ, indʳᵉᵐᴼᵛᵉ)

        try
            global indᶠᵉ₋₀ = max(findfirst(x->x>0, logFᴱⁱ₂ᵥₛ)-1,1)
        catch
            global indᶠᵉ₋₀ = NaN
        end

        try
            global indᴿ₋₀ = findfirst(x->x<0, logr₂ᵥₛ)
        catch
            global indᴿ₋₀ = NaN
        end

        QOⁱⁿᵈᵉˣ = QuasiOptimality(logϕᵃᶜᵗᶸᵃˡ, logFᴱⁱ₂ᵥₛ, Fᴱⁱᵥ)

        indΔSᵐₘᵢₙ = argmin(ΔSᵐ₂ₛᵥ)
        indΔSᵐ⁻¹ₘᵢₙ = argmin(ΔSᵐ⁻¹₂ₛᵥ)
        indΔFᴱₘᵢₙ = argmin(ΔFᴱ₂ₛᵥ)

        DrawErrors(structure, measurements, folder_name, folder_path, logϕᵃᶜᵗᶸᵃˡ, indᶠᵉ₋₀, indᴿ₋₀, QOⁱⁿᵈᵉˣ, logΔSᵐ₂ₛ, logΔSᵐ⁻¹₂ₛ, logΔFᴱ₂ₛ; displayError = displayError, saveError = saveError)
        DrawDiscrepancy(structure, measurements, folder_name, folder_path, ρ, Nʳʰᴼ, logϕᵃᶜᵗᶸᵃˡ, logr₂ᵥₛ, logFᴱⁱ₂ᵥₛ, (ηˢ/ηˢ), indᶠᵉ₋₀, indᴿ₋₀, QOⁱⁿᵈᵉˣ; displayDiscrepancy = displayDiscrepancy, saveDiscrepancy = saveDiscrepancy)
        DrawLCurve(structure, measurements, folder_name, folder_path, ρ, Nʳʰᴼ, ϕᵃᶜᵗᶸᵃˡ, logFᴱⁱ₂ᵥₛ, logr₂ᵥₛ, indᶠᵉ₋₀, indᴿ₋₀, QOⁱⁿᵈᵉˣ; displayLCurve = displayLCurve, saveLCurve = saveLCurve)
        SaveFullResults(structure, measurements, folder_name, folder_path, α₀, ηˢ, ηᶠ, ρ, Nʳʰᴼ, nᵃᶜᵗᶸᵃˡ, ϕᵃᶜᵗᶸᵃˡ, r₂ᵥₛ, Fᴱⁱ₂ᵥₛ, ΔSᵐ₂ₛᵥ, ΔSᵐ⁻¹₂ₛᵥ, ΔFᴱ₂ₛᵥ, indᶠᵉ₋₀, indᴿ₋₀, QOⁱⁿᵈᵉˣ, indΔSᵐₘᵢₙ, indΔSᵐ⁻¹ₘᵢₙ, indΔFᴱₘᵢₙ)

    end
end

displayTower = false
saveTower = true
drawForces = true
saveResults = true
displayError = false 
saveError = true
displayDiscrepancy = false
saveDiscrepancy = true
displayLCurve = false
saveLCurve = true
testRegStrat = true

structure = "100_nodes_random"


measurementsᵥ = ["every", "tenth", "thirtyfifth", "tenth_most_low", "tenth_low", "thirtyfifth_most_low", "thirtyfifth_low", "thirtyfifth_very_low"]

ρᵥ = [0.9]

Nʳʰᴼ = 200

nˢᵗᵉᵖˢ = 2

for ρ in ρᵥ
        RunFullAnalysis(structure, measurementsᵥ, ρ, Nʳʰᴼ, nˢᵗᵉᵖˢ; displayTower = displayTower, saveTower = saveTower, drawForces = drawForces, saveResults = saveResults, displayError = displayError, saveError = saveError, displayDiscrepancy = displayDiscrepancy, saveDiscrepancy = saveDiscrepancy, displayLCurve = displayLCurve, saveLCurve = saveLCurve, testRegStrat = testRegStrat)
end