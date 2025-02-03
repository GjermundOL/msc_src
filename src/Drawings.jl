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

    x = Float64[]
    y = Float64[]
    u = Float64[]
    v = Float64[]
    x_adjust_right = 2
    x_adjust_left = 0
    y_adjust_top = nNodes
    y_adjust_bottom = -1

    if externalForces != nothing
        
        for nᵢ = 1:div(length(externalElements),2)
            #println("nᵢ: ", nᵢ)
            #println(externalElements[1])

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

            #println("Coords: ", nᶜᴼᴼʳᵈˢ₀)
            
            #println("ΔCˣ: ", ΔCˣ)
            #println("ΔCʸ: ", ΔCʸ)
            #println("typeof(ΔCˣ): ", typeof(ΔCˣ))
            #println("new coords: ", nᶜᴼᴼʳᵈˢ₁)

            Fᴱˣ = externalForces[2*nᵢ-1]
            Fᴱʸ = externalForces[2*nᵢ]

            Fᴱ = [Fᴱˣ, Fᴱʸ]./ex_scale

            #println("Fᴱ: ", Fᴱ)
            
            append!(x, nᶜᴼᴼʳᵈˢ₁[1])
            append!(y, nᶜᴼᴼʳᵈˢ₁[2])
            append!(u, Fᴱ[1])
            append!(v, Fᴱ[2])

        end
        #x_adjust_right = maximum([maximum(u[2:2:end]), maximum(u[1:2:end])-2])
        #x_adjust_left = minumum([minumum(u[1:2:end]), minumum(u[2:2:end])+2])
        #y_adjust_top = maximum([maximum(v[2:2:end]), maximum(u[1:2:end])-2])
        #y_adjust_bottom = 0
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

            #println("Coords: ", nᶜᴼᴼʳᵈˢ₀)
            
            #println("ΔCˣ: ", ΔCˣ)
            #println("ΔCʸ: ", ΔCʸ)
            #println("typeof(ΔCˣ): ", typeof(ΔCˣ))
            #println("new coords: ", nᶜᴼᴼʳᵈˢ₁)

            #println("Fᴱ: ", Fᴱ)
            
            append!(x, nᶜᴼᴼʳᵈˢ₁[1])
            append!(y, nᶜᴼᴼʳᵈˢ₁[2])
        end
        x_adjust_right = maximum(x)
        x_adjust_left = minimum(x)
        y_adjust_top = maximum([maximum(y), nNodes])
        y_adjust_bottom = minimum([minimum(y), -1])

    end

    GLMakie.activate!(title=Title)
    fig = Figure(size = (20*2/nNodes*cm,20cm), fontsize = 12pt)
    #ax = Axis(fig[1, 1], yticks = 0:round(Int, nNodes/25)*5:nNodes, xticks = 0:2, aspect = DataAspect(), limits = (nothing, nothing, -yautolimit*nNodes, nNodes), xautolimitmargin = (0.1, 0.1), xlabel = "meter [m]", ylabel = "meter [m]")
    ax = Axis(fig[1, 1], yticks = 0:round(Int, nNodes/25)*5:nNodes, xticks = round(Int, x_adjust_left):2:round(Int, x_adjust_right), limits = (x_adjust_left-0.5, x_adjust_right+0.5, y_adjust_bottom, y_adjust_top), xlabel = "meter [m]", ylabel = "meter [m]")
    #ax = Axis(fig[1, 1], yticks = 0:round(Int, nNodes/25)*5:nNodes, xticks = 0:2, xlabel = "meter [m]", ylabel = "meter [m]")
    #ax = Axis(fig[1, 1], aspect = DataAspect(), xlabel = "meter [m]", ylabel = "meter [m]")
    

    draw(ax,state)

    
    #println("typeof(x): ", typeof(x))
    #println("x: ", x)
    #println("y: ", y)
    #println("u: ", u)
    #println("v: ", v)

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
        file_name = GenerateFileName("$(Title)__phi_$(ϕ)__$(folder_name)", dir_path, ".png")

        full_path = abspath(joinpath(dir_path, file_name))

        save(full_path, fig, px_per_unit = 300/inch)
    end

end

