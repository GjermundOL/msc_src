using Muscade
using StaticArrays
using LinearAlgebra

function BuildTower(model::Model, nNodes::Integer, tWidth::𝕣, nHeight::𝕣, E::𝕣, Aᶜˢ::𝕣, g::𝕣, density::𝕣)

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
                eᵢ₋₁    = addelement!(model, BarElement, [Vₙ[i-2], nᵢ]; E, Aᶜˢ, g, density)
                eᵢ      = addelement!(model, BarElement, [Vₙ[i-1], nᵢ]; E, Aᶜˢ, g, density)
                
                append!(Vₙ, [nᵢ])
                append!(Vₑ, [eᵢ₋₁, eᵢ])
            
            end
        # If nNodes=3:
        else
            n₃ = addnode!(model, [tWidth/2, nHeight/2])
            e₅ = addelement!(model, BarElement, [n₁, n₃]; E, Aᶜˢ, g, density)
            e₆ = addelement!(model, BarElement, [n₂, n₃]; E, Aᶜˢ, g, density)
            
            append!(Vₙ, [n₃])
            append!(Vₑ, [e₅, e₆])

            println("Tiny tower!")

        end
        return Vₙ, Vₑ
    end

end

@once cost(eleres,X,U,A,t,Sᵐ,eₙ,β) = β/2*(eleres.S - Sᵐ[eₙ])^2

function BuildInverseTower(model::Model, nNodes::Integer, Sᵐ::Vector{𝕣}, Vₑₘ::Vector{Int64}, β::𝕣, tWidth::𝕣, nHeight::𝕣, E::𝕣, Aᶜˢ::𝕣, g::𝕣, density::𝕣)

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
                nᵢ      = addnode!(model, [tWidth * (1-mod(i,2)), nHeight/2 * (i-2-div(i,nNodes))])
                # Adding two new elements per node.
                for j = 2:-1:1

                    eₙ = 2*i-j-3

                    if eₙ in Vₑₘ

                        eₖ = findfirst(x->x==eₙ,Vₑₘ)

                        eⱼ =    addelement!(model, ElementCost, [Vₙ[i-j], nᵢ]; req=@request(S), costargs=(Sᵐ = Sᵐ, eₙ = eₖ, β = β), cost=cost, 
                                ElementType=BarElement, elementkwargs=(;E, Aᶜˢ, g, density))

                    else
                        eⱼ =    addelement!(model, BarElement, [Vₙ[i-j], nᵢ]; E, Aᶜˢ, g, density)

                    end
                    append!(Vₑ, [eⱼ])
                end
                
                append!(Vₙ, [nᵢ])

                uᵢˣ = addelement!(model, SingleUdof, [nᵢ]; Xfield=:tx1, Ufield=:utx1, cost=(u,t)->1/2*u^2)
                uᵢʸ  = addelement!(model, SingleUdof, [nᵢ]; Xfield=:tx2, Ufield=:utx2, cost=(u,t)->1/2*u^2)
                append!(Vᵤ, [uᵢˣ, uᵢʸ])

            end
        # If nNodes=3:
        else
            n₃ = addnode!(model, [tWidth/2, nHeight/2])
            e₅ = addelement!(model, BarElement, [n₁, n₃]; E, Aᶜˢ, g, density)
            e₆ = addelement!(model, BarElement, [n₂, n₃]; E, Aᶜˢ, g, density)
            
            append!(Vₙ, [n₃])
            append!(Vₑ, [e₅, e₆])

            println("Tiny tower!")

            Vᵤ = nothing

        end
        return Vₙ, Vₑ, Vᵤ
    end

end
