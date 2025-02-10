using Muscade
using StaticArrays
using LinearAlgebra
using MasterTask
using GLMakie

const 𝕣 = Float64

function DrawTower(state, Title, folder_name, folder_path, ϕ; displayTower = false, saveTower = false, externalForces = nothing, externalElements = nothing, ex_scale = nothing)
    nNodes = length(state.model.nod)
    if nNodes > 50
        yautolimit = 0.05
    else
        yautolimit = 0.1
    end

    inch = 96
    pt = 4/3
    cm = inch / 2.54

    x = 𝕣[]
    y = 𝕣[]
    u = 𝕣[]
    v = 𝕣[]
    x_adjust_right = 2
    x_adjust_left = 0
    y_adjust_top = nNodes
    y_adjust_bottom = -1
    if  !isnothing(externalForces)
        
        for nᵢ = 1:div(length(externalElements),2)

            eID₁ = externalElements[2*nᵢ-1]
            element₁ = state.model.ele[eID₁]
            eID₂ = externalElements[2*nᵢ]
            element₂ = state.model.ele[eID₂]
            
            nID = element₁.nodID[1]
            nod = state.model.nod[nID]
            
            nᶜᴼᴼʳᵈˢ₀ = coord([nod])[1]

            ΔCˣ = getdof(state;field=:tx1,nodID=[nID])
            ΔCʸ = getdof(state;field=:tx2,nodID=[nID])
            
            nᶜᴼᴼʳᵈˢ₁ = nᶜᴼᴼʳᵈˢ₀ + [ΔCˣ[1], ΔCʸ[1]]

            Fᴱˣ = externalForces[2*nᵢ-1]
            Fᴱʸ = externalForces[2*nᵢ]

            Fᴱ = [Fᴱˣ, Fᴱʸ]./ex_scale

            append!(x, nᶜᴼᴼʳᵈˢ₁[1])
            append!(y, nᶜᴼᴼʳᵈˢ₁[2])
            append!(u, Fᴱ[1])
            append!(v, Fᴱ[2])

        end
        x_adjust_right = maximum([maximum(x+u), maximum(x)])
        x_adjust_left = minimum([minimum(x+u), minimum(x)])
        y_adjust_top = maximum([maximum(y+v), nNodes])
        y_adjust_bottom = minimum([minimum(y+v), -1])
    else

        nods = state.model.nod
        for nᵢ in nods

            nID = nᵢ.ID
            
            nᶜᴼᴼʳᵈˢ₀ = coord([nᵢ])[1]

            ΔCˣ = getdof(state;field=:tx1,nodID=[nID])
            ΔCʸ = getdof(state;field=:tx2,nodID=[nID])
            
            nᶜᴼᴼʳᵈˢ₁ = nᶜᴼᴼʳᵈˢ₀ + [ΔCˣ[1], ΔCʸ[1]]
            
            append!(x, nᶜᴼᴼʳᵈˢ₁[1])
            append!(y, nᶜᴼᴼʳᵈˢ₁[2])
        end
        x_adjust_right = maximum(x)
        x_adjust_left = minimum(x)
        y_adjust_top = maximum([maximum(y), nNodes])
        y_adjust_bottom = minimum([minimum(y), -1])

    end

    if x_adjust_right > 150 || x_adjust_left < -150 || y_adjust_top > 200 || y_adjust_bottom < -50
        return
    end

    GLMakie.activate!(title=Title)
    fig = Figure(size = (20*2/nNodes*cm,20cm), fontsize = 12pt)
    ax = Axis(fig[1, 1], yticks = 0:round(Int, nNodes/25)*5:nNodes, xticks = round(Int, x_adjust_left):2:round(Int, x_adjust_right), limits = (x_adjust_left-0.5, x_adjust_right+0.5, y_adjust_bottom, y_adjust_top), xlabel = "meter [m]", ylabel = "meter [m]")

    draw(ax,state)

    arrows!(x, y, u, v)
    
    colsize!(fig.layout, 1, Aspect(1, (1+x_adjust_right-x_adjust_left)/(y_adjust_top-y_adjust_bottom)))
    resize_to_layout!(fig)

    Title = replace(Title, " " => "_")
    Title = replace(Title, "," => "")

    if displayTower
        wait(display(fig))
    end

    if saveTower
        
        dir_path = abspath(joinpath(folder_path, "towers"))
        mkpath(dir_path)
        file_name = GenerateFileName("$(Title)__phi_$(round(ϕ, sigdigits=4))__$(folder_name)", dir_path, ".png")

        full_path = abspath(joinpath(dir_path, file_name))

        save(full_path, fig, px_per_unit = 300/inch)
    end

end

