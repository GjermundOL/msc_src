using Muscade
using StaticArrays
using LinearAlgebra
using MasterTask

function GenerateFileName(Title, dir_path, filetype)
    file_nr = 1
    free_nr = false
    while !free_nr
        file_name = "$(Title)_$(file_nr)$(filetype)"
        if !isfile(abspath(joinpath(dir_path, file_name)))
            return file_name
        else
            file_nr += 1
        end
    end
end

function GenerateFolderName(structure, measurements, ρ, Nʳʰᴼ, dir_path)
    folder_nr = 1
    free_nr = false

    rho = replace("$(ρ)", "." => "o")
    
    while !free_nr
        folder_name = "$(structure)__$(measurements)__rho_$(rho)__Nrho_$(Nʳʰᴼ)__$(folder_nr)"
        if !isdir(abspath(joinpath(dir_path, folder_name)))
            return folder_name
        else
            folder_nr += 1
        end
    end
end

function SaveResults(structure, measurements, folder_name, folder_path, ϕ, ρ, Nʳʰᴼ, cs_area, E, mass, g, nNodes, tWidth, nHeight, ex_type, ex_scale, σₗ, σᵤʳᵉˡ, σᵤ, δLᶠ, δLⁱ, Fᵁᶠ, Fᵁⁱ, ΔδL, ΔδL∞, ΔδL₂, ΔFᵁ, ΔFᵁ∞, ΔFᵁ₂, σᵤ∞ˢ, σᵤ₂ˢ, ΔFᵁ∞ˢ, ΔFᵁ₂ˢ)
    

    dir_path = abspath(joinpath(folder_path, "logs"))
    mkpath(dir_path)
    file_name = GenerateFileName("log__phi_$(ϕ)", dir_path, ".txt")

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
        println(file, "ϕ:\t", ϕ)
        println(file, "ρ:\t", ρ)
        println(file, "Nʳʰᴼ:\t", Nʳʰᴼ)
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