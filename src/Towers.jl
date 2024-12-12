using Muscade
using StaticArrays
using LinearAlgebra

function BuildTower(model::Model, nNodes::Integer, tWidth::𝕣, nHeight::𝕣, y_mod::𝕣, cs_area::𝕣, g::𝕣, mass::𝕣)

    if nNodes <= 2
        throw(ArgumentError("Tower must have at least two nodes."))

    else
        n₁ = addnode!(model, [0., 0.])
        n₂ = addnode!(model, [tWidth, 0])
        e₁ = addelement!(model, Hold, [n₁]; field=:tx1)
        e₂ = addelement!(model, Hold, [n₁]; field=:tx2)
        e₃ = addelement!(model, Hold, [n₂]; field=:tx1)
        e₄ = addelement!(model, Hold, [n₂]; field=:tx2)

        Vₙ = [n₁, n₂]
        Vₑ = [e₁, e₂, e₃, e₄]

        if nNodes != 3
            
            for i = 3:nNodes
                
                # Odd-indexed nodes are initialized at x=0. Even-indexed nodes are initialized at x=tWidth.
                # The statement "-div(i,n)" ensures that the final node is placed on the same height as the penultimate node.
                nᵢ      = addnode!(model, [tWidth * (1-mod(i,2)), nHeight/2 * (i-2-div(i,nNodes))])
                eᵢ₋₁    = addelement!(model, BarElement, [Vₙ[i-2], nᵢ]; y_mod, cs_area, g, mass)
                eᵢ      = addelement!(model, BarElement, [Vₙ[i-1], nᵢ]; y_mod, cs_area, g, mass)
                
                append!(Vₙ, [nᵢ])
                append!(Vₑ, [eᵢ₋₁, eᵢ])
            
            end
        # If nNodes=3:
        else
            n₃ = addnode!(model, [tWidth/2, nHeight/2])
            e₅ = addelement!(model, BarElement, [n₁, n₃]; y_mod, cs_area, g, mass)
            e₆ = addelement!(model, BarElement, [n₂, n₃]; y_mod, cs_area, g, mass)
            
            append!(Vₙ, [n₃])
            append!(Vₑ, [e₅, e₆])

            println("Tiny tower!")

        end
        return Vₙ, Vₑ
    end

end

@once elcost(eleres,X,U,A,t;eₙ,ϵₘ) = 1/2*(eleres.ϵ - ϵₘ[eₙ])^2

function BuildInverseTower(model::Model, nNodes::Integer, ϵₘ::Vector{𝕣}, Vₑₘ::Vector{Int64}, tWidth::𝕣, nHeight::𝕣, y_mod::𝕣, cs_area::𝕣, g::𝕣, mass::𝕣)

    if nNodes <= 2
        throw(ArgumentError("Tower must have at least two nodes."))

    else
        n₁ = addnode!(model, [0., 0.])
        n₂ = addnode!(model, [tWidth, 0])
        e₁ = addelement!(model, Hold, [n₁]; field=:tx1)
        e₂ = addelement!(model, Hold, [n₁]; field=:tx2)
        e₃ = addelement!(model, Hold, [n₂]; field=:tx1)
        e₄ = addelement!(model, Hold, [n₂]; field=:tx2)

        Vₙ = [n₁, n₂]
        Vₑ = [e₁, e₂, e₃, e₄]
        Vᵤ = []

        
        if nNodes != 3
            
            for i = 3:nNodes
                
                # Odd-indexed nodes are initialized at x=0. Even-indexed nodes are initialized at x=tWidth.
                # The statement "-div(i,n)" ensures that the final node is placed on the same height as the penultimate node.
                
                
                # Adding anpther node
                nᵢ      = addnode!(model, [tWidth * (1-mod(i,2)), nHeight/2 * (i-2-div(i,nNodes))])
                
                # Adding two new elements per node.
                for j = 2:-1:1

                    eₙ = 2*i-j-3

                    if eₙ in Vₑₘ

                        eⱼ =    addelement!(model, ElementCost, [Vₙ[i-j], nᵢ]; req=@request(ϵ), costargs=(ϵₘ = ϵₘ, eₙ = eₙ), cost=elcost, 
                                ElementType=BarElement, elementkwargs=(y_mod, cs_area, g, mass))

                    else
                        eⱼ =    addelement!(model, BarElement, [Vₙ[i-j], nᵢ]; y_mod, cs_area, g, mass)
                

                    end
                    append!(Vₑ, [eⱼ])
                end
                
                append!(Vₙ, [nᵢ])

                # Add U-dof to model
                # costargs?
                # req?
                uᵢₓ = addelement!(model, SingleUdof, [nᵢ]; Xfield=:tx1, Ufield=:utx1, cost=(u,t)->1/2*u^2)
                uᵢy  = addelement!(model, SingleUdof, [nᵢ]; Xfield=:tx2, Ufield=:utx2, cost=(u,t)->1/2*u^2)
                append!(Vᵤ, [uᵢ, uᵢy])

            end
        # If nNodes=3:
        else
            n₃ = addnode!(model, [tWidth/2, nHeight/2])
            e₅ = addelement!(model, BarElement, [n₁, n₃]; y_mod, cs_area, g, mass)
            e₆ = addelement!(model, BarElement, [n₂, n₃]; y_mod, cs_area, g, mass)
            
            append!(Vₙ, [n₃])
            append!(Vₑ, [e₅, e₆])

            println("Tiny tower!")

        end
        return Vₙ, Vₑ, Vᵤ
    end

end