function DrawSingleErrors(Title, measurements, folder_name, folder_path, ϕ, ρ, Nʳʰᴼ, σₗ, σᵤ∞ˢ, σᵤ₂ˢ, ΔS∞, ΔS₂, ΔFᵁ∞ˢ, ΔFᵁ₂ˢ; displayError = false, saveError = false)

    GLMakie.activate!(title=Title)
    fig = Figure()

    ax1 = Axis(fig[1,1], yautolimitmargin = (0.1, 0.1), xautolimitmargin = (0.1, 0.1))
    ax2 = Axis(fig[1,2], yautolimitmargin = (0.1, 0.1), xautolimitmargin = (0.1, 0.1), yaxisposition = :right)

    lines!(ax1, 0:1, [σₗ, σₗ], label = "σₗ")
    lines!(ax1, 0:1, [ΔS∞, ΔS∞], label = "ΔS∞")
    lines!(ax1, 0:1, [ΔS₂, ΔS₂], label = "ΔS₂")

    lines!(ax2, 0:1, [σᵤ∞ˢ, σᵤ∞ˢ], label = "σᵤ∞ˢ")
    lines!(ax2, 0:1, [σᵤ₂ˢ, σᵤ₂ˢ], label = "σᵤ₂ˢ")
    lines!(ax2, 0:1, [ΔFᵁ∞ˢ, ΔFᵁ∞ˢ], label = "ΔFᵁ∞ˢ")
    lines!(ax2, 0:1, [ΔFᵁ₂ˢ, ΔFᵁ₂ˢ], label = "ΔFᵁ₂ˢ")

    hidexdecorations!(ax1, grid = false)
    hidexdecorations!(ax2, grid = false)

    axislegend(ax1, position = :rc)
    axislegend(ax2, position = :rc)

    if displayError
        wait(display(fig))
    end
    
    if saveError

        dir_path = abspath(joinpath(folder_path, "errors"))
        mkpath(dir_path)
        file_name = GenerateFileName("error__phi_$(ϕ)", dir_path, ".png")

        full_path = abspath(joinpath(dir_path, file_name))

        save(full_path, fig)
    end

end

function DrawErrors(Title, measurements, folder_name, folder_path, ϕᵥ, indᶠᵉ₋₀, indᴿ₋₀, QOⁱⁿᵈᵉˣ, logΔSᵐ₂ₛ, logΔSᵐ⁻¹₂ₛ, logΔFᴱ₂ₛ; displayError = false, saveError = false)

    GLMakie.activate!(title=Title)
    fig = Figure()

    ax1 = Axis(fig[1:2,1], yautolimitmargin = (0.1, 0.1), xautolimitmargin = (0.1, 0.1), xlabel = "log(α/α₀)", ylabel = "log||ΔS||", title = "ΔS")
    ax2 = Axis(fig[1:2,2], yautolimitmargin = (0.1, 0.1), xautolimitmargin = (0.1, 0.1), xlabel = "log(α/α₀)", ylabel = "log||ΔFᴱ||", title = "ΔFᴱ", yaxisposition = :right)

    lines!(ax1, ϕᵥ, logΔSᵐ₂ₛ, label = "log||ΔSᴹ||")
    lines!(ax1, ϕᵥ, logΔSᵐ⁻¹₂ₛ, label = "log||ΔSᵁ||", color = :deeppink4)

    if !isnan(indᴿ₋₀)
        scatter!(ax1, ϕᵥ[indᴿ₋₀], logΔSᵐ₂ₛ[indᴿ₋₀], label = "||r|| < ηˢ", markersize = (5, 20), color = :green)
        scatter!(ax1, ϕᵥ[indᴿ₋₀], logΔSᵐ⁻¹₂ₛ[indᴿ₋₀], markersize = (5, 20), color = :green)
    end
    if !isnan(indᶠᵉ₋₀)
        scatter!(ax1, ϕᵥ[indᶠᵉ₋₀], logΔSᵐ₂ₛ[indᶠᵉ₋₀], label = "||Fᴱ|| < ηᶠ", markersize = (20,5), color = :red)
        scatter!(ax1, ϕᵥ[indᶠᵉ₋₀], logΔSᵐ⁻¹₂ₛ[indᶠᵉ₋₀], markersize = (20,5), color = :red)
    end

    scatter!(ax1, ϕᵥ[QOⁱⁿᵈᵉˣ], logΔSᵐ₂ₛ[QOⁱⁿᵈᵉˣ], label = "Fᴱₒₚₜ", color = :mediumpurple2)
    scatter!(ax1, ϕᵥ[QOⁱⁿᵈᵉˣ], logΔSᵐ⁻¹₂ₛ[QOⁱⁿᵈᵉˣ], color = :mediumpurple2)


    lines!(ax2, ϕᵥ, logΔFᴱ₂ₛ, label = "log||ΔFᴱ||")
    if !isnan(indᴿ₋₀)
        scatter!(ax2, ϕᵥ[indᴿ₋₀], logΔFᴱ₂ₛ[indᴿ₋₀], label = "||r|| < ηˢ", markersize = (5, 20), color = :green)
    end
    if !isnan(indᶠᵉ₋₀)
        scatter!(ax2, ϕᵥ[indᶠᵉ₋₀], logΔFᴱ₂ₛ[indᶠᵉ₋₀], label = "||Fᴱ|| < ηᶠ", markersize = (20,5), color = :red)
    end
    scatter!(ax2, ϕᵥ[QOⁱⁿᵈᵉˣ], logΔFᴱ₂ₛ[QOⁱⁿᵈᵉˣ], label = "Fᴱₒₚₜ", color = :mediumpurple2)

    fig[1,3] = Legend(fig, ax1, "ΔS")
    fig[2,3] = Legend(fig, ax2, "ΔFᴱ")

    if displayError
        wait(display(fig))
    end
    
    if saveError

        file_name = "errors_$(folder_name).png"

        full_path = abspath(joinpath(folder_path, file_name))
        
        save(full_path, fig)
    end

