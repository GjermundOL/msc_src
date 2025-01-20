using Muscade
using StaticArrays
using LinearAlgebra
using MasterTask

function GenerateFileName(structure, measurements, dir_path, filetype)
    file_nr = 1
    free_nr = false
    while !free_nr
        file_name = "$(structure)_$(measurements)_$(file_nr)$(filetype)"
        if !isfile(abspath(joinpath(dir_path, file_name)))
            return file_name
        else
            file_nr += 1
        end
    end
end

function SaveResults(structure, measurements, cs_area, E, mass, g, nNodes, tWidth, nHeight, ex_type, ex_scale, σₗ, σᵤʳᵉˡ, σᵤ, δLᶠ, δLⁱ, Fᵁᶠ, Fᵁⁱ, ΔδL, ΔδL∞, ΔδL₂, ΔFᵁ, ΔFᵁ∞, ΔFᵁ₂, σᵤ∞ˢ, σᵤ₂ˢ, ΔFᵁ∞ˢ, ΔFᵁ₂ˢ)
    
    #println(cs_area, E, mass, g, nNodes, tWidth, nHeight, ex_type, ex_scale, σₗ, σᵤʳᵉˡ, σᵤ, δLᶠ, δLⁱ, Fᵁᶠ, Fᵁⁱ)

    dir_path = "./results/logs"
    mkpath(dir_path)
    
    #files = [f for f in readdir(dir_path) if ]

    file_name = GenerateFileName(structure, measurements, dir_path, ".txt")

    full_path = abspath(joinpath(dir_path, file_name))
    
    open(full_path, "w") do file
        println(file, "cs_area:\t", cs_area)
        println(file, "E:\t", E)
        println(file, "mass:\t", mass)
        println(file, "g:\t", g)
        println(file, "nNodes:\t", nNodes)
        println(file, "tWidth:\t", tWidth)
        println(file, "nHeight:\t", nHeight)
        println(file, "ex_type:\t", ex_type)
        println(file, "ex_scale:\t", ex_scale)
        println(file, "σₗ:\t", σₗ)
        println(file, "σᵤʳᵉˡ:\t", σᵤʳᵉˡ)
        println(file, "σᵤ:\t", σᵤ)
        println(file, "δLᶠ:\t", δLᶠ)
        println(file, "δLⁱ:\t", δLⁱ)
        println(file, "Fᵁᶠ:\t", Fᵁᶠ)
        println(file, "Fᵁⁱ:\t", Fᵁⁱ)
        println(file, "ΔδL:\t", ΔδL)
        println(file, "ΔδL∞:\t", ΔδL∞)
        println(file, "ΔδL₂:\t", ΔδL₂)
        println(file, "ΔFᵁ:\t", ΔFᵁ)
        println(file, "ΔFᵁ∞:\t", ΔFᵁ∞)
        println(file, "ΔFᵁ₂:\t", ΔFᵁ₂)
        println(file, "σᵤ∞ˢ:\t", σᵤ∞ˢ)
        println(file, "σᵤ₂ˢ:\t", σᵤ₂ˢ)
        println(file, "ΔFᵁ∞ˢ:\t", ΔFᵁ∞ˢ)
        println(file, "ΔFᵁ₂ˢ:\t", ΔFᵁ₂ˢ)
        
    end
end