function DrawSingleErrors(Title, measurements, folder_name, folder_path, ϕ, ρ, Nʳʰᴼ, σₗ, σᵤ∞ˢ, σᵤ₂ˢ, ΔδL∞, ΔδL₂, ΔFᵁ∞ˢ, ΔFᵁ₂ˢ; displayError = false, saveError = false)

    GLMakie.activate!(title=Title)
    fig = Figure()

    ax1 = Axis(fig[1,1], yautolimitmargin = (0.1, 0.1), xautolimitmargin = (0.1, 0.1), title = "ΔδL")
    ax2 = Axis(fig[1,2], yautolimitmargin = (0.1, 0.1), xautolimitmargin = (0.1, 0.1), title = "ΔFᵁˢ", yaxisposition = :right)



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

        dir_path = abspath(joinpath(folder_path, "errors"))
        mkpath(dir_path)
        file_name = GenerateFileName("error__phi_$(ϕ)", dir_path, ".png")

        full_path = abspath(joinpath(dir_path, file_name))

        save(full_path, fig)
    end

end

function DrawErrors(Title, measurements, folder_name, folder_path, ϕᵥ, indᶠᵉ₋₀, indᴿ₋₀, QOⁱⁿᵈᵉˣ, ΔδL₂ˢ, ΔFᴱ₂ˢ; displayError = false, saveError = false)

    GLMakie.activate!(title=Title)
    fig = Figure()

    ax1 = Axis(fig[1,1], yautolimitmargin = (0.1, 0.1), xautolimitmargin = (0.1, 0.1), xlabel = "log(ϕ)", ylabel = "log||ΔδL||", title = "ΔδL")
    ax2 = Axis(fig[1,2], yautolimitmargin = (0.1, 0.1), xautolimitmargin = (0.1, 0.1), xlabel = "log(ϕ)", ylabel = "log||ΔFᴱ||", title = "ΔFᴱ", yaxisposition = :right)



    lines!(ax1, ϕᵥ, ΔδL₂ˢ, label = "log||ΔδL||")
    scatter!(ax1, ϕᵥ[indᴿ₋₀], ΔδL₂ˢ[indᴿ₋₀], label = "||R|| < ηᵟᴸ", markersize = (5, 20), color = :green)
    scatter!(ax1, ϕᵥ[indᶠᵉ₋₀], ΔδL₂ˢ[indᶠᵉ₋₀], label = "||Fᴱ|| < ηᶠᵉ", markersize = (20,5), color = :red)
    scatter!(ax1, ϕᵥ[QOⁱⁿᵈᵉˣ], ΔδL₂ˢ[QOⁱⁿᵈᵉˣ], label = "Fᴱₒₚₜ", color = :mediumpurple2)



    lines!(ax2, ϕᵥ, ΔFᴱ₂ˢ, label = "log||ΔFᴱ||")
    scatter!(ax2, ϕᵥ[indᴿ₋₀], ΔFᴱ₂ˢ[indᴿ₋₀], label = "||R|| < ηᵟᴸ", markersize = (5, 20), color = :green)
    scatter!(ax2, ϕᵥ[indᶠᵉ₋₀], ΔFᴱ₂ˢ[indᶠᵉ₋₀], label = "||Fᴱ|| < ηᶠᵉ", markersize = (20,5), color = :red)
    scatter!(ax2, ϕᵥ[QOⁱⁿᵈᵉˣ], ΔFᴱ₂ˢ[QOⁱⁿᵈᵉˣ], label = "Fᴱₒₚₜ", color = :mediumpurple2)


    #hidexdecorations!(ax1, grid = false)
    #hidexdecorations!(ax2, grid = false)

    #fig[1,2] = Legend(fig, ax1, framevisible = false)
    #fig[1,4] = Legend(fig, ax2, framevisible = false)

    axislegend(ax1, position = :rb)
    axislegend(ax2, position = :rb)


    Title = replace(Title, " " => "_")
    Title = replace(Title, "," => "")

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

    #ax1 = Axis(fig[1,1], yautolimitmargin = (0.1, 0.1), xautolimitmargin = (0.1, 0.1), xlabel = "log(ϕ)", ylabel = "||R||₂", xticks = log.(ϕᵥ), title = "Discrepancy analysis")
    #ax1 = Axis(fig[1,1], yautolimitmargin = (0.1, 0.1), xautolimitmargin = (0.1, 0.1), xlabel = "log(ϕ)", ylabel = "||R||₂", title = "Discrepancy analysis", yticklabelcolor = :blue)
    #ax2 = Axis(fig[1,1], yautolimitmargin = (0.1, 0.1), xautolimitmargin = (0.1, 0.1), ylabel = "||Fᴱ||₂", yticklabelcolor = :red, yaxisposition = :right)

    ax1 = Axis(fig[1,1], yautolimitmargin = (0.1, 0.1), xautolimitmargin = (0.1, 0.1), xlabel = "log(ϕ)", ylabel = "log||R||₂", title = "Discrepancy analysis", yticklabelcolor = :blue)
    ax2 = Axis(fig[1,1], yautolimitmargin = (0.1, 0.1), xautolimitmargin = (0.1, 0.1), ylabel = "log||Fᴱ||₂", yticklabelcolor = :red, yaxisposition = :right)

    #lines!(ax1, log10.(ϕᵥ), R₂ᵥ, label = "||R||₂", color = :blue)
    #lines!(ax2, log10.(ϕᵥ), Fᵁⁱ₂ᵥ, label = "||Fᴱ||₂|", color = :red)
    #lines!(ax1, log10.(ϕᵥ), [η for ϕ in ϕᵥ], label = "η")
    
    lines!(ax1, log10.(ϕᵥ), log10.(R₂ᵥ), label = "log||R||₂", color = :blue)
    lines!(ax2, log10.(ϕᵥ), log10.(Fᵁⁱ₂ᵥ), label = "log||Fᴱ||₂|", color = :red)
    lines!(ax1, log10.(ϕᵥ), [log10.(η) for ϕ in ϕᵥ], label = "log(η)")

    #scatter!(ax1, log10.(ϕᵥ[indᴿ₋₀]), R₂ᵥ[indᴿ₋₀], label = "log||R||₂ < 0\nlog||Fᴱⁱ||₂ = $(round(Fᵁⁱ₂ᵥ[indᴿ₋₀] , sigdigits = 3))\nϕ = $(round(ϕᵥ[indᴿ₋₀] , sigdigits = 3))", color = :green)
    #scatter!(ax2, log10.(ϕᵥ[indᶠᵉ₋₀]), Fᵁⁱ₂ᵥ[indᶠᵉ₋₀], label = "log||Fᴱⁱ||₂ < 0\nlog||R||₂ = $(round(R₂ᵥ[indᶠᵉ₋₀] , sigdigits = 3))\nϕ = $(round(ϕᵥ[indᶠᵉ₋₀] , sigdigits = 3))", color = :red)
    #scatter!(ax2, log10.(ϕᵥ[QOⁱⁿᵈᵉˣ]), Fᵁⁱ₂ᵥ[QOⁱⁿᵈᵉˣ], label = "Fᴱˢᵗᵃᵇˡᵉ\nϕ = $(round(ϕᵥ[QOⁱⁿᵈᵉˣ] , sigdigits = 3))", color = :mediumpurple2)

    scatter!(ax1, log10.(ϕᵥ[indᴿ₋₀]), log10.(R₂ᵥ[indᴿ₋₀]), label = "||R|| < ηᵟᴸ", color = :green)
    scatter!(ax2, log10.(ϕᵥ[indᶠᵉ₋₀]), log10.(Fᵁⁱ₂ᵥ[indᶠᵉ₋₀]), label = "||Fᴱ|| < ηᶠᵉ", color = :red)
    scatter!(ax2, log10.(ϕᵥ[QOⁱⁿᵈᵉˣ]), log10.(Fᵁⁱ₂ᵥ[QOⁱⁿᵈᵉˣ]), label = "Fᴱₒₚₜ", color = :mediumpurple2)

    #hidexdecorations!(ax1, grid = false)

    #fig[1,2] = Legend(fig, ax1, framevisible = false)
    #fig[1,4] = Legend(fig, ax2, framevisible = false)

    axislegend(ax1, position = (0.3, 0.05))
    axislegend(ax2, position = (0.7, 0.05))


    Title = replace(Title, " " => "_")
    Title = replace(Title, "," => "")

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

    ax1 = Axis(fig[1,1], yautolimitmargin = (0.1, 0.1), xautolimitmargin = (0.1, 0.1), xlabel = "log||Fᴱⁱ||", ylabel = "log||R||", title = "L-curve analysis")
    #ax1 = Axis(fig[1,1], yautolimitmargin = (0.1, 0.1), xautolimitmargin = (0.1, 0.1), xlabel = "||Fᵁⁱ||₂", ylabel = "||R||₂", title = "L-curve analysis")

    lines!(ax1, Fᵁⁱ₂ᵥ, R₂ᵥ)
    
    #scatter!(ax1, Fᵁⁱ₂ᵥ[indᴿ₋₀], R₂ᵥ[indᴿ₋₀], label = "log||R||₂ < 0\nlog||Fᴱⁱ||₂ = $(round(Fᵁⁱ₂ᵥ[indᴿ₋₀] , sigdigits = 3))\nϕ = $(round(ϕᵥ[indᴿ₋₀] , sigdigits = 3))", color = :green)
    #scatter!(ax1, Fᵁⁱ₂ᵥ[indᶠᵉ₋₀], R₂ᵥ[indᶠᵉ₋₀], label = "log||Fᴱⁱ||₂ < 0\nlog||R||₂ = $(round(R₂ᵥ[indᶠᵉ₋₀] , sigdigits = 3))\nϕ = $(round(ϕᵥ[indᶠᵉ₋₀] , sigdigits = 3))", color = :red)
    #scatter!(ax1, Fᵁⁱ₂ᵥ[QOⁱⁿᵈᵉˣ], R₂ᵥ[QOⁱⁿᵈᵉˣ], label = "Fᴱˢᵗᵃᵇˡᵉ\nϕ = $(round(ϕᵥ[QOⁱⁿᵈᵉˣ] , sigdigits = 3))", color = :mediumpurple2)

    scatter!(ax1, Fᵁⁱ₂ᵥ[indᴿ₋₀], R₂ᵥ[indᴿ₋₀], label = "||R|| < ηᵟᴸ", markersize = (5, 20), color = :green)
    scatter!(ax1, Fᵁⁱ₂ᵥ[indᶠᵉ₋₀], R₂ᵥ[indᶠᵉ₋₀], label = "||Fᴱ|| < ηᶠᵉ", markersize = (20, 5), color = :red)
    scatter!(ax1, Fᵁⁱ₂ᵥ[QOⁱⁿᵈᵉˣ], R₂ᵥ[QOⁱⁿᵈᵉˣ], label = "Fᴱₒₚₜ", color = :mediumpurple2)


    #hidexdecorations!(ax1, grid = false)

    #fig[1,2] = Legend(fig, ax1, framevisible = false)
    #fig[1,4] = Legend(fig, ax2, framevisible = false)

    axislegend(ax1, position = :lb)


    Title = replace(Title, " " => "_")
    Title = replace(Title, "," => "")

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
    ax1 = Axis(fig[1,1], yautolimitmargin = (0.1, 0.1), xautolimitmargin = (0.1, 0.1), xticksvisible = false, yticksvisible = false, xlabel = "x", ylabel = "y", title = "Forces acting on single bar")
    
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

function DrawRegStrat(folder_name, folder_path, ηᵟᴸᵥ, ΔFᴱ₂ᵥ; displayRegStrat = false, saveRegStrat = false)
    
    inch = 96
    pt = 4/3
    cm = inch / 2.54
    GLMakie.activate!(title="Regularization strategy test")
    fig = Figure(size = (20cm,15cm), fontsize = 12pt)
    ax1 = Axis(fig[1,1], yautolimitmargin = (0.1, 0.1), xautolimitmargin = (0.1, 0.1), xlabel = "log(ηᵟᴸ)", ylabel = "log||ΔFᴱ||", title = "Regularization strategy test")
    

    lines!(ax1, log10.(ηᵟᴸᵥ), log10.(ΔFᴱ₂ᵥ), label = "log||ΔFᴱ||")
        
    if displayRegStrat
        wait(display(fig))
    end
    
    if saveRegStrat

        file_name = "RegStrat_$(folder_name).png"
        full_path = abspath(joinpath(folder_path ,file_name))
        save(full_path, fig)
    end

end