end

function DrawDiscrepancy(Title, measurements, folder_name, folder_path, ρ, Nʳʰᴼ, ϕᵥ, R₂ᵥ, Fᵁⁱ₂ᵥ, η, indᶠᵉ₋₀, indᴿ₋₀, QOⁱⁿᵈᵉˣ; displayDiscrepancy = false, saveDiscrepancy = false)

    GLMakie.activate!(title=Title)
    fig = Figure()

    ax1 = Axis(fig[1:2,1], yautolimitmargin = (0.1, 0.1), xautolimitmargin = (0.1, 0.1), xlabel = "log(α/α₀)", ylabel = "log||r||", yticklabelcolor = :blue)
    ax2 = Axis(fig[1:2,1], yautolimitmargin = (0.1, 0.1), xautolimitmargin = (0.1, 0.1), ylabel = "log||Fᴱ||", yticklabelcolor = :red, yaxisposition = :right)
    
    lines!(ax1, ϕᵥ, R₂ᵥ, label = "log||r||", color = :blue)
    lines!(ax2, ϕᵥ, Fᵁⁱ₂ᵥ, label = "log||Fᴱ||", color = :red)
    lines!(ax1, ϕᵥ, [log10.(η) for ϕ in ϕᵥ], label = "log(ηˢ)")


    if !isnan(indᴿ₋₀)
        scatter!(ax1, ϕᵥ[indᴿ₋₀], R₂ᵥ[indᴿ₋₀], label = "||r|| < ηˢ", color = :green)
    end
    if !isnan(indᶠᵉ₋₀)        
        scatter!(ax2, ϕᵥ[indᶠᵉ₋₀], Fᵁⁱ₂ᵥ[indᶠᵉ₋₀], label = "||Fᴱ|| < ηᶠ", markersize = (5, 20), color = :blue)
    end
    scatter!(ax2, ϕᵥ[QOⁱⁿᵈᵉˣ], Fᵁⁱ₂ᵥ[QOⁱⁿᵈᵉˣ], label = "Fᴱₒₚₜ", markersize = (20, 5), color = :mediumpurple2)

    fig[1,2] = Legend(fig, ax1, "r")
    fig[2,2] = Legend(fig, ax2, "Fᴱ")


    if displayDiscrepancy
        wait(display(fig))
    end
    
    if saveDiscrepancy

        file_name = "discrepancy_$(folder_name).png"

        full_path = abspath(joinpath(folder_path, file_name))
        
        save(full_path, fig)
    end
end


function DrawLCurve(Title, measurements, folder_name, folder_path, ρ, Nʳʰᴼ, ϕᵥ, Fᵁⁱ₂ᵥ, R₂ᵥ, indᶠᵉ₋₀, indᴿ₋₀, QOⁱⁿᵈᵉˣ; displayLCurve = false, saveLCurve = false)

    GLMakie.activate!(title=Title)
    fig = Figure()

    ax1 = Axis(fig[1,1], yautolimitmargin = (0.1, 0.1), xautolimitmargin = (0.1, 0.1), xlabel = "log||Fᴱ||", ylabel = "log||r||")

    lines!(ax1, Fᵁⁱ₂ᵥ, R₂ᵥ)
    
    if !isnan(indᴿ₋₀)
        scatter!(ax1, Fᵁⁱ₂ᵥ[indᴿ₋₀], R₂ᵥ[indᴿ₋₀], label = "||r|| < ηˢ", markersize = (5, 20), color = :green)
    end
    if !isnan(indᶠᵉ₋₀)
        scatter!(ax1, Fᵁⁱ₂ᵥ[indᶠᵉ₋₀], R₂ᵥ[indᶠᵉ₋₀], label = "||Fᴱ|| < ηᶠ", markersize = (20, 5), color = :red)
    end
    scatter!(ax1, Fᵁⁱ₂ᵥ[QOⁱⁿᵈᵉˣ], R₂ᵥ[QOⁱⁿᵈᵉˣ], label = "Fᴱₒₚₜ", color = :mediumpurple2)

    axislegend(ax1, position = :lb)

    if displayLCurve
        wait(display(fig))
    end
    
    if saveLCurve

        file_name = "LCurve_$(folder_name).png"

        full_path = abspath(joinpath(folder_path, file_name))


        save(full_path, fig)
    end
