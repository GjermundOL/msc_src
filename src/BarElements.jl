using Muscade
using StaticArrays
using LinearAlgebra
using GLMakie


const 𝕣 = Float64


struct BarElement <:AbstractElement
    L:: 𝕣   # Length
    κ:: 𝕣   # Axial stiffness
    Fᵂ:: 𝕣  # Weight
    Vₚ :: Vector{𝕣} # Vector from n₁ to n₂ 
    coords :: Vector{Vector{𝕣}}
end


function BarElement(nod::Vector{Node}; E::𝕣, Aᶜˢ::𝕣, g::𝕣, density::𝕣)
    coords = coord(nod)
    Vₚ = coords[2]-coords[1]
    L = sqrt(LinearAlgebra.dot(Vₚ, Vₚ))
    κ = E*Aᶜˢ
    Fᵂ = g*density*Aᶜˢ*L
    return BarElement(L, κ, Fᵂ, Vₚ, coords)
end



Muscade.doflist(::Type{<:BarElement})=(inod=(1,1,2,2),class=ntuple(i->:X,4), field=(:tx1,:tx2,:tx1,:tx2))

@espy function Muscade.residual(o::BarElement, X,U,A,t,SP,dbg)

    X₀  = ∂0(X)

    coord₁ = o.coords[1] + [X₀[1], X₀[2]]  # Coordinates of nᵢ 
    coord₂ = o.coords[2] + [X₀[3], X₀[4]]  # Coordinates of nⱼ 

    Vₚᵗ = coord₂ - coord₁   # Vector from nᵢ to nⱼ 
    Lᵗ = norm(Vₚᵗ)    # Length of element
    ΔL = Lᵗ - o.L      # Difference in length compared to original length
    ☼S = ΔL/o.L        # Length change ratio
    ☼Fₐ = o.κ * S   # Axial forces
    uₚᵗ = Vₚᵗ / Lᵗ          # Unit vector parallel to Vₚᵗ

    Fᵥ = Fₐ * uₚᵗ   # Force vector acting on node₂. Force vector acting on node₁ is -Fᵥ.

    ☼F = SVector(-Fᵥ[1], o.Fᵂ/2 - Fᵥ[2], Fᵥ[1], o.Fᵂ/2 + Fᵥ[2])

    return F, noFB
end

function Muscade.draw(::Type{<:BarElement}, axe,o, Λ,X,U,A, t,SP,dbg;kwargs...)

    X₀ = ∂0(X) # Matrix, X₀[idof, iel]
    
    xs = []
    ys = []

    for j = 1:length(X₀[1,:])
        
        Δx₁ = X₀[1, j]
        Δy₁ = X₀[2, j]
        Δx₂ = X₀[3, j]
        Δy₂ = X₀[4, j]

        Δn₁ = [Δx₁, Δy₁]
        Δn₂ = [Δx₂, Δy₂]

        n₁, n₂ = o[j].coords[1] + Δn₁, o[j].coords[2] + Δn₂
        
        append!(xs, [n₁[1], n₂[1]])
        append!(ys, [n₁[2], n₂[2]])
        if j != length(X₀[1,:])
            append!(xs, [NaN])
            append!(ys, [NaN])
        end
        
    end
    
    lines!(axe, xs, ys ;kwargs...)
end

Muscade.draw(::Type{<:AbstractElement}, axe,o, Λ,X,U,A, t,SP,dbg;kwargs...) = nothing