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

function SaveFullResults(structure, measurements, folder_name, folder_path, α₀, ηˢ, ηᶠ, ρ, Nʳʰᴼ, nᵃᶜᵗᶸᵃˡ, ϕᵃᶜᵗᶸᵃˡ, r₂ᵥₛ, Fᴱⁱ₂ᵥₛ, ΔSᵐ₂ₛᵥ, ΔSᵐ⁻¹₂ₛᵥ, ΔFᴱ₂ₛᵥ, indᶠᵉ₋₀, indᴿ₋₀, QOⁱⁿᵈᵉˣ, indΔSᵐₘᵢₙ, indΔSᵐ⁻¹ₘᵢₙ, indΔFᴱₘᵢₙ)
    
    
    file_name = "log_$(folder_name).txt"

    full_path = abspath(joinpath(folder_path, file_name))
    
    open(full_path, "w") do file

        println(file, "Solved for:")
        println(file, "ρ:\t", ρ)
        println(file, "Nʳʰᴼ:\t", Nʳʰᴼ)
        println(file, "α₀:\t", round(α₀, sigdigits = 4))
        println(file, "ηˢ:\t", round(ηˢ, sigdigits = 4))
        println(file, "ηᶠ:\t", round(ηᶠ, sigdigits = 4))
        println(file, "\n")

        println(file, "Stable for:")
        println(file, nᵃᶜᵗᶸᵃˡ[1], " ≤ n ≤ ", nᵃᶜᵗᶸᵃˡ[end])
        println(file, round(ϕᵃᶜᵗᶸᵃˡ[1], sigdigits = 4), " ≤ ϕ ≤ ", round(ϕᵃᶜᵗᶸᵃˡ[end], sigdigits = 4))
        println(file, "\n")

        if !isnan(indᴿ₋₀)
            println(file, "||r|| < ηˢ:")
            println(file, "n:\t", nᵃᶜᵗᶸᵃˡ[indᴿ₋₀])
            println(file, "ϕ:\t", round( ϕᵃᶜᵗᶸᵃˡ[indᴿ₋₀], sigdigits = 4))
            println(file, "||r||:\t", round( r₂ᵥₛ[indᴿ₋₀], sigdigits = 4))
            println(file, "||Fᴱ||:\t", round( Fᴱⁱ₂ᵥₛ[indᴿ₋₀], sigdigits = 4))
            println(file, "||ΔSᴹ||:\t", round( ΔSᵐ₂ₛᵥ[indᴿ₋₀], sigdigits = 4))
            println(file, "||ΔSᵁ||:\t", round( ΔSᵐ⁻¹₂ₛᵥ[indᴿ₋₀], sigdigits = 4))
            println(file, "||ΔFᴱ||:\t", round( ΔFᴱ₂ₛᵥ[indᴿ₋₀], sigdigits = 4))
            println(file, "\n")
        else
            println(file, "||r|| < ηˢ:", indᴿ₋₀)
            println(file, "\n")
        end
        if !isnan(indᶠᵉ₋₀)
            println(file, "||Fᴱ|| < ηᶠ:")
            println(file, "n:\t", nᵃᶜᵗᶸᵃˡ[indᶠᵉ₋₀])
            println(file, "ϕ:\t", round( ϕᵃᶜᵗᶸᵃˡ[indᶠᵉ₋₀], sigdigits = 4))
            println(file, "||r||:\t", round( r₂ᵥₛ[indᶠᵉ₋₀], sigdigits = 4))
            println(file, "||Fᴱ||:\t", round( Fᴱⁱ₂ᵥₛ[indᶠᵉ₋₀], sigdigits = 4))
            println(file, "||ΔSᴹ||:\t", round( ΔSᵐ₂ₛᵥ[indᶠᵉ₋₀], sigdigits = 4))
            println(file, "||ΔSᵁ||:\t", round( ΔSᵐ⁻¹₂ₛᵥ[indᶠᵉ₋₀], sigdigits = 4))
            println(file, "||ΔFᴱ||:\t", round( ΔFᴱ₂ₛᵥ[indᶠᵉ₋₀], sigdigits = 4))
            println(file, "\n")
        else
            println(file, "||Fᴱ|| < ηᶠ:", indᶠᵉ₋₀)
            println(file, "\n")
        end
        println(file, "Fᴱₒₚₜ")
        println(file, "n:\t", nᵃᶜᵗᶸᵃˡ[QOⁱⁿᵈᵉˣ])
        println(file, "ϕ:\t", round( ϕᵃᶜᵗᶸᵃˡ[QOⁱⁿᵈᵉˣ], sigdigits = 4))
        println(file, "||r||:\t", round( r₂ᵥₛ[QOⁱⁿᵈᵉˣ], sigdigits = 4))
        println(file, "||Fᴱ||:\t", round( Fᴱⁱ₂ᵥₛ[QOⁱⁿᵈᵉˣ], sigdigits = 4))
        println(file, "||ΔSᴹ||:\t", round( ΔSᵐ₂ₛᵥ[QOⁱⁿᵈᵉˣ], sigdigits = 4))
        println(file, "||ΔSᵁ||:\t", round( ΔSᵐ⁻¹₂ₛᵥ[QOⁱⁿᵈᵉˣ], sigdigits = 4))
        println(file, "||ΔFᴱ||:\t", round( ΔFᴱ₂ₛᵥ[QOⁱⁿᵈᵉˣ], sigdigits = 4))
        println(file, "\n")

        println(file, "min(ΔSᴹ)")
        println(file, "n:\t", nᵃᶜᵗᶸᵃˡ[indΔSᵐₘᵢₙ])
        println(file, "ϕ:\t", round( ϕᵃᶜᵗᶸᵃˡ[indΔSᵐₘᵢₙ], sigdigits = 4))
        println(file, "||r||:\t", round( r₂ᵥₛ[indΔSᵐₘᵢₙ], sigdigits = 4))
        println(file, "||Fᴱ||:\t", round( Fᴱⁱ₂ᵥₛ[indΔSᵐₘᵢₙ], sigdigits = 4))
        println(file, "||ΔSᴹ||:\t", round( ΔSᵐ₂ₛᵥ[indΔSᵐₘᵢₙ], sigdigits = 4))
        println(file, "||ΔSᵁ||:\t", round( ΔSᵐ⁻¹₂ₛᵥ[indΔSᵐₘᵢₙ], sigdigits = 4))
        println(file, "||ΔFᴱ||:\t", round( ΔFᴱ₂ₛᵥ[indΔSᵐₘᵢₙ], sigdigits = 4))
        println(file, "\n")

        println(file, "min(ΔSᵁ)")
        println(file, "n:\t", nᵃᶜᵗᶸᵃˡ[indΔSᵐ⁻¹ₘᵢₙ])
        println(file, "ϕ:\t", round( ϕᵃᶜᵗᶸᵃˡ[indΔSᵐ⁻¹ₘᵢₙ], sigdigits = 4))
        println(file, "||r||:\t", round( r₂ᵥₛ[indΔSᵐ⁻¹ₘᵢₙ], sigdigits = 4))
        println(file, "||Fᴱ||:\t", round( Fᴱⁱ₂ᵥₛ[indΔSᵐ⁻¹ₘᵢₙ], sigdigits = 4))
        println(file, "||ΔSᴹ||:\t", round( ΔSᵐ₂ₛᵥ[indΔSᵐ⁻¹ₘᵢₙ], sigdigits = 4))
        println(file, "||ΔSᵁ||:\t", round( ΔSᵐ⁻¹₂ₛᵥ[indΔSᵐ⁻¹ₘᵢₙ], sigdigits = 4))
        println(file, "||ΔFᴱ||:\t", round( ΔFᴱ₂ₛᵥ[indΔSᵐ⁻¹ₘᵢₙ], sigdigits = 4))
        println(file, "\n")

        println(file, "min(ΔFᴱ)")
        println(file, "n:\t", nᵃᶜᵗᶸᵃˡ[indΔFᴱₘᵢₙ])
        println(file, "ϕ:\t", round( ϕᵃᶜᵗᶸᵃˡ[indΔFᴱₘᵢₙ], sigdigits = 4))
        println(file, "||r||:\t", round( r₂ᵥₛ[indΔFᴱₘᵢₙ], sigdigits = 4))
        println(file, "||Fᴱ||:\t", round( Fᴱⁱ₂ᵥₛ[indΔFᴱₘᵢₙ], sigdigits = 4))
        println(file, "||ΔSᴹ||:\t", round( ΔSᵐ₂ₛᵥ[indΔFᴱₘᵢₙ], sigdigits = 4))
        println(file, "||ΔSᵁ||:\t", round( ΔSᵐ⁻¹₂ₛᵥ[indΔFᴱₘᵢₙ], sigdigits = 4))
        println(file, "||ΔFᴱ||:\t", round( ΔFᴱ₂ₛᵥ[indΔFᴱₘᵢₙ], sigdigits = 4))
        println(file, "\n")

    end
end