end

function DrawSingleBar(folder_name, folder_path;displayBar = true, saveBar = true)
    inch = 96
    pt = 4/3
    cm = inch / 2.54
    GLMakie.activate!(title="Forces acting on single bar")
    fig = Figure(size = (20cm,15cm), fontsize = 12pt)
    ax1 = Axis(fig[1,1], yautolimitmargin = (0.1, 0.1), xautolimitmargin = (0.1, 0.1), xticksvisible = false, yticksvisible = false, xlabel = "x", ylabel = "y")
    
    x = [0., 2.]
    y = [1., 0.]
    u = [2., -2.]./4
    v = [-1., 1.]./4
    u₁ = [1., 1.]./4
    v₁ = [1., 1.]./4
    
    lines!(ax1, x, y, label = "bⱼ")
    
    arrows!([x[1]], [y[1]], [u[1]], [v[1]], label = "Fˢ(cᵢ,cₗ)", color = :magenta)
    arrows!([x[2]], [y[2]], [u[2]], [v[2]], label = "Fˢ(cₗ,cᵢ)", color = :red)
    arrows!(x, y, [0.,0.], [-0.5, -0.5], label = "Fᵂ(cᵢ,cₗ)", color = :green)

    arrows!([x[1]], [y[1]], [u₁[1]], [v₁[1]], label = "Fᴱᵢ", color = :deeppink4)
    arrows!([x[2]], [y[2]], [u₁[2]], [v₁[2]], label = "Fᴱₗ", color = :grey58)

    scatter!(ax1, x[1], y[1], label = "cᵢ", color = :gold4)
    scatter!(ax1, x[2], y[2], label = "cₗ", color = :darkorchid)
    
    hidedecorations!(ax1, label = false)
    axislegend(ax1, position = :lb)
    
    if displayBar
        wait(display(fig))
    end
    
    if saveBar

        file_name = "Singlebar_$(folder_name).png"
        folder_path = joinpath(folder_path ,"single_bar")
        mkpath(folder_path)
        full_path = abspath(joinpath(folder_path ,file_name))
        save(full_path, fig)
    end
end

function DrawRegStratParameter(folder_name, folder_path, logδˢᵥ, logΔFᴱ₂ᵥₛ; displayRegStrat = false, saveRegStrat = false)
    
    inch = 96
    pt = 4/3
    cm = inch / 2.54
    GLMakie.activate!(title="Regularization strategy parameter analysis")
    fig = Figure(fontsize = 12pt)
    ax1 = Axis(fig[1,1], yautolimitmargin = (0.1, 0.1), xautolimitmargin = (0.1, 0.1), xlabel = "log(δ)", ylabel = "log||ΔFᴱ||")
    
    lines!(ax1, logδˢᵥ, logΔFᴱ₂ᵥₛ, label = "log||ΔFᴱ||")
        
    if displayRegStrat
        wait(display(fig))
    end
    
    if saveRegStrat

        file_name = "RegStratParameter_$(folder_name).png"
        full_path = abspath(joinpath(folder_path ,file_name))
        save(full_path, fig)
    end

end

function DrawRegStrat(folder_name, folder_path, logαᵥ, logΔFᴱ₂ᵥₛ; displayRegStrat = false, saveRegStrat = false)
    
    inch = 96
    pt = 4/3
    cm = inch / 2.54
    GLMakie.activate!(title="Regularization strategy analysis")
    fig = Figure(fontsize = 12pt)
    ax1 = Axis(fig[1,1], yautolimitmargin = (0.1, 0.1), xautolimitmargin = (0.1, 0.1), xlabel = "log(α)", ylabel = "log||ΔFᴱ||")
    
    lines!(ax1, logαᵥ, logΔFᴱ₂ᵥₛ, label = "log||ΔFᴱ||")
        
    if displayRegStrat
        wait(display(fig))
    end
    
    if saveRegStrat

        file_name = "RegStrat_$(folder_name).png"
        full_path = abspath(joinpath(folder_path ,file_name))
        save(full_path, fig)
    end

end