using Muscade
using StaticArrays
using LinearAlgebra
using MasterTask
using GLMakie

const 𝕣 = Float64


function DrawTower(state, Title; displayTower = false, saveTower = false)
    GLMakie.activate!(title=Title)
    fig = Figure()
    ax = Axis(fig[1, 1], yautolimitmargin = (0.1, 0.1), xautolimitmargin = (0.1, 0.1))
    draw(ax,state)

    Title = replace(Title, " " => "_")
    Title = replace(Title, "," => "")

    if displayTower
        wait(display(fig))
    end

    if saveTower
        mkpath("./results/towers")
        save("./results/towers/$(Title)_$(length(state.model.nod))_nodes.png", fig)
    end

end

function DrawErrors(Title, measurements, σₗ, σᵤ, ΔδL∞, ΔδL₂, ΔFᵁ∞, ΔFᵁ₂; displayError = false, saveError = false)

    GLMakie.activate!(title=Title)
    fig = Figure()

    ax1 = Axis(fig[1,1], yautolimitmargin = (0.1, 0.1), xautolimitmargin = (0.1, 0.1), title = "ΔδL")
    ax2 = Axis(fig[1,2], yautolimitmargin = (0.1, 0.1), xautolimitmargin = (0.1, 0.1), title = "ΔFᵁ")



    lines!(ax1, 0:1, [σₗ, σₗ], label = "σₗ")
    lines!(ax1, 0:1, [ΔδL∞, ΔδL∞], label = "ΔδL∞")
    lines!(ax1, 0:1, [ΔδL₂, ΔδL₂], label = "ΔδL₂")


    lines!(ax2, 0:1, [σᵤ, σᵤ], label = "σᵤ")
    lines!(ax2, 0:1, [ΔFᵁ∞, ΔFᵁ∞], label = "ΔFᵁ∞")
    lines!(ax2, 0:1, [ΔFᵁ₂, ΔFᵁ₂], label = "ΔFᵁ₂")

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