using Muscade
using StaticArrays
using LinearAlgebra
using MasterTask
using GLMakie

const 𝕣 = Float64


function DrawTower(state, Title; displayTower = false, saveTower = false)
    nNodes = length(state.model.nod)
    if nNodes > 50
        yautolimit = 0.05
    else
        yautolimit = 0.1
    end
    
    GLMakie.activate!(title=Title)
    fig = Figure()
    ax = Axis(fig[1, 1], yticks = 0:round(Int, nNodes/25)*5:nNodes, xticks = 0:2, limits = (nothing, nothing, -yautolimit*nNodes, nNodes), xautolimitmargin = (0.1, 0.1), xlabel = "meter [m]", ylabel = "meter [m]")
    draw(ax,state)

    Title = replace(Title, " " => "_")
    Title = replace(Title, "," => "")

    if displayTower
        wait(display(fig))
    end

    if saveTower
        mkpath("./results/towers")
        save("./results/towers/$(Title)_$(nNodes)_nodes.png", fig)
    end

end

function DrawErrors(Title, measurements, σₗ, σᵤ∞ˢ, σᵤ₂ˢ, ΔδL∞, ΔδL₂, ΔFᵁ∞ˢ, ΔFᵁ₂ˢ; displayError = false, saveError = false)

    GLMakie.activate!(title=Title)
    fig = Figure()

    ax1 = Axis(fig[1,1], yautolimitmargin = (0.1, 0.1), xautolimitmargin = (0.1, 0.1), title = "ΔδL")
    ax2 = Axis(fig[1,2], yautolimitmargin = (0.1, 0.1), xautolimitmargin = (0.1, 0.1), title = "ΔFᵁˢ")



    lines!(ax1, 0:1, [σₗ, σₗ], label = "σₗ")
    lines!(ax1, 0:1, [ΔδL∞, ΔδL∞], label = "ΔδL∞")
    lines!(ax1, 0:1, [ΔδL₂, ΔδL₂], label = "ΔδL₂")


    lines!(ax2, 0:1, [σᵤ∞ˢ, σᵤ∞ˢ], label = "σᵤ∞ˢ")
    lines!(ax2, 0:1, [σᵤ₂ˢ, σᵤ₂ˢ], label = "σᵤ₂ˢ")
    lines!(ax2, 0:1, [ΔFᵁ∞ˢ, ΔFᵁ∞ˢ], label = "ΔFᵁ∞ˢ")
    lines!(ax2, 0:1, [ΔFᵁ₂ˢ, ΔFᵁ₂ˢ], label = "ΔFᵁ₂ˢ")

    hidexdecorations!(ax1, grid = false)
    hidexdecorations!(ax2, grid = false)

    #fig[1,2] = Legend(fig, ax1, framevisible = false)
    #fig[1,4] = Legend(fig, ax2, framevisible = false)

    axislegend(ax1, position = :rc)
    axislegend(ax2, position = :rc)


    Title = replace(Title, " " => "_")
    Title = replace(Title, "," => "")

    if displayError
        wait(display(fig))
    end
    
    if saveError
        dir_path = "./results/errors"
        mkpath(dir_path)

        file_name = GenerateFileName(Title, measurements, dir_path, ".png")

        full_path = abspath(joinpath(dir_path, file_name))

        save(full_path, fig)
    end

end

function DrawDiscrepancy(Title, measurements, ϕᵥ, R₂ᵥ, η; displayDiscrepancy = false, saveDiscrepancy = false)

    GLMakie.activate!(title=Title)
    fig = Figure()

    ax1 = Axis(fig[1,1], yautolimitmargin = (0.1, 0.1), xautolimitmargin = (0.1, 0.1), xlabel = "ϕ", ylabel = "||R||₂", xticks = ϕᵥ, title = "Discrepancy analysis")



    lines!(ax1, ϕᵥ, R₂ᵥ, label = "R₂")
    lines!(ax1, ϕᵥ, [η for ϕ in ϕᵥ], label = "η")


    #hidexdecorations!(ax1, grid = false)

    #fig[1,2] = Legend(fig, ax1, framevisible = false)
    #fig[1,4] = Legend(fig, ax2, framevisible = false)

    axislegend(ax1, position = :rc)


    Title = replace(Title, " " => "_")
    Title = replace(Title, "," => "")

    if displayDiscrepancy
        wait(display(fig))
    end
    
    if saveDiscrepancy
        dir_path = "./results/Discrepancies"
        mkpath(dir_path)

        file_name = GenerateFileName(Title, measurements, dir_path, ".png")

        full_path = abspath(joinpath(dir_path, file_name))

        save(full_path, fig)
    end
end


function DrawLCurve(Title, measurements, ϕᵥ, Fᵁⁱ₂ᵥ, R₂ᵥ; displayLCurve = false, saveLCurve = false)

    GLMakie.activate!(title=Title)
    fig = Figure()

    ax1 = Axis(fig[1,1], yautolimitmargin = (0.1, 0.1), xautolimitmargin = (0.1, 0.1), xlabel = "log(||Fᵁⁱ||₂)", ylabel = "log(||R||₂) ", title = "L-curve analysis")

    lines!(ax1, log.(Fᵁⁱ₂ᵥ), log.(R₂ᵥ))


    #hidexdecorations!(ax1, grid = false)

    #fig[1,2] = Legend(fig, ax1, framevisible = false)
    #fig[1,4] = Legend(fig, ax2, framevisible = false)

    #axislegend(ax1, position = :rc)


    Title = replace(Title, " " => "_")
    Title = replace(Title, "," => "")

    if displayLCurve
        wait(display(fig))
    end
    
    if saveLCurve
        dir_path = "./results/LCurve"
        mkpath(dir_path)

        file_name = GenerateFileName(Title, measurements, dir_path, ".png")

        full_path = abspath(joinpath(dir_path, file_name))

        save(full_path, fig)
    end